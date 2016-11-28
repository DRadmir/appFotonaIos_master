//
//  FIFavoriteViewController.m
//  fotona
//
//  Created by Janos on 07/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIFavoriteViewController.h"
#import "FDB.h"
#import "FItemFavorite.h"
#import "FIGalleryTableViewCell.h"
#import "FIFlowController.h"
#import "FHelperRequest.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FImage.h"
#import "FGoogleAnalytics.h"
#import "FIPDFViewController.h"
#import "FIContentViewController.h"


@interface FIFavoriteViewController ()

{
    NSMutableArray *favorites;
    int updateCounter;
    int success;
    FIPDFViewController *pdfViewController;
    FICaseViewController *caseViewController;
    FIContentViewController *disclaimerView;

    UIViewController *lastOpened;
}

@end


@implementation FIFavoriteViewController

@synthesize favoriteTableView;
@synthesize imgFotona;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    favorites = [FDB getAllFavoritesForUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [favoriteTableView reloadData];
    
    updateCounter = 0;
    success = 0;
    [FGoogleAnalytics writeGAForItem:nil andType:GAFAVORITETABINT];
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    [flow setFavoriteTab:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 182;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return favorites.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FItemFavorite *item = favorites[indexPath.row];
    FIGalleryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FITableGalleryCells" owner:self options:nil] objectAtIndex:0];
    [cell setItem:item];
    [cell setIndex:indexPath];
    [cell setParentIphone:self];
    if ([[item typeID] intValue] == BOOKMARKCASEINT) {
        
        FCase *caseToShow = [FDB getCaseWithID:[item itemID]];
       
        [cell setContentForCase:caseToShow];
    } else {
        if ([[item typeID] intValue] == BOOKMARKVIDEOINT || [[item typeID] intValue] == BOOKMARKPDFINT) {
            [cell setContentForFavorite:item forTableView:tableView onIndex:indexPath];
            
        }
    }
    cell.userInteractionEnabled = cell.enabled;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FItemFavorite *item = favorites[indexPath.row];
    switch ([[item typeID] intValue]) {
        case BOOKMARKCASEINT:
            [self openCaseWithID:[item itemID]];
            break;
        case BOOKMARKVIDEOINT:
        case BOOKMARKPDFINT:
            [self openMedia:[item itemID]  andType:[item typeID]];
            break;
        default:
            break;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(void)deleteRowAtIndex:(NSIndexPath *) index{
    favorites = [FDB getAllFavoritesForUser];
    [favoriteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: index] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Case

-(void)openCaseWithID:(NSString *) caseID{
    FCase *caseToOpen = [FDB getCaseWithID:caseID];
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:caseID andType:BOOKMARKCASE];
    
    if (( [[caseToOpen bookmark] boolValue] && flag)|| [[caseToOpen coverflow] boolValue]){
        [self openCase:caseToOpen];
    } else{
        if([ConnectionHelper connectedToInternet]){
            NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:caseID onView: self.view];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                // I get response as XML here and parse it in a function
                
                FCase *caseObj=[FCase parseCaseFromServer:[operation responseData]];                updateCounter++;
                success++;
                [self removeHud];
                [self openCase:caseObj];
                
                
            }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Cases failed %@",error.localizedDescription);
                                                 updateCounter++;
                                                 
                                                 [self removeHud];
                                                 
                                             }];
            [operation start];
        } else {
            [self.viewDeckController toggleLeftViewAnimated:YES];
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}


-(void) openCase:(FCase *) caseToOpen{
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    if ([flow caseView] != nil) {
        caseViewController = [flow caseView];
    } else {
        if (caseViewController == nil) {
            caseViewController = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil]  instantiateViewControllerWithIdentifier:@"caseView"];
        }
        [flow setCaseView:caseViewController];
    }
    caseViewController.caseToOpen = caseToOpen;
    caseViewController.parent = nil;
    caseViewController.favoriteParent = self;
    caseViewController.canBookmark = true;
    [[self navigationController] pushViewController:caseViewController animated:YES];
    lastOpened = caseViewController;
 
}

-(void)openMedia:(NSString *)mediaID  andType:(NSString *)mediaType{
    FMedia *media = [FDB getMediaWithId:mediaID andType:mediaType];
    if ([[media mediaType] intValue] == [MEDIAVIDEO intValue]) {
        [FCommon playVideo:media onViewController:self isFromCoverflow:NO];
    } else {
        if ([[media mediaType] intValue] == [MEDIAPDF intValue]) {
            [self openPdf:media];
        }
    }
}

#pragma mark - HUD

-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (success<updateCounter) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"ERRORCONTENTFETCH", nil)]  delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av setTag:0];
        [av show];
    }
    updateCounter=0;
    success=0;
}

#pragma mark - Refresh

-(void) refreshCellWithItemID:(NSString *)itemID andItemType:(NSString *) itemType{
    for (int i = 0; i<[favorites count]; i++){
        FItemFavorite *item = favorites[i];
        if ([[item itemID] intValue]== [itemID intValue] && [[item typeID] intValue] == [itemType intValue]  ) {
            NSIndexPath *index = [NSIndexPath  indexPathForItem:i inSection:0];
            [favoriteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}
    
-(void) openPdf:(FMedia *) pdf{
    if (pdfViewController == nil) {
        pdfViewController = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"pdfViewController"];
    }
    pdfViewController.pdfMedia = pdf;
    [[self navigationController] pushViewController:pdfViewController animated:YES];
    lastOpened = pdfViewController;
}

#pragma mark - Rest

-(void)clearViews
{
    if (lastOpened != nil) {
        lastOpened = nil;
        
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)openDisclaimer{
    [[self navigationController] popViewControllerAnimated:YES];
    if (disclaimerView == nil) {
        disclaimerView = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil]  instantiateViewControllerWithIdentifier:@"contentViewController"];
    }
    
    disclaimerView.titleContent = @"Disclaimer";
    disclaimerView.descriptionContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"];
    [[self navigationController] pushViewController:disclaimerView animated:YES];
    lastOpened = disclaimerView;
}


@end

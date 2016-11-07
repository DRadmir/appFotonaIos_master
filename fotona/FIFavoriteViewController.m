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

@interface FIFavoriteViewController ()

{
    NSMutableArray *favorites;
    int updateCounter;
    int success;
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
    
    if ([[item typeID] intValue] == BOOKMARKCASEINT) {
        
        FIGalleryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FITableGalleryCells" owner:self options:nil] objectAtIndex:0];
        FCase *caseToShow = [FDB getCaseWithID:[item itemID]];
        [cell setItem:item];
        [cell setIndex:indexPath];
        [cell setParentIphone:self];
        [cell setContentForCase:caseToShow];
        return cell;
    } else {
        if ([[item typeID] intValue] == BOOKMARKVIDEOINT || [[item typeID] intValue] == BOOKMARKPDFINT) {
            
            FIGalleryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FITableGalleryCells" owner:self options:nil] objectAtIndex:0];
            [cell setContentForFavorite:item forTableView:tableView onIndex:indexPath];
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FItemFavorite *item = favorites[indexPath.row];
    if (((FIGalleryTableViewCell *) [tableView cellForRowAtIndexPath:indexPath]).enabled) {
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
        if([APP_DELEGATE connectedToInternet]){
            NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:caseID onView: self.view];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                // I get response as XML here and parse it in a function
                
                NSError *jsonError;
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                NSString *c = [dic objectForKey:@"d"];
                NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
                FCase *caseObj=[[FCase alloc] initWithDictionaryFromServer:[NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                   error:&jsonError]];
                NSMutableArray *imgs = [[NSMutableArray alloc] init];
                for (NSDictionary *imgLink in [caseObj images]) {
                    FImage * img = [[FImage alloc] initWithDictionaryFromServer:imgLink];
                    
                    [imgs addObject:img];
                }
                [caseObj setImages:imgs];
                NSMutableArray *videos = [[NSMutableArray alloc] init];
                for (NSDictionary *videoLink in [caseObj video]) {
                    FMedia * videoTemp = [[FMedia alloc] initWithDictionary:videoLink];
                    
                    [videos addObject:videoTemp];
                }
                [caseObj setVideo:videos];
                updateCounter++;
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
    flow.caseFlow = caseToOpen;
    if (flow.caseMenu != nil)
    {
        [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    flow.lastIndex = 3;
    [flow.tabControler setSelectedIndex:3];
    
}

-(void)openMedia:(NSString *)mediaID  andType:(NSString *)mediaType{
    FMedia *media = [FDB getMediaWithId:mediaID andType:mediaType];
    [FMedia openMedia:media];
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

@end

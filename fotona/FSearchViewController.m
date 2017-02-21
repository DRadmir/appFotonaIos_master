//
//  FSearchViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 4/16/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FSearchViewController.h"
#import "FNews.h"
#import "FCase.h"
#import "FMDatabase.h"
#import "FFeaturedViewController_iPad.h"
#import "FCasebookViewController.h"
#import "IIViewDeckController.h"
#import "ASDepthModalViewController.h"
#import "FFeaturedViewController_iPad.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FImage.h"
#import "FMedia.h"
#import "FDB.h"
#import "FHelperRequest.h"
#import "FEventViewController.h"

@interface FSearchViewController (){
    NSMutableArray *order;
}

@end

@implementation FSearchViewController
@synthesize searchTxt;
@synthesize tableSearch;
@synthesize newsSearchRes;
@synthesize casesSearchRes;
@synthesize videosSearchRes;
@synthesize pdfsSearchRes;
@synthesize parent;
@synthesize popupView;
@synthesize popupTitle;
@synthesize popupText;
@synthesize characterLimit;
@synthesize eventsSearchRes;

#define newsOrder 1
#define eventsOrder 2
#define videoOrder 3
#define pdfOrder 4
#define caseOrder 5

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    updateCounter=0;
    success=0;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    order = [NSMutableArray new];
    if(searchTxt.length >= 2)
        characterLimit = TRUE;
    else
        characterLimit = FALSE;
    int count = 0;
    if (characterLimit){
        if ([newsSearchRes count]>0)
        {
            count++;
            [order addObject:[NSString stringWithFormat:@"%d", newsOrder]];
        }
        if ([eventsSearchRes count]>0) {
            count++;
             [order addObject:[NSString stringWithFormat:@"%d", eventsOrder]];
        }
        if ([videosSearchRes count]>0)
        {
            count++;
             [order addObject:[NSString stringWithFormat:@"%d", videoOrder]];
        }
        if ([pdfsSearchRes count]>0)
        {
            count++;
             [order addObject:[NSString stringWithFormat:@"%d", pdfOrder]];
        }
        if ([casesSearchRes count]>0)
        {
            count++;
             [order addObject:[NSString stringWithFormat:@"%d", caseOrder]];
        }
        
    }
    return count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    switch ([order[section] intValue]) {
        case newsOrder:
            return newsSearchRes.count;
            break;
        case eventsOrder:
            return eventsSearchRes.count;
            break;
        case videoOrder:
            return videosSearchRes.count;
            break;
        case pdfOrder:
            return pdfsSearchRes.count;
            break;
        case caseOrder:
            return casesSearchRes.count;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ([order[section] intValue]) {
        case newsOrder:
            return @"News";
            break;
        case eventsOrder:
            return @"Events";
            break;
        case videoOrder:
            return @"Videos";
            break;
        case pdfOrder:
            return @"PDFs";
            break;
        case caseOrder:
            return @"Cases";
            break;
        default:
            return @"Something wrong";
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    switch ([order[indexPath.section] intValue]) {
        case newsOrder:
            [cell.textLabel setText:[[newsSearchRes objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[newsSearchRes objectAtIndex:indexPath.row] description]];
            break;
        case eventsOrder:
            [cell.textLabel setText:[[eventsSearchRes objectAtIndex:indexPath.row] title]];
            break;
        case videoOrder:
            [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] description]];
            break;
        case pdfOrder:
            [cell.textLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] description]];
            break;
        case caseOrder:
            [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
            break;
        default:
            [cell.textLabel setText:@"Something wrong"];
            break;
    }

    return cell;

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parent.view endEditing:YES];

    switch ([order[indexPath.section] intValue]) {
        case newsOrder:
            [self openNews:indexPath];
            break;
        case eventsOrder:
            [self openEvents:indexPath];
            break;
        case videoOrder:
            [self openMedia:videosSearchRes[indexPath.row]];
            break;
        case pdfOrder:
             [self openMedia:pdfsSearchRes[indexPath.row]];
            break;
        case caseOrder:
            [self openCase:indexPath];
            break;
        default:
        {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Something wrong" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
            break;
    }

    
}
-(void)search
{
    if(characterLimit){
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        NSString *userP = [FCommon getUserPermissionsForDBWithColumnName:USERPERMISSIONCOLUMNNAME];
        newsSearchRes=[FDB getNewsForSearchFromDB:searchTxt withDatabase:database];
        eventsSearchRes = [FDB getEventsForSearchFromDB:searchTxt withDatabase:database];
        videosSearchRes=[FDB getVideosForSearchFromDB:searchTxt withDatabase:database userPermissions:userP];
        pdfsSearchRes = [FDB getPDFForSearchFromDB:searchTxt withDatabase:database userPermissions:userP];
        casesSearchRes=[FDB getCasesForSearchFromDB:searchTxt withDatabase:database];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
}

-(IBAction)closePopup:(id)sender
{
    [tmpNews removeFromSuperview];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    [[(FCasebookViewController *)parent viewDeckController] setEnabled:YES];
}



-(NSMutableArray *)getNewsFromDB:(FMDatabase *) database
{
    NSMutableArray *news=[[NSMutableArray alloc] init];
    
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=%@ and (title like '%%%@%%'or description like '%%%@%%'or text like '%%%@%%' ) ORDER BY newsID DESC",@"1",searchTxt,searchTxt,searchTxt]];
    while([results next]) {
        FNews *f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        [news addObject:f];
    }
    
    return news;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:3] centerController];
    [MBProgressHUD hideAllHUDsForView: [(FCasebookViewController *)[tempC topViewController] view] animated:YES];
    if (success<updateCounter) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"ERRORCONTENTFETCH", nil)]  delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av setTag:0];
        [av show];
    }
    updateCounter=0;
    success=0;
}

#pragma mark OpenElements
//-(void) openEvent:(NSIndexPath*) index
//{
//    FEvent *tmpN=[eventsSearchRes objectAtIndex:index.row];
//    [popupTitle setText:tmpN.title];
//    NSString *htmlString=tmpN.text;
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    [popupText setText:attrStr.string];
//    [APP_DELEGATE setEventTemp:tmpN];
//    [[(FFeaturedViewController_iPad *)parent popover] dismissPopoverAnimated:YES];
//    if ([[APP_DELEGATE tabBar] selectedIndex]==0) {
//        [(FFeaturedViewController_iPad *)parent  openEvent:tmpN];
//    }
//    else{
//        [[APP_DELEGATE tabBar] setSelectedIndex:0];
//        [(FFeaturedViewController_iPad *)[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:0]  openNews:tmpN];
//
//    }
//}


-(void) openNews:(NSIndexPath*) index
{
    FNews *tmpN=[newsSearchRes objectAtIndex:index.row];
    [popupTitle setText:tmpN.title];
    NSString *htmlString=tmpN.text;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [popupText setText:attrStr.string];
    [APP_DELEGATE setNewsTemp:tmpN];
    [[(FFeaturedViewController_iPad *)parent popover] dismissPopoverAnimated:YES];
    if ([[APP_DELEGATE tabBar] selectedIndex]==0) {
        [(FFeaturedViewController_iPad *)parent  openNews:tmpN];
    }
    else{
        [[APP_DELEGATE tabBar] setSelectedIndex:0];
        [(FFeaturedViewController_iPad *)[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:0]  openNews:tmpN];
        
    }
}


-(void) openCase:(NSIndexPath*) index
{
    if ([[casesSearchRes objectAtIndex:index.row] isKindOfClass:[FCase class]]) {
        [[(FFeaturedViewController_iPad *)parent popover] dismissPopoverAnimated:YES];
        UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:3] centerController];
        
        FCase *item = [casesSearchRes objectAtIndex:index.row];
        if ( [[item bookmark] boolValue]|| [[item coverflow] boolValue]){
            
            
            [(FCasebookViewController *)[tempC topViewController] setCurrentCase:item];
            [(FCasebookViewController *)[tempC topViewController] setFlagCarousel:YES];
            if ([parent isKindOfClass:[FCasebookViewController class]]) {
                [(FCasebookViewController*)parent openCase];
            }else{
                [parent.tabBarController setSelectedIndex:3];
            }
            
        } else{
            if([ConnectionHelper connectedToInternet]){
                
                NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:[item caseID] onView:[(FCasebookViewController *)[tempC topViewController] view]];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    FCase *caseObj=[FCase parseCaseFromServer:[operation responseData]];                    updateCounter++;
                    success++;
                    [self removeHud];
                    
                    [(FCasebookViewController *)[tempC topViewController] setCurrentCase:caseObj];
                    [(FCasebookViewController *)[tempC topViewController] setFlagCarousel:YES];
                    if ([parent isKindOfClass:[FCasebookViewController class]]) {
                        [(FCasebookViewController*)parent openCase];
                    }else{
                        [parent.tabBarController setSelectedIndex:3];
                    }
                }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     NSLog(@"Cases failed %@",error.localizedDescription);
                                                     updateCounter++;
                                                     [self removeHud];
                                                 }];
                [operation start];
            } else {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        }
    }
    
}

-(void) openMedia:(FMedia*) media
{
    [[(FFotonaViewController *)parent popover] dismissPopoverAnimated:YES];
    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:2] centerController];
    [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES forMedia:media];
    if (parent.tabBarController.selectedIndex == 2) {
        [(FFotonaViewController *)[tempC topViewController] openMediaFromSearch:media];
    } else {
        [parent.tabBarController setSelectedIndex:2];
    }
}
-(void) openEvents:(NSIndexPath *) index
{
    [[(FFotonaViewController *)parent popover] dismissPopoverAnimated:YES];
    [APP_DELEGATE setEventTemp:[self.eventsSearchRes objectAtIndex:index.row]];
    [[APP_DELEGATE tabBar] setSelectedIndex:1];
    FEventViewController * tempEventVC = [[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:1];
    [tempEventVC  openPopupOutside];
}


@end

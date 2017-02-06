//
//  FISearchViewViewController.m
//  fotona
//
//  Created by Janos on 31/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FISearchViewController.h"
#import "FDB.h"
#import "MBProgressHUD.h"
#import "FIFlowController.h"
#import "FMDatabase.h"

@interface FISearchViewController (){
    NSMutableArray *orderIPhone;
}

@end

@implementation FISearchViewController

@synthesize searchTxtIPhone;
@synthesize tableSearchIPhone;
@synthesize newsSearchResIPhone;
@synthesize casesSearchResIPhone;
@synthesize videosSearchResIPhone;
@synthesize pdfsSearcResIPhone;
@synthesize parentIPhone;
@synthesize characterLimit;
@synthesize eventsSearcResIPhone;

#define newsOrderIPhone 1
#define eventsOrderIPhone 2
#define videoOrderIPhone 3
#define pdfOrderIPhone 4
#define caseOrderIPhone 5

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor clearColor]];
    [self.searchBarIPhone setBackgroundColor: [UIColor whiteColor]];
    [self.searchBarIPhone setAlpha:1.0];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    orderIPhone = [NSMutableArray new];
    if(searchTxtIPhone.length >= 2)
        characterLimit = TRUE;
    else
        characterLimit = FALSE;
    int count = 0;
    if ([newsSearchResIPhone count]>0)
    {
        [orderIPhone addObject:[NSString stringWithFormat:@"%d", newsOrderIPhone]];
        count++;
    }
    if ([eventsSearcResIPhone count]>0) {
        [orderIPhone addObject:[NSString stringWithFormat:@"%d", eventsOrderIPhone]];
        count++;
    }
    if ([videosSearchResIPhone count]>0)
    {
        [orderIPhone addObject:[NSString stringWithFormat:@"%d", videoOrderIPhone]];
        count++;
    }
    if ([pdfsSearcResIPhone count]>0)
    {
        [orderIPhone addObject:[NSString stringWithFormat:@"%d", pdfOrderIPhone]];
        count++;
    }
    if ([casesSearchResIPhone count]>0) {
        [orderIPhone addObject:[NSString stringWithFormat:@"%d", caseOrderIPhone]];
        count++;
    }
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ([orderIPhone[section] intValue]) {
        case newsOrderIPhone:
            return newsSearchResIPhone.count;
            break;
        case eventsOrderIPhone:
            return eventsSearcResIPhone.count;
            break;
        case videoOrderIPhone:
            return videosSearchResIPhone.count;
            break;
        case pdfOrderIPhone:
            return pdfsSearcResIPhone.count;
            break;
        case caseOrderIPhone:
            return casesSearchResIPhone.count;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ([orderIPhone[section] intValue]) {
        case newsOrderIPhone:
            return @"News";
            break;
        case eventsOrderIPhone:
            return @"Events";
            break;
        case videoOrderIPhone:
            return @"Videos";
            break;
        case pdfOrderIPhone:
            return @"PDFs";
            break;
        case caseOrderIPhone:
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
    switch ([orderIPhone[indexPath.section] intValue]) {
        case newsOrderIPhone:
            [cell.textLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] description]];
            break;
        case eventsOrderIPhone:
            [cell.textLabel setText:[[eventsSearcResIPhone objectAtIndex:indexPath.row] title]];
            break;
        case videoOrderIPhone:
            [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] description]];
            break;
        case pdfOrderIPhone:
            [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
            [cell.detailTextLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] description]];
            break;
        case caseOrderIPhone:
            [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
            break;
        default:
            [cell.textLabel setText:@"Something wrong"];
            break;
    }

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parentIPhone.view endEditing:YES];
    FIFlowController *flow = [FIFlowController sharedInstance];
    [flow.lastOpenedView toggleSearchBar];
    [self.view endEditing:true];
    switch ([orderIPhone[indexPath.section] intValue]) {
        case newsOrderIPhone:
           [self openNews:indexPath];
            break;
        case eventsOrderIPhone:
            [self openEvent:indexPath];
            break;
        case videoOrderIPhone:
            [self openMedia:videosSearchResIPhone[indexPath.row]];
            break;
        case pdfOrderIPhone:
            [self openMedia:pdfsSearcResIPhone[indexPath.row]];
            break;
        case caseOrderIPhone:
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchTxtIPhone = searchText;
    [self searchIPhone];
}

-(void)searchIPhone
{
    //TODO - optimize
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *userP = [FCommon getUserPermissionsForDBWithColumnName:USERPERMISSIONCOLUMNNAME];
    newsSearchResIPhone=[FDB getNewsForSearchFromDB:searchTxtIPhone withDatabase:database];
    eventsSearcResIPhone=[FDB getEventsForSearchFromDB:searchTxtIPhone withDatabase:database];
    videosSearchResIPhone=[FDB getVideosForSearchFromDB:searchTxtIPhone withDatabase:database userPermissions:userP];
    pdfsSearcResIPhone=[FDB getPDFForSearchFromDB:searchTxtIPhone withDatabase:database userPermissions:userP];
    casesSearchResIPhone=[FDB getCasesForSearchFromDB:searchTxtIPhone withDatabase:database userPermissions:userP];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

-(IBAction)closePopup:(id)sender
{
    [tmpNewsIPhone removeFromSuperview];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    [[(FCasebookViewController *)parentIPhone viewDeckController] setEnabled:YES];
}


-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    [MBProgressHUD hideAllHUDsForView:[parentIPhone.viewDeckController.centerController view] animated:YES];
    if (successIPhone<updateCounterIPhone) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Problem with content update!" delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil]
        ;
        [av setTag:0];
        [av show];
    }
    updateCounterIPhone=0;
    successIPhone=0;
}

#pragma mark - Open News

-(void) openNews:(NSIndexPath*) index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    [APP_DELEGATE setNewsTemp:newsSearchResIPhone[index.row]];
    flow.lastIndex = 0;
    [flow.newsTab openNews];
    [flow.tabControler setSelectedIndex:0];
}


#pragma mark - Open Case
-(void) openCase:(NSIndexPath*) index
{
    [FCase openCase:casesSearchResIPhone[index.row]];
}

#pragma mark - Open Video
-(void) openMedia:(FMedia *)media
{
    [FMedia openMedia:media];
}

#pragma mark - Open Event
-(void) openEvent:(NSIndexPath *) index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    
    [APP_DELEGATE setEventTemp:eventsSearcResIPhone[index.row]];
    flow.lastIndex = 1;
    [flow.eventTab openEvent];
    [flow.tabControler setSelectedIndex:1];

}
@end

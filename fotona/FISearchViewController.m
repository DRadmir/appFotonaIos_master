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

@interface FISearchViewController ()

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
    if(searchTxtIPhone.length >= 2)
        characterLimit = TRUE;
    else
        characterLimit = FALSE;
    int count = 0;
    if ([newsSearchResIPhone count]>0)
    {
        count++;
    }
    if ([eventsSearcResIPhone count]>0) {
        count++;
    }
    if ([videosSearchResIPhone count]>0)
    {
        count++;
    }
    if ([pdfsSearcResIPhone count]>0)
    {
        count++;
    }
    if ([casesSearchResIPhone count]>0) {
        count++;
    }
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                return newsSearchResIPhone.count;
            }else
            {
                if (eventsSearcResIPhone.count>0) {
                    return eventsSearcResIPhone.count;
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        return videosSearchResIPhone.count;
                    }else{
                        if (pdfsSearcResIPhone.count>0) {
                            return pdfsSearcResIPhone.count;
                        }
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && eventsSearcResIPhone.count>0) {
                return eventsSearcResIPhone.count;
            }else
            {
                if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)) {
                    return videosSearchResIPhone.count;
                }else{
                    if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0))
                        return pdfsSearcResIPhone.count;
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0)) {
                return videosSearchResIPhone.count;
            }else{
                if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1))
                    return pdfsSearcResIPhone.count;
            }
            break;
        case 3:
            if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1)) {
                return pdfsSearcResIPhone.count;
            }
        default:
            return casesSearchResIPhone.count;
    }
    return casesSearchResIPhone.count;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                return @"News";
            }else
            {
                if (eventsSearcResIPhone.count>0) {
                    return @"Events";
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        return @"Videos";
                    }else{
                        if (pdfsSearcResIPhone.count>0) {
                            return @"PDFs";
                        }
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && eventsSearcResIPhone.count>0) {
                return @"Events";
            }else
            {
                if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 || casesSearchResIPhone.count>0)) {
                    return @"Videos";
                }else{
                    if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0))
                        return @"PDFs";
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0)) {
                return @"Videos";
            }else{
                if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1))
                    return @"PDFs";
            }
            break;
        case 3:
            if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1)) {
                return @"PDFs";
            }
        default:
            return @"Cases";
    }
    return @"Cases";
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    switch (indexPath.section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                [cell.textLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] title]];
                [cell.detailTextLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] description]];
            }else
            {
                if (eventsSearcResIPhone.count>0) {//casesSearchResIPhone
                    [cell.textLabel setText:[[eventsSearcResIPhone objectAtIndex:indexPath.row] title]];
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
                        [cell.detailTextLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] description]];
                    }else{
                        if (pdfsSearcResIPhone.count>0) {
                            [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                            [cell.detailTextLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] description]];
                        }else {
                            [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
                            
                        }
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && eventsSearcResIPhone.count>0) {
                [cell.textLabel setText:[[eventsSearcResIPhone objectAtIndex:indexPath.row] title]];
            }else
            {
                if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)) {
                    [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
                    [cell.detailTextLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] description]];
                }else{
                    if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)){
                        [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                        [cell.detailTextLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] description]];
                    }else {
                        [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
                    }
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 && eventsSearcResIPhone.count>0)) {
                [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
                [cell.detailTextLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] description]];
            }else{
                if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1)){
                    [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                    [cell.detailTextLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] description]];
                }else {
                    [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
                }
            }
            break;
        case 3:
            if (pdfsSearcResIPhone.count>0 && ((videosSearchResIPhone.count+newsSearchResIPhone.count+eventsSearcResIPhone.count)>1)){
                [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                [cell.detailTextLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] description]];
            }else {
                [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
            }
            break;
            
        default:
            [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
    }
    
    return cell;
    //[cell.detailTextLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] description]];
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parentIPhone.view endEditing:YES];
    FIFlowController *flow = [FIFlowController sharedInstance];
    [flow.lastOpenedView toggleSearchBar];
    [self.view endEditing:true];
    switch (indexPath.section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                [self openNews:indexPath];
            }else
            {
                if (eventsSearcResIPhone.count>0) {
                    [self openEvent:indexPath];
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        [self openMedia:videosSearchResIPhone[indexPath.row]];
                    }else{
                        if (pdfsSearcResIPhone.count>0) {
                            [self openMedia:pdfsSearcResIPhone[indexPath.row]];
                        }else {
                            [self openCase:indexPath];
                        }
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                [self openEvent:indexPath];
            }else
            {
                if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)) {
                    [self openMedia:videosSearchResIPhone[indexPath.row]];
                }else{
                    if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)){
                        [self openMedia:pdfsSearcResIPhone[indexPath.row]];
                    }else {
                        [self openCase:indexPath];
                    }
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0 && (newsSearchResIPhone.count>0 && eventsSearcResIPhone.count>0)) {
                [self openMedia:videosSearchResIPhone[indexPath.row]];
            }else{
                if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)){
                    [self openMedia:pdfsSearcResIPhone[indexPath.row]];
                }else {
                    [self openCase:indexPath];
                }
            }
            break;
        case 3:
            if (pdfsSearcResIPhone.count>0 && (videosSearchResIPhone.count>0 || newsSearchResIPhone.count>0 || eventsSearcResIPhone.count>0)){
                [self openMedia:pdfsSearcResIPhone[indexPath.row]];
            }else {
                [self openCase:indexPath];
            }
            break;
            
        default:
            [self openCase:indexPath];
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

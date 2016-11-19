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
    int count = 0;
    if ([newsSearchResIPhone count]>0)
    {
        count++;
    }
    if ([casesSearchResIPhone count]>0) {
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
                if (casesSearchResIPhone.count>0) {
                    return casesSearchResIPhone.count;
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        return videosSearchResIPhone.count;
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                return casesSearchResIPhone.count;
            }else
            {
                if (videosSearchResIPhone.count>0) {
                    return videosSearchResIPhone.count;
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0) {
                return videosSearchResIPhone.count;
            }
            break;
        default:
            return pdfsSearcResIPhone.count;
    }
    return pdfsSearcResIPhone.count;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                return @"News";
            }else
            {
                if (casesSearchResIPhone.count>0) {
                    return @"Cases";
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        return @"Videos";
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                return @"Cases";
            }else
            {
                if (videosSearchResIPhone.count>0) {
                    return @"Videos";
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0) {
                return @"Videos";
            }
            break;
        default:
            return @"PDFs";
    }
    return @"PDFs";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    switch (indexPath.section) {
        case 0:
            if (newsSearchResIPhone.count>0) {
                [cell.textLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] title]];
            }else
            {
                if (casesSearchResIPhone.count>0) {
                    [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
                    }else {
                        [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
            }else
            {
                if (videosSearchResIPhone.count>0) {
                    [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
                }else {
                    [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0) {
                [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
            } else {
                [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
            }
            break;
        case 3:
            [cell.textLabel setText:[[pdfsSearcResIPhone objectAtIndex:indexPath.row] title]];
            break;
        default:
            [cell.textLabel setText:@"TITLE IPAD"];
    }
    
    return cell;

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
                if (casesSearchResIPhone.count>0) {
                    [self openCase:indexPath];
                }else
                {
                    if (videosSearchResIPhone.count>0) {
                        [self openMedia:videosSearchResIPhone[indexPath.row]];
                    }else {
                        [self openMedia:pdfsSearcResIPhone[indexPath.row]];
                    }
                }
            }
            break;
        case 1:
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                [self openCase:indexPath];
            }else
            {
                if (videosSearchResIPhone.count>0) {
                    [self openMedia:videosSearchResIPhone[indexPath.row]];
                }else {
                    [self openMedia:pdfsSearcResIPhone[indexPath.row]];
                }
            }
            break;
        case 2:
            if (videosSearchResIPhone.count>0) {
                [self openMedia:videosSearchResIPhone[indexPath.row]];
            } else {
                [self openMedia:pdfsSearcResIPhone[indexPath.row]];
            }
            break;
        case 3:
            [self openMedia:pdfsSearcResIPhone[indexPath.row]];
            break;
        default:
            break;
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchTxtIPhone = searchText;
    [self searchIPhone];
}

-(void)searchIPhone
{
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    newsSearchResIPhone=[FDB getNewsForSearchFromDB:searchTxtIPhone withDatabase:database];
    casesSearchResIPhone=[FDB getCasesForSearchFromDB:searchTxtIPhone withDatabase:database];
    videosSearchResIPhone=[FDB getVideosForSearchFromDB:searchTxtIPhone withDatabase:database];
    pdfsSearcResIPhone=[FDB getPDFForSearchFromDB:searchTxtIPhone withDatabase:database];
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

@end

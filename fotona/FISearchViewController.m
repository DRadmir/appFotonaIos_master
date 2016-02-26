//
//  FISearchViewViewController.m
//  fotona
//
//  Created by Janos on 31/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FISearchViewController.h"
#import "FAppDelegate.h"
#import "FDB.h"
#import "MBProgressHUD.h"
#import "FIFlowController.h"

@interface FISearchViewController ()

@end

@implementation FISearchViewController

@synthesize searchTxtIPhone;
@synthesize tableSearchIPhone;
@synthesize newsSearchResIPhone;
@synthesize casesSearchResIPhone;
@synthesize videosSearchResIPhone;
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
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (newsSearchResIPhone.count>0) {
            return newsSearchResIPhone.count;
        }else
        {
            if (casesSearchResIPhone.count>0) {
                return casesSearchResIPhone.count;
            }else
            {
                return videosSearchResIPhone.count;
            }
        }
    }else
    {
        if (section==1) {
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                return casesSearchResIPhone.count;
            }else
            {
                return videosSearchResIPhone.count;
            }
        }else
        {
            return videosSearchResIPhone.count;
        }
        
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        if (newsSearchResIPhone.count>0) {
            return @"News";
        }else
        {
            if (casesSearchResIPhone.count>0) {
                return @"Cases";
            }else
            {
                return @"Videos";
            }
        }
    }else
    {
        if (section==1) {
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                return @"Cases";
            }else
            {
                return @"Videos";
            }
        }else
        {
            return @"Videos";
        }
        
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    if (indexPath.section==0) {
        if (newsSearchResIPhone.count>0) {
            [cell.textLabel setText:[[newsSearchResIPhone objectAtIndex:indexPath.row] title]];
        }else
        {
            if (casesSearchResIPhone.count>0) {
                [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
            }else
            {
                [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
            }
        }
    }else
    {
        if (indexPath.section==1) {
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                [cell.textLabel setText:[[casesSearchResIPhone objectAtIndex:indexPath.row] title]];
            }else
            {
                [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
            }
        }else
        {
            [cell.textLabel setText:[[videosSearchResIPhone objectAtIndex:indexPath.row] title]];
        }
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parentIPhone.view endEditing:YES];
    FIFlowController *flow = [FIFlowController sharedInstance];
    [flow.lastOpenedView toggleSearchBar];
    [self.view endEditing:true];
    if (indexPath.section==0) {
        if (newsSearchResIPhone.count>0) {
            [self openNews:indexPath];
        }else
        {
            if (casesSearchResIPhone.count>0) {
                [self openCase:indexPath];
            }else
            {
                [self openVideo:indexPath];
            }
        }
    }else
    {
        if (indexPath.section==1) {
            if (newsSearchResIPhone.count>0 && casesSearchResIPhone.count>0) {
                [self openCase:indexPath];
            }else
            {
                [self openVideo:indexPath];
            }
        }else
        {
            [self openVideo:indexPath];
        }
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchTxtIPhone = searchText;
    [self searchIPhone];
}

-(void)searchIPhone
{
    newsSearchResIPhone=[FDB getNewsForSearchFromDB:searchTxtIPhone];
    casesSearchResIPhone=[FDB getCasesForSearchFromDB:searchTxtIPhone];
    videosSearchResIPhone=[FDB getVideosForSearchFromDB:searchTxtIPhone];
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

#pragma mark OpenElements

-(void) openNews:(NSIndexPath*) index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    [APP_DELEGATE setNewsTemp:newsSearchResIPhone[index.row]];
    flow.lastIndex = 0;
    [flow.newsTab openNews];
    [flow.tabControler setSelectedIndex:0];
}


-(void) openCase:(NSIndexPath*) index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.caseFlow = casesSearchResIPhone[index.row];
    if (flow.caseMenu != nil)
    {
        [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    if (flow.lastIndex != 3) {
        flow.lastIndex = 3;
        [flow.tabControler setSelectedIndex:3];
    } else {
        flow.caseTab.caseToOpen = flow.caseFlow;
        [flow.caseTab openCase];
    }
}

-(void) openVideo:(NSIndexPath*) index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.vidToOpen = videosSearchResIPhone[index.row];
    flow.videoGal = flow.vidToOpen.videoGalleryID;
    flow.fromSearch = true;
    if (flow.fotonaMenu != nil)
    {
        [[[flow fotonaMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    if (flow.lastIndex != 2) {
        flow.lastIndex = 2;
        [flow.tabControler setSelectedIndex:2];
    } else {
        [flow.fotonaTab openGalleryFromSearch:flow.videoGal andReplace:true];
    }
 
}

@end

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
#import "FAppDelegate.h"
#import "FFeaturedViewController_iPad.h"
#import "FCasebookViewController.h"
#import "IIViewDeckController.h"
#import "ASDepthModalViewController.h"
#import "FFeaturedViewController_iPad.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FImage.h"
#import "FVideo.h"
#import "FDB.h"

@interface FSearchViewController ()

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
    int count = 0;
    if ([newsSearchRes count]>0)
    {
        count++;
    }
    if ([casesSearchRes count]>0) {
        count++;
    }
    if ([videosSearchRes count]>0)
    {
        count++;
    }
    if ([pdfsSearchRes count]>0)
    {
        count++;
    }
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (newsSearchRes.count>0) {
                return newsSearchRes.count;
            }else
            {
                if (casesSearchRes.count>0) {
                    return casesSearchRes.count;
                }else
                {
                    if (videosSearchRes.count>0) {
                        return videosSearchRes.count;
                    }
                }
            }
            break;
        case 1:
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                return casesSearchRes.count;
            }else
            {
                if (videosSearchRes.count>0) {
                    return videosSearchRes.count;
                }
            }
            break;
        case 2:
            if (videosSearchRes.count>0) {
                return videosSearchRes.count;
            }
            break;
        default:
            return pdfsSearchRes.count;
    }
    return pdfsSearchRes.count;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            if (newsSearchRes.count>0) {
                return @"News";
            }else
            {
                if (casesSearchRes.count>0) {
                    return @"Cases";
                }else
                {
                    if (videosSearchRes.count>0) {
                        return @"Videos";
                    }
                }
            }
            break;
        case 1:
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                return @"Cases";
            }else
            {
                if (videosSearchRes.count>0) {
                    return @"Videos";
                }
            }
            break;
        case 2:
            if (videosSearchRes.count>0) {
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
            if (newsSearchRes.count>0) {
                [cell.textLabel setText:[[newsSearchRes objectAtIndex:indexPath.row] title]];
            }else
            {
                if (casesSearchRes.count>0) {
                    [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
                }else
                {
                    if (videosSearchRes.count>0) {
                        [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
                    }else {
                        [cell.textLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] title]];
                    }
                }
            }
            break;
        case 1:
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
            }else
            {
                if (videosSearchRes.count>0) {
                    [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
                }else {
                    [cell.textLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] title]];
                }
            }
            break;
        case 2:
            if (videosSearchRes.count>0) {
                [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
            } else {
                [cell.textLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] title]];
            }
            break;
        case 3:
            [cell.textLabel setText:[[pdfsSearchRes objectAtIndex:indexPath.row] title]];
            break;
        default:
            [cell.textLabel setText:@"TITLE IPAD"];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parent.view endEditing:YES];
    
    switch (indexPath.section) {
        case 0:
            if (newsSearchRes.count>0) {
                [self openNews:indexPath];
            }else
                {
                    if (casesSearchRes.count>0) {
                        [self openCase:indexPath];
                    }else
                    {
                        if (videosSearchRes.count>0) {
                            [self openVideo:indexPath];
                        }else {
                            [self openPDF:indexPath];
                        }
                    }
                }
            break;
        case 1:
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                [self openCase:indexPath];
            }else
            {
                if (videosSearchRes.count>0) {
                    [self openVideo:indexPath];
                }else {
                    [self openPDF:indexPath];
                }
            }
            break;
        case 2:
            if (videosSearchRes.count>0) {
                [self openVideo:indexPath];
            } else {
                [self openPDF:indexPath];
            }
            break;
        case 3:
            [self openPDF:indexPath];
            break;
        default:
            break;
    }
}

-(void)search
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    newsSearchRes=[FDB getNewsForSearchFromDB:searchTxt withDatabase:database];
    casesSearchRes=[FDB getCasesForSearchFromDB:searchTxt withDatabase:database];
    videosSearchRes=[FDB getVideosForSearchFromDB:searchTxt withDatabase:database];
    pdfsSearchRes = [FDB getPDFForSearchFromDB:searchTxt withDatabase:database];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}


-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    [MBProgressHUD hideAllHUDsForView:[parent.viewDeckController.centerController view] animated:YES];
    if (success<updateCounter) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Problem with content update!" delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil]
        ;
        [av setTag:0];
        [av show];
    }
    updateCounter=0;
    success=0;
}

#pragma mark OpenElements

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
    [[(FFeaturedViewController_iPad *)parent popover] dismissPopoverAnimated:YES];
    if ([[casesSearchRes objectAtIndex:index.row] isKindOfClass:[FCase class]]) {
        FCase *item = [casesSearchRes objectAtIndex:index.row];
        if ( [[item bookmark] boolValue]|| [[item coverflow] boolValue]){
            
            UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:3] centerController];
            
            [(FCasebookViewController *)[tempC topViewController] setCurrentCase:item];
            [(FCasebookViewController *)[tempC topViewController] setFlagCarousel:YES];
            if ([parent isKindOfClass:[FCasebookViewController class]]) {
                [(FCasebookViewController*)parent openCase];
            }else{
                [parent.tabBarController setSelectedIndex:3];
            }
            
        } else{
            if([APP_DELEGATE connectedToInternet]){
                MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:[parent.viewDeckController.centerController view]];
                [[(FCasebookViewController*)self.viewDeckController.centerController view] addSubview:hud];
                hud.labelText = @"Opening case";
                [hud show:YES];
                NSString *requestData;
                requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"caseID\":\"%@\",\"access_token\":\"%@\",\"dateUpdated\":\"%@\"}",langID,[item caseID]  ,globalAccessToken,@"01.01.2000 10:36:20"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@GetCaseById",webService]];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
                [request setHTTPMethod:@"POST"];
                [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *jsonError;
                    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                    NSString *c = [dic objectForKey:@"d"];
                    NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
                    FCase *caseObj=[[FCase alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&jsonError]];
                    NSMutableArray *imgs = [[NSMutableArray alloc] init];
                    for (NSDictionary *imgLink in [caseObj images]) {
                        FImage * img = [[FImage alloc] initWithDictionary:imgLink];
                        
                        [imgs addObject:img];
                    }
                    [caseObj setImages:imgs];
                    NSMutableArray *videos = [[NSMutableArray alloc] init];
                    for (NSDictionary *videoLink in [caseObj video]) {
                        FVideo * videoTemp = [[FVideo alloc] initWithDictionary:videoLink];
                        [videos addObject:videoTemp];
                    }
                    [caseObj setVideo:videos];
                    updateCounter++;
                    success++;
                    [self removeHud];
                    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:3] centerController];
                    
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

-(void) openVideo:(NSIndexPath*) index
{
    [[(FFotonaViewController *)parent popover] dismissPopoverAnimated:YES];
    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:2] centerController];
    
    [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES];
    [parent.tabBarController setSelectedIndex:2];
    
    [(FFotonaViewController *)[tempC topViewController] openVideoFromSearch:[videosSearchRes objectAtIndex:index.row]];
    
}

-(void) openPDF:(NSIndexPath*) index
{
    [[(FFotonaViewController *)parent popover] dismissPopoverAnimated:YES];
    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:2] centerController];
    
    [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES];
    [(FFotonaViewController *)[tempC topViewController] setPDF:[pdfsSearchRes objectAtIndex:index.row] ];
    if (parent.tabBarController.selectedIndex == 2) {
         [(FFotonaViewController *)[tempC topViewController] openPDFFromSearch];
    } else {
        [parent.tabBarController setSelectedIndex:2];
    }
}


@end

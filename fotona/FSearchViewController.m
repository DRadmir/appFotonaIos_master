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

@interface FSearchViewController ()

@end

@implementation FSearchViewController
@synthesize searchTxt;
@synthesize tableSearch;
@synthesize newsSearchRes;
@synthesize casesSearchRes;
@synthesize videosSearchRes;
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
    // Do any additional setup after loading the view from its nib.
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
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (newsSearchRes.count>0) {
            return newsSearchRes.count;
        }else
        {
            if (casesSearchRes.count>0) {
                return casesSearchRes.count;
            }else
            {
                return videosSearchRes.count;
            }
        }
    }else
    {
        if (section==1) {
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                return casesSearchRes.count;
            }else
            {
                return videosSearchRes.count;
            }
        }else
        {
            return videosSearchRes.count;
        }
        
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        if (newsSearchRes.count>0) {
            return @"News";
        }else
        {
            if (casesSearchRes.count>0) {
                return @"Cases";
            }else
            {
                return @"Videos";
            }
        }
    }else
    {
        if (section==1) {
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
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
        if (newsSearchRes.count>0) {
            [cell.textLabel setText:[[newsSearchRes objectAtIndex:indexPath.row] title]];
        }else
        {
            if (casesSearchRes.count>0) {
                [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
            }else
            {
                [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
            }
        }
    }else
    {
        if (indexPath.section==1) {
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
                [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
            }else
            {
                [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
            }
        }else
        {
            [cell.textLabel setText:[[videosSearchRes objectAtIndex:indexPath.row] title]];
        }
        
    }
    
    
    
    
    //    if (indexPath.section==0) {
    //        if (newsSearchRes.count>0) {
    //            [cell.textLabel setText:[[newsSearchRes objectAtIndex:indexPath.row] title]];
    //        }else
    //        {
    //            [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
    //        }
    //    }else
    //    {
    //        [cell.textLabel setText:[[casesSearchRes objectAtIndex:indexPath.row] title]];
    //    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parent.view endEditing:YES];
    //    if (indexPath.section==0) {
    //        if (newsSearchRes.count>0) {
    //            [self openNews:indexPath];
    //        }else
    //        {
    //            [self openCase:indexPath];
    //        }
    //    }else
    //    {
    //        [self openCase:indexPath];
    //    }
    
    if (indexPath.section==0) {
        if (newsSearchRes.count>0) {
            [self openNews:indexPath];
        }else
        {
            if (casesSearchRes.count>0) {
                [self openCase:indexPath];
            }else
            {
                [self openVideo:indexPath];
            }
        }
    }else
    {
        if (indexPath.section==1) {
            if (newsSearchRes.count>0 && casesSearchRes.count>0) {
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

-(void)search
{
    newsSearchRes=[self getNewsFromDB];
    casesSearchRes=[self getCasesFromDB];
    videosSearchRes=[self getVideosFromDB];
}

-(IBAction)closePopup:(id)sender
{
    [tmpNews removeFromSuperview];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    [[(FCasebookViewController *)parent viewDeckController] setEnabled:YES];
}



-(NSMutableArray *)getNewsFromDB
{
    NSMutableArray *news=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=%@ and (title like '%%%@%%'or description like '%%%@%%'or text like '%%%@%%' ) ORDER BY newsID DESC",@"1",searchTxt,searchTxt,searchTxt]];
    while([results next]) {
        
        FNews *f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        [news addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return news;
}


-(NSMutableArray *)getCasesFromDB
{
    NSMutableArray *tmp=[[NSMutableArray alloc] init];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and (title like '%%%@%%' or name like '%%%@%%' or introduction like '%%%@%%' or procedure like '%%%@%%' or results like '%%%@%%' or 'references' like '%%%@%%')",searchTxt,searchTxt,searchTxt,searchTxt,searchTxt,searchTxt]];
    while([results next]) {
        FCase *f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        //[tmp addObject:f];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [tmp addObject:f];
            }
        } else {
            [tmp addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return tmp;
}

-(NSMutableArray *)getVideosFromDB
{
    NSMutableArray *tmpVideo=[[NSMutableArray alloc] init];
    
    FMDatabase *databaseVideo = [FMDatabase databaseWithPath:DB_PATH];
    [databaseVideo open];
    
    FMResultSet *results = [databaseVideo executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaType=1 and (title like '%%%@%%')",searchTxt]];
    while([results next]) {
        FVideo *f=[[FVideo alloc] init];
        [f setItemID:[results stringForColumn:@"mediaID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setPath:[results stringForColumn:@"path"]];
        [f setLocalPath:[results stringForColumn:@"localPath"]];
        [f setVideoGalleryID:[results stringForColumn:@"galleryID"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setTime:[results stringForColumn:@"time"]];
        [f setVideoImage:[results stringForColumn:@"videoImage"]];
        [f setSort:[results stringForColumn:@"sort"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setUserType:[results stringForColumn:@"userType"]];
        [f setUserSubType:[results stringForColumn:@"userSubType"]];
       /* ta del za pravice na videu
        if ([f checkVideoForUser]) {
            [tmpVideo addObject:f];
        } */// če so pravice na videu
            if (f.videoGalleryID != nil) {
                FMResultSet *resultsFC= [databaseVideo executeQuery:[NSString stringWithFormat:@"SELECT categoryID FROM FotonaMenu where active=1 and videoGalleryID=%@",f.videoGalleryID]];
        
                NSString *fCategory = @"";
                while([resultsFC next]) {
                    fCategory = [resultsFC stringForColumn:@"categoryID"];
                }
        
                if ([self checkFotonaForUserSearch:fCategory]) {
                    [tmpVideo addObject:f];
                }
                
                
            }


    }
   
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [databaseVideo close];
    
    return tmpVideo;
}


-(BOOL)checkFotonaForUserSearch:(NSString *)fc
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        for (NSString *subType in [[APP_DELEGATE currentLogedInUser] userTypeSubcategory]) {
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",fc,subType]];
            while([results next]) {
                check=YES;
            }
        }
    }
    else{
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserType where fotonaID=%@ and userType=%@",fc,[[APP_DELEGATE currentLogedInUser] userType]]];
        while([results next]) {
            check=YES;
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
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
        // UINavigationController *tempC = [(IIViewDeckController *)[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:0] centerController];
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
    //    [[APP_DELEGATE tabBar] setSelectedIndex:2];
    //    UINavigationController *tempC = [[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:2];
    //
    //    [(FFotonaViewController *)[tempC visibleViewController]  openVideoFromSearch:[videosSearchRes objectAtIndex:index.row]];
    UINavigationController *tempC = [[[parent.tabBarController viewControllers] objectAtIndex:2] centerController];
    
    [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES];
    [parent.tabBarController setSelectedIndex:2];
    
    [(FFotonaViewController *)[tempC topViewController] openVideoFromSearch:[videosSearchRes objectAtIndex:index.row]];
    
}

@end

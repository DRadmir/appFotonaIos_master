//
//  FISettingsViewController.m
//  fotona
//
//  Created by Janos on 25/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FISettingsViewController.h"
#import "MBProgressHUD.h"
#import "HelperBookmark.h"
#import "FMDatabase.h"
#import "FIFlowController.h"
#import "FIExternalLinkViewController.h"

@interface FISettingsViewController ()

@end

@implementation FISettingsViewController
{
    NSMutableArray *tableData;
}
@synthesize popover;


@synthesize unbookmarAll;
@synthesize settingsViewHeight;




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        //        [self setTitle:@"Settings"];
        //        [self.tabBarItem setImage:[UIImage imageNamed:@"settings_grey.png"]];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(cancelMenu:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    [self fillTableData];
    
    logoutBtn.layer.cornerRadius = 3;
    logoutBtn.layer.borderWidth = 1;
    logoutBtn.layer.borderColor = logoutBtn.titleLabel.textColor.CGColor;
    
    btnBookmark.layer.cornerRadius = 3;
    btnBookmark.layer.borderWidth = 1;
    btnBookmark.layer.borderColor = btnBookmark.titleLabel.textColor.CGColor;
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.fotonaSettings = self;
    
    if (tableData == nil) {
        tableData = [NSMutableArray array];
    }
    NSMutableString *temp = [NSMutableString string];
    if (([[[APP_DELEGATE currentLogedInUser] firstName] isKindOfClass:[NSNull class]] ||
         [[APP_DELEGATE currentLogedInUser] firstName] == nil ||
         [[[APP_DELEGATE currentLogedInUser] firstName] isEqualToString:@""]) &&
        ([[[APP_DELEGATE currentLogedInUser] lastName] isKindOfClass:[NSNull class]] ||
         [[APP_DELEGATE currentLogedInUser] lastName] == nil ||
         [[[APP_DELEGATE currentLogedInUser] lastName] isEqualToString:@""]))
    {
        [temp appendString:[NSString stringWithFormat:@"%@ ",[[APP_DELEGATE currentLogedInUser] username]]];
        
        
    } else
    {
        
        if (![[[APP_DELEGATE currentLogedInUser] firstName] isKindOfClass:[NSNull class]] &&
            [[APP_DELEGATE currentLogedInUser] firstName] != nil &&
            ![[[APP_DELEGATE currentLogedInUser] firstName] isEqualToString:@""])
        {
            [temp appendString:[NSString stringWithFormat:@"%@ ",[[APP_DELEGATE currentLogedInUser] firstName]]];
            
        }
        if (![[[APP_DELEGATE currentLogedInUser] lastName] isKindOfClass:[NSNull class]] &&
            [[APP_DELEGATE currentLogedInUser] lastName] != nil &&
            ![[[APP_DELEGATE currentLogedInUser] lastName] isEqualToString:@""])
        {
            [temp appendString:[NSString stringWithFormat:@"%@ ",[[APP_DELEGATE currentLogedInUser] lastName]]];
            
        }
        
    }
    if (![logedAs.text isEqualToString: temp]) {
        [logedAs setText: temp];
        [self fillTableData];
        [self.categoryTable reloadData];
    }
    
    if (downloadView.isHidden) {
        [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height-74, downloadView.frame.size.width,downloadView.frame.size.height)];
    } else {
        [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height+8, downloadView.frame.size.width,downloadView.frame.size.height)];
    }
    
    //    [self.view setNeedsDisplay];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    if ([[[APP_DELEGATE currentLogedInUser] userType] intValue]==0) {
        [changePassBtn setHidden:YES];
    }else
    {
        [changePassBtn setHidden:NO];
    }
    [self.tabBarItem setImage:[UIImage imageNamed:@"settings_red.png"]];
    
    
    
    [wifiSwitch setOn: [APP_DELEGATE wifiOnlyConnection]];
    
    if ([APP_DELEGATE bookmarkCountLeft]>0 && downloadView.isHidden) {
        [btnBookmark setEnabled:YES];
        [btnBookmark setTitle:@"Stop" forState:UIControlStateNormal];
        btnBookmark.layer.borderColor = [[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1] CGColor];
        [self.categoryTable setUserInteractionEnabled:NO];
        [wifiSwitch setUserInteractionEnabled:NO];
        [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height+8, downloadView.frame.size.width,downloadView.frame.size.height)];
        downloadView.hidden = NO;
        
        self.progressPercentige.text = [NSString stringWithFormat:@"%.0f%%",(1-[APP_DELEGATE bookmarkCountLeft]/[APP_DELEGATE bookmarkCountAll])*100];
        [self.downloadProgress setProgress:1-[APP_DELEGATE bookmarkCountLeft]/[APP_DELEGATE bookmarkCountAll] animated:YES];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
}

-(void)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"autoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [APP_DELEGATE setCurrentLogedInUser:nil];
   // [self.navigationController popToRootViewControllerAnimated:NO];
    [self stopDownload];
    btnBookmark.layer.borderColor = btnBookmark.titleLabel.textColor.CGColor;
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        [[flow tabControler] removeViews];
    }];
}

-(void)changePassword:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    FIExternalLinkViewController *externalView = [sb instantiateViewControllerWithIdentifier:@"webViewController"];
    externalView.urlString = @"http://www.fotona.com/en/support/passreset/";
    externalView.changePass = true;
    [self.navigationController pushViewController:externalView animated:true];
}

- (IBAction)changeWifiCheck:(id)sender {
    [APP_DELEGATE setWifiOnlyConnection:wifiSwitch.isOn];
    if (wifiSwitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wifiOnly"];
    }
    
}

- (IBAction)bookmarkSelected:(id)sender {
    if ([btnBookmark.titleLabel.text isEqualToString:@"Bookmark"]) {
        if (!wifiSwitch.isOn) {
            UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
            [av showInView:self.view];
        } else {
            
            
            MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.labelText = @"Preparing to download";
            [hud show:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                });
                [self bookmark];
                
            });
        }
    } else {
        [self stopDownload];
        btnBookmark.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

-(void) bookmark{
    if ([APP_DELEGATE connectedToInternet]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE setBookmarkAll:YES];
            [btnBookmark setTitle:@"Stop" forState:UIControlStateNormal];
            [self.categoryTable setUserInteractionEnabled:NO];
            [wifiSwitch setUserInteractionEnabled:NO];
            
            [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height+8, downloadView.frame.size.width,downloadView.frame.size.height)];
            downloadView.hidden = NO;
            [HelperBookmark bookmarkAll:self.categoryTable.indexPathsForSelectedRows];
            btnBookmark.layer.borderColor = btnBookmark.titleLabel.textColor.CGColor;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    
    
}

- (void)stopDownload {
    [APP_DELEGATE setBookmarkAll:NO];
    [HelperBookmark cancelBookmark];
    [btnBookmark setTitle:@"Bookmark" forState:UIControlStateNormal];
    [btnBookmark setEnabled:NO];
    
    [self.categoryTable setUserInteractionEnabled:YES];
    [wifiSwitch setUserInteractionEnabled:YES];
    [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height-74, downloadView.frame.size.width,downloadView.frame.size.height)];
    downloadView.hidden = YES;
    [[APP_DELEGATE imagesToDownload]removeAllObjects];
    [[APP_DELEGATE videosToDownload]removeAllObjects];
    [[APP_DELEGATE pdfToDownload]removeAllObjects];
    [[APP_DELEGATE authorsImageToDownload]removeAllObjects];
    [[APP_DELEGATE downloadList] removeAllObjects];
    [[APP_DELEGATE bookmarkingVideos] removeAllObjects];
    [APP_DELEGATE setBookmarkCountLeft:0];
    [APP_DELEGATE setBookmarkCountAll:0];
    for (NSIndexPath *index in [self.categoryTable indexPathsForVisibleRows]) {
        [self.categoryTable cellForRowAtIndexPath:index].accessoryType = UITableViewCellAccessoryNone;
        [self.categoryTable deselectRowAtIndexPath:index animated:YES];
    }
    self.progressPercentige.text = [NSString stringWithFormat:@"0%%"];
    btnBookmark.layer.borderColor = [[UIColor grayColor] CGColor];
    [[APP_DELEGATE fotonaController] refreshVideoCells];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 1: [self unbookmark ];
            
            break;
    }
}


- (IBAction)unbookmarkAll:(id)sender {
    //    UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKUNBOOKMARK", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"NO",@"YES",nil];
    //    [av showInView:self.view];
    
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"CHECKUNBOOKMARK", nil)] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [av show];
    
}

- (void)unbookmark{
    [self stopDownload];
    NSString *currentUsr = [FCommon getUser];
    int x = 0;
    FMDatabase *localDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [localDatabase open];
    FMResultSet *resultsBookmarked =  [localDatabase executeQuery:@"SELECT * FROM UserBookmark where username=?" withArgumentsInArray:@[currentUsr]];
    while([resultsBookmarked next]) {
        NSLog(@"%d",x);
        x++;
        NSString *type = [resultsBookmarked stringForColumn:@"typeID"];
        FMResultSet *resultItem;
        BOOL still = NO;
        if ([type isEqualToString:BOOKMARKNEWS]) {// news
            [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKNEWS];
            resultItem = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=? and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKNEWS, nil]];
            while([resultItem next]) {
                still = YES;
            }
            if (!still) {//if not bookmaked anymore
                resultItem = [localDatabase executeQuery:@"SELECT * FROM News where newsID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKNEWS, nil]];
                while([resultItem next]) {
                    FNews *f=[[FNews alloc] initWithDictionary:[resultItem resultDictionary]];
                    [localDatabase executeUpdate:@"UPDATE News set isBookmark=? where newsID=?",@"0", [NSString stringWithFormat:@"%ld", (long)f.newsID]];
                    if ([f.rest isEqualToString:@"1"]) {
                        NSString *downloadFilename = [NSString stringWithFormat:@"%@%@",docDir,f.localImage];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:downloadFilename error:&error];
                        
                        for (int i =0; i<[f.localImages count]; i++) {
                            downloadFilename = [NSString stringWithFormat:@"%@%@",docDir,[f.localImages objectAtIndex:i]];
                            [fileManager removeItemAtPath:downloadFilename error:&error];
                            x++;
                        }
                        
                    }
                }
            }
        } else {
            if ([type isEqualToString:BOOKMARKEVENTS]) {//events
                [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKEVENTS];
                resultItem = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=? and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKEVENTS, nil]];
                while([resultItem next]) {
                    still = YES;
                }
                if (!still) {
                    [localDatabase executeUpdate:@"UPDATE Events set isBookmark=? where eventID=?",@"0", [NSString stringWithFormat:@"%@", [resultsBookmarked stringForColumn:@"documentID"]]];
                }
                
            } else {
                if ([type isEqualToString:BOOKMARKVIDEO]) {//video
                    [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKVIDEO];
                    [[APP_DELEGATE fotonaController] refreshCellUnbookmark:[[resultsBookmarked stringForColumn:@"documentID"] intValue]];
                    FMResultSet *results =  [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKVIDEO]];
                    BOOL flag=NO;
                    while([results next]) {
                        flag=YES;
                    }
                    if (!flag) {
                        [localDatabase executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",[resultsBookmarked stringForColumn:@"documentID"]];
                        FMResultSet *results2 = [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ order by sort",[resultsBookmarked stringForColumn:@"documentID"]]];
                        
                        while([results2 next]) {
                            //  NSString *folder=@".Cases";
                            NSString *downloadFilename = [results2 stringForColumn:@"localPath"];//[[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[results2 stringForColumn:@"localPath"]];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSError *error;
                            [fileManager removeItemAtPath:downloadFilename error:&error];
                            
                            //                            downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[results2 stringForColumn:@"videoImage"]];
                            NSArray *pathComp=[[results2 stringForColumn:@"mediaImage"] pathComponents];
                            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[results2 stringForColumn:@"mediaImage"] lastPathComponent]];
                            [fileManager removeItemAtPath:pathTmp error:&error];
                            x++;
                        }
                        
                        
                    }
                    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                } else {
                    if ([type isEqualToString:BOOKMARKPDF]) {//pdf
                        [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKPDF];
                        FMResultSet *results =  [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKPDF]];
                        BOOL flag=NO;
                        NSString *pdfSrc =@"pdfSrc";
                        while([results next]) {
                            flag=YES;
                            pdfSrc = [results stringForColumn:@"pdfSrc"];
                        }
                        if (!flag) {
                            [localDatabase executeUpdate:@"UPDATE FotonaMenu set isBookmark=? where categoryID=?",@"0",[resultsBookmarked stringForColumn:@"documentID"]];
                            results= [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where active=1 and categoryID=%@",[resultsBookmarked stringForColumn:@"documentID"]]];
                            while([results next]) {
                                pdfSrc = [results stringForColumn:@"pdfSrc"];
                            }
                            NSString *folder=@".PDF";
                            NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[pdfSrc lastPathComponent]];
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSError *error;
                            [fileManager removeItemAtPath:downloadFilename error:&error];
                            
                            
                        }
                        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                    } else {//case
                        [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=0",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,nil];
                        BOOL bookmarked = NO;
                        
                        FMResultSet *results = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=0 and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"], nil]];
                        while([results next]) {
                            bookmarked = YES;
                        }
                        FMResultSet *selectedCases = [localDatabase executeQuery:@"SELECT * FROM Cases where caseID=?" withArgumentsInArray:@[[resultsBookmarked stringForColumn:@"documentID"]]];
                        FCase * selected;
                        while([selectedCases next]) {
                            selected =  [[FCase alloc] initWithDictionary:[selectedCases resultDictionary]];
                        }
                        
                        if (!bookmarked) {
                            if ([[selected coverflow] boolValue]) {
                                [localDatabase executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"0",selected.caseID];
                                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                            }
                            else{
                                [localDatabase executeUpdate:@"DELETE FROM Cases WHERE caseID=?",selected.caseID];
                                [localDatabase executeUpdate:@"INSERT INTO Cases (caseID,title, coverTypeID,name,image,active,authorID,isBookmark,alloweInCoverFlow, deleted, download, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?)",selected.caseID,selected.title,selected.coverTypeID,selected.name,selected.image,selected.active,selected.authorID,@"0",selected.coverflow,selected.deleted, selected.download, selected.userPermissions];
                                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                                x+=[selected getImages].count-1;
                                x+=[selected getVideos].count-1;
                                [[[FCasebookViewController alloc]init]  deleteMediaForCaseGalleryID:selected.galleryID withArray:[selected getImages] andType:0];
                                [[[FCasebookViewController alloc]init] deleteMediaForCaseGalleryID:selected.videoGalleryID withArray:[selected getVideos] andType:1];
                                [[[FUpdateContent alloc]init] addMediaWhithout:[selected parseImages] withType:0];
                                [[[FUpdateContent alloc]init] addMediaWhithout:[selected parseVideos] withType:1];
                            }
                            
                        }
                    }
                }
            }
        }
    }
    [localDatabase close];
    
    NSLog(@"Unbookmarking complete");
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEDBULKBOOKMARKS", nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

//creating cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"setttingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *selectedView =[ [UIView alloc] init];
    selectedView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1];
    cell.selectedBackgroundView = selectedView;
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1];
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
}

//click on cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    //[tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1];
    btnBookmark.enabled = true;
    btnBookmark.layer.borderColor = btnBookmark.titleLabel.textColor.CGColor;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    //[tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:0.216 green:0.216 blue:0.216 alpha:1];
    if ([[tableView indexPathsForSelectedRows] count] == 0) {
        btnBookmark.enabled = false;
        btnBookmark.layer.borderColor = btnBookmark.titleLabel.textColor.CGColor;
    }
}

- (void) fillTableData{
    [tableData removeAllObjects];
    NSArray *temp =[APP_DELEGATE currentLogedInUser].userTypeSubcategory;
    if ([[APP_DELEGATE currentLogedInUser].userType intValue] == 0 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 1 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3) {
        temp = @[@"2",@"1",  @"3"];
    }
    
    NSString *name = @"";
    for (int i = 0; i< temp.count; i++) {
        NSString *category = temp[i];
        switch (category.intValue) {
            case 1:
                name = @"Dentistry";
                break;
            case 2:
                name = @"Aesthetics";
                break;
            case 3:
                name = @"Gynecology";
                break;
            case 4:
                name = @"Surgery";
                break;
            default:
                break;
        }
        [tableData addObject:name];
    }
    settingsViewHeight.constant += tableData.count * 50;
    checkViewHeight.constant = tableData.count * 50;
    tableviewHeight.constant = tableData.count * 50;
    
}



-(void) refreshStatusBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressPercentige.text = [NSString stringWithFormat:@"%.0f%%",(1-[APP_DELEGATE bookmarkCountLeft]/[APP_DELEGATE bookmarkCountAll])*100];
        [self.downloadProgress setProgress:1-[APP_DELEGATE bookmarkCountLeft]/[APP_DELEGATE bookmarkCountAll] animated:YES];
        if ([APP_DELEGATE bookmarkCountLeft] == 0) {
            [APP_DELEGATE setBookmarkCountAll:0];
            [[APP_DELEGATE imagesToDownload]removeAllObjects];
            [[APP_DELEGATE videosToDownload]removeAllObjects];
            [[APP_DELEGATE pdfToDownload]removeAllObjects];
            [[APP_DELEGATE authorsImageToDownload]removeAllObjects];
            [APP_DELEGATE setBookmarkAll:NO];
            [[APP_DELEGATE bookmarkingVideos] removeAllObjects];
            [HelperBookmark cancelBookmark];
            [btnBookmark setTitle:@"Bookmark" forState:UIControlStateNormal];
            [btnBookmark setEnabled:NO];
            btnBookmark.layer.borderColor = [[UIColor grayColor] CGColor];
            [self.categoryTable setUserInteractionEnabled:YES];
            
            [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height-74, downloadView.frame.size.width,downloadView.frame.size.height)];
            downloadView.hidden = YES;
            for (NSIndexPath *index in [self.categoryTable indexPathsForVisibleRows]) {
                [self.categoryTable cellForRowAtIndexPath:index].accessoryType = UITableViewCellAccessoryNone;
                [self.categoryTable deselectRowAtIndexPath:index animated:YES];
            }
            self.progressPercentige.text = [NSString stringWithFormat:@"0%%"];
            [wifiSwitch setUserInteractionEnabled:YES];
            
        } else {
            if (downloadView.isHidden) {
                [btnBookmark setTitle:@"Stop" forState:UIControlStateNormal];
                [btnBookmark setEnabled:YES];
                [self.categoryTable setUserInteractionEnabled:NO];
                [wifiSwitch setUserInteractionEnabled:NO];
                [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,downloadView.frame.origin.y, downloadView.frame.size.width,downloadView.frame.size.height)];
                downloadView.hidden = NO;
                btnBookmark.layer.borderColor = [[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1] CGColor];
            }
            
        }
    });
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex > -1) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"OK"]) {
            [self bookmark];
        }
        if ([buttonTitle isEqualToString:NSLocalizedString(@"CHECKWIFIONLYBTN", nil)]) {
            [wifiSwitch setOn:YES animated:YES];
            [APP_DELEGATE setWifiOnlyConnection:wifiSwitch.isOn];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
            [self bookmark];
        }
    }
    
}

#pragma mark - Close Menu

- (IBAction)cancelMenu:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

@end

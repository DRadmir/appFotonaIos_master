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
#import "FMediaManager.h"
#import "FHelperRequest.h"
#import "FNotificationManager.h"

@interface FISettingsViewController ()

@end

@implementation FISettingsViewController
{
    NSMutableArray *tableData;
}
@synthesize popover;
@synthesize unbookmarAll;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getVersionApp];
    
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
    
    self.categoryTable.delegate = self;
    self.categoryTable.dataSource = self;
    
}

-(void)getVersionApp
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    versionLabel.text = [NSString stringWithFormat:@"Version: %@", version];
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
    
    [wifiSwitch setOn: [ConnectionHelper getWifiOnlyConnection]];
    
    if ([APP_DELEGATE bookmarkCountLeft]>0 && downloadView.isHidden) {
        [btnBookmark setEnabled:YES];
        [btnBookmark setTitle:@"Stop" forState:UIControlStateNormal];
        btnBookmark.layer.borderColor = [[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1] CGColor];
        [self.categoryTable setUserInteractionEnabled:NO];
        [wifiSwitch setUserInteractionEnabled:NO];
        [downloadView setFrame:CGRectMake(downloadView.frame.origin.x,checkView.frame.origin.y+checkView.frame.size.height+8, downloadView.frame.size.width,downloadView.frame.size.height)];
        downloadView.hidden = NO;
        
        self.progressPercentige.text = [NSString stringWithFormat:@"%.0f%%",(1-[APP_DELEGATE bookmarkSizeLeft]/[APP_DELEGATE bookmarkSizeAll])*100];
        [self.downloadProgress setProgress:1-[APP_DELEGATE bookmarkSizeLeft]/[APP_DELEGATE bookmarkSizeAll] animated:YES];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


-(void)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"autoLoginEnabled"];
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
    externalView.urlString = @"http://www.fotona.com/en/support/profile/"; //@"http://www.fotona.com/en/support/passreset/"
    externalView.changePass = true;
    [self.navigationController pushViewController:externalView animated:true];
}

- (IBAction)changeNotifCheck:(id)sender{
    
    UIApplication *application = [UIApplication sharedApplication];
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeNone)];
    if (notifSwitch.isOn) {
        [FNotificationManager setActiveNotificationa:@"1"];
    } else {
        [FNotificationManager setActiveNotificationa:@"0"];
    }
    
    [FHelperRequest sendDeviceData];
}

- (IBAction)changeWifiCheck:(id)sender {
    [ConnectionHelper setWifiOnlyConnection:wifiSwitch.isOn];
    if (wifiSwitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wifiOnly"];
    }
    
}

- (IBAction)bookmarkSelected:(id)sender {
    if ([btnBookmark.titleLabel.text isEqualToString:@"Download"]) {
        if (![ConnectionHelper connectedToInternet]) {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            //            if([wifiSwitch.isOn]){
            //            UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
            //            [av showInView:self.view];}
            
        } else {
            MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.labelText = @"Preparing to download";
            [hud show:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                [self bookmark];
            });
        }
    } else {
        [self stopDownload];
        btnBookmark.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

-(void) bookmark{
    if ([ConnectionHelper connectedToInternet]) {
        
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
    [btnBookmark setTitle:@"Download" forState:UIControlStateNormal];
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
    [APP_DELEGATE setBookmarkSizeAll:0];
    [APP_DELEGATE setBookmarkSizeLeft:0];
    for (NSIndexPath *index in [self.categoryTable indexPathsForVisibleRows]) {
        [self.categoryTable cellForRowAtIndexPath:index].accessoryType = UITableViewCellAccessoryNone;
        [self.categoryTable deselectRowAtIndexPath:index animated:YES];
    }
    self.progressPercentige.text = [NSString stringWithFormat:@"0%%"];
    btnBookmark.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 1: [self unbookmark ];
            
            break;
    }
}


- (IBAction)unbookmarkAll:(id)sender {
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"CHECKUNBOOKMARK", nil)] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [av show];
    
}

-(void)unbookmark{
    [self stopDownload];
    [HelperBookmark unbookmarkAll];
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
    if ([[APP_DELEGATE currentLogedInUser].userType intValue] == 0 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3) {
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
    tableviewHeight.constant = tableData.count * 50;
    
}



-(void) refreshStatusBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        float res = 0;
        if ([APP_DELEGATE bookmarkSizeLeft] > 0 && [APP_DELEGATE bookmarkSizeAll] > 0) {
            res = [APP_DELEGATE bookmarkSizeLeft]/[APP_DELEGATE bookmarkSizeAll];
        }
        self.progressPercentige.text = [NSString stringWithFormat:@"%.0f%% of %.2f GB",(1-res)*100, [APP_DELEGATE bookmarkSizeAll]/1073741824];
        [self.downloadProgress setProgress:1-[APP_DELEGATE bookmarkSizeLeft]/[APP_DELEGATE bookmarkSizeAll] animated:YES];
        if ([APP_DELEGATE bookmarkCountLeft] == 0) {
            [APP_DELEGATE setBookmarkCountAll:0];
            [APP_DELEGATE setBookmarkSizeAll:0];
            [APP_DELEGATE setBookmarkSizeLeft:0];
            [[APP_DELEGATE imagesToDownload]removeAllObjects];
            [[APP_DELEGATE videosToDownload]removeAllObjects];
            [[APP_DELEGATE pdfToDownload]removeAllObjects];
            [[APP_DELEGATE authorsImageToDownload]removeAllObjects];
            [APP_DELEGATE setBookmarkAll:NO];
            [[APP_DELEGATE bookmarkingVideos] removeAllObjects];
            [HelperBookmark cancelBookmark];
            [btnBookmark setTitle:@"Download" forState:UIControlStateNormal];
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
            [ConnectionHelper setWifiOnlyConnection:wifiSwitch.isOn];
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

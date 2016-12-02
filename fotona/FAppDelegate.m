//
//  FAppDelegate.m
//  Fotona
//
//  Created by Dejan Krstevski on 3/13/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FAppDelegate.h"
#import "FMainViewController_iPad.h"
#import "FMainViewController.h"
#import <QuickLook/QuickLook.h>
#import "ASDepthModalViewController.h"
#import "FNews.h"
#import "FEvent.h"
#import "IIViewDeckController.h"
#import "FCase.h"
#import "FCasebookViewController.h"
#import "FMDatabase.h"
#import "Reachability.h"
#import "FSettingsViewController.h"
#import "FDownloadManager.h"
#import "UIColor+Hex.h"
#import "FIFlowController.h"
#import "UIWindow+Fotona.h"
#import "FIExternalLinkViewController.h"
#import <AVKit/AVKit.h>
#import "FHelperRequest.h"
#import "FFavoriteViewController.h"
#import "FIPDFViewController.h"
#import "FDB.h"
#import "FNotificationManager.h"



@implementation FAppDelegate

int notificationType = 0;
NSString *notificationUrl = @"";

@synthesize  DEVELOP;

@synthesize tabBar;
@synthesize currentLogedInUser;
@synthesize userFolderPath;
@synthesize main;
@synthesize main_ipad;
@synthesize authorsImageToDownload;
@synthesize imagesToDownload;
@synthesize videosToDownload;
@synthesize pdfToDownload;
@synthesize indexToSelect;

@synthesize newNews;
@synthesize currentOrientation;
@synthesize updateInProgress;
@synthesize eventArray;
@synthesize caseArray;
@synthesize downloadManagerArray = _downloadManagerArray;
@synthesize videoImages;

@synthesize closedNews;
@synthesize closedEvents;


@synthesize settingsController;
@synthesize fotonaController;
@synthesize favoriteController;
@synthesize casebookController;

@synthesize bookmarkCountAll;
@synthesize bookmarkCountLeft;
@synthesize bookmarkSizeAll;
@synthesize bookmarkSizeLeft;

@synthesize loginShown;

@synthesize logText;
@synthesize logingEnabled;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.DEVELOP = true;
    self.logText = @"";
    self.logingEnabled = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"pushType"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
   
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"newUpdate"]) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSFileManager* fm = [[NSFileManager alloc] init];
        NSDirectoryEnumerator* en = [fm enumeratorAtPath:docDir];
        NSError* err = nil;
        BOOL res;
        NSString* file;
        while (file = [en nextObject]) {
            res = [fm removeItemAtPath:[docDir stringByAppendingPathComponent:file] error:&err];
            if (!res && err) {
                NSLog(@"oops: %@", err);
            }
        }
    }
    
    [FDB copyDatabaseIfNeeded];
    [self setBookmarkAll:NO];
    [self prepareDownloadArrays];
    tabBar=[[FTabBarController alloc] init];
    
    [self setIndexToSelect:0];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        main_ipad=[[FMainViewController_iPad alloc] init];
        UINavigationController *navRoot=[[UINavigationController alloc] initWithRootViewController:main_ipad];
        [self.window setRootViewController:navRoot];
    } else
    {
        main=[[FMainViewController alloc] init];
        UINavigationController *navRoot=[[UINavigationController alloc] initWithRootViewController:main];
        [self.window setRootViewController:navRoot];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorFromHex:FOTONARED]];
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)
        {
            [[UINavigationBar appearance] setTranslucent:NO];
        }
    }
    
    
    settingsController = [[FSettingsViewController alloc] initWithNibName:@"FSettingsViewController" bundle:nil];
    fotonaController = [[FFotonaViewController alloc] init];
    casebookController = [[FCasebookViewController alloc] init];
    
    [self setAppearance];
    
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"wifiOnly"]) {
        [ConnectionHelper setWifiOnlyConnection:[[NSUserDefaults standardUserDefaults] boolForKey:@"wifiOnly"] ];
    } else {
        [ConnectionHelper setWifiOnlyConnection:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
    }
    
    [self setDownloadList:[[NSMutableArray alloc] init]];
    [self setLoginShown:NO];
    
    
    //Google analytics
    [self prepareGA];
    
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeNone)];

    application.applicationIconBadgeNumber=0;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveDownloadArrays];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[self saveDownloadArrays]; DONE LAST
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        [self prepareDownloadArrays];
        if ([ConnectionHelper connectedToInternet]) {
            if (![self updateInProgress]) {
                [self setUpdateInProgress:YES];
                [[FUpdateContent shared] updateContent:[self main]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            
        });
    });
    
       
    closedNews = YES;
    closedEvents = YES;
    [ConnectionHelper setWifiOnlyConnection:[[NSUserDefaults standardUserDefaults] boolForKey:@"wifiOnly"] ];
     }


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber=0;
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveDownloadArrays];
    if ([ConnectionHelper getWifiOnlyConnection]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wifiOnly"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray *)downloadManagerArray
{
    if (!_downloadManagerArray) {
        _downloadManagerArray = [[NSMutableArray alloc]init];
    }
    
    return _downloadManagerArray;
}


#pragma mark Download Arrays
-(void)prepareDownloadArrays
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"authorsImageArray"]) {
        [defaults setValue:[[NSArray alloc] init] forKeyPath:@"authorsImageArray"];
    }
    if (![defaults objectForKey:@"imagesArray"]) {
        [defaults setValue:[[NSArray alloc] init] forKeyPath:@"imagesArray"];
        
    }
    if (![defaults objectForKey:@"videosArray"]) {
        [defaults setValue:[[NSArray alloc] init] forKeyPath:@"videosArray"];
        
    }
    if (![defaults objectForKey:@"pdfArray"]) {
        [defaults setValue:[[NSArray alloc] init] forKeyPath:@"pdfArray"];
        
    }
    [defaults synchronize];
    
    [self setAuthorsImageToDownload:[[defaults objectForKey:@"authorsImageArray"] mutableCopy]];
    [self setImagesToDownload:[[defaults objectForKey:@"imagesArray"] mutableCopy]];
    [self setVideosToDownload:[[defaults objectForKey:@"videosArray"] mutableCopy]];
    [self setPdfToDownload:[[defaults objectForKey:@"pdfArray"] mutableCopy]];
    [APP_DELEGATE setBookmarkAll:[defaults boolForKey:@"bookmarkAll"]];
    
    
}

-(void)saveDownloadArrays
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *tmpAuthors=authorsImageToDownload;

    for (int i=0; i<tmpAuthors.count; i++){
        NSString *fileName = [tmpAuthors objectAtIndex:i];
        NSString *local=[NSString stringWithFormat:@"%@/.Authors/%@",docDir,fileName.lastPathComponent];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
            [authorsImageToDownload removeObjectAtIndex:i];
        }
    }
    
    NSMutableArray *tmpImgs=imagesToDownload;

    for (int i=0; i<tmpImgs.count; i++){
        NSString *fileName = [tmpImgs objectAtIndex:i];
        NSString *local=[NSString stringWithFormat:@"%@/.Cases/%@",docDir,fileName.lastPathComponent];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
            [imagesToDownload removeObjectAtIndex:i];
        }
    }
    
    NSMutableArray *tmpVideos=videosToDownload;
    for (int i=0; i<tmpVideos.count; i++){
        NSString *fileName = [tmpVideos objectAtIndex:i];
        NSString *local=[NSString stringWithFormat:@"%@/.Cases/%@",docDir,fileName.lastPathComponent];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
            [videosToDownload removeObjectAtIndex:i];
        }
    }

    NSMutableArray *tmpPDF=pdfToDownload;
    for (int i=0; i<tmpPDF.count; i++){
        NSString *fileName = [tmpPDF objectAtIndex:i];
        NSString *local=[NSString stringWithFormat:@"%@/.PDF/%@",docDir,fileName.lastPathComponent];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
            [pdfToDownload removeObjectAtIndex:i];
        }
    }
    
    
    [defaults setValue:[self authorsImageToDownload] forKeyPath:@"authorsImageArray"];
    [defaults setValue:[self imagesToDownload] forKeyPath:@"imagesArray"];
    [defaults setValue:[self videosToDownload] forKeyPath:@"videosArray"];
    [defaults setValue:[self pdfToDownload] forKeyPath:@"pdfArray"];
    [defaults setBool:[APP_DELEGATE bookmarkAll] forKey:@"bookmarkAll"];
    [defaults synchronize];
}


#pragma mark Other

-(NSString *) stringByStrippingHTML:(NSString *)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}


-(NSString *)timestampToDateString:(NSString *)timestamp
{
    //timestamp=[[[[timestamp componentsSeparatedByString:@"("] objectAtIndex:1] componentsSeparatedByString:@")"] objectAtIndex:0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    //NSDate*d=[NSDate dateWithTimeIntervalSince1970:([timestamp longLongValue] / 1000)];
    NSDate *d  = [dateFormat dateFromString:timestamp];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    
    return [dateFormat stringFromDate:d];
}


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}

//registering notificationa
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#if !TARGET_IPHONE_SIMULATOR
    
    //    NSLog(@"Did register for remote notifications: %@", devToken);
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    // Set the defaults to disabled unless we find otherwise...
    NSString *pushBadge = @"enabled";
    NSString *pushAlert = @"enabled";
    NSString *pushSound = @"enabled";
    
    // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
    // one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
    // single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
    // true if those two notifications are on.  This is why the code is written this way
    if(rntypes == UIRemoteNotificationTypeBadge){
        pushBadge = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeAlert){
        pushAlert = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeSound){
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceUuid;
    NSString *deviceName = dev.name;
    NSString *deviceModel = dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    if ([dev respondsToSelector:@selector(identifierForVendor)])
    {
        //        deviceUuid = dev.uniqueIdentifier;
        NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
        deviceUuid = [uuid UUIDString];
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id uuid = [defaults objectForKey:@"deviceUuid"];
        if (uuid)
            deviceUuid = (NSString *)uuid;
        else {
            deviceUuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
            [defaults setObject:deviceUuid forKey:@"deviceUuid"];
        }
    }
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *devToken = [[[[deviceToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString *requestData =[NSString stringWithFormat:@"{\"deviceID\":null,\"appname\":\"%@\",\"appversion\":\"%@\",\"deviceuid\":\"%@\",\"devicetoken\":\"%@\",\"devicename\":\"%@\",\"devicemodel\":\"%@\",\"deviceversion\":\"%@\",\"pushbadge\":true,\"pushalert\":true,\"pushsound\":true",appName,appVersion,deviceUuid,devToken,deviceName,deviceModel,deviceSystemVersion];
    
    [FNotificationManager setActiveNotificationa:@"1"];
    [FHelperRequest setDeviceData:requestData];
#endif
}



/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
#if !TARGET_IPHONE_SIMULATOR
    
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    
    notificationUrl = [userInfo objectForKey:@"url"];
    notificationType = [[userInfo objectForKey:@"notificationType"] intValue];
    
    [[FUpdateContent shared] updateContent:[self.window rootViewController]];
    
    if (application.applicationState == UIApplicationStateActive ) {
        NSLog(@"app is active");
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"New notification!" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"View", nil];
        [av setTag:100];
        [av show];
    }else
    {
        [FNotificationManager openNotification:notificationUrl ofType:notificationType];
    }
    
#endif
}

-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle{
    UIAlertView *alert;
    if([otherTitle isEqualToString:@""])
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:nil,nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:otherTitle,nil];
    [alert show];
}


-(void)sendFeedback:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:@[@"info@fotona.com"]];
        [mailViewController setSubject:@"Fotona iOS App Feedback"];
        [mailViewController setMessageBody:@"" isHTML:NO];
        
        
        if ([FCommon isIpad]) {
            [mailViewController.navigationBar setTintColor:[UIColor redColor]];
            [tabBar presentViewController:mailViewController animated:YES completion:nil];
        } else
        {
            [mailViewController.navigationBar setTintColor:[UIColor whiteColor]];
            FIFlowController *flow = [FIFlowController sharedInstance];
            [flow.tabControler presentViewController:mailViewController animated:YES completion:nil];
        }
        
    }else{
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Please setup email account" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Now",nil];
        [av setTag:10];
        [av show];
    }
    
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10) {
        if (buttonIndex==1) {
            NSString *recipients = @"mailto:?subject=";
            NSString *body = @"";
            
            NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }else if (alertView.tag==100)
    {
        if (buttonIndex==1) {
            [FNotificationManager openNotification:notificationUrl ofType:notificationType];
            notificationType = 0;
            notificationUrl = @"";
        }else{
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"pushType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}


-(NSString *)differenceBetweenDate:(NSDate *)startDate and:(NSDate *)endDate
{
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    NSInteger months = [components month];
    NSInteger days = [components day];
    
    
    return [NSString stringWithFormat:@"%lu,%lu",(long)months,(long)days];
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

-(void)setAppearance
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        
        [[UITabBar appearance] setTintColor:[UIColor redColor]];
        [[UINavigationBar appearanceWhenContainedIn:[QLPreviewController class], nil] setTintColor:[UIColor redColor]];
        [[UINavigationBar appearanceWhenContainedIn:[UIImagePickerController class], nil] setTintColor:[UIColor redColor]];    } else
    {
        
        [[UITabBar appearance] setTintColor:[UIColor redColor]];
        [[UINavigationBar appearanceWhenContainedIn:[QLPreviewController class], nil] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearanceWhenContainedIn:[MFMailComposeViewController class], nil] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearanceWhenContainedIn:[UIImagePickerController class], nil] setTintColor:[UIColor redColor]];
    }
}

-(void)rotatePopupSearchedNewsInView:(UIView *)view
{
    UIView *tmpNews=[view viewWithTag:1000];
    for (UIView *v in tmpNews.subviews) {
        if (v.tag==1001) {
            [v setCenter:CGPointMake(view.center.x, view.center.y)];
        }
    }
}

-(FNews *)getNewsByID:(NSString *)newsID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FNews *f=[[FNews alloc] init];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=1 and newsID=%@",newsID]];
    while([results next]) {
        f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        
    }
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return f;
}


-(FCase *)getCase:(NSString *)caseID
{
    FCase *f;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and caseID=%@ limit 1",caseID]];
    while([results next]) {
        f = [[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
    }
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([FCommon userPermission:[f userPermissions]]) {
        return f;
    }
    return nil;
}



- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self.window.visibleViewController isKindOfClass:[AVPlayerViewController class]] || [self.window.visibleViewController isKindOfClass:[FIFotonaViewController class]] || [self.window.visibleViewController isKindOfClass:[QLPreviewController class]] || [self.window.visibleViewController isKindOfClass:[FICasebookContainerViewController class]] || [self.window.visibleViewController isKindOfClass:[FICasebookContainerViewController class]] ||[self.window.visibleViewController isKindOfClass:[EBPhotoPagesController class]] || [self.window.visibleViewController isKindOfClass:[FICaseViewController class]] || [self.window.visibleViewController isKindOfClass:[FIPDFViewController class]] || [FCommon isIpad]) {
        if ( [self.window.visibleViewController isKindOfClass:[FICasebookContainerViewController class]]) {
            for (UIView *object in self.window.visibleViewController.childViewControllers ) {
                if([object isKindOfClass:[FICaseViewController class]])
                {
                    return UIInterfaceOrientationMaskAllButUpsideDown;
                }
            }
            return UIInterfaceOrientationMaskPortrait;
        } else if ( [self.window.visibleViewController isKindOfClass:[FIFotonaViewController class]]) {
            for (UIView *object in self.window.visibleViewController.childViewControllers ) {
                if([object isKindOfClass:[FIExternalLinkViewController class]] || [object isKindOfClass:[FIPDFViewController class]])
                {
                    return UIInterfaceOrientationMaskAllButUpsideDown;
                }
            }
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Google Analytics

- (void) prepareGA{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
   // gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release --- Uncomment if want to see logger of what GA is doing in console
}



@end

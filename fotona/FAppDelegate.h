//
//  FAppDelegate.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/13/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUser.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FUpdateContent.h"
#import "FEvent.h"
#import "FNews.h"
#import "FTabBarController.h"
#import "FSettingsViewController.h"
#import "FMainViewController.h"
//#import <GoogleAnalytics.h>
#import "FFavoriteViewController.h"

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>

#define APP_DELEGATE (FAppDelegate *)[[UIApplication sharedApplication] delegate]
#define langID  @"1"

#define globalAccessToken @"eyUpQ6JOcYaa86DNIDvv8ooxQHtuI6Cz0agTpOfjeZk3N7Ak0YkoaeJfXEGvZZcnQwnqPqktutfDGJjNz0J2j1qk8Bcgm6PUuuBY"
#define DB_PATH [NSString stringWithFormat:@"%@/Documents/.db/fotona.db",NSHomeDirectory()]
#define addPath @"http://razvoj.4egenus.com/fotona/"
#define docDir [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]

@interface FAppDelegate : UIResponder <UIApplicationDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) FTabBarController *tabBar;
@property (nonatomic,retain) FMainViewController_iPad *main_ipad;
@property (nonatomic,retain) FMainViewController *main;
@property (nonatomic,retain) FSettingsViewController *settingsController;
@property (nonatomic,retain) FFotonaViewController *fotonaController;
@property (nonatomic,retain) FFavoriteViewController *favoriteController;
@property (nonatomic,retain) FCasebookViewController *casebookController;
@property (nonatomic,retain) FUser *currentLogedInUser;
@property (nonatomic,retain) NSString *userFolderPath;


- (void)setAppearance;
- (NSString *) stringByStrippingHTML:(NSString *)s;
- (NSString *)timestampToDateString:(NSString *)timestamp;
- (NSString *)differenceBetweenDate:(NSDate *)startDate and:(NSDate *)endDate;
- (IBAction)sendFeedback:(id)sender;
- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;


@property (nonatomic,retain) NSMutableArray *authorsImageToDownload;
@property (nonatomic,retain) NSMutableArray *imagesToDownload;
@property (nonatomic,retain) NSMutableArray *videosToDownload;
@property (nonatomic,retain) NSMutableArray *pdfToDownload;
@property (assign) BOOL newNews;
@property (assign) int currentOrientation;// 0=portrait, 1=landscape
@property (assign) BOOL updateInProgress;
@property (nonatomic,retain) NSMutableArray *eventArray;
@property (nonatomic,retain) NSMutableArray *caseArray;
@property (nonatomic,retain) NSMutableArray *newsArray;
@property (nonatomic,retain) NSMutableArray *downloadManagerArray;
@property (nonatomic,retain) FEvent *eventTemp;
@property (nonatomic,retain) FNews *newsTemp;
@property (assign) BOOL openBook;
@property (assign) BOOL openCase;
@property (assign) BOOL bookmarkAll;
@property (assign) BOOL loginShown;
@property (nonatomic, retain) NSMutableArray *downloadList;
@property (nonatomic, retain) NSMutableArray *bookmarkingVideos;

@property (assign) BOOL DEVELOP;
@property (assign) BOOL closedNews;
@property (assign) BOOL closedEvents;



@property (nonatomic,retain) NSMutableDictionary *videoImages;

@property (assign) float bookmarkCountAll;
@property (assign) float bookmarkCountLeft;
@property (assign) float bookmarkSizeAll;
@property (assign) float bookmarkSizeLeft;

@property (assign) NSString* logText;
@property (assign) BOOL logingEnabled;

-(void)rotatePopupSearchedNewsInView:(UIView *)view;


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@property (assign) int indexToSelect;


@end

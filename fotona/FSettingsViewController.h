//
//  FSettingsViewController.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSettingsViewController : UIViewController <UISearchBarDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *logedAs;
    IBOutlet UIButton *feedbackBtn;
    IBOutlet UIButton *changePassBtn;
    NSString *imageName;
    IBOutlet UIButton *logoutBtn;

    //only wifi view
    IBOutlet UIView *wifiView;
    IBOutlet UISwitch *wifiSwitch;
    
    
    IBOutlet NSLayoutConstraint *tableviewHeight;
    IBOutlet NSLayoutConstraint *checkViewHeight;
    IBOutlet UIButton *btnBookmark;
    IBOutlet UIView *downloadView;
    
    IBOutlet UIView *checkView;
    IBOutlet UISwitch *notifSwitch;
}
@property (strong, nonatomic) UIPopoverController *popover;

@property (strong, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;

@property (strong, nonatomic) IBOutlet UITableView *categoryTable;

@property (nonatomic, retain) NSString *active;

@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (strong, nonatomic) IBOutlet UILabel *progressPercentige;
@property (strong, nonatomic) IBOutlet UIButton *unbookmarAll;

-(IBAction)logout:(id)sender;
-(IBAction)changePassword:(id)sender;

- (IBAction)changeWifiCheck:(id)sender;
- (IBAction)changeNotifiCheck:(id)sender;

- (IBAction)bookmarkSelected:(id)sender;
- (IBAction)unbookmarkAll:(id)sender;

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void) refreshStatusBar;
+(void)sendDeviceData;
@end

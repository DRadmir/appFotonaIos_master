//
//  FISettingsViewController.h
//  fotona
//
//  Created by Janos on 25/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FISettingsViewController : UIViewController <UISearchBarDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
//UIImagePickerControllerDelegate,
{
    IBOutlet UILabel *logedAs;
    IBOutlet UIButton *changePassBtn;
    IBOutlet UIButton *logoutBtn;
    
    //only wifi view
    IBOutlet UIView *wifiView;
    IBOutlet UISwitch *wifiSwitch;
    IBOutlet UISwitch *notifSwitch;
    
    IBOutlet UILabel *versionLabel;
    
    IBOutlet NSLayoutConstraint *tableviewHeight;
    IBOutlet UIButton *btnBookmark;
    IBOutlet UIView *downloadView;
    
    IBOutlet UIView *checkView;
}
@property (strong, nonatomic) UIPopoverController *popover;

@property (strong, nonatomic) IBOutlet UIScrollView *contentScroll;

@property (strong, nonatomic) IBOutlet UITableView *categoryTable;


@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (strong, nonatomic) IBOutlet UILabel *progressPercentige;
@property (strong, nonatomic) IBOutlet UIButton *unbookmarAll;

-(IBAction)logout:(id)sender;
-(IBAction)changePassword:(id)sender;

- (IBAction)changeWifiCheck:(id)sender;
- (IBAction)changeNotifCheck:(id)sender;

- (IBAction)bookmarkSelected:(id)sender;
- (IBAction)unbookmarkAll:(id)sender;

-(void) refreshStatusBar;


@end

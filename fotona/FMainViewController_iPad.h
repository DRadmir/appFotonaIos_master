//
//  FMainViewController.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/13/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCaseMenuViewController.h"
#import "FBookmarkMenuViewController.h"
#import "FFotonaMenuViewController.h"

@import Security;
@import SafariServices;


@interface FMainViewController_iPad : UIViewController <UIAlertViewDelegate,UITextFieldDelegate>
{
    IBOutlet UIButton *forgotPassBtn;
    IBOutlet UIButton *registerBtn;
    IBOutlet UIButton *existingBtn;
    IBOutlet UIView *loginView;
    IBOutlet UIView *forgotView;
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginGuestBtn;

@property (assign) int letToLogin;
@property (nonatomic, strong) FCaseMenuViewController *caseMenu;
@property (nonatomic, strong) FFotonaMenuViewController *fotonaMenu;
@property (nonatomic, strong) FBookmarkMenuViewController *bookMenu;

@property (nonatomic, strong) UINavigationController *caseMenuNav;
@property (nonatomic, strong) UINavigationController *bookMenuNav;

- (IBAction)login:(id)sender;
- (IBAction)guest:(id)sender;
- (IBAction)forgetPass:(id)sender;
- (IBAction)registerNewUser:(id)sender;
- (IBAction)existing:(id)sender;

-(void) showFeatured;
-(void) showLoginForm;

@end

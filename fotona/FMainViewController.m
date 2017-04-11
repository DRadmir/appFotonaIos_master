//
//  FMainViewController.m
//  fotona
//
//  Created by Janos on 15/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FMainViewController.h"
#import "FSetDefaults.h"
#import "FLogin.h"
#import "MBProgressHUD.h"
#import "DisclaimerViewController.h"
#import "FRegistrationViewController.h"
#import "FIFlowController.h"
#import "FITabbarController.h"

@interface FMainViewController ()

@end

@implementation FMainViewController

@synthesize viewUser;
@synthesize viewForgoten;

@synthesize btnForgoten;
@synthesize btnGuest;
@synthesize btnLogin;
@synthesize btnRegister;
@synthesize btnUser;

@synthesize textFieldPass;
@synthesize textFieldUser;

@synthesize scrollViewLogin;

FLogin * login;
int forgotenBottom = 0;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self.navigationController navigationBar] setHidden:YES];
    
    [FSetDefaults setDefaults];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textFieldUser setLeftViewMode:UITextFieldViewModeAlways];
    [textFieldUser setLeftView:spacerView];
    
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textFieldPass setLeftViewMode:UITextFieldViewModeAlways];
    [textFieldPass setLeftView:spacerView1];
    
    textFieldPass.delegate = self;
    textFieldUser.delegate = self;
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.mainControler = self;
//    
//    [textFieldUser setText:@"radovanovic"];
//    [textFieldPass setText:@"n3cuqaKU"];
}

-(void)viewWillAppear:(BOOL)animated{
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"] isEqualToString:@"guest"]) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]) {
            [textFieldUser setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]];
        }
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"autoLoginPassword"]) {
            [textFieldPass setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLoginPassword"]];
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    login =[[FLogin alloc] init];
    [login setDefaultParent:nil andiPhone:self];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"autoLoginEnabled"]) {
        [login autoLogin];
        
        
    }else
    {
        [self showLoginForm];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"pushType"]) {
            FUser *usr=[APP_DELEGATE currentLogedInUser];
            if (!usr) {
                FUser *guest=[[FUser alloc] init];
                [guest setUserType:@"0"];
                [guest setUsername:@"guest"];
                [APP_DELEGATE setCurrentLogedInUser:guest];
                usr=guest;
                [[NSUserDefaults standardUserDefaults] setValue:usr.username forKey:@"autoLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [login autoLogin];
            }
        }
    }
     [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
     [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pressedUser:(id)sender {
    if ( viewUser.isHidden) {
        [UIView animateWithDuration:0.5 animations:^{
            [viewForgoten setAlpha:1.0];
            [viewUser setAlpha:1.0];
            
            btnLogin.hidden = NO;
            textFieldUser.hidden = NO;
            textFieldPass.hidden = NO;
            viewUser.hidden = NO;
            viewForgoten.hidden = NO;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [viewForgoten setAlpha:0.0];
            [viewUser setAlpha:0.0];
        } completion:^(BOOL finished) {
            
            btnLogin.hidden = YES;
            textFieldUser.hidden = YES;
            textFieldPass.hidden = YES;
            viewUser.hidden = YES;
            viewForgoten.hidden = YES;
        }];
        
    }

}

-(void)showLoginForm
{
    [btnForgoten setHidden:NO];
    [btnRegister setHidden:NO];
    [btnGuest setHidden:NO];
    [viewForgoten setHidden:NO];
}



- (IBAction)pressedRegister:(id)sender
{
    FRegistrationViewController *registrationView = [[FRegistrationViewController alloc] init];
    registrationView.urlString = @"http://www.fotona.com/en/#registration";  //@"http://www.fotona.com/en/support/register/";
    registrationView.fromSettings = false;
    [[self  navigationController] pushViewController:registrationView animated:true];
}

- (IBAction)pressedForgoten:(id)sender
{
    FRegistrationViewController *registrationView = [[FRegistrationViewController alloc] init];
    registrationView.urlString = @"http://www.fotona.com/en/#lost-password"; //@"http://www.fotona.com/en/support/passreset/"
    registrationView.fromSettings = false;
    [[self  navigationController] pushViewController:registrationView animated:true];
}

#pragma mark - Logins

- (IBAction)pressedLogin:(id)sender
{
    [login login:sender];
}

- (IBAction)pressedGuest:(id)sender
{
    [login guest:sender];
}

#pragma mark - Featured

-(void)showFeatured
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [super viewDidLoad];
    
    NSString *usr = [FCommon getUser];
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"disclaimerShown"]];
    if(![usersarray containsObject:usr]){
        //show disclaimer
        DisclaimerViewController *disclaimer=[[DisclaimerViewController alloc] init];
        disclaimer.parentiPhone = self;
        [self.navigationController pushViewController:disclaimer animated:YES];
    } else
    {
        //[self prepareTabBarController];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FITabbarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
        
        [self.navigationController presentViewController:vc animated:true completion:nil];
    }
}

//adding tabs to tabcontroler
-(void)prepareTabBarController
{

}

//tracking keyboard
- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint viewOrigin = viewForgoten.frame.origin;
    CGFloat viewHeight = viewForgoten.frame.size.height;
    viewOrigin.y += viewHeight;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, viewOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, viewOrigin.y - visibleRect.size.height);
        
        [self.scrollViewLogin setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollViewLogin setContentOffset:CGPointZero animated:YES];
    
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // done button was pressed - dismiss keyboard
    [textField resignFirstResponder];
    return YES;
}


@end

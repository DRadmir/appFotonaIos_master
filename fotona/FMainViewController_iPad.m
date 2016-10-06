//
//  FMainViewController.m
//  Fotona
//
//  Created by Dejan Krstevski on 3/13/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FMainViewController_iPad.h"
#import "FAppDelegate.h"
#import "FFeaturedViewController_iPad.h"
#import "FBookmarkViewController.h"
#import "FBookmarkMenuViewController.h"
#import "FCasebookViewController.h"
#import "FCaseMenuViewController.h"
#import "FEventViewController.h"
#import "FFotonaViewController.h"
#import "FFotonaMenuViewController.h"
#import "FSettingsViewController.h"
#import "FUser.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "IIViewDeckController.h"
#import "DisclaimerViewController.h"
#import "FSetDefaults.h"
#import "FLogin.h"
#import "FRegistrationViewController.h"

@interface FMainViewController_iPad ()

@end

@implementation FMainViewController_iPad
@synthesize letToLogin;
@synthesize caseMenuNav;
@synthesize bookMenuNav;
@synthesize username;
@synthesize password;
@synthesize loginBtn;
@synthesize loginGuestBtn;

int logintype = -1;
FLogin * login;
UIButton *tmp;

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
    // Do any additional setup after loading the view from its nib.
    [[self.navigationController navigationBar] setHidden:YES];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [username setLeftViewMode:UITextFieldViewModeAlways];
    [username setLeftView:spacerView];
    
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [password setLeftViewMode:UITextFieldViewModeAlways];
    [password setLeftView:spacerView1];
    
    
    if (self.view.frame.size.width>900) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
    
    [FSetDefaults setDefaults];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE setLoginShown:true];
    if (self.view.frame.size.width>900) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
    
//    [username setText:@"radovanovic"];
//    [password setText:@"n3cuqaKU"];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    login =[[FLogin alloc] init];
    [login setDefaultParent:self andiPhone:nil];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]) {
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
}

-(void)showLoginForm
{
    [forgotPassBtn setHidden:NO];
    [registerBtn setHidden:NO];
    [loginGuestBtn setHidden:NO];
    [forgotView setHidden:NO];
}

-(void)login:(id)sender
{
    [login login:sender];
}


-(void)guest:(id)sender
{
    [login guest:sender];
}


-(void)forgetPass:(id)sender
{
    FRegistrationViewController *registrationView = [[FRegistrationViewController alloc] init];
    registrationView.urlString = @"http://www.fotona.com/en/support/passreset/";
    registrationView.fromSettings = false;
    [[self  navigationController] pushViewController:registrationView animated:true];

}

-(void)registerNewUser:(id)sender
{
    FRegistrationViewController *registrationView = [[FRegistrationViewController alloc] init];
    registrationView.urlString = @"http://www.fotona.com/en/support/register/";
    registrationView.fromSettings = false;
    [[self  navigationController] pushViewController:registrationView animated:true];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        [APP_DELEGATE setCurrentOrientation:1];
        if (!loginView.isHidden) {
            [scrollView setContentOffset:CGPointMake(0, 50) animated:YES];
        }
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

//shows form for loging exsiting user
- (IBAction)existing:(id)sender
{
    if (loginView.isHidden) {
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
        {
            [scrollView setContentOffset:CGPointMake(0, 50) animated:YES];
        }
        [UIView animateWithDuration:0.5 animations:^{
            [forgotView setAlpha:1.0];
            [loginView setAlpha:1.0];
            loginBtn.hidden = NO;
            username.hidden = NO;
            password.hidden = NO;
            loginView.hidden = NO;
            forgotView.hidden = NO;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [forgotView setAlpha:0.0];
            [loginView setAlpha:0.0];
        } completion:^(BOOL finished)
        {
            loginBtn.hidden = YES;
            username.hidden = YES;
            password.hidden = YES;
            loginView.hidden = YES;
            forgotView.hidden = YES;
        }];
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskPortrait;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [scrollView setContentOffset:CGPointMake(0, 352) animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [scrollView setContentOffset:CGPointMake(0, 50) animated:YES];
    }
}



-(void)showFeatured
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [super viewDidLoad];
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;
    if (usr == nil) {
        usr =@"guest";
    }
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"disclaimerShown"]];
    if(![usersarray containsObject:usr]){
        
        DisclaimerViewController *disclaimer=[[DisclaimerViewController alloc] init];
        disclaimer.parentiPad = self;
        [self.navigationController pushViewController:disclaimer animated:YES];
    } else
    {
        [self prepareTabBarController];
        [self.navigationController pushViewController:[APP_DELEGATE tabBar] animated:YES];
    }

}

//adding tabs to tabcontroler
-(void)prepareTabBarController
{
    //features tab
    FFeaturedViewController_iPad *featuredVC=[[FFeaturedViewController_iPad alloc] init];
    
    //casebook tab
    FCasebookViewController *casebookVC=[APP_DELEGATE casebookController];
    UINavigationController *caseNav=[[UINavigationController alloc] initWithRootViewController:casebookVC];
    [caseNav.navigationBar setHidden:YES];
    self.caseMenu=[[FCaseMenuViewController alloc] init];
    [self.caseMenu setParent:casebookVC];
    caseMenuNav=[[UINavigationController alloc] initWithRootViewController:self.caseMenu];
    [[caseMenuNav navigationBar] setTintColor:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
    IIViewDeckController *caseDeckController=[[IIViewDeckController alloc] initWithCenterViewController:caseNav leftViewController:caseMenuNav];
    [caseDeckController setLeftSize:[APP_DELEGATE window].frame.size.width-320];
    
    //event tab
    FEventViewController *eventVC=[[FEventViewController alloc] init];
    UINavigationController *navigationForEvent=[[UINavigationController alloc] initWithRootViewController:eventVC];
    [navigationForEvent.navigationBar setHidden:YES];
    [[navigationForEvent navigationBar] setTintColor:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
    
    //bookmark tab
    FBookmarkViewController *bookmarkVC=[[FBookmarkViewController alloc] init];
    self.bookMenu=[[FBookmarkMenuViewController alloc] init];
    bookMenuNav=[[UINavigationController alloc] initWithRootViewController:self.bookMenu];
    [self.bookMenu setParent:bookmarkVC];
    [[bookMenuNav navigationBar] setTintColor:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
    IIViewDeckController *bookDeck=[[IIViewDeckController alloc] initWithCenterViewController:bookmarkVC leftViewController:bookMenuNav];
    [bookDeck setLeftSize:[APP_DELEGATE window].frame.size.width-320];
    
    
    
    
    //fotona tab
    FFotonaViewController *fotonaVC=[APP_DELEGATE fotonaController];
    UINavigationController *fotonaNav=[[UINavigationController alloc] initWithRootViewController:fotonaVC];
    [fotonaNav.navigationBar setHidden:YES];
    self.fotonaMenu=[[FFotonaMenuViewController alloc] init];
    [self.fotonaMenu setParent:fotonaVC];
    UINavigationController *fotonaMenuNav=[[UINavigationController alloc] initWithRootViewController:self.fotonaMenu];
    [[fotonaMenuNav navigationBar] setTintColor:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
    IIViewDeckController *fotonaDeckController=[[IIViewDeckController alloc] initWithCenterViewController:fotonaNav leftViewController:fotonaMenuNav];
    [fotonaDeckController setLeftSize:[APP_DELEGATE window].frame.size.width-320];
    
    //tabbar
    [[APP_DELEGATE tabBar] setViewControllers:@[featuredVC,eventVC,fotonaDeckController,caseDeckController,bookDeck]];
    [[[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:1] tabBarItem] setImage:[UIImage imageNamed:@"events.png"]];
    [[[[[APP_DELEGATE tabBar]viewControllers] objectAtIndex:2] tabBarItem] setImage:[UIImage imageNamed:@"fotona_red.png"]];
    [[[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:3] tabBarItem] setImage:[UIImage imageNamed:@"casebook_grey.png"]];
    [[[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:4] tabBarItem] setImage:[UIImage imageNamed:@"bookmarks.png"]];
    [[APP_DELEGATE tabBar] setSelectedIndex:[APP_DELEGATE indexToSelect]];
    
}


@end

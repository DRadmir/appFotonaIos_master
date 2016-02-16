//
//  FMainViewController.h
//  fotona
//
//  Created by Janos on 15/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMainViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnGuest;
@property (strong, nonatomic) IBOutlet UIButton *btnUser;

@property (strong, nonatomic) IBOutlet UITextField *textFieldUser;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPass;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

@property (strong, nonatomic) IBOutlet UIView *viewUser;
@property (strong, nonatomic) IBOutlet UIView *viewForgoten;

@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnForgoten;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewLogin;

- (IBAction)pressedGuest:(id)sender;
- (IBAction)pressedUser:(id)sender;
- (IBAction)pressedLogin:(id)sender;
- (IBAction)pressedRegister:(id)sender;
- (IBAction)pressedForgoten:(id)sender;

-(void) showFeatured;
-(void) showLoginForm;

@end

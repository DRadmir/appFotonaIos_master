//
//  FLogin.h
//  fotona
//
//  Created by Janos on 16/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FMainViewController_iPad.h"
#import "FMainViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "UpdateDelegate.h"

@interface FLogin : NSObject <UpdateDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) FMainViewController_iPad *parentiPad;
@property (nonatomic, retain) FMainViewController *parentiPhone;
@property (nonatomic, retain) UIViewController *parent;
@property (assign) int logintype;
@property (assign) int letToLogin;

-(void) setDefaultParent:(FMainViewController_iPad * )piPad andiPhone:(FMainViewController *)piPhone;
-(void) autoLogin;
-(void) guest:(id)sender;
-(void) login:(id)sender;
@end

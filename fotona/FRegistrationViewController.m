//
//  FRegistrationViewController.m
//  fotona
//
//  Created by Janos on 15/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FRegistrationViewController.h"
#import "UIView+Border.h"
#import "FAppDelegate.h"

@interface FRegistrationViewController ()

@end


@implementation FRegistrationViewController

@synthesize urlString;
@synthesize fromSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    btnClose.layer.cornerRadius = 3;
    btnClose.layer.borderWidth = 1;
    btnClose.layer.borderColor = btnClose.tintColor.CGColor;
    
    NSURL *url=[NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeRegistration:(id)sender {
    if (fromSettings) {
        [[self presentingViewController] dismissViewControllerAnimated:false completion:nil];
    } else{
        if ([self navigationController] != nil) {
            [[self navigationController] popViewControllerAnimated:true];
        } else {
            [self.view removeFromSuperview];
        }
        
    }
 
    
}

@end

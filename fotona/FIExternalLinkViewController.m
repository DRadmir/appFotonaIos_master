//
//  FExternalLinkViewController.m
//  fotona
//
//  Created by Janos on 20/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIExternalLinkViewController.h"
#import "MBProgressHUD.h"

@interface FIExternalLinkViewController ()

@end

@implementation FIExternalLinkViewController

@synthesize urlString;
@synthesize previousUrl;
@synthesize externalWebView;
@synthesize enabled;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.changePass) { //add cancel to close menu if it is change pass
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelMenu:)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];

    }
    previousUrl = @"";
    
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    [externalWebView setDelegate:self];
    if (![previousUrl isEqualToString: urlString]) {
        [self reloadView];
    }
    previousUrl = urlString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)reloadView
{
    if([APP_DELEGATE connectedToInternet]){
        NSURL *url=[NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [externalWebView loadRequest:requestObj];
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

   
}


#pragma mark WebView
-(void)webViewDidStartLoad:(UIWebView *)webView{
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
    [webView addSubview:hud];
    hud.labelText = NSLocalizedString(@"LOADINGWEBPAGE", nil);
    [hud show:YES];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Page: \n%@", urlString);
    NSLog(@"Error: %@ %@", error, [error userInfo]);
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"LOADINGWEBPAGEERROR", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
    }

#pragma mark - Close Menu

- (IBAction)cancelMenu:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}




@end

//
//  FIContentViewController.m
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIContentViewController.h"
#import "HelperString.h"

@interface FIContentViewController ()

@end

@implementation FIContentViewController

@synthesize titleContent;
@synthesize descriptionContent;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reloadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadView
{
    self.lblTitleContent.text = titleContent;
    NSString *htmlString=[HelperString toHtmlIphone:descriptionContent];
    [[self webViewContent] loadHTMLString:htmlString baseURL:nil];
}

@end

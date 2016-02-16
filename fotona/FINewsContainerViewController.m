//
//  FINewsContainerViewController.m
//  fotona
//
//  Created by Janos on 29/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FINewsContainerViewController.h"
#import "FINewsViewController.h"
#import "FIContentViewController.h"

@interface FINewsContainerViewController ()

@end

@implementation FINewsContainerViewController

@synthesize newsContainerView;
@synthesize showAbout;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (showAbout) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FIContentViewController *contentView = [sb instantiateViewControllerWithIdentifier:@"contentViewController"];
        [contentView.view setFrame:newsContainerView.bounds];
        [newsContainerView addSubview:contentView.view];
        [self addChildViewController:contentView];
        [contentView didMoveToParentViewController:self];
        contentView.titleContent = @"About fotona";
        contentView.descriptionContent = NSLocalizedString(@"ABOUTLONG", nil);
    } else{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FINewsViewController *newsView = [sb instantiateViewControllerWithIdentifier:@"newsViewController"];
        [newsView.view setFrame:newsContainerView.bounds];
        [newsContainerView addSubview:newsView.view];
        [self addChildViewController:newsView];
        [newsView didMoveToParentViewController:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

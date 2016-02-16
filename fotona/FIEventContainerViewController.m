//
//  FIEventContainerViewController.m
//  fotona
//
//  Created by Janos on 29/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIEventContainerViewController.h"
#import "FIEventSingleViewController.h"

@interface FIEventContainerViewController ()

@end

@implementation FIEventContainerViewController

@synthesize eventToContain;
@synthesize eventContainerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    FIEventSingleViewController *eventView = [sb instantiateViewControllerWithIdentifier:@"eventViewController"];
    eventView.eventToOpen = eventToContain;
    [eventView.view setFrame:eventContainerView.bounds];
    [eventContainerView addSubview:eventView.view];
    [self addChildViewController:eventView];
    [eventView didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


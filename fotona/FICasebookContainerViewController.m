//
//  FICasebookViewController.m
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FICasebookContainerViewController.h"
#import "FIFlowController.h"
#import "FIContentViewController.h"
#import "FICaseViewController.h"
#import "FCase.h"


@interface FICasebookContainerViewController ()
{
    UINavigationController *menu;
    UIStoryboard *sb;
    FIContentViewController *disclaimerView;
    FICaseViewController *caseView;
    UIViewController *openedView;
    FCase *lastCase;

}

@end

@implementation FICasebookContainerViewController

@synthesize caseToOpen;
@synthesize caseContainer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(showMenu:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    menu = [sb instantiateViewControllerWithIdentifier:@"caseMenuNavigation"];
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.caseTab == nil)
    {
        flow.caseTab = self;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.caseFlow != nil)
    {
        caseToOpen = flow.caseFlow;
        flow.caseFlow = nil;
        [self openCase];
    }
    
    if (flow.showMenu)
    {
        flow.showMenu = false;
        [self showMenu:self];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Open menu

- (IBAction)showMenu:(id)sender
{
    [self presentViewController:menu animated:true completion:nil];
}

#pragma mark - Open Disclaimer

- (void) openDisclaimer
{
    if (disclaimerView == nil) {
        disclaimerView = [sb instantiateViewControllerWithIdentifier:@"contentViewController"];
    }
    
    disclaimerView.titleContent = @"Disclaimer";
    disclaimerView.descriptionContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"];
    
    if (openedView != disclaimerView)
    {
        if (openedView != nil) {
            [openedView willMoveToParentViewController:nil];
            [openedView.view removeFromSuperview];
            [openedView removeFromParentViewController];
            
        }
        [self openViewInContainer:disclaimerView];
        openedView = disclaimerView;
        lastCase = nil;
    }
    
}

- (void)openViewInContainer: (UIViewController *) viewToOpen
{
    [viewToOpen.view setFrame:caseContainer.bounds];
    [caseContainer addSubview:viewToOpen.view];
    [self addChildViewController:viewToOpen];
    [viewToOpen didMoveToParentViewController:self];
}

#pragma mark - Open Case

-(void)openCase
{
    if (lastCase.caseID != caseToOpen.caseID)
    {
        if (caseView == nil) {
            caseView = [sb instantiateViewControllerWithIdentifier:@"caseView"];
        }
        caseView.caseToOpen = caseToOpen;
        caseView.parent = self;
        caseView.canBookmark = true; //true if opened in casebooktab
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
        [self openViewInContainer:caseView];
        openedView = caseView;
        lastCase = caseToOpen;
    }
}

-(void)clearViews
{
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
        
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.caseMenu != nil)
        {
            [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
        }
        
    }
    lastCase = nil;
    
    [self showMenu:self];
}




@end

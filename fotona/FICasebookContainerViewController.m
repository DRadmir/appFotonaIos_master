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
#import "UIWindow+Fotona.h"


@interface FICasebookContainerViewController ()
{
    UINavigationController *menu;
    FICasebookMenuViewController *subm;
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
    subm = [sb instantiateViewControllerWithIdentifier:@"caseMenuViewController"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.caseTab = self;
    if (flow.caseFlow != nil)
    {
        //[self clearViews];
        caseToOpen = flow.caseFlow;
        [self openCase];
    }
    
    NSString *usr = [FCommon getUser];
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"casebookHelper"]];
    
    if (flow.showMenu && flow.caseFlow == nil && ([usersarray containsObject:usr] || !caseToOpen))
    {
        flow.showMenu = false;
        [self showMenu:self];
    }
    flow.caseFlow = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Open menu

- (IBAction)showMenu:(id)sender
{
   // [self presentViewController:menu animated:true completion:nil];
    FIFlowController *flow = [FIFlowController sharedInstance];
    
    if (flow.caseMenuArray.count > 0) {
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        for (FICasebookMenuViewController *m in flow.caseMenuArray) {
            [controllers addObject:m];
        }
        [self.navigationController setViewControllers:controllers animated:YES];
    } else
    {
        [flow.caseMenuArray addObject:subm];
        [self.navigationController pushViewController:subm animated:true];
    }
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
        caseView.favoriteParent = nil;
        caseView.canBookmark = true; 
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
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
        openedView = nil;
    }
    if (flow.caseMenu != nil)
    {
        [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
        [flow.caseMenuArray removeAllObjects];
    }
    
    lastCase = nil;
    if (flow.caseMenuArray.count > 1) {
        [flow.caseMenuArray removeAllObjects];
    }

    if (![self.navigationController.visibleViewController isKindOfClass:[FICasebookMenuViewController class]]) {
        [self showMenu:self];
    }
   
}




@end

//
//  FITabbarController.m
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FITabbarController.h"
#import "UIColor+Hex.h"
#import "FIFlowController.h"
#import "UIWindow+Fotona.h"

@interface FITabbarController ()<UITabBarControllerDelegate>

@end

@implementation FITabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegate:self];
    [[self tabBar] setTintColor:[UIColor colorFromHex:FOTONARED]];
    [[self tabBar] setTranslucent:NO];
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.tabControler = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"openFotonaTab"]){
        self.selectedIndex = 2;
        [[NSUserDefaults standardUserDefaults] setBool: false forKey:@"openFotonaTab"];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"openCaseTab"]){
        self.selectedIndex = 3;
        [[NSUserDefaults standardUserDefaults] setBool: false forKey:@"openCaseTab"];
    }
    
}



-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    int t = [tabBar.items indexOfObject:item];
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (t == flow.lastIndex) {
        switch (t) {
            case 2:
                [[flow fotonaTab] clearViews];
               
                break;
            case 3:
                [[flow caseTab] clearViews];
                break;
            case 4:
                [[flow favoriteTab] clearViews];
                break;
                
            default:
                break;
        }
    } else
    {
        if((t==2)||(t==3)||(t==4))
        {
            flow.showMenu = true;
        }
    }
    flow.lastIndex = t;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return viewController != tabBarController.selectedViewController;
}

-(void)removeViews
{
    [self dismissViewControllerAnimated:true completion:nil];
}
@end

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

@interface FITabbarController ()

@end

@implementation FITabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tabBar] setTintColor:[UIColor colorFromHex:@"ED1C24"]];
    [[self tabBar] setTranslucent:NO];
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.tabControler = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                [[flow bookmarkTab] clearViews];
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


-(void)removeViews
{
    [self dismissViewControllerAnimated:true completion:nil];
}

@end

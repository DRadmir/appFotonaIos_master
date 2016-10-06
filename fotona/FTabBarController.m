//
//  FTabBarController.m
//  fotona
//
//  Created by Janos on 15/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FTabBarController.h"

@interface FTabBarController (){
    int last;
}

@end

@implementation FTabBarController


- (id) init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    last = -1;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    switch (tabBarController.selectedIndex) {
        case 0:
            if (last == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseOnTabNews" object:self];
            }
            last=0;
            break;
            
        case 1:
            if (last == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseOnTabEvents" object:self];
            }
            last=1;
            break;
        case 2:
            if (last == 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseOnTabFotona" object:self];
            }
            last=2;
            break;
        case 3:
            if (last == 3) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseOnTabCasebook" object:self];
            }
            //[APP_DELEGATE setOpenCase:YES];
            last=3;
            break;
        default:
            if (last == 4) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseOnTabBookmarks" object:self];
            }
           // [APP_DELEGATE setOpenBook:YES];
            
            last=4;
            break;
    }
}

-(void)setLast:(int)index{
last=index;
}

-(int)getLast{
    return last;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

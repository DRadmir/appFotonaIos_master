//
//  FTabBarController.h
//  fotona
//
//  Created by Janos on 15/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTabBarController : UITabBarController  <UITabBarControllerDelegate>

-(void)setLast:(int)index;
-(int)getLast;

@end

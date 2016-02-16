//
//  FIBaseView.h
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FISearchViewController.h"

@interface FIBaseView : UIViewController

@property (strong, nonatomic) FISearchViewController *searchBar;

-(void) toggleSearchBar;

@end

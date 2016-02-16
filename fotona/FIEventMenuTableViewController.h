//
//  FIEventMenuTableViewController.h
//  fotona
//
//  Created by Janos on 30/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIEventViewController.h"

@interface FIEventMenuTableViewController : UIViewController <UITabBarDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIEventViewController *parent;
@property (strong, nonatomic) IBOutlet UITableView *eventMenuTableView;

@end

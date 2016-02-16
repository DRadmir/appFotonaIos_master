//
//  FIOptionsViewController.h
//  fotona
//
//  Created by Janos on 25/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *menuIcons;
@property (nonatomic, retain) NSArray *menuTitles;


@property (strong, nonatomic) IBOutlet UITableView *optionsTableView;
@end

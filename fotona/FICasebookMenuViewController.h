//
//  FICasebookMenuViewController.h
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICasebookContainerViewController.h"

@interface FICasebookMenuViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *menuIcons;
@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic, retain) NSString *previousIcon;
@property (nonatomic, retain) NSString *previousCategory;
@property (nonatomic, retain) NSString *previousCategoryID;
@property (strong, nonatomic) FICasebookContainerViewController *parent;
@property (strong, nonatomic) IBOutlet UITableView *caseMenuTableView;
@property (nonatomic) int type;

@end

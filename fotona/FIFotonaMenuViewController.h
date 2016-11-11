//
//  FIFotonaMenuViewController.h
//  fotona
//
//  Created by Janos on 18/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIFotonaViewController.h"
#import "Bubble.h"

@interface FIFotonaMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
}

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

@property (nonatomic, retain) NSString *previousIcon;
@property (nonatomic, retain) NSString *previousCategory;
@property (nonatomic, retain) NSString *previousCategoryID;
@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic, retain) NSMutableArray *menuIcons;

@property (nonatomic,retain) NSMutableArray *bookmarkPDF;

@property (strong, nonatomic) FIFotonaViewController *parent;

- (IBAction)closeMenu:(id)sender;

@end

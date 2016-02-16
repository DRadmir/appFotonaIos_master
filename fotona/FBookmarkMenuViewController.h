//
//  FCasesMenuViewController.h
//  fotona
//
//  Created by Dejan Krstevski on 4/18/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBookmarkViewController.h"

@interface FBookmarkMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UILabel *menuTitle;
    IBOutlet UITableView *menuTable;
    IBOutlet UIView *menuHeader;
    IBOutlet UIButton *back;

}

@property (nonatomic, retain) NSString *selectedIcon;


@property (nonatomic,retain) NSMutableArray *menuItems;
@property (nonatomic,retain) NSMutableArray *casesInMenu;
@property (nonatomic,retain) NSMutableArray *menuTitles;
@property (nonatomic,retain) NSMutableArray *menuIcons;
@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic, retain) NSMutableArray *allCasesInMenu;

@property (strong, nonatomic) FBookmarkViewController *parent;


-(IBAction)backBtn:(id)sender;

-(void) resetViewAnime:(BOOL) anime;



@end

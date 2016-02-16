//
//  FFotonaMenuViewController.h
//  fotona
//
//  Created by Dejan Krstevski on 4/17/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFotonaViewController.h"

@interface FFotonaMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    IBOutlet UITableView *table;
    IBOutlet UILabel *menuTitle;
    IBOutlet UIView *menuHeader;
    IBOutlet UIButton *back;
    
}
@property (strong, nonatomic) FFotonaViewController *parent;

@property (nonatomic,retain) NSString *selectedIcon;
@property (nonatomic, retain) NSString *lastSelectedCategory;

@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic,retain) NSMutableArray *menuItems;
@property (nonatomic,retain) NSMutableArray *menuTitles;
@property (nonatomic,retain) NSMutableArray *menuIcons;
@property (nonatomic,retain) NSMutableArray *bookmarkPDF;

- (void) refreshPDF:(NSString *)link;


-(void) resetViewAnime:(BOOL) anime;
@end

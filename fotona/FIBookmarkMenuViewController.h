//
//  FIBookmarkMenuViewController.h
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBookmarkViewController.h"

@interface FIBookmarkMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (strong, nonatomic) NSString* titleMenu;
@property (nonatomic) int category;
@property (nonatomic) int documentType;
@property (nonatomic) int subDocumentType;

@property (nonatomic,retain) NSMutableArray *menuTitles;
@property (nonatomic,retain) NSMutableArray *menuIcons;
@property (nonatomic,retain) NSMutableArray *categories;

@property (strong, nonatomic) FIBookmarkViewController *parent;

@end

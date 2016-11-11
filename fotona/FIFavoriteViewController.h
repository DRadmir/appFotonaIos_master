//
//  FIFavoriteViewController.h
//  fotona
//
//  Created by Janos on 07/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"

@interface FIFavoriteViewController : FIBaseView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *imgFotona;
@property (strong, nonatomic) IBOutlet UITableView *favoriteTableView;

-(void)deleteRowAtIndex:(NSIndexPath *) index;
-(void) refreshCellWithItemID:(NSString *)itemID andItemType:(NSString *) itemType;
@end

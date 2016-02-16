//
//  FEventViewCell.h
//  fotona
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIEventViewController.h"

@interface FEventViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UIImageView *dotImg;

+ (NSString *)reuseIdentifier;

+ (FEventViewCell *) fillCell:(NSIndexPath *) indexPath fromArray:(NSMutableArray *)events andCategory:(int) ci andOwner:(FIEventViewController *)owner;

@end

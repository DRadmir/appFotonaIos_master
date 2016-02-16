//
//  FIEventTableViewCell.h
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIEventTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageDot;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

+(FIEventTableViewCell *)fillCell:(NSIndexPath *)indexPath fromArray:(NSArray *)events andCategory:(int) ci andTableView:(UITableView *)tableView;

@end

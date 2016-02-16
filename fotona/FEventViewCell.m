//
//  FEventViewCell.m
//  fotona
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FEventViewCell.h"
#import "FEvent.h"
#import "HelperDate.h"
#import "FIEventViewController.h"

@implementation FEventViewCell

@synthesize  title;
@synthesize date;
@synthesize place;
@synthesize dotImg;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)reuseIdentifier {
    return @"FEventViewCellIdentifier";
}

+(FEventViewCell *)fillCell:(NSIndexPath *)indexPath fromArray:(NSMutableArray *)events andCategory:(int) ci andOwner:(FIEventViewController *)owner
{
    FEventViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FEventViewCell" owner:owner options:nil] objectAtIndex:0];
    NSString * img =@"";
    if (ci==0) {
        img = [[events objectAtIndex:indexPath.row] getDot];
    } else{
        img = [[events objectAtIndex:indexPath.row] getDot:ci];
    }
    [cell.dotImg setImage:[UIImage imageNamed:img]];
    cell.title.text = [[events objectAtIndex:indexPath.row] title];
    
    cell.date.text = [[HelperDate formatedDate:[[events objectAtIndex:indexPath.row] eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[[events objectAtIndex:indexPath.row] eventdateTo]]]];
    
    cell.place.text = [[events objectAtIndex:indexPath.row] eventplace];
    return cell;

}

@end

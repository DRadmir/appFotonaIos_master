//
//  FIEventTableViewCell.m
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIEventTableViewCell.h"
#import "FIEventViewController.h"
#import "FEvent.h"
#import "HelperDate.h"

@implementation FIEventTableViewCell

@synthesize  imageDot;
@synthesize lblTitle;
@synthesize lblDate;
@synthesize lblLocation;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(FIEventTableViewCell *)fillCell:(NSIndexPath *)indexPath fromArray:(NSArray *)events andCategory:(int) ci andTableView:(UITableView *)tableView
{
    FIEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventsTabelViewCell"];//[[[NSBundle mainBundle] loadNibNamed:@"FEventViewCell" owner:owner options:nil] objectAtIndex:0];
    NSString * img =@"";
    if (ci==0) {
        img = [[events objectAtIndex:indexPath.row] getDot];
    } else{
        img = [[events objectAtIndex:indexPath.row] getDot:ci];
    }
    [cell.imageDot setImage:[UIImage imageNamed:img]];
    cell.lblTitle.text = [[[events objectAtIndex:indexPath.row] title] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    cell.lblDate.text = [[HelperDate formatedDate:[[events objectAtIndex:indexPath.row] eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[[events objectAtIndex:indexPath.row] eventdateTo]]]];
    
    cell.lblLocation.text = [[events objectAtIndex:indexPath.row] eventplace];
    return cell;
    
}

@end

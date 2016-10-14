//
//  FFavoriteCaseTableViewCell.m
//  fotona
//
//  Created by Janos on 10/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FFavoriteCaseTableViewCell.h"
#import "FDB.h"

@implementation FFavoriteCaseTableViewCell
@synthesize caseToShow;
@synthesize item;
@synthesize parentIphone;
@synthesize index;
@synthesize enabled;
@synthesize cellView;

- (void)awakeFromNib {
    [super awakeFromNib];
    cellView = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:0];
    [[self contentView] addSubview: cellView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) showCase:(FCase *)fcase{
    enabled = true;
    [cellView setItem:item];
    [cellView setIndex:index];
    [cellView setParentIphone:parentIphone];
    [cellView showCase:fcase];
   }

@end

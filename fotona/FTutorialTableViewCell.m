//
//  FTutorialTableViewCell.m
//  fotona
//
//  Created by Ares on 05/12/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FTutorialTableViewCell.h"

@implementation FTutorialTableViewCell

@synthesize lblTutorial;
@synthesize imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

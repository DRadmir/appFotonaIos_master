//
//  FIFeaturedNewsTableViewCell.m
//  fotona
//
//  Created by Janos on 04/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIFeaturedNewsTableViewCell.h"
#import "HelperDate.h"

@implementation FIFeaturedNewsTableViewCell

@synthesize contentView;
@synthesize topViewContentView;
@synthesize enabled;

//TODO : zbrisat xib file za ta class
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)fillCell
{
    if ([self.restorationIdentifier isEqualToString:@"FIAboutNewsTableViewCell"] )
    {
        self.lblAbout.text = NSLocalizedString(@"ABOUTSHORT", nil);
    }else
    {
        self.lblTitleNewsCell.text = self.news.title;
        self.lblDateNewsCell.text = [HelperDate formatedDate:self.news.nDate];
        [self.imgViewNewsCell setContentMode:UIViewContentModeScaleAspectFill];
        [self.imgViewNewsCell setClipsToBounds:true];
        if (self.related)
        {
            self.signNewNewsCell.hidden = true;
            self.imgViewNewsCell.image =[self.news headerImage];
        } else
        {
            self.signNewNewsCell.hidden = self.news.isReaded;
            self.imgViewNewsCell.image =[[self.news images] objectAtIndex:0];
        }
    }
    [self setUserInteractionEnabled:enabled];
}

@end

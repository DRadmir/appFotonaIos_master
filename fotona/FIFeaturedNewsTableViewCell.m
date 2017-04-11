//
//  FIFeaturedNewsTableViewCell.m
//  fotona
//
//  Created by Janos on 04/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIFeaturedNewsTableViewCell.h"
#import "HelperDate.h"
#import "FDB.h"

@implementation FIFeaturedNewsTableViewCell

@synthesize contentView;
@synthesize topViewContentView;
@synthesize enabled;

@synthesize index;
@synthesize tableView;

//TODO : zbrisat xib file za ta class
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)fillCell
{
    if ([self.restorationIdentifier isEqualToString:@""] || [self.restorationIdentifier isEqualToString:@"FIAboutNewsTableViewCell"])
    {
        self.lblAbout.text = NSLocalizedString(@"ABOUTSHORT", nil);
    }else
    {
        [self setUserInteractionEnabled:NO];
        if ([[[self news] rest] isEqualToString:@"1"] && [ConnectionHelper connectedToInternet]) {
            self.lblTitleNewsCell.text = @" ";
            self.lblDateNewsCell.text = @" ";
            [self.lblTitleNewsCell setBackgroundColor:[UIColor lightGrayColor]];
            [self.lblDateNewsCell setBackgroundColor:[UIColor lightGrayColor]];
            
                        dispatch_queue_t queue = dispatch_queue_create("com.4egenus.fotona", NULL);
                        dispatch_async(queue, ^{
                            self.news = [[FNews getImages:[[NSMutableArray alloc] initWithObjects:[self news], nil] fromStart:0 forNumber:1] objectAtIndex:0];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
                            });
                        });


        } else {
            [self setUserInteractionEnabled:YES];
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
    }
}

@end

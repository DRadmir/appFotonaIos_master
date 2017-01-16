//
//  NewsViewCell.m
//  fotona
//
//  Created by Janus! on 25/02/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "NewsViewCell.h"
#import "FCollectionViewCell.h"
#import "HelperDate.h"

@implementation NewsViewCell

@synthesize newsView;
@synthesize newsDate;
@synthesize newsImage;
@synthesize newsNew;
@synthesize newsTitle;
@synthesize news;

- (void)awakeFromNib {
    // Initialization code
}


-(void)fillCell
{
    
    
    if ([self.restorationIdentifier isEqualToString:@""])
    {
        self.lblAbout.text = NSLocalizedString(@"ABOUTSHORT", nil);
    }else
    {
        
        [self.newsTitle setBackgroundColor:[UIColor clearColor]];
        [self.newsDate setBackgroundColor:[UIColor clearColor]];
        
        [self setUserInteractionEnabled:NO];
        if ([[[self news] rest] isEqualToString:@"1"] && [ConnectionHelper connectedToInternet]) {
            self.newsTitle.text = @" ";
            self.newsDate.text = @" ";
            [self.newsTitle setBackgroundColor:[UIColor lightGrayColor]];
            [self.newsDate setBackgroundColor:[UIColor lightGrayColor]];
        }
        else {
            [self setUserInteractionEnabled:YES];
            self.newsTitle.text = self.news.title;
            self.newsDate.text = [HelperDate formatedDate:self.news.nDate];
            [self.newsImage setContentMode:UIViewContentModeScaleAspectFill];
            [self.newsImage setClipsToBounds:true];
            if (self.related)
            {
                self.newsNew.hidden = true;
                self.newsImage.image =[self.news headerImage];
            } else
            {
                self.newsNew.hidden = self.news.isReaded;
                self.newsImage.image =[[self.news images] objectAtIndex:0];
            }
        }
    }
}



@end

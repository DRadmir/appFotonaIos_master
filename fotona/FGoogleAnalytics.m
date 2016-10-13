//
//  FGoogleAnalytics.m
//  fotona
//
//  Created by Janos on 13/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FGoogleAnalytics.h"

@implementation FGoogleAnalytics


id<GAITracker> tracker;


+(void)writeGAForItem:(NSString *)title andType:(int) type{
    
    NSString *text = @"";
    switch (type) {
        case FOTONAPDFINT:
            text = @"PDF with title ";
            break;
        case FOTONAVIDEOINT:
            text = @"Video with title ";
            break;
        case FOTONAWEBPAGEINT:
            text = @"Webpage with title ";
            break;
        default:
            break;
    }
    text = [NSString stringWithFormat:@"%@%@",text,title];
    
    if (tracker == nil){
        tracker = [[GAI sharedInstance] defaultTracker];
    }
    [tracker set:kGAIScreenName value:text];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

@end

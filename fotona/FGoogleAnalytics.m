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
        case GAFOTONAPDFINT:
            text = [NSString stringWithFormat:@"PDF with title %@",title];
            break;
        case GAFOTONAVIDEOINT:
            text = [NSString stringWithFormat:@"Video with title %@",title];
            break;
        case GAFOTONAWEBPAGEINT:
            text = [NSString stringWithFormat:@"Webpage with title %@",title];
            break;
        case GACASEINT:
            text = [NSString stringWithFormat:@"Case with title %@",title];
            break;
        case GACASEMENUINT:
            text = [NSString stringWithFormat:@"Case menu with title %@",title];
            break;
        case GAFEATUREDTABINT:
            text = [NSString stringWithFormat:@"Featured tab"];
            break;
        case GAEVENTTABINT:
            text = [NSString stringWithFormat:@"Event tab"];
            break;
        case GAFAVORITETABINT:
            text = [NSString stringWithFormat:@"Favorite tab"];
            break;
        default:
            break;
    }
    
    if (tracker == nil){
        tracker = [[GAI sharedInstance] defaultTracker];
    }
    [tracker setAllowIDFACollection:YES];
    [tracker set:kGAIScreenName value:text];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

@end

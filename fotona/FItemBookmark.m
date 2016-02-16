//
//  FItemBookmark.m
//  fotona
//
//  Created by Janos on 04/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FItemBookmark.h"

@implementation FItemBookmark
@synthesize itemID;
@synthesize type;
@synthesize category;
@synthesize link;

-(id) initWithItemID:(NSString *)itemID ofType:(NSString *)type inCategory:(int)category withLink:(NSString *)link{
    self=[super init];
    if (self) {
        [self setItemID:itemID];
        [self setType:type];
        [self setCategory:[NSString stringWithFormat:@"%d",category]];
        [self setLink:link];
    }
    return self;
}

-(id) initWithItemIDint:(int)itemID ofType:(NSString *)type inCategory:(int)category withLink:(NSString *)link{
    self=[super init];
    if (self) {
        [self setItemID:[NSString stringWithFormat:@"%d",itemID]];
        [self setType:type];
        [self setCategory:[NSString stringWithFormat:@"%d",category]];
        [self setLink:link];
        
    }
    return self;
}
@end

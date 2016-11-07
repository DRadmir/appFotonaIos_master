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
@synthesize link;
@synthesize bookmarkSourceType;
@synthesize  cases;

-(id) initWithItemID:(NSString *)_itemID ofType:(NSString *)_type fromSource:(int)_bookmarkSourceType forCases:(NSString *) _cases withLink:(NSString *)_link{
    self=[super init];
    if (self) {
        [self setItemID:_itemID];
        [self setType:_type];
        [self setLink:_link];
        [self setBookmarkSourceType:_bookmarkSourceType];
        [self setCases:_cases];
    }
    return self;
}

-(id) initWithItemIDint:(int)_itemID ofType:(NSString *)_type fromSource:(int)_bookmarkSourceType forCases:(NSString *) _cases withLink:(NSString *)_link{
    self=[super init];
    if (self) {
        [self setItemID:[NSString stringWithFormat:@"%d",_itemID]];
        [self setType:_type];
        [self setLink:_link];
        [self setBookmarkSourceType:_bookmarkSourceType];
        [self setCases:_cases];
    }
    return self;
}
@end

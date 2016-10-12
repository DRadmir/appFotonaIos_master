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

-(id) initWithItemID:(NSString *)_itemID ofType:(NSString *)_type inCategory:(int)_category withLink:(NSString *)_link{
    self=[super init];
    if (self) {
        [self setItemID:_itemID];
        [self setType:_type];
        [self setCategory:[NSString stringWithFormat:@"%d",_category]];
        [self setLink:_link];
    }
    return self;
}

-(id) initWithItemIDint:(int)_itemID ofType:(NSString *)_type inCategory:(int)_category withLink:(NSString *)_link{
    self=[super init];
    if (self) {
        [self setItemID:[NSString stringWithFormat:@"%d",_itemID]];
        [self setType:_type];
        [self setCategory:[NSString stringWithFormat:@"%d",_category]];
        [self setLink:_link];
        
    }
    return self;
}
@end

//
//  FItemBookmark.m
//  fotona
//
//  Created by Janos on 04/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FItemBookmark.h"
#import "FAppDelegate.h"

@implementation FItemBookmark
@synthesize itemID;
@synthesize type;
@synthesize link;
@synthesize bookmarkSourceType;
@synthesize  cases;
@synthesize fileSize;

-(id) initWithItemID:(NSString *)_itemID ofType:(NSString *)_type fromSource:(int)_bookmarkSourceType forCases:(NSString *) _cases withLink:(NSString *)_link withFileSize:(int)_fileSize{
    self=[super init];
    if (self) {
        [self setItemID:_itemID];
        [self setType:_type];
        [self setLink:_link];
        [self setBookmarkSourceType:_bookmarkSourceType];
        [self setCases:_cases];
        [self setFileSize:_fileSize];
    }
    return self;
}

-(id) initWithItemIDint:(int)_itemID ofType:(NSString *)_type fromSource:(int)_bookmarkSourceType forCases:(NSString *) _cases withLink:(NSString *)_link withFileSize:(int)_fileSize{
    self=[super init];
    if (self) {
        [self setItemID:[NSString stringWithFormat:@"%d",_itemID]];
        [self setType:_type];
        [self setLink:_link];
        [self setBookmarkSourceType:_bookmarkSourceType];
        [self setCases:_cases];
        [self setFileSize:_fileSize];
    }
    return self;
}

+(void) removeFromListItemWithLink:(NSString *)itemLink{
    NSArray *list = [APP_DELEGATE downloadList];
    for (FItemBookmark *item in list) {
        if ([[item link] isEqualToString:itemLink]) {
            [APP_DELEGATE setBookmarkSizeAll:[APP_DELEGATE bookmarkSizeAll]-[item fileSize]];
            [APP_DELEGATE setBookmarkSizeLeft:[APP_DELEGATE bookmarkSizeLeft]-[item fileSize]];
            [[APP_DELEGATE downloadList] removeObject:item];
            break;
        }
    }
}
@end

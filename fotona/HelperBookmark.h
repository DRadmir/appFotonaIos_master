//
//  HelperBookmark.h
//  fotona
//
//  Created by Janos on 29/07/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FCase.h"
#import "FMedia.h"
#import "FFotonaMenu.h"

@interface HelperBookmark : NSObject

+ (void) bookmarkAll: (NSArray *)categorys;
+ (BOOL) bookmarked: (int) itemID withType:(NSString *)type inCategory:(int) category;
+ (BOOL) bookmarked: (int) itemID withType:(NSString *)type;

+ (void)bookmarkCase:(FCase*) currentCase;
+ (BOOL) bookmarkMedia: (FMedia *)media;

+ (void) cancelBookmark;
+ (void) userBookmarked;
+ (void) checkAllFiles:(NSString *)dlink;
+ (void) warning;
+ (void) success;
@end

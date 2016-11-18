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
#import "FImage.h"

@interface HelperBookmark : NSObject

+ (void) bookmarkAll: (NSArray *)categorys;
+ (BOOL) bookmarked: (int) itemID withType:(NSString *)type;

+ (void)bookmarkCase:(FCase*) currentCase;
+ (BOOL) bookmarkMedia: (FMedia *)media;

+ (void) cancelBookmark;
+ (void) userBookmarked;
+ (void) checkAllFiles:(NSString *)dlink;
+ (void) warning;
+ (void) success;

+(void)addImageToDownloadList:(FImage *)img forCase:(NSString *)caseID;
+(void)addVideoToDownloadList:(FMedia *)video forCase:(NSString *)caseID;

+(void) unbookmarkAll;

+(void)removeBookmarkForMedia:(FMedia *)media andType:(NSString *)itemType forBookmarkType:(int)bookType;
+(void)removeBookmarkForImage:(FImage *)image andType:(NSString *)itemType forBookmarkType:(int)bookType;
+(void)removeBookmarkedCase:(FCase *)caseToRemove;
@end

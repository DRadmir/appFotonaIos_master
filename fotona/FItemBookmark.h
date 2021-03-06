//
//  FItemBookmark.h
//  fotona
//
//  Created by Janos on 04/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//


@interface FItemBookmark : NSObject
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *link;
@property (nonatomic) int bookmarkSourceType;
@property (nonatomic, retain) NSString *cases;
@property (nonatomic) int fileSize;


-(id)initWithItemID:(NSString *) itemID ofType:(NSString *)type fromSource:(int)bookmarkSourceType forCases:(NSString *) cases withLink:(NSString *)link withFileSize:(int)_fileSize;
-(id)initWithItemIDint:(int) itemID ofType:(NSString *)type fromSource:(int)bookmarkSourceType forCases:(NSString *) cases withLink:(NSString *)link withFileSize:(int)_fileSize;

+(void) removeFromListItemWithLink:(NSString *)itemLink;
@end



//
//  FItemBookmark.h
//  fotona
//
//  Created by Janos on 04/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FItemBookmark : NSObject
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *category;


-(id)initWithItemID:(NSString *) itemID ofType:(NSString *)type inCategory:(int)category withLink:(NSString *)link;
-(id)initWithItemIDint:(int) itemID ofType:(NSString *)type inCategory:(int)category withLink:(NSString *)link;
@end

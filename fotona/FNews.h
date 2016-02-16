//
//  FNews.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNews : NSObject


@property (nonatomic) NSInteger newsID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSString *nDate;
@property (nonatomic) BOOL isReaded;
@property (nonatomic, retain) UIImage *headerImage;
@property (nonatomic, retain) NSString *headerImageLink;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *imagesLinks;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSString *rest;//for knowing if its over 12

@property (nonatomic, retain) NSString *bookmark;

//database
@property (nonatomic, retain) NSString *activeDB;
@property (nonatomic, retain) NSString *isReadedDB;
@property (nonatomic, retain) NSString *imagesDB;
@property (nonatomic, retain) NSString *imagesLinksDB;
@property (nonatomic, retain) NSString *categoriesDB;
@property (nonatomic, retain) NSString *headerImageDB;

@property (nonatomic, retain) NSString *localImage;
@property (nonatomic, retain) NSMutableArray *localImages;

-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionaryDB:(NSDictionary *)dic WithRest:(NSString *)online andBookmarked:(NSString *)bookmark;
-(id)initWithDictionaryToDB:(FNews *)news WithRest:(NSString *)online andBookmarked:(NSString *)bookmark;
-(id)initWithDictionaryToDB:(FNews *)news WithRest:(NSString *)online forBookmarked:(NSString *)bookmark;

+(NSMutableArray *) getImages:(NSMutableArray *) newsArray fromStart:(int) startIndex forNumber:(int)number;


@end

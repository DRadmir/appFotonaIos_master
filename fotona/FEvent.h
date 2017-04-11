//
//  FEvent.h
//  fotona
//
//  Created by Gost on 26/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

@interface FEvent : NSObject

@property (nonatomic) NSInteger eventID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *eventplace;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *eventdate;
@property (nonatomic, retain) NSString *eventdateTo;
@property (nonatomic) NSInteger typeE;
@property (nonatomic, retain) NSMutableArray *eventcategories;
@property (nonatomic, retain) NSMutableArray *eventImages;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL mobileFeatured;

//database
@property (nonatomic, retain) NSString *eventcategoriesDB;
@property (nonatomic, retain) NSString *eventImagesDB;
@property (nonatomic, retain) NSString *activeDB;
@property (nonatomic, retain) NSString *mobileFeaturedDB;

@property (nonatomic, retain) NSString *bookmark;


-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionaryDB:(NSDictionary *)dic;
-(NSString *)getDot;
-(NSString *)getDot:(int)cat;

@end

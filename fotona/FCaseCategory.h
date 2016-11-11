//
//  FCaseCategory.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//


@interface FCaseCategory : NSObject
@property (nonatomic, retain) NSString *categoryID;
@property (nonatomic, retain) NSString *categoryIDPrev;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *active;
@property (nonatomic, retain) NSString *sort;
@property (nonatomic, retain) NSString *deleted;

-(id)initWithDictionary:(NSDictionary *)dic;

@end

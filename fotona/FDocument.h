//
//  FDocument.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//


@interface FDocument : NSObject
@property (nonatomic, retain) NSString *documentID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *iconType;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *isLink;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *src;
@property (nonatomic, retain) NSString *active;
@property (nonatomic, retain) NSMutableArray *allowedUserTypes;
@property (nonatomic, retain) NSMutableArray *allowedUserSubTypes;
@property (nonatomic, retain) NSString *bookmark;

-(id)initWithDictionary:(NSDictionary *)dic;

@end

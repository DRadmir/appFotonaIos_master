//
//  FCase.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//


@interface FCase : NSObject
@property (nonatomic, retain) NSString *caseID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *coverTypeID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *imageLocal;
@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSString *procedure;
@property (nonatomic, retain) NSString *results;
@property (nonatomic, retain) NSString *references;
@property (nonatomic, retain) NSString *parametars;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *galleryID;
@property (nonatomic, retain) NSString *videoGalleryID;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *video;
@property (nonatomic, retain) NSString *active;
@property (nonatomic, retain) NSString *allowedForGuests;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSString *authorID;
@property (nonatomic, retain) NSString *bookmark;
@property (nonatomic, retain) NSString *coverflow;

-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionaryDB:(NSDictionary *)dic;

-(NSMutableArray *)getImages;
-(NSMutableArray *)getVideos;
-(NSMutableArray *)parseImages;
-(NSMutableArray *)parseVideos;
-(NSString *)getAuthorName;

@end

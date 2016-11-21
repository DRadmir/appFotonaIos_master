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
@property (nonatomic, retain) NSString *parameters;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *video;
@property (nonatomic, retain) NSString *active;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSString *authorID;
@property (nonatomic, retain) NSString *bookmark;
@property (nonatomic, retain) NSString *coverflow;

@property (nonatomic, retain) NSString *deleted;
@property (nonatomic, retain) NSString *download;
@property (nonatomic, retain) NSString *userPermissions;
@property (nonatomic, retain) NSString *galleryItemVideoIDs;
@property (nonatomic, retain) NSString *galleryItemImagesIDs;

-(id)initWithDictionaryFromServer:(NSDictionary *)dic;
-(id)initWithDictionaryFromDB:(NSDictionary *)dic;

-(NSMutableArray *)getImages;
-(NSMutableArray *)getVideos;
-(NSMutableArray *)parseImagesFromServer: (BOOL)fromServer;
-(NSMutableArray *)parseVideosFromServer: (BOOL)fromServer;
-(NSString *)getAuthorName;

+(void) openCase:(FCase *)caseToOpen;

@end

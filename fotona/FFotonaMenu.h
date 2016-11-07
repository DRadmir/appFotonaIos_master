//
//  FFotonaMenu.h
//  fotona
//
//  Created by Dejan Krstevski on 4/15/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

@interface FFotonaMenu : NSObject
@property (nonatomic,retain) NSString *categoryID;
@property (nonatomic,retain) NSString *categoryIDPrev;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *fotonaCategoryType;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *caseID;
@property (nonatomic,retain) NSString *externalLink;
@property (nonatomic,retain) NSMutableArray *videoArray;
@property (nonatomic,retain) NSMutableArray *pdfArray;
@property (nonatomic,retain) NSString *active;
@property (nonatomic,retain) NSString *iconName;
@property (nonatomic,retain) NSString *sort;
@property (nonatomic,retain) NSString *bookmark;
@property (nonatomic,retain) NSString *galleryItemIDs;
@property (nonatomic,retain) NSString *userPermissions;
@property (nonatomic,retain) NSString *deleted;
@property (nonatomic) int sortInt;
//To use in parsing
@property (nonatomic, retain) NSArray *videosDicArr;
@property (nonatomic, retain) NSArray *pdfsDicArr;

-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionaryFromServer:(NSDictionary *)dic;
-(void)updateVideos;
-(NSMutableArray *)getVideos;
@end

//
//  FFotonaMenu.h
//  fotona
//
//  Created by Dejan Krstevski on 4/15/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFotonaMenu : NSObject
@property (nonatomic,retain) NSString *categoryID;
@property (nonatomic,retain) NSString *categoryIDPrev;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *fotonaCategoryType;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *caseID;
@property (nonatomic,retain) NSString *pdfSrc;
@property (nonatomic,retain) NSString *externalLink;
@property (nonatomic,retain) NSString *videoGalleryID;
@property (nonatomic,retain) NSMutableArray *videos;
@property (nonatomic,retain) NSString *active;
@property (nonatomic,retain) NSString *iconName;
@property (nonatomic,retain) NSString *sort;
@property (nonatomic,retain) NSMutableArray *allowedUserTypes;
@property (nonatomic,retain) NSMutableArray* allowedUserSubTypes;
@property (nonatomic,retain) NSString *bookmark;
@property (nonatomic) int sortInt;

@property (nonatomic, retain) NSArray *videosDicArr;

-(id)initWithDictionary:(NSDictionary *)dic;
-(void)updateVideos;
-(NSMutableArray *)getVideos;
@end

//
//  FVideo.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FVideo : NSObject
@property (nonatomic,retain) NSString *itemID;
@property (nonatomic,retain) NSString *videoGalleryID;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSString *localPath;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *bookmark;
@property (nonatomic,retain) NSString *time;
@property (nonatomic,retain) NSString *videoImage;
@property (nonatomic,retain) NSString *sort;
@property (nonatomic,retain) NSString *userType;
@property (nonatomic,retain) NSString *userSubType;
@property (nonatomic,retain) NSDate *dateUpdated;

-(id)initWithDictionary:(NSDictionary *)dic;
-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder;

-(BOOL) checkVideoForCategory:(NSString *)category;
@end

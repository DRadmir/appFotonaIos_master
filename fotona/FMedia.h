//
//  FMedia.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

@interface FMedia : NSObject
@property (nonatomic,retain) NSString *itemID;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSString *localPath;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *bookmark;
@property (nonatomic,retain) NSString *mediaImage;
@property (nonatomic,retain) NSString *sort;
@property (nonatomic,retain) NSString *deleted;
@property (nonatomic,retain) NSString *filesize;
@property (nonatomic,retain) NSString *userPermissions;
@property (nonatomic,retain) NSString *active;
@property (nonatomic,retain) NSString *download;
@property (nonatomic,retain) NSString *mediaType;
@property (nonatomic,retain) NSString *time;

-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionaryFromServer:(NSDictionary *)dic forMediType: (NSString *)type;


-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder;

-(BOOL) checkVideoForCategory:(NSString *)category;
@end

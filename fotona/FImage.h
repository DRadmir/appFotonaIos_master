//
//  FImage.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

@interface FImage : NSObject
@property (nonatomic,retain) NSString *itemID;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSString *localPath;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *sort;
@property (nonatomic,retain) NSString *deleted;
@property (nonatomic,retain) NSString *fileSize;


-(id)initWithDictionaryFromServer:(NSDictionary *)dic;
-(id)initWithDictionaryFromDB:(NSDictionary *)dic;
-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder;

@end

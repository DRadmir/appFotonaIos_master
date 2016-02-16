//  FCase.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FCase.h"
#import "FImage.h"
#import "FVideo.h"
#import "FMDatabase.h"
#import "FAppDelegate.h"

@implementation FCase
@synthesize caseID;
@synthesize title;
@synthesize coverTypeID;
@synthesize name;
@synthesize image;
@synthesize imageLocal;
@synthesize introduction;
@synthesize procedure;
@synthesize results;
@synthesize references;
@synthesize parametars;
@synthesize date;
@synthesize galleryID;
@synthesize videoGalleryID;
@synthesize images;
@synthesize video;
@synthesize active;
@synthesize allowedForGuests;
@synthesize categories;
@synthesize authorID;
@synthesize bookmark;
@synthesize coverflow;

//befor saving into BD
-(id)initWithDictionaryDB:(NSDictionary *)dic
{
    
    self=[super init];
    if (self) {
        [self setCaseID:[dic valueForKey:@"caseID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setCoverTypeID:[dic valueForKey:@"coverTypeID"]];
        [self setName:[dic valueForKey:@"name"]];
        [self setImage:[dic valueForKey:@"image"]];
        [self setImageLocal:@""];
        [self setIntroduction:[dic valueForKey:@"introduction"]];
        [self setProcedure:[dic valueForKey:@"procedure"]];//html
        [self setResults:[dic valueForKey:@"results"]];
        [self setReferences:[dic valueForKey:@"references"]];
        [self setDate:[dic valueForKey:@"date"]];
        [self setParametars:[dic valueForKey:@"parameters"]];
        [self setGalleryID:[dic valueForKey:@"galleryID"]];
        [self setVideoGalleryID:[dic valueForKey:@"videoGalleryID"]];
        if ([dic objectForKey:@"images"]==[NSNull null]) {
            images=[[NSMutableArray alloc] init];
        }else{
            NSArray *tmp=[dic objectForKey:@"images"];
            NSMutableArray *imgs=[[NSMutableArray alloc] init];
            for (NSDictionary *dic in tmp) {
                FImage *img=[[FImage alloc] initWithDictionary:dic];
                [imgs addObject:img];
            }
            [self setImages:imgs];
        }
        if ([dic objectForKey:@"videos"]==[NSNull null]) {
            video=[[NSMutableArray alloc] init];
        }else{
            [self setVideo:[dic objectForKey:@"videos"]];
        }
        [self setActive:[dic valueForKey:@"active"]];
        [self setAllowedForGuests:[dic valueForKey:@"allowedForGuests"]];
        if ([dic objectForKey:@"categories"]==[NSNull null]) {
            categories=[[NSMutableArray alloc] init];
        }else{
            [self setCategories:[dic objectForKey:@"categories"]];
        }
        [self setAuthorID:[dic valueForKey:@"authorID"]];

        if ([[dic valueForKey:@"allowInCoverFlow"] boolValue]) {
            [self setCoverflow:@"1"];
        } else {
           [self setCoverflow:@"0"];
        }
        
        
    }
    
    
    return self;
}

//puling from DB
-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setCaseID:[dic valueForKey:@"caseID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setCoverTypeID:[dic valueForKey:@"coverTypeID"]];
        [self setName:[dic valueForKey:@"name"]];
        [self setImage:[dic valueForKey:@"image"]];
        [self setImageLocal:@""];
        [self setIntroduction:[dic valueForKey:@"introduction"]];
        [self setProcedure:[dic valueForKey:@"procedure"]];//html
        [self setResults:[dic valueForKey:@"results"]];
        [self setReferences:[dic valueForKey:@"references"]];
        [self setDate:[dic valueForKey:@"date"]];
        [self setParametars:[dic valueForKey:@"parameters"]];
        [self setGalleryID:[dic valueForKey:@"galleryID"]];
        [self setVideoGalleryID:[dic valueForKey:@"videoGalleryID"]];
        if ([dic objectForKey:@"images"]== nil || [dic objectForKey:@"images"]== (id)[NSNull null] ) {
            [self setImages:[self getImages]];
        }else{
            NSArray *tmp=[dic objectForKey:@"images"];
           
                NSMutableArray *imgs=[[NSMutableArray alloc] init];
                for (NSDictionary *dicImg in tmp) {
                    FImage *img=[[FImage alloc] initWithDictionary:dicImg];
                    [imgs addObject:img];
                }
                [self setImages:imgs];
            
            
        }
        if ([dic objectForKey:@"videos"]==[NSNull null]) {
            [self setVideo:[self getVideos]];
        }else{
            NSLog(@"%@",[dic objectForKey:@"videos"]);
            NSArray *tmp=[dic objectForKey:@"videos"];
            NSMutableArray *videos=[[NSMutableArray alloc] init];
            for (NSDictionary *dicVid in tmp) {
                FVideo *vid=[[FVideo alloc] initWithDictionary:dicVid];
                [videos addObject:vid];
            }
            [self setVideo:videos];
        }
        [self setActive:[dic valueForKey:@"active"]];
        [self setAllowedForGuests:[dic valueForKey:@"allowedForGuests"]];
        if ([dic objectForKey:@"categories"]==[NSNull null]) {
            categories=[[NSMutableArray alloc] init];
        }else{
            [self setCategories:[dic objectForKey:@"categories"]];
        }
        [self setAuthorID:[dic valueForKey:@"authorID"]];
        [self setBookmark:[dic valueForKey:@"isBookmark"]];
        [self setCoverflow:[dic valueForKey:@"alloweInCoverFlow"]];
        if (self.coverflow == nil) {
            [self setCoverflow:[dic valueForKey:@"allowInCoverFlow"]];
        }
    }
    
    
    return self;
}

-(NSMutableArray *)getImages
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    if([self galleryID] != (id)[NSNull null]) {
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *result = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where galleryID=%@ order by sort;",self.galleryID]];
    while([result next]) {
        FImage *f=[[FImage alloc] init];
        [f setItemID:[result stringForColumn:@"mediaID"]];
        [f setTitle:[result stringForColumn:@"title"]];
        [f setPath:[result stringForColumn:@"path"]];
        [f setDescription:[result stringForColumn:@"description"]];
        [f setLocalPath:[result stringForColumn:@"localPath"]];
        [f setGalleryID:[result stringForColumn:@"galleryID"]];
        [arr addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
        }
    return arr;
}

-(NSMutableArray *)getVideos
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    if([self videoGalleryID] != (id)[NSNull null]  ){
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *result = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where galleryID=%@;",self.videoGalleryID]];
    while([result next]) {
        FVideo *f=[[FVideo alloc] init];
        [f setItemID:[result stringForColumn:@"mediaID"]];
        [f setTitle:[result stringForColumn:@"title"]];
        [f setPath:[result stringForColumn:@"path"]];
        [f setLocalPath:[result stringForColumn:@"localPath"]];
        [f setVideoGalleryID:[result stringForColumn:@"galleryID"]];
        [f setUserType:[result stringForColumn:@"userType"]];
        [f setUserSubType:[result stringForColumn:@"userSubType"]];
        [arr addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    }
    return arr;
}

-(NSMutableArray *)parseImages
{
    NSMutableArray *tmpImgs=[[NSMutableArray alloc] init];
//    NSArray *imgsArr=[NSJSONSerialization JSONObjectWithData:[imgs dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    
    if (self.images.count>0) {
        for (NSDictionary *imgDic in self.images) {
            FImage *img=[[FImage alloc] initWithDictionary:imgDic];
            [tmpImgs addObject:img];
        }
    }
    [self setImage:[tmpImgs mutableCopy]];
    return tmpImgs;
}
-(NSMutableArray *)parseVideos
{
    NSMutableArray *tmpVideos=[[NSMutableArray alloc] init];
    if (self.video.count>0) {
        for (NSDictionary *videDic in self.video) {
            FVideo *v=[[FVideo alloc] initWithDictionary:videDic];
            [tmpVideos addObject:v];
        }
    }
    return tmpVideos;
}


-(NSString *)getAuthorName
{
    NSString *result=@"";
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *resultQ = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author where authorID=%@;",self.authorID]];
    while([resultQ next]) {
        result=[resultQ stringForColumn:@"name"];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return result;
}

@end


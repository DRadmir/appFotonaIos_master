//  FCase.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FCase.h"
#import "FImage.h"
#import "FMedia.h"
#import "FMDatabase.h"

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
@synthesize parameters;
@synthesize date;
@synthesize images;
@synthesize video;
@synthesize active;
@synthesize allowedForGuests;
@synthesize categories;
@synthesize authorID;
@synthesize bookmark;
@synthesize coverflow;
@synthesize deleted;
@synthesize download;
@synthesize userPermissions;

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
        [self setParameters:[dic valueForKey:@"parameters"]];
        if ([dic objectForKey:@"images"]==[NSNull null]) {
            images=[[NSMutableArray alloc] init];
        }else{
            NSArray *tmp=[dic objectForKey:@"images"];
            NSMutableArray *imgs=[[NSMutableArray alloc] init];
            for (NSDictionary *dic in tmp) {
                FImage *img=[[FImage alloc] initWithDictionaryFromServer:dic];
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
        if ([[dic valueForKey:@"deleted"] boolValue]) {
            [self setDeleted:@"1"];
        } else {
            [self setDeleted:@"0"];
        }
        if ([[dic valueForKey:@"download"] boolValue]) {
            [self setDownload:@"1"];
        } else {
            [self setDownload:@"0"];
        }
        [self setGalleryItemVideoIDs:[FCommon arrayToString:[dic valueForKey:@"galleryItemVideoIDs"] withSeparator:@","]];
        [self setGalleryItemImagesIDs:[FCommon arrayToString:[dic valueForKey:@"galleryItemImagesIDs"] withSeparator:@","]];
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
        [self setParameters:[dic valueForKey:@"parameters"]];
        if ([dic objectForKey:@"images"]== nil || [dic objectForKey:@"images"]== (id)[NSNull null] ) {
            [self setImages:[self getImages]];
        }else{
            NSArray *tmp=[dic objectForKey:@"images"];
            
            NSMutableArray *imgs=[[NSMutableArray alloc] init];
            for (NSDictionary *dicImg in tmp) {
                FImage *img=[[FImage alloc] initWithDictionaryFromDB:dicImg];
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
                FMedia *vid=[[FMedia alloc] initWithDictionary:dicVid];
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
        [self setDeleted:[dic valueForKey:@"deleted"]];
       
        [self setDownload:[dic valueForKey:@"download"]];
       
        [self setGalleryItemVideoIDs:[dic valueForKey:@"galleryItemVideoIDs"]];
        [self setGalleryItemImagesIDs:[dic valueForKey:@"galleryItemImagesIDs"]];
    }
    
    
    return self;
}

-(NSMutableArray *)getImages
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    NSArray *imagesArray = [FCommon stringToArray:[self galleryItemImagesIDs] withSeparator:@","];
    if(imagesArray != nil  && [imagesArray count] != 0 ){
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        for (NSString *imgId in imagesArray) {
            FMResultSet *result = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@;",imgId]];
            while([result next]) {
                FImage *f=[[FImage alloc] initWithDictionaryFromDB:[result resultDictionary]];
                [arr addObject:f];
            }
        }
        
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
    return arr;
}

-(NSMutableArray *)getVideos
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    NSArray *videosArray = [FCommon stringToArray:[self galleryItemVideoIDs] withSeparator:@","];
    if(videosArray!= nil  && [videosArray count] != 0 ){
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        for (NSString *vidId in videosArray) {
            FMResultSet *result = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@;",vidId]];
            while([result next]) {
                FMedia *f=[[FMedia alloc] initWithDictionary:[result resultDictionary]];
                [arr addObject:f];
            }
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
            FImage *img=[[FImage alloc] initWithDictionaryFromServer:imgDic];
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
            FMedia *v=[[FMedia alloc] initWithDictionary:videDic ];//TODO: pogledat ali je iz baze ali iz serverja
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


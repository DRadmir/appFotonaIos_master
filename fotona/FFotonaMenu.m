//
//  FFotonaMenu.m
//  fotona
//
//  Created by Dejan Krstevski on 4/15/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FFotonaMenu.h"
#import "FMedia.h"
#import "FMDatabase.h"
#import "FDB.h"

@implementation FFotonaMenu
@synthesize categoryID;
@synthesize categoryIDPrev;
@synthesize title;
@synthesize fotonaCategoryType;
@synthesize description;
@synthesize text;
@synthesize caseID;
@synthesize externalLink;
@synthesize videoArray;
@synthesize pdfArray;
@synthesize active;
@synthesize videosDicArr;
@synthesize iconName;
@synthesize sort;
@synthesize bookmark;
@synthesize userPermissions;
@synthesize galleryItems;
@synthesize sortInt;
@synthesize deleted;

-(id)initWithDictionaryFromServer:(NSDictionary *)dic
{
    NSLog(@"%@",[dic objectForKey:@"videos"]);
    self=[super init];
    if (self) {
        [self initCommon:dic];
        [self setExternalLink:[dic objectForKey:@"link"]];

        if (![[dic objectForKey:@"videos"] isEqual:[NSNull null]] && ![[dic objectForKey:@"videos"] isKindOfClass:[NSString class]]) {
            [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            self.videosDicArr=[[NSArray alloc] init];
        }
        [self parseVideos:videosDicArr isFromServer:YES];
        //TODO: parsanje pdfov
        if (![[dic objectForKey:@"pdfs"] isEqual:[NSNull null]] && ![[dic objectForKey:@"pdfs"] isKindOfClass:[NSString class]]) {
           // [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            //self.videosDicArr=[[NSArray alloc] init];
        }
        [self parseVideos:videosDicArr isFromServer:YES];
        
        [self setGalleryItems:[FCommon arrayToString:[dic objectForKey:@"galleryItemIDs"] withSeparator:@","]];
    }
    
    return self;
}



-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        
        [self initCommon:dic];
        [self setExternalLink:[dic objectForKey:@"externalLink"]];
        if (![[dic objectForKey:@"videos"] isEqual:[NSNull null]] && ![[dic objectForKey:@"videos"] isKindOfClass:[NSString class]]) {
            [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            self.videosDicArr=[[NSArray alloc] init];
        }
        [self parseVideos:videosDicArr isFromServer:NO];
        
        //TODO: parsanje pdfov
        if (![[dic objectForKey:@"pdfs"] isEqual:[NSNull null]] && ![[dic objectForKey:@"pdfs"] isKindOfClass:[NSString class]]) {
            // [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            //self.videosDicArr=[[NSArray alloc] init];
        }
        [self parseVideos:videosDicArr isFromServer:YES];
        
        [self setGalleryItems:[dic objectForKey:@"galleryItemIDs"]];
    }
    
    return self;
}

-(void) initCommon:(NSDictionary *) dic {
    [self setCategoryID:[dic objectForKey:@"categoryID"]];
    [self setCategoryIDPrev:[dic objectForKey:@"categoryIDPrev"]];
    [self setTitle:[dic objectForKey:@"title"]];
    [self setFotonaCategoryType:[dic objectForKey:@"fotonaCategoryType"]];
    [self setIconName:[dic objectForKey:@"fotonaImageType"]];
    [self setCaseID:[dic objectForKey:@"caseID"]];
    [self setDescription:[dic objectForKey:@"description"]];
    [self setText:[dic objectForKey:@"text"]];
    [self setActive:[dic objectForKey:@"active"]];
    [self setDeleted:[dic objectForKey:@"deleted"]];
    [self setSort:[dic objectForKey:@"sort"]];
    [self setBookmark:[dic objectForKey:@"isBookmark"]];
    [self setUserPermissions:[dic objectForKey:@"userPermissions"]];
}


-(void)updateVideos
{
    self.videoArray=[[NSMutableArray alloc] init];
    [self parseVideos:videosDicArr isFromServer:true];
}

-(void)parseVideos:(NSArray *)arrVideos isFromServer:(BOOL) server
{
    if (![arrVideos isEqual:[NSNull null]]) {
        for (NSDictionary *dicVideo in arrVideos) {
            FMedia *video;
            if (server) {
                video=[[FMedia alloc] initWithDictionaryFromServer:dicVideo forMediType:MEDIAVIDEO];
            } else {
                 video=[[FMedia alloc] initWithDictionary:dicVideo];
            }
           
            [self.videoArray addObject:video];
        }
    }
}



-(NSMutableArray *)getVideos
{
    return [FDB getVideosFromArray:[FCommon stringToArray:[self galleryItems] withSeparator:@","]];    
}

-(NSDate *) formateDate:(NSString *) stringDate{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater dateFromString:stringDate];
}

@end

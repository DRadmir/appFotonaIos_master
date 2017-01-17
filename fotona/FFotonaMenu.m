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
@synthesize iconName;
@synthesize sort;
@synthesize bookmark;
@synthesize userPermissions;
@synthesize galleryItemIDs;
@synthesize sortInt;
@synthesize deleted;

@synthesize videosDicArr;
@synthesize pdfsDicArr;

-(id)initWithDictionaryFromServer:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.videoArray = [[NSMutableArray alloc] init];
        self.pdfArray = [[NSMutableArray alloc] init];
        [self initCommon:dic];
        [self setExternalLink:[dic objectForKey:@"link"]];
        if (![[dic objectForKey:@"pdfs"] isEqual:[NSNull null]] && ![[dic objectForKey:@"pdfs"] isKindOfClass:[NSString class]]) {
            [self setPdfsDicArr:[dic objectForKey:@"pdfs"]];
        }else
        {
            self.pdfsDicArr=[[NSArray alloc] init];
        }
        if (![[dic objectForKey:@"videos"] isEqual:[NSNull null]] && ![[dic objectForKey:@"videos"] isKindOfClass:[NSString class]]) {
            [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            self.videosDicArr=[[NSArray alloc] init];
        }

        [self parseMedia:videosDicArr isFromServer:YES  forMediaType:MEDIAVIDEO];
        [self parseMedia:pdfsDicArr isFromServer:YES forMediaType:MEDIAPDF];
        [self setGalleryItemIDs:[FCommon arrayToString:[dic objectForKey:@"galleryItemIDs"] withSeparator:@","]];
        if ([[dic valueForKey:@"deleted"] boolValue]) {
            [self setDeleted:@"1"];
        } else {
            [self setDeleted:@"0"];
        }
        if ([[dic valueForKey:@"active"] boolValue]) {
            [self setActive:@"1"];
        } else {
            [self setActive:@"0"];
        }
            }
    
    return self;
}


-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.videoArray = [[NSMutableArray alloc] init];
        self.pdfArray = [[NSMutableArray alloc] init];
        [self initCommon:dic];
        [self setExternalLink:[dic objectForKey:@"externalLink"]];
        [self parseMedia:videosDicArr isFromServer:NO forMediaType:MEDIAVIDEO];
        [self parseMedia:pdfsDicArr isFromServer:NO forMediaType:MEDIAPDF];
        [self setGalleryItemIDs:[dic objectForKey:@"galleryItemIDs"]];
        [self setActive:[dic objectForKey:@"active"]];
        [self setDeleted:[dic objectForKey:@"deleted"]];
        if (![[dic objectForKey:@"sort"] isKindOfClass:[NSNull class]]) {
             [self setSortInt:[[dic objectForKey:@"sort"] intValue]];
        } else {
            [self setSortInt:0];
        }
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
    [self setSort:[dic objectForKey:@"sort"]];
    [self setBookmark:[dic objectForKey:@"isBookmark"]];
    [self setUserPermissions:[dic objectForKey:@"userPermissions"]];
   
}


-(void)updateVideos
{
    self.videoArray=[[NSMutableArray alloc] init];
    [self parseMedia:videosDicArr isFromServer:true forMediaType:MEDIAVIDEO];
}

-(void)parseMedia:(NSArray *)arrMedia isFromServer:(BOOL) server forMediaType: (NSString *) mediatype
{
    if (![arrMedia isEqual:[NSNull null]]) {
        for (NSDictionary *dicMedia in arrMedia) {
            FMedia *media;
            if (server) {
                media=[[FMedia alloc] initWithDictionaryFromServer:dicMedia];
            } else {
                 media=[[FMedia alloc] initWithDictionary:dicMedia];
            }
           
            if ([mediatype isEqualToString:MEDIAVIDEO]) {
                [self.videoArray addObject:media];
            } else {
                if ([mediatype isEqualToString:MEDIAPDF]) {
                    [self.pdfArray addObject:media];
                }
            }
        }
    }
}

-(NSMutableArray *)getMedia
{
    NSString *type = MEDIAVIDEO;
    if ([[self fotonaCategoryType] intValue] ==[CATEGORYPDF intValue]) {
        type = MEDIAPDF;
    }
    return [FDB getMediaForGallery:[self galleryItemIDs] withMediType:type];
}

-(NSDate *) formateDate:(NSString *) stringDate{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater dateFromString:stringDate];
}

@end

//
//  FFotonaMenu.m
//  fotona
//
//  Created by Dejan Krstevski on 4/15/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FFotonaMenu.h"
#import "FVideo.h"
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
@synthesize pdfSrc;
@synthesize externalLink;
@synthesize videoGalleryID;
@synthesize videos;
@synthesize active;
@synthesize allowedUserSubTypes;
@synthesize allowedUserTypes;
@synthesize videosDicArr;
@synthesize iconName;
@synthesize sort;
@synthesize bookmark;

@synthesize sortInt;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setCategoryID:[dic objectForKey:@"categoryID"]];
        [self setCategoryIDPrev:[dic objectForKey:@"categoryIDPrev"]];
        [self setTitle:[dic objectForKey:@"title"]];
        [self setFotonaCategoryType:[dic objectForKey:@"fotonaCategoryType"]];
        [self setDescription:[dic objectForKey:@"description"]];
        [self setText:[dic objectForKey:@"text"]];
        [self setCaseID:[dic objectForKey:@"caseID"]];
        [self setPdfSrc:[dic objectForKey:@"pdfSrc"]];
        [self setExternalLink:[dic objectForKey:@"externalLink"]];
        [self setVideoGalleryID:[dic objectForKey:@"videoGalleryID"]];
        
        if (![[dic objectForKey:@"videos"] isEqual:[NSNull null]] && ![[dic objectForKey:@"videos"] isKindOfClass:[NSString class]]) {
            [self setVideosDicArr:[dic objectForKey:@"videos"]];
        }else
        {
            self.videosDicArr=[[NSArray alloc] init];
        }
        [self parseVideos:videosDicArr];
        [self setActive:[dic objectForKey:@"active"]];
        [self setAllowedUserTypes:[dic objectForKey:@"allowedUserTypes"]];
        [self setAllowedUserSubTypes:[dic objectForKey:@"allowedUserSubTypes"]];
        [self setIconName:[dic objectForKey:@"fotonaImageType"]];
        [self setSort:[dic objectForKey:@"sort"]];
        [self setBookmark:[dic objectForKey:@"isBookmark"]];
    }
    
    return self;
}


-(void)updateVideos
{
    self.videos=[[NSMutableArray alloc] init];
    [self parseVideos:videosDicArr];
}

-(void)parseVideos:(NSArray *)arrVideos
{
    if (![arrVideos isEqual:[NSNull null]]) {
        for (NSDictionary *dicVideo in arrVideos) {
            FVideo *video=[[FVideo alloc] initWithDictionary:dicVideo];
                   [self.videos addObject:video];
        }
    }
}


-(void)insertIntoDB:(NSMutableArray *)video
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FVideo *v in video) {
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where galleryID=%@;",self.videoGalleryID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO Media (mediaID,galleryID,title,path,localPath,description,mediaType,bookmark,videoImage,sort,userType,userSubType) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",v.itemID,self.videoGalleryID,v.title,v.path,@"",v.description,@"1",@"0",v.videoImage,v.sort,v.userType,v.userSubType];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}
-(NSMutableArray *)getVideos
{
    return [FDB getVideosWithGallery:self.videoGalleryID];

}

-(NSDate *) formateDate:(NSString *) stringDate{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater dateFromString:stringDate];
}

@end

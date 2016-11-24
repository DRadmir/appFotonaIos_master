//
//  FDB.m
//  fotona
//
//  Created by Janos on 22/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FDB.h"
#import "FMDatabase.h"
#import "FCaseCategory.h"
#import "FAuthor.h"
#import "FImage.h"
#import "FMedia.h"
#import "FDownloadManager.h"
#import "FItemFavorite.h"
#import "FMediaManager.h"
#import "HelperBookmark.h"
#import "FDocument.h"

@implementation FDB


#pragma mark - Author
+(UIImage *)getAuthorImage:(NSString *)authID
{
    UIImage *image=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT image,imageLocal FROM Author where authorID=%@",authID]];
    while([results next]) {
        NSString *imgOnline=[results stringForColumn:@"image"];
        NSArray *pathComp=[imgOnline pathComponents];
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Authors",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[imgOnline lastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadFilename]) {
            //image=[NSData dataWithContentsOfURL:[NSURL URLWithString:[results stringForColumn:@"image"]]];
            NSMutableArray *authorsImgs = [[NSMutableArray alloc] init];
            if ([APP_DELEGATE connectedToInternet]) {
                [authorsImgs addObject:[imgOnline stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            }
            if (authorsImgs.count != 0) {
                [[FDownloadManager shared] downloadAuthorsImage:authorsImgs];
            }
        }else{
            image = [UIImage imageWithContentsOfFile:downloadFilename];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return image;
}

+(FAuthor *)getAuthorWithID:(NSString *)authID
{
    FAuthor *author=[[FAuthor alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author where authorID=%@",authID]];
    while([results next]) {
        FAuthor *f=[[FAuthor alloc] init];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setImageLocal:[results stringForColumn:@"imageLocal"]];
        [f setCv:[results stringForColumn:@"cv"]];
        [f setActive:[results stringForColumn:@"active"]];
        author = f;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return author;
}


+(NSMutableArray *)getAuthors{
    NSMutableArray *authors=[[NSMutableArray alloc] init];
    NSMutableArray *authorsImgs = [[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author where active=1 ORDER BY name"]];
    while([results next]) {
        FAuthor *f=[[FAuthor alloc] init];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        if ([results stringForColumn:@"imageLocal"] && ![[results stringForColumn:@"imageLocal"] isEqualToString:@""])
        {
            NSArray *pathComp=[f.image pathComponents];
            NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Authors",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[f.image lastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            [f setImageLocal:downloadFilename];
        } else
        {
            if ([APP_DELEGATE connectedToInternet]) {
                [authorsImgs addObject:[f.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            }
        }
        [f setCv:[results stringForColumn:@"cv"]];
        [f setActive:[results stringForColumn:@"active"]];
        [authors addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if (authorsImgs.count != 0) {
        [[FDownloadManager shared] downloadAuthorsImage:authorsImgs];
    }
    
    return authors;
}

#pragma mark - Cases

+(NSMutableArray *)getCasesForCarouselFromDB
{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and alloweInCoverFlow=1"]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        [cases addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSMutableArray *returnCases=[[NSMutableArray alloc] init];
    for (int i=MIN(30, (int)[cases count]-1); i>=0; i--) {
        [returnCases addObject:[cases objectAtIndex:i]];
    }
    
    return returnCases;
}




+(NSMutableArray *)getCasesForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database
{
    NSMutableArray *tmp=[[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and (title like '%%%@%%' or name like '%%%@%%' or introduction like '%%%@%%' or procedure like '%%%@%%' or results like '%%%@%%' or 'references' like '%%%@%%')",searchTxt,searchTxt,searchTxt,searchTxt,searchTxt,searchTxt];
    
    if (![APP_DELEGATE connectedToInternet]) {
        query = [NSString stringWithFormat:@"%@ AND (isBookmark=1 OR alloweInCoverFlow=1)",query];
    }
    FMResultSet *results= [database executeQuery:query];

    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        if ([FCommon userPermission:[f userPermissions]] || [[f coverflow] isEqualToString:@"1"]) {
             [tmp addObject:f];
        }
    }
    return tmp;
}


+(FCase *)getCaseForFotona:(NSString *)caseID{
    FCase *f=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and caseID=%@",caseID]];
    while([results next]) {
        f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([FCommon userPermission:[f userPermissions]]) {
        return f;
    }
    return nil;
}

+(FCase *)getCaseWithID:(NSString *)caseID{
    FCase *f=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@",caseID]];
    while([results next]) {
        f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([FCommon userPermission:[f userPermissions]] || [[f coverflow] isEqualToString:@"1"]) {
        return f;
    }
    return nil;
}


+(NSMutableArray *)getCasesWithCategoryID:(NSString *)catID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT c.* FROM Cases as c,CasesInCategories as cic where cic.categorieID=%@ and cic.caseID=c.caseID and c.active=1",catID]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        if ([FCommon userPermission:[f userPermissions]] || [[f coverflow] isEqualToString:@"1"]) {
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}
+(NSMutableArray *)getCasesWithAuthorID:(NSString *)authorID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and authorID=%@",authorID]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        if ([FCommon userPermission:[f userPermissions]] || [[f coverflow] isEqualToString:@"1"]) {
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

+(NSMutableArray *)getAlphabeticalCasesForBookmark:(NSString *)category
{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and isBookmark=1 order by title"]];
    while([results next]) {
        NSString *usr = [FCommon getUser];
        FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, [results stringForColumn:@"caseID"]]];
        BOOL flag=NO;
        while([resultsBookmarked next]) {
            flag=YES;
        }
        
        if (flag) {
            FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
            if (![category isEqualToString:@"0"]) {
                if ([f.coverTypeID isEqualToString:category])
                    [cases addObject:f];
                
            } else {
                [cases addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}



+(void)removeCaseWithID:(NSString *)fotonaID{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"DELETE FROM Cases WHERE caseID=? ",fotonaID];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

#pragma mark - Case Category

+(NSMutableArray *)getCasebookMenu
{
    NSMutableArray *m=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM CaseCategories where categorieIDPrev is null AND active=1 order by sort"]];
    while([results next]) {
        FCaseCategory *cc=[[FCaseCategory alloc] init];
        [cc setCategoryID:[results stringForColumn:@"categorieID"]];
        [cc setCategoryIDPrev:[results stringForColumn:@"categorieIDPrev"]];
        [cc setTitle:[results stringForColumn:@"title"]];
        [cc setActive:[results stringForColumn:@"active"]];
        [m addObject:cc];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return m;
}

+(NSMutableArray *)getCaseCategoryWithPrev:(NSString *)prev
{
    NSMutableArray *m=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM CaseCategories where categorieIDPrev=%@ AND active=1 order by sort",prev]];
    while([results next]) {
        FCaseCategory *cc=[[FCaseCategory alloc] init];
        [cc setCategoryID:[results stringForColumn:@"categorieID"]];
        [cc setCategoryIDPrev:[results stringForColumn:@"categorieIDPrev"]];
        [cc setTitle:[results stringForColumn:@"title"]];
        [cc setActive:[results stringForColumn:@"active"]];
        [m addObject:cc];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return m;
}



#pragma mark - Events


+(NSArray *)getEventsFromDB
{
    NSMutableArray *events=[[NSMutableArray alloc] init];
    NSArray *eventsArray=[[NSArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Events ORDER BY title ASC"]];
    while([results next]) {
        FEvent *f=[[FEvent alloc] initWithDictionary:[results resultDictionary]];
        [events addObject:f];
        
    }
    
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    
    [database close];
    eventsArray = [events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [df dateFromString:[(FEvent*)a eventdate]];
        NSDate *second = [df dateFromString:[(FEvent*)b eventdate]];
        return [first compare:second];
    }];
    
    [APP_DELEGATE setEventArray:[eventsArray mutableCopy]];
    
    return eventsArray;
}

+(NSMutableArray *)getEventsForCategory:(NSString *)category
{
    
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    BOOL showEvent = false;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=?" withArgumentsInArray:[NSArray arrayWithObjects:usr,BOOKMARKEVENTS, nil]];
    while([resultsBookmarked next]) {
        showEvent = false;
        FEvent *e=[[FEvent alloc] init];
        FMResultSet *results = [database executeQuery:@"SELECT * FROM Events where eventID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"], nil]];
        while([results next]) {
            e=[[FEvent alloc] initWithDictionary:[results resultDictionary]];
            if (![category isEqualToString:@"0"]) {
                if (([e.eventcategories containsObject:category])|| ([category isEqualToString:@"4"] && [e.eventcategories containsObject:@"2"] )){
                    [menu addObject:e];
                }
            } else {
                [menu addObject:e];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return (menu);
}


+(NSMutableArray  *) fillEventsWithCategory:(NSInteger) ci andType:(NSInteger) ti andMobile:(BOOL) mobile{
    NSMutableArray * returnTable=[[NSMutableArray alloc] init];
    [returnTable removeAllObjects];
    NSArray *eventsTable = [FDB getEventsFromDB];
    for (int i=0; i<[eventsTable count]; i++) {
        BOOL addt = YES;
        BOOL addc = YES;
        if (ti>0){
            addt = NO;
            int temp =[[eventsTable objectAtIndex:i] typeE];
            if((temp/2) == ti)
                addt = YES;
        }
        if (ci>0) {
            addc = NO;
            NSArray * temp =[[eventsTable objectAtIndex:i] eventcategories];
            if([temp containsObject:[NSString stringWithFormat:@"%ld",ci]])
                addc = YES;
        }
        if (addt && addc) {
            if ((mobile && [[eventsTable objectAtIndex:i] mobileFeatured]) || (!mobile)) {
                [returnTable addObject:[eventsTable objectAtIndex:i]];
            }
        }
    }
    return returnTable;
}



#pragma mark - News

+(NSMutableArray *)getNewsForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database
{
    NSMutableArray *news=[[NSMutableArray alloc] init];
    
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=%@ and (title like '%%%@%%'or description like '%%%@%%'or text like '%%%@%%' ) ORDER BY newsID DESC",@"1",searchTxt,searchTxt,searchTxt]];
    while([results next]) {
        FNews *f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        [news addObject:f];
    }
    
    return news;
}

+(NSMutableArray *)getNewsSortedDateFromDB
{
    NSMutableArray *news=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=%hhd ORDER BY title DESC",YES]];
    while([results next]) {
        FNews *f;
        f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        [news addObject:f];
        
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    news = [NSMutableArray arrayWithArray:[news sortedArrayUsingFunction:dateSortForNews context:nil] ];
    
    //The date sort function
    return news;
}



+(NSMutableArray *)getNewsForCategory:(NSString *)category
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=?" withArgumentsInArray:[NSArray arrayWithObjects:usr,BOOKMARKNEWS, nil]];
    while([resultsBookmarked next]) {
        FNews *f=[[FNews alloc] init];
        FMResultSet *results = [database executeQuery:@"SELECT * FROM News where newsID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"], nil]];
        while([results next]) {
            f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
            
            if (![category isEqualToString:@"0"]) {
                
                if (([f.categories containsObject:category])|| ([category isEqualToString:@"4"] && [f.categories containsObject:@"2"] )){
                    [menu addObject:f];
                }
            } else {
                [menu addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return menu;
}


+(void)setNewsRead:(FNews *)news
{
    FMDatabase *databaseN = [FMDatabase databaseWithPath:DB_PATH];
    [databaseN open];
    
    NSString *usr = [FCommon getUser];
    NSString * newsIDtemp=[NSString stringWithFormat:@"%ld",[news newsID]];
    [databaseN executeUpdate:@"INSERT INTO NewsRead (newsID, userName) VALUES (?,?)",newsIDtemp,usr];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [databaseN close];
}

+(void)setNewsRest:(FNews *)news
{
    FMDatabase *databaseN = [FMDatabase databaseWithPath:DB_PATH];
    [databaseN open];
    
    NSString *usr = [FCommon getUser];
    NSString * newsIDtemp=[NSString stringWithFormat:@"%ld",[news newsID]];
    [databaseN executeUpdate:@"INSERT INTO NewsRead (newsID, userName) VALUES (?,?)",newsIDtemp,usr];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [databaseN close];
}


#pragma mark - Videos

+(NSMutableArray *)getVideosForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database{
    NSMutableArray *tmpVideo=[[NSMutableArray alloc] init];
    FMResultSet *results;
    if ([APP_DELEGATE connectedToInternet]) {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media m where m.mediaType=1 and m.active=1 and (m.title like '%%%@%%')",searchTxt]];
    } else {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media m where m.mediaType=1 AND isBookmark=1 AND m.active=1 and (m.title like '%%%@%%')",searchTxt]];
    }
    while([results next]) {
        FMedia *f=[[FMedia alloc] initWithDictionary:[results resultDictionary]];
        if ([FCommon userPermission:[f userPermissions]]) {
            [tmpVideo addObject:f];
        }
        
    }
    
    return tmpVideo;
}

+(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory
{
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    NSMutableArray *videosSelected=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? " withArgumentsInArray:@[usr, BOOKMARKVIDEO]];
    while([resultsBookmarked next]) {
        [videosSelected addObject:[resultsBookmarked objectForColumnName:@"documentID"]];
    }
    for (NSString *vidID in videosSelected) {
        FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ order by sort",vidID]];
        
        while([results2 next]) {
            FMedia *f=[[FMedia alloc] initWithDictionary:[results2 resultDictionary]];
            
            if ([FCommon checkItemPermissions:[f userPermissions] ForCategory:videoCategory]) {
                [videosTmp addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    videosTmp=[[videosTmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];
    return videosTmp;
}



#pragma mark - FotonaMenu

+(NSMutableArray *)getFotonaMenu:(NSString *)catID
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results;
    if (catID) {
        results= [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where active=1 and categoryIDPrev=%@ ORDER BY sort,fotonaCategoryType",catID]];
    }else{
        results= [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where active=1 and categoryIDPrev is null ORDER BY sort,fotonaCategoryType"]];
    }
    
    while([results next]) {
        FFotonaMenu *f=[[FFotonaMenu alloc] initWithDictionary:[results resultDictionary]];
        NSString *usr = [FCommon getUser];
        FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKPDF, f.categoryID]];
        NSString *flag=@"0";
        while([resultsBookmarked next]) {
            flag=@"1";
        }
        [f setBookmark:flag];
        BOOL checkFotona=[FCommon userPermission:[f userPermissions]];
        if (checkFotona) {
            [menu addObject:f];
        }
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortInt" ascending:YES];
    [menu sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return menu;
}

+(NSMutableArray *)getPDFForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database{
    NSMutableArray *tmpPDF=[[NSMutableArray alloc] init];
    FMResultSet *results;
    if ([APP_DELEGATE connectedToInternet]) {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media m where m.mediaType=2 and m.active=1 and (m.title like '%%%@%%')",searchTxt]];
    } else {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media m where m.mediaType=2 AND isBookmark=1 AND m.active=1 and (m.title like '%%%@%%')",searchTxt]];
    }
        while([results next]) {
        FMedia *f=[[FMedia alloc] initWithDictionary:[results resultDictionary]];
         if ([FCommon userPermission:[f userPermissions]]) {
             [tmpPDF addObject:f];
         }
    }
    
    return tmpPDF;
}

+(void)removeFotonaMenuWithID:(NSString *)fotonaID{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"DELETE FROM FotonaMenu WHERE categoryID=? ",fotonaID];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}



#pragma mark - Check if bookmarked

+(BOOL)checkIfBookmarkedForDocumentID:(NSString *)documentID andType:(NSString *)type
{
    BOOL bookmarked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, type, documentID]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    return bookmarked;
}


#pragma mark - Media

+(void)addMedia:(NSMutableArray *)m withType:(int)type andDownload:(BOOL) toDownload{
    if (m.count>0) {
        NSMutableArray *links =[[NSMutableArray alloc] init];
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        if (type==0) {
            [database open];
            for (FImage *img in m) {
                FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where itemID=%@ AND mediaType=0;", img.itemID]];
                BOOL flag=NO;
                while([results next]) {
                    flag=YES;
                }
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                if (!flag) {
                    
                    [database executeUpdate:@"INSERT INTO Media (mediaID, title, path, localPath, description, mediaType,  fileSize, deleted, sort) VALUES (?,?,?,?,?,?,?,?,?)",img.itemID, img.title, img.path, pathTmp, img.description, @"0", img.fileSize, img.deleted, img.sort];
                    
                    
                } else {
                    [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,,fileSize=?, deleted=?, sort=? WHERE mediaID=? AND mediaType=0",img.title, img.path, pathTmp, img.description, @"0", img.fileSize, img.deleted, img.sort, img.itemID];
                }
                [links addObject:img.path];
            }
            
            if (toDownload) {
                [[FDownloadManager shared] downloadImages:links];
            }
            
        }else {
            if (type==1){
                for (FMedia *v in m) {
                    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where itemID=%@ AND mediaType=1;", v.itemID]];
                    BOOL flag=NO;
                    while([results next]) {
                        flag=YES;
                    }
                    
                    if (!flag) {
                        [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,mediaImage,sort,userPermissions,active,deleted,download, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",  v.itemID,v.title,v.path,@"",v.description,@"1",@"0",v.mediaImage,v.sort,v.userPermissions, v.active, v.deleted, v.download, v.filesize];
                    } else {
                        [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaType=?,isBookmark=?,mediaImage=?,sort=?, userPermissions=?,active=?,deleted=?,download=?, fileSize=? WHERE mediaID=? AND mediaType=1",v.title,v.path,@"",v.description,@"1",v.bookmark,v.mediaImage,v.sort,v.userPermissions, v.active, v.deleted, v.download, v.filesize,v.itemID];
                    }
                }
            } else {
                if (type==2) {
                    for (FMedia *p in m) {
                        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where itemID=%@ AND mediaType=2;", p.itemID]];
                        BOOL flag=NO;
                        while([results next]) {
                            flag=YES;
                        }
                        
                        if (!flag) {
                            [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,mediaImage,sort,userPermissions,active,deleted,download, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",  p.itemID,p.title,p.path,@"",p.description,@"2",@"0",p.mediaImage,p.sort,p.userPermissions, p.active, p.deleted, p.download, p.filesize];
                        } else {
                            [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,isBookmark=?,mediaImage=?,sort=?, userPermissions=?,active=?,deleted=?,download=?, fileSize=? WHERE mediaID=? AND mediaType=2",p.title,p.path,@"",p.description,@"0",p.mediaImage, p.sort, p.userPermissions, p.active, p.deleted, p.download, p.filesize,p.itemID];
                        }
                    }
                }
            }
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
        [APP_DELEGATE setBookmarkAll:YES];
    }
    
}



+(void) updateMedia:(NSMutableArray *)mediaArray andType:(NSString *) type andDownload:(BOOL) download  forCase:(NSString *) caseID{
    BOOL deleted = NO;
    NSString *mediaType = @"-1";
    FMedia *media;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    if ([type isEqualToString:MEDIAIMAGE]) {
        for (FImage *img in mediaArray) {
            if ([[img deleted] isEqualToString:@"1"]) {
                [database executeUpdate:@"DELETE FROM Media WHERE mediaID=? AND mediaType=0",[img itemID]];
                [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[img itemID],[FCommon getUser],BOOKMARKCASE];
                 [FMediaManager deleteImage:img];
            } else {
                FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media WHERE mediaID=%@ AND mediaType=0;", img.itemID]];
                BOOL exists = NO;
                while ([results next]) {
                    exists = YES;
                }
                
                if (!exists) {
                    [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,sort,deleted, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?)",  img.itemID,img.title,img.path,@"",img.description,@"0",@"0",img.sort, img.deleted, img.fileSize];
                    if (download) {
                        [HelperBookmark addImageToDownloadList:img forCase:caseID];
                    }
                } else {
                    [database executeUpdate:@"UPDATE Media set title=?,path=?,description=?,sort=?, deleted=?, fileSize=? WHERE mediaID=? AND mediaType=1",img.title,img.path,img.description, img.sort, img.deleted, img.fileSize,img.itemID];
                }
            }
        }
    } else {
        //TODO: če je pdf ali video bookmarkan bi mogu sliko posodobit
        if ([type isEqualToString:MEDIAVIDEO]){
            for (FMedia *vid in mediaArray) {
                if ([[vid deleted] isEqualToString:@"1"]) {
                    [database executeUpdate:@"DELETE FROM Media WHERE mediaID=? AND mediaType=1",[vid itemID]];
                    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[vid itemID],[FCommon getUser],BOOKMARKVIDEO];
                     [FMediaManager deleteVideo:vid];
                    deleted = YES;
                    mediaType = MEDIAVIDEO;
                    media = vid;
                } else {
                    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media WHERE mediaID=%@ AND mediaType=1;", vid.itemID]];
                    BOOL exists = NO;
                    while ([results next]) {
                        exists = YES;
                    }
                    if (!exists) {
                        [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,mediaImage,sort,userPermissions,active,deleted,download, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",  vid.itemID,vid.title,vid.path,@"",vid.description,@"1",@"0",vid.mediaImage,vid.sort,vid.userPermissions, vid.active, vid.deleted, vid.download, vid.filesize];
                    } else {
                        [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaImage=?,sort=?, userPermissions=?,active=?,deleted=?,download=?, fileSize=? WHERE mediaID=? AND mediaType=1",vid.title,vid.path,@"",vid.description,vid.mediaImage, vid.sort, vid.userPermissions, vid.active, vid.deleted, vid.download, vid.filesize,vid.itemID];
                    }
                }
            }
        } else{
            if ([type isEqualToString:MEDIAPDF]){
                for (FMedia *pdf in mediaArray) {
                    if ([[pdf deleted] isEqualToString:@"1"]) {
                        [database executeUpdate:@"DELETE FROM Media WHERE mediaID=? AND mediaType=2",[pdf itemID]];
                        [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[pdf itemID],[FCommon getUser],BOOKMARKPDF];
                         [FMediaManager deletePDF:pdf];
                        deleted = YES;
                        mediaType = MEDIAPDF;
                        media = pdf;
                    } else {
                        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media WHERE mediaID=%@ AND mediaType=2;", pdf.itemID]];
                        BOOL exists = NO;
                        while ([results next]) {
                            exists = YES;
                        }
                        if (!exists) {
                            [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,mediaImage,sort,userPermissions,active,deleted,download, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",  pdf.itemID,pdf.title,pdf.path,@"",pdf.description,@"2",@"0",pdf.mediaImage,pdf.sort,pdf.userPermissions, pdf.active, pdf.deleted, pdf.download, pdf.filesize];
                        } else {
                            [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaImage=?,sort=?, userPermissions=?,active=?,deleted=?,download=?, fileSize=? WHERE mediaID=? AND mediaType=2",pdf.title,pdf.path,@"",pdf.description,pdf.mediaImage, pdf.sort, pdf.userPermissions, pdf.active, pdf.deleted, pdf.download, pdf.filesize,pdf.itemID];
                        }
                    }
                }
            }
        }
    }
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if (deleted) {
        [self removeFromFavoritesItem:[[media itemID] intValue] ofType:BOOKMARKVIDEO];
        if ([mediaType isEqualToString:MEDIAVIDEO] || [mediaType isEqualToString:MEDIAPDF]) {
            [self removeBookmarkedMedia:media];
        } 
    }
}


+(NSMutableArray *)getMediaForGallery:(NSString *)galleryItems withMediType: (NSString *)mediaType{
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    NSArray *videoIDArray = [FCommon stringToArray:galleryItems withSeparator:@","];
    if ([videoIDArray count] > 0) {
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        for (NSString * vid in videoIDArray) {
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaType=%@ AND mediaID=%@",mediaType, vid]];
            while ([results next]) {
                FMedia *video = [[FMedia alloc] initWithDictionary:[results resultDictionary]];
                if ([FCommon userPermission:[video userPermissions]]) {
                    [videosTmp addObject:video];
                }
            }
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
    
    return videosTmp;
}

+(FMedia *)getMediaWithId:(NSString *) videoId andType: (NSString *)mediaType{
    FMedia *video;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ and mediaType=%@ order by sort",videoId, mediaType]];
    while([results2 next]) {
        video = [[FMedia alloc] initWithDictionary:[results2 resultDictionary]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return video;
}

+(void) removeBookmarkedMedia:(FMedia *)media
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",media.itemID,usr,media.mediaType];
    
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",media.itemID,media.mediaType]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",media.itemID];
        
        NSString *downloadFilename = [FMedia createLocalPathForLink:[media path] andMediaType:[media mediaType]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:downloadFilename error:&error];
        
        NSArray *pathComp=[[media mediaImage] pathComponents];
        NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[media mediaImage] lastPathComponent]];
        [fileManager removeItemAtPath:pathTmp error:&error];
    }
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

+(void)removeFromBookmarkForMediaID:(NSString *)mediaID withMediaType:(NSString *)mediaType;
{
    FMedia *media = [self getMediaWithId:mediaID andType:mediaType];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",media.itemID,usr,media.mediaType];
    
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",media.itemID,media.mediaType]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",media.itemID];
        
        NSString *downloadFilename = [FMedia createLocalPathForLink:[media path] andMediaType:[media mediaType]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:downloadFilename error:&error];
        
        NSArray *pathComp=[[media mediaImage] pathComponents];
        NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[media mediaImage] lastPathComponent]];
        [fileManager removeItemAtPath:pathTmp error:&error];
    }
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}



#pragma mark - Favorites

+(void) addTooFavoritesItem:(int) documentID ofType:(NSString *) typeID {
    NSString *usr = [FCommon getUser];
    bool exist = [self checkIfFavoritesItem:documentID ofType:typeID];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if (!exist) {
        [database executeUpdate:@"INSERT INTO UserFavorites (username,documentID,typeID) VALUES (?,?,?)", usr, [NSString stringWithFormat:@"%d", documentID], typeID];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

+(void) removeFromFavoritesItem:(int) documentID ofType:(NSString *) typeID {
    NSString *usr = [FCommon getUser];
    bool exist = [self checkIfFavoritesItem:documentID ofType:typeID];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if (exist) {
        [database executeUpdate:@"DELETE FROM UserFavorites where username=? and documentID=? and typeID=?", usr, [NSString stringWithFormat:@"%d", documentID], typeID];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

+(BOOL)checkIfFavoritesItem:(int)documentID ofType:(NSString *)typeID{
    NSString *usr = [FCommon getUser];
    bool exist = false;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *resultsFavorites = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserFavorites where username='%@' AND documentID=%@ AND typeID=%@",usr, [NSString stringWithFormat:@"%d", documentID],typeID]];
    
    while([resultsFavorites next]) {
        exist = true;
    }
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return exist;
}

+ (NSMutableArray *) getAllFavoritesForUser {
    NSString *usr = [FCommon getUser];
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *resultsFavorites = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserFavorites where username='%@' ORDER BY typeID",usr]];
    while([resultsFavorites next]) {
        FItemFavorite *favorite = [[FItemFavorite alloc] initWithDictionary:[resultsFavorites resultDictionary]];
        [favorites addObject:favorite];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return favorites;
}


#pragma mark - Rest

NSComparisonResult dateSortForNews(FNews *n1, FNews *n2, void *context) {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSDate *d1 = [formatter dateFromString:n1.nDate];
    NSDate *d2 = [formatter dateFromString:n2.nDate];
    
    //return [d1 compare:d2]; // ascending order
    return [d2 compare:d1]; // descending order
}


+(NSMutableArray *)getDocuments
{
    NSMutableArray *doc=[[NSMutableArray alloc] init];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Documents where active=1"]];
    while([results next]) {
        FDocument *f=[[FDocument alloc] init];
        [f setDocumentID:[results stringForColumn:@"documentID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setIconType:[results stringForColumn:@"iconType"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setIsLink:[results stringForColumn:@"isLink"]];
        [f setLink:[results stringForColumn:@"link"]];
        [f setSrc:[results stringForColumn:@"src"]];
        [f setActive:[results stringForColumn:@"active"]];
        
        [doc addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return doc;
}

#pragma mark - Migration

+ (void) copyDatabaseIfNeeded {
    NSMutableArray *userBookmarked = [[NSMutableArray alloc] init];
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"fotona.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        [defaults synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"3.0" forKey:@"DBLastUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self resetAllDefaults];
        [APP_DELEGATE setBookmarkCountAll:0];
        [APP_DELEGATE setBookmarkCountLeft:0];
        [APP_DELEGATE setBookmarkSizeAll:0];
        [APP_DELEGATE setBookmarkSizeLeft:0];
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    } else {
        NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"DBLastUpdate"];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DBLastUpdate"] || ([lastUpdate floatValue]<2)) {
            [fileManager removeItemAtPath:dbPath error:&error];
            NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"fotona.db"];
            success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
            
            if (!success)
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            else{
                [[NSUserDefaults standardUserDefaults] setObject:@"2.4" forKey:@"DBLastUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self resetAllDefaults];
                
                
            }
        } else {
            //add sort column into media table if the database is 2.0 version
            if ([lastUpdate isEqualToString:@"2.0"]){
                FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                [database open];
                [database executeUpdate:@"ALTER TABLE Media ADD COLUMN sort INTEGER"];
                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                [database close];
                [[NSUserDefaults standardUserDefaults] setObject:@"2.1" forKey:@"DBLastUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [defaults setObject:@"" forKey:@"lastUpdate"];
                userBookmarked = [[NSMutableArray alloc] init];
                [defaults setObject:userBookmarked forKey:@"userBookmarked"];
                [defaults synchronize];
                lastUpdate = @"2.1";
            }
            //added bookmarking for event and news
            if ([lastUpdate isEqualToString:@"2.1"]){
                FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                [database open];
                [database executeUpdate:@"ALTER TABLE Events ADD COLUMN isBookmark TEXT"];
                [database executeUpdate:@"ALTER TABLE News ADD COLUMN isBookmark TEXT"];
                [database executeUpdate:@"ALTER TABLE UserBookmark ADD COLUMN categories TEXT"];
                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                [database close];
                [[NSUserDefaults standardUserDefaults] setObject:@"2.2" forKey:@"DBLastUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [defaults setObject:@"" forKey:@"lastUpdate"];
                userBookmarked = [[NSMutableArray alloc] init];
                [defaults setObject:userBookmarked forKey:@"userBookmarked"];
                [defaults synchronize];
                
                [APP_DELEGATE setBookmarkCountAll:0];
                [APP_DELEGATE setBookmarkCountLeft:0];
                [APP_DELEGATE setBookmarkSizeAll:0];
                [APP_DELEGATE setBookmarkSizeLeft:0];
                lastUpdate = @"2.2";
                
            }
            if ([lastUpdate isEqualToString:@"2.2"]){
                //added itemType for videos
                FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                [database open];
                [database executeUpdate:@"ALTER TABLE Media ADD COLUMN userType TEXT"];
                [database executeUpdate:@"ALTER TABLE Media ADD COLUMN userSubType TEXT"];
                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                [database close];
                [[NSUserDefaults standardUserDefaults] setObject:@"2.3" forKey:@"DBLastUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [defaults setObject:@"" forKey:@"lastUpdate"];
                userBookmarked = [[NSMutableArray alloc] init];
                [defaults setObject:userBookmarked forKey:@"userBookmarked"];
                [defaults synchronize];
                
                [APP_DELEGATE setBookmarkCountAll:0];
                [APP_DELEGATE setBookmarkCountLeft:0];
                [APP_DELEGATE setBookmarkSizeAll:0];
                [APP_DELEGATE setBookmarkSizeLeft:0];
                lastUpdate = @"2.3";
            }
            if ([lastUpdate isEqualToString:@"2.3"]){
                //added itemType for videos
                [[NSUserDefaults standardUserDefaults] setObject:@"2.4" forKey:@"DBLastUpdate"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"casesLastUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [defaults setObject:@"" forKey:@"lastUpdate"];
                userBookmarked = [[NSMutableArray alloc] init];
                [defaults setObject:userBookmarked forKey:@"userBookmarked"];
                [defaults synchronize];
                lastUpdate = @"2.4";
            }
            if ([lastUpdate isEqualToString:@"2.4"]){
                
                [fileManager removeItemAtPath:dbPath error:&error];
                NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"fotona.db"];
                success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
                
                if (!success)
                    NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
                else{
                    [[NSUserDefaults standardUserDefaults] setObject:@"3.0" forKey:@"DBLastUpdate"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self resetAllDefaults];
                }
                
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *directory = [NSString stringWithFormat:@"%@/%@/",docDir,FOLDERVIDEO];
                NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:directory error:nil];
                for (NSString *filename in fileArray)  {
                    
                    [fileMgr removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:NULL];
                }
                
                directory = [NSString stringWithFormat:@"%@/%@/",docDir,FOLDERIMAGE];
                fileArray = [fileMgr contentsOfDirectoryAtPath:directory error:nil];
                for (NSString *filename in fileArray)  {
                    
                    [fileMgr removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:NULL];
                }
                
                directory = [NSString stringWithFormat:@"%@/%@/",docDir,FOLDERPDF];
                fileArray = [fileMgr contentsOfDirectoryAtPath:directory error:nil];
                for (NSString *filename in fileArray)  {
                    
                    [fileMgr removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:NULL];
                }
                
                lastUpdate = @"3.0";
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dbPath]];
}


+ (NSString *) getDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/.db",documentsDir]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/.db",documentsDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path=[NSString stringWithFormat:@"%@/.db/fotona.db",documentsDir];
    return path;
}

+(void) resetAllDefaults{
    NSMutableArray *userBookmarked = [[NSMutableArray alloc] init];

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    [defaults setObject:@"" forKey:@"newsLastUpdate"];
    [defaults setObject:@"" forKey:@"eventsLastUpdate"];
    [defaults setObject:@"" forKey:@"caseCategoriesLastUpdate"];
    [defaults setObject:@"" forKey:@"casesLastUpdate"];
    [defaults setObject:@"" forKey:@"authorsLastUpdate"];
    [defaults setObject:@"" forKey:@"documentsLastUpdate"];
    [defaults setObject:@"" forKey:@"fotonaLastUpdate"];
    [defaults setObject:@"" forKey:@"lastUpdate"];
    [defaults setObject:userBookmarked forKey:@"userBookmarked"];
    [defaults synchronize];

}





@end

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
#import "FVideo.h"
#import "FDownloadManager.h"
#import "FItemFavorite.h"


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
        FCase *f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
            [cases addObject:f];
        }
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
    
    FMResultSet *results;
    if ([APP_DELEGATE checkGuest]) {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and (title like '%%%@%%' or name like '%%%@%%' or introduction like '%%%@%%' or procedure like '%%%@%%' or results like '%%%@%%' or 'references' like '%%%@%%')",searchTxt,searchTxt,searchTxt,searchTxt,searchTxt,searchTxt]];
    } else {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and allowedForGuests=1 and (title like '%%%@%%' or name like '%%%@%%' or introduction like '%%%@%%' or procedure like '%%%@%%' or results like '%%%@%%' or 'references' like '%%%@%%')",searchTxt,searchTxt,searchTxt,searchTxt,searchTxt,searchTxt]];
    }
    while([results next]) {
        FCase *f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [tmp addObject:f];
    }
    return tmp;
}


+(FCase *)getCaseForFotona:(NSString *)caseID{
    FCase *f=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and caseID=%@",caseID]];
    while([results next]) {
        f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([APP_DELEGATE checkGuest]) {
        if ([f.allowedForGuests isEqualToString:@"1"]) {
            return f;
        }
    } else {
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
        f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([APP_DELEGATE checkGuest]) {
        if ([f.allowedForGuests isEqualToString:@"1"]) {
            return f;
        }
    } else {
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
        FCase *f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
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
        FCase *f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
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
            FCase *f=[[FCase alloc] init];
            [f setCaseID:[results stringForColumn:@"caseID"]];
            [f setTitle:[results stringForColumn:@"title"]];
            [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
            [f setName:[results stringForColumn:@"name"]];
            [f setImage:[results stringForColumn:@"image"]];
            [f setIntroduction:[results stringForColumn:@"introduction"]];
            [f setProcedure:[results stringForColumn:@"procedure"]];
            [f setResults:[results stringForColumn:@"results"]];
            [f setReferences:[results stringForColumn:@"references"]];
            [f setParametars:[results stringForColumn:@"parameters"]];
            [f setDate:[results stringForColumn:@"date"]];
            [f setGalleryID:[results stringForColumn:@"galleryID"]];
            [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
            [f setActive:[results stringForColumn:@"active"]];
            [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
            [f setAuthorID:[results stringForColumn:@"authorID"]];
            [f setBookmark:[results stringForColumn:@"isBookmark"]];
            [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
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

+(void)removeBookmarkedCase:(FCase *)caseToRemove
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=0",caseToRemove.caseID,usr,nil];
    BOOL bookmarked = NO;
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where typeID=0 and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:caseToRemove.caseID, nil]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    
    if (!bookmarked) {
        if ([[caseToRemove coverflow] boolValue]) {
            [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"0",caseToRemove.caseID];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }
        else{
            [database executeUpdate:@"DELETE FROM Cases WHERE caseID=?",caseToRemove.caseID];
            [database executeUpdate:@"INSERT INTO Cases (caseID,title,name,active,authorID,isBookmark,alloweInCoverFlow) VALUES (?,?,?,?,?,?,?)",caseToRemove.caseID,caseToRemove.title,caseToRemove.name,caseToRemove.active,caseToRemove.authorID,@"0",caseToRemove.coverflow];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            
            [self deleteMediaForCaseGalleryID:caseToRemove.galleryID withArray:caseToRemove.images andType:0];
            [self deleteMediaForCaseGalleryID:caseToRemove.videoGalleryID withArray:caseToRemove.video andType:1];
        }
    }
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
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
    
    [APP_DELEGATE setEventArray:eventsArray];
    
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


#pragma mark - Videos

+(NSMutableArray *)getVideosForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database{
    NSMutableArray *tmpVideo=[[NSMutableArray alloc] init];
    
    FMResultSet *results;
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT res.* FROM (SELECT m.*, fm.categoryID  FROM Media m LEFT JOIN FotonaMenu fm  ON  m.galleryID = fm.videoGalleryID where m.mediaType=1 and fm.active=1 and (m.title like '%%%@%%')) as res LEFT JOIN FotonaMenuForUserSubType fust ON fust.fotonaID=res.categoryID WHERE fust.userSubType IN %@",searchTxt,[[APP_DELEGATE currentLogedInUser] userTypeSubcategory]]];
    }
    else{
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT res.* FROM (SELECT m.*, fm.categoryID  FROM Media m LEFT JOIN FotonaMenu fm  ON  m.galleryID = fm.videoGalleryID where m.mediaType=1 and fm.active=1 and (m.title like '%%%@%%')) LEFT JOIN FotonaMenuForUserType fut ON fut.fotonaID=res.categoryID WHERE fut.userType=%@",searchTxt,[[APP_DELEGATE currentLogedInUser] userType]]];
    }
    
    while([results next]) {
        FVideo *f=[[FVideo alloc] init];
        [f setItemID:[results stringForColumn:@"mediaID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setPath:[results stringForColumn:@"path"]];
        [f setLocalPath:[results stringForColumn:@"localPath"]];
        [f setVideoGalleryID:[results stringForColumn:@"galleryID"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setTime:[results stringForColumn:@"time"]];
        [f setVideoImage:[results stringForColumn:@"videoImage"]];
        [f setSort:[results stringForColumn:@"sort"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setUserType:[results stringForColumn:@"userType"]];
        [f setUserSubType:[results stringForColumn:@"userSubType"]];
        
        [tmpVideo addObject:f];
    }
    
    return tmpVideo;
}

+(NSMutableArray *)getVideosWithGallery:(NSString *)videoGalleryID
{
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where galleryID=%@ order by sort",videoGalleryID]];
    while([results next]) {
        FVideo *f=[[FVideo alloc] init];
        [f setItemID:[results stringForColumn:@"mediaID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setPath:[results stringForColumn:@"path"]];
        [f setLocalPath:[results stringForColumn:@"localPath"]];
        [f setVideoGalleryID:[results stringForColumn:@"galleryID"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setTime:[results stringForColumn:@"time"]];
        [f setVideoImage:[results stringForColumn:@"videoImage"]];
        [f setSort:[results stringForColumn:@"sort"]];
        [f setUserType:[results stringForColumn:@"userType"]];
        [f setUserSubType:[results stringForColumn:@"userSubType"]];
        /* ta del za pravice na videu
         if ([f checkVideoForUser]) {
         [videosTmp addObject:f];
         } */// če so pravice na videu
        
        if (f.videoGalleryID != nil) {
            FMResultSet *resultsFC= [database executeQuery:[NSString stringWithFormat:@"SELECT categoryID FROM FotonaMenu where active=1 and videoGalleryID=%@",f.videoGalleryID]];
            
            NSString *fCategory = @"";
            while([resultsFC next]) {
                fCategory = [resultsFC stringForColumn:@"categoryID"];
            }
            
            if ([self checkFotonaForUserSearch:fCategory]) {
                [videosTmp addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return videosTmp;
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
            FVideo *f=[[FVideo alloc] init];
            [f setItemID:[results2 stringForColumn:@"mediaID"]];
            [f setTitle:[results2 stringForColumn:@"title"]];
            [f setPath:[results2 stringForColumn:@"path"]];
            [f setLocalPath:[results2 stringForColumn:@"localPath"]];
            [f setVideoGalleryID:[results2 stringForColumn:@"galleryID"]];
            [f setDescription:[results2 stringForColumn:@"description"]];
            [f setTime:[results2 stringForColumn:@"time"]];
            [f setVideoImage:[results2 stringForColumn:@"videoImage"]];
            [f setSort:[results2 stringForColumn:@"sort"]];
            [f setUserType:[results2 stringForColumn:@"userType"]];
            [f setUserSubType:[results2 stringForColumn:@"userSubType"]];
            
            if ([f checkVideoForCategory:videoCategory]) {
                [videosTmp addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    videosTmp=[videosTmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    return videosTmp;
}



+(void) removeBookmarkedVideo:(FVideo *)videoToRemove
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",videoToRemove.itemID,usr,BOOKMARKVIDEO];
    
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",videoToRemove.itemID,BOOKMARKVIDEO]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",videoToRemove.itemID];
        NSString *downloadFilename = [videoToRemove path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:downloadFilename error:&error];
        
        NSArray *pathComp=[[videoToRemove videoImage] pathComponents];
        NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[videoToRemove videoImage] lastPathComponent]];
        [fileManager removeItemAtPath:pathTmp error:&error];
    }
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

+(FVideo *)getVideoWithId:(NSString *) videoId{
    FVideo *video=[[FVideo alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ and mediaType=1 order by sort",videoId]];
    
    [video setItemID:[results2 stringForColumn:@"mediaID"]];
    [video setTitle:[results2 stringForColumn:@"title"]];
    [video setPath:[results2 stringForColumn:@"path"]];
    [video setLocalPath:[results2 stringForColumn:@"localPath"]];
    [video setVideoGalleryID:[results2 stringForColumn:@"galleryID"]];
    [video setDescription:[results2 stringForColumn:@"description"]];
    [video setTime:[results2 stringForColumn:@"time"]];
    [video setVideoImage:[results2 stringForColumn:@"videoImage"]];
    [video setSort:[results2 stringForColumn:@"sort"]];
    [video setUserType:[results2 stringForColumn:@"userType"]];
    [video setUserSubType:[results2 stringForColumn:@"userSubType"]];
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return video;
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
        FFotonaMenu *f=[[FFotonaMenu alloc] init];
        [f setCategoryID:[results stringForColumn:@"categoryID"]];
        [f setCategoryIDPrev:[results stringForColumn:@"categoryIDPrev"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setFotonaCategoryType:[results stringForColumn:@"fotonaCategoryType"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setText:[results stringForColumn:@"text"]];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setPdfSrc:[results stringForColumn:@"pdfSrc"]];
        [f setExternalLink:[results stringForColumn:@"externalLink"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setSort:[results stringForColumn:@"sort"]];
        [f setIconName:[results stringForColumn:@"icon"]];
        [f setSortInt:[f.sort intValue]];
        NSString *usr = [FCommon getUser];
        FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKPDF, f.categoryID]];
        NSString *flag=@"0";
        while([resultsBookmarked next]) {
            flag=@"1";
        }
        [f setBookmark:flag];
        BOOL checkFotona=[FDB checkFotonaForUser:f];
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
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT fm.* FROM FotonaMenu fm LEFT JOIN FotonaMenuForUserSubType fust ON fust.fotonaID=fm.categoryID where fm.fotonaCategoryType = 6 and fm.active=1 and (fm.title like '%%%@%%') AND fust.userSubType IN %@",searchTxt,[[APP_DELEGATE currentLogedInUser] userTypeSubcategory]]];
    }
    else{
        results = [database executeQuery:[NSString stringWithFormat:@"SELECT fm.* FROM FotonaMenu fm LEFT JOIN FotonaMenuForUserType fut ON fut.fotonaID=fm.categoryID where fm.fotonaCategoryType = 6 and fm.active=1 and (fm.title like '%%%@%%') AND fut.userType=%@",searchTxt,[[APP_DELEGATE currentLogedInUser] userType]]];
    }
    while([results next]) {
        FFotonaMenu *f=[[FFotonaMenu alloc] init];
        [f setCategoryID:[results stringForColumn:@"categoryID"]];
        [f setCategoryIDPrev:[results stringForColumn:@"categoryIDPrev"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setFotonaCategoryType:[results stringForColumn:@"fotonaCategoryType"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setText:[results stringForColumn:@"text"]];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setPdfSrc:[results stringForColumn:@"pdfSrc"]];
        [f setExternalLink:[results stringForColumn:@"externalLink"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setSort:[results stringForColumn:@"sort"]];
        [f setIconName:[results stringForColumn:@"icon"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        
        [tmpPDF addObject:f];
    }
    
    return tmpPDF;
}



+(NSMutableArray *)getPDFForCategory:(NSString *)category
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    NSMutableArray *documents=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=2" withArgumentsInArray:[NSArray arrayWithObjects:usr, nil]];
    while([resultsBookmarked next]) {
        [documents addObject:[resultsBookmarked objectForColumnName:@"documentID"]];
    }
    for (NSString *docID in documents) {
        FMResultSet *results = [database executeQuery:@"SELECT * FROM FotonaMenu where categoryID=? and active=1" withArgumentsInArray:[NSArray arrayWithObjects:docID, nil]];
        
        while([results next]) {
            FFotonaMenu *f=[[FFotonaMenu alloc] init];
            [f setCategoryID:[results stringForColumn:@"categoryID"]];
            [f setCategoryIDPrev:[results stringForColumn:@"categoryIDPrev"]];
            [f setTitle:[results stringForColumn:@"title"]];
            [f setFotonaCategoryType:[results stringForColumn:@"fotonaCategoryType"]];
            [f setDescription:[results stringForColumn:@"description"]];
            [f setText:[results stringForColumn:@"text"]];
            [f setCaseID:[results stringForColumn:@"caseID"]];
            [f setPdfSrc:[results stringForColumn:@"pdfSrc"]];
            [f setExternalLink:[results stringForColumn:@"externalLink"]];
            [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
            [f setActive:[results stringForColumn:@"active"]];
            [f setSort:[results stringForColumn:@"sort"]];
            [f setIconName:[results stringForColumn:@"icon"]];
            [f setBookmark:[results stringForColumn:@"isBookmark"]];
            
            if (![category isEqualToString:@"0"]) {
                if ([self checkFotonaForUser:f andCategory:category]) {
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



#pragma mark - User

+(BOOL)checkFotonaForUserSearch:(NSString *)fc;
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        for (NSString *subType in [[APP_DELEGATE currentLogedInUser] userTypeSubcategory]) {
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",fc,subType]];
            while([results next]) {
                check=YES;
            }
        }
    }
    else{
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserType where fotonaID=%@ and userType=%@",fc,[[APP_DELEGATE currentLogedInUser] userType]]];
        while([results next]) {
            check=YES;
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
}


+(BOOL)checkFotonaForUser:(FFotonaMenu *)f
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        for (NSString *subType in [[APP_DELEGATE currentLogedInUser] userTypeSubcategory]) {
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",f.categoryID,subType]];
            while([results next]) {
                check=YES;
            }
        }
    }
    else{
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserType where fotonaID=%@ and userType=%@",f.categoryID,[[APP_DELEGATE currentLogedInUser] userType]]];
        while([results next]) {
            check=YES;
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
}

+(BOOL)checkFotonaForUser:(FFotonaMenu *)f andCategory:(NSString *)category
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",f.categoryID,category]];
    while([results next]) {
        check=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
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


+(void)removeFromBookmarkForDocumentID:(NSString *)documentID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",documentID,usr,BOOKMARKPDF];
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",documentID,BOOKMARKPDF]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        NSString * pdfSrc=@"";
        [database executeUpdate:@"UPDATE FotonaMenu set isBookmark=? where categoryID=?",@"0",documentID];
        
        FMResultSet *results= [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where active=1 and categoryID=%@",documentID]];
        while([results next]) {
            pdfSrc = [results stringForColumn:@"pdfSrc"];
        }
        NSString *folder=@".PDF";
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[pdfSrc lastPathComponent]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:downloadFilename error:&error];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}


#pragma mark - Media

+(void)addMedia:(NSMutableArray *)m withType:(int)type{
    if (m.count>0) {
        NSMutableArray *links =[[NSMutableArray alloc] init];
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,galleryID,title,path,localPath,description,mediaType,isBookmark,sort) VALUES (?,?,?,?,?,?,?,?,?)",img.itemID,img.galleryID,img.title,img.path,pathTmp,img.description,@"0",@"0",img.sort];
                //                [img downloadFile:img.path inFolder:@"/.Cases"];
                [links addObject:img.path];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            [APP_DELEGATE setBookmarkAll:YES];
            [[FDownloadManager shared] downloadImages:links];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FVideo *vid in m) {
                NSArray *pathComp=[vid.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,galleryID,title,path,localPath,description,mediaType,isBookmark,time,videoImage,sort, userType,userSubType) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.videoGalleryID,vid.title,vid.path,pathTmp,vid.description,@"1",@"0",vid.time,vid.videoImage,vid.sort, vid.userType,vid.userSubType];
                [links addObject:vid.path];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            [APP_DELEGATE setBookmarkAll:YES];
            [[FDownloadManager shared] downloadVideos:links];
        }
        
    }
}

+(void)deleteMediaForCaseGalleryID:(NSString *)gID withArray:(NSMutableArray *)array andType:(int)t
{
    if (t==0) {
        for (FImage *img in array) {
            NSArray *pathComp=[img.path pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    } else if (t==1){
        for (FVideo *vid in array) {
            NSArray *pathComp=[vid.path pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    }
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"delete from Media where galleryID=?",gID];
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



@end

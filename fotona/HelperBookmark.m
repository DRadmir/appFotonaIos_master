//
//  HelperBookmark.m
//  fotona
//
//  Created by Janos on 29/07/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "HelperBookmark.h"
#import "FMDatabase.h"
#import "FImage.h"
#import "FMedia.h"
#import "FDownloadManager.h"
#import "FItemBookmark.h"
#import "AFNetworking.h"
#import "FIFlowController.h"
#import "FHelperRequest.h"

@implementation HelperBookmark
{
}
NSMutableArray *newsToBookmark;
NSMutableArray *eventsToBookmark;
NSMutableArray *casesToBookmark;
NSMutableArray *fotonaToBookmark;
int bookmarkedCount;

+(void)bookmarkAll:(NSArray *)categorys{
    bookmarkedCount = 0;
    for (NSIndexPath *obj in categorys) {
        NSArray *temp =[APP_DELEGATE currentLogedInUser].userTypeSubcategory;
        if ([[APP_DELEGATE currentLogedInUser].userType intValue] == 0 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 1 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3) {
            temp =  @[@"2", @"1",  @"3"];;
        }
        int category =[[temp objectAtIndex:obj.row] intValue];
        //bookmark news
        [self selectNews:category];
        //bookmark events
        [self selectEvents:category];
        //bokmark cases
        [self selectCases:category];
        //bookmark fotona
        [self selectFotona:category];
        if (category == 2) {
            //bookmark news
            [self selectNews:4];
            //bookmark events
            [self selectEvents:4];
        }
    }
    [[FDownloadManager shared] prepareForDownloadingFiles];
    //    if ([APP_DELEGATE downloadList].count == 0) {
    //        NSLog(@"%d",bookmarkedCount);
    //        [HelperBookmark success];
    //    }
}

+(void) cancelBookmark {
    
    [[FDownloadManager shared] cancelDownload];
    
}

#pragma mark News

+(void) selectNews: (int) category{
    NSMutableDictionary *list = [NSMutableDictionary new];
    NSString * c;
    NSArray *categories;
    int newsID;
    FMDatabase *newsDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedNews;
    [newsDatabase open];
    selectedNews = [newsDatabase executeQuery:[NSString stringWithFormat:@"SELECT newsID, categories FROM News"]];
    while([selectedNews next]) {
        c = [selectedNews stringForColumn:@"categories"];
        categories =  [c componentsSeparatedByString:@","];
        newsID = [selectedNews intForColumn:@"newsID"];
        [list setObject:categories forKey:@(newsID)];
    }
    [newsDatabase close];
    FNews *n;
    for (id nID in list.allKeys) {
        if ([[list objectForKey:nID] containsObject:[[NSNumber numberWithInt:category] stringValue]]) {
            if (![self bookmarked:[nID intValue] withType:BOOKMARKNEWS inCategory:category]) {
                [newsDatabase open];
                selectedNews = [newsDatabase executeQuery:@"SELECT * FROM News where newsID=?" withArgumentsInArray:@[[[NSNumber numberWithInt:[nID intValue]] stringValue]]];
                while([selectedNews next]) {
                    n=[[FNews alloc] initWithDictionary:[selectedNews resultDictionary]];
                }
                [newsDatabase close];
                [self bookmarkNews:n forCategory:(int) category];
            }
        }
    }
}

+(void) bookmarkNews: (FNews *) news forCategory:(int) category{
    if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",news.newsID] forCategory:category andType:BOOKMARKNEWS]) {
        NSString *url_Img_FULL = news.headerImageLink;
        [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
       //TODO: FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:news.newsID ofType:BOOKMARKNEWS inCategory:category withLink:url_Img_FULL];
       //TODO: [[APP_DELEGATE downloadList] addObject:headerImage];
        [HelperBookmark countBookmarks:1];
        for (int i =0; i<[news.imagesLinks count]; i++) {
            NSString *url_Img_FULL = [news.imagesLinks objectAtIndex:i];
            [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
          //TODO:  FItemBookmark *image = [[FItemBookmark alloc] initWithItemIDint:news.newsID ofType:BOOKMARKNEWS inCategory:category withLink:url_Img_FULL];
          //TODO:  [[APP_DELEGATE downloadList] addObject:image];
            [HelperBookmark countBookmarks:1];
        }
        
    }
    
}



#pragma mark Events

+(void) selectEvents: (int) category{
    NSMutableDictionary *list = [NSMutableDictionary new];
    NSString * c;
    NSArray *categories;
    int eventID;
    FMDatabase *newsDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedEvents;
    [newsDatabase open];
    selectedEvents = [newsDatabase executeQuery:[NSString stringWithFormat:@"SELECT eventID, categories FROM Events"]];
    while([selectedEvents next]) {
        c = [selectedEvents stringForColumn:@"categories"];
        categories =  [c componentsSeparatedByString:@","];
        eventID = [selectedEvents intForColumn:@"eventID"];
        [list setObject:categories forKey:@(eventID)];
    }
    [newsDatabase close];
    FEvent *e;
    for (id eID in list.allKeys) {
        if ([[list objectForKey:eID] containsObject:[[NSNumber numberWithInt:category] stringValue]]) {
            if (![self bookmarked:[eID intValue] withType:BOOKMARKEVENTS inCategory:category]) {
                [newsDatabase open];
                selectedEvents = [newsDatabase executeQuery:@"SELECT * FROM Events where eventID=?" withArgumentsInArray:@[[[NSNumber numberWithInt:[eID intValue]] stringValue]]];
                while([selectedEvents next]) {
                    e=[[FEvent alloc] initWithDictionary:[selectedEvents resultDictionary]];
                }
                [newsDatabase close];
                [self bookmarkEvent:e forCategory:(int) category];
            }
        }
    }
}

+(void) bookmarkEvent: (FEvent *) event forCategory:(int) category{
    //    NSLog(@"Event id:%ld",(long)event.eventID);
    NSString *categories = [NSString stringWithFormat:@"%d",category];
    NSString *eventUsr = [FCommon getUser];
    FMDatabase *eventsBookmarkDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [eventsBookmarkDatabase open];
    BOOL bookmarked = true;
    FMResultSet *resultsBookmarkedAlready =  [eventsBookmarkDatabase executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[eventUsr,BOOKMARKEVENTS,[NSString stringWithFormat:@"%ld", event.eventID]]];
    while([resultsBookmarkedAlready next]) {
        bookmarked = false;
    }
    if (bookmarked) {
        [eventsBookmarkDatabase executeUpdate:@"INSERT INTO UserBookmark (username,documentID,typeID) VALUES (?,?,?)",eventUsr,[NSString stringWithFormat:@"%ld", event.eventID],BOOKMARKEVENTS];
    }
    //    [eventsBookmarkDatabase executeUpdate:@"INSERT INTO UserBookmark (username,documentID,typeID, categories) VALUES (?,?,?,?)",eventUsr,[NSString stringWithFormat:@"%ld", event.eventID],BOOKMARKEVENTS,categories];
    [eventsBookmarkDatabase executeUpdate:@"UPDATE Events set isBookmark=? where eventID=?",@"1", [NSString stringWithFormat:@"%ld", (long)event.eventID]];
    [eventsBookmarkDatabase close];
}


#pragma mark checkIfBookmarked

+(BOOL) bookmarked: (int) itemID withType:(NSString *)type inCategory:(int) category {
    NSString *itemUsr = [FCommon getUser];
    FMDatabase *localDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [localDatabase open];
    FMResultSet *resultsBookmarked =  [localDatabase executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[itemUsr,type,[[NSNumber numberWithInt:itemID] stringValue]]];
    while([resultsBookmarked next]) {
        //        NSString * c = [resultsBookmarked stringForColumn:@"categories"];
        //        NSArray *categories =  [c componentsSeparatedByString:@","];
        //        if (![categories containsObject:[[NSNumber numberWithInt:category] stringValue]]){
        //
        //            //TODO to preselt v funkcijo ki bookmarka
        //            c = [c stringByAppendingString:[NSString stringWithFormat:@"%d", category]];
        //            [localDatabase executeUpdate:@"UPDATE UserBookmark set categories=? where userBookmarkID=?",c, [resultsBookmarked stringForColumn:@"userBookmarkID"]];
        //        }
        [localDatabase close];
        return YES;
    }
    [localDatabase close];
    return NO;
}

+(BOOL) bookmarked: (int) itemID withType:(NSString *)type{
    NSString *itemUsr = [FCommon getUser];
    FMDatabase *localDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [localDatabase open];
    FMResultSet *resultsBookmarked =  [localDatabase executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[itemUsr,type,[[NSNumber numberWithInt:itemID] stringValue]]];
    while([resultsBookmarked next]) {
        [localDatabase close];
        return YES;
    }
    [localDatabase close];
    return NO;
}

+(void) selectCases: (int) category{
    NSMutableArray *list = [NSMutableArray new];
    FMDatabase *casesDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [casesDatabase open];
            FMResultSet *selectedCases = [casesDatabase executeQuery:@"SELECT * FROM Cases where coverTypeID=? AND active=1 AND download=1" withArgumentsInArray:@[[[NSNumber numberWithInt:category] stringValue]]];
        
    while([selectedCases next]) {
        FCase * selected =  [[FCase alloc] initWithDictionaryFromDB:[selectedCases resultDictionary]];
        if ([FCommon userPermission:[selected userPermissions]] && [FCommon checkItemPermissions:[selected userPermissions] ForCategory:[NSString stringWithFormat:@"%d",category]]) {
             [list addObject:selected];
        }
    }
    [casesDatabase close];
    
    for (FCase *sCase in list) {
        if (![self bookmarked:[[sCase caseID] intValue] withType:BOOKMARKCASE inCategory:category]) {
            [self bookmarkCase:sCase forCategory:category];
        }
    }
}



+ (void)bookmarkCase:(FCase*) currentCase forCategory:(int) category {
    
    if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[currentCase.caseID intValue]] forCategory:category andType:BOOKMARKCASE]) {
        NSString *usr = [FCommon getUser];
        if (![[currentCase coverflow] boolValue]) {
            //insertMedia TODO
            
            NSMutableArray *imgs = [currentCase parseImages];
            NSMutableArray *videosA = [currentCase parseVideosFromServer:NO];
            
            [self addMedia:imgs withType:0 fromcase:[currentCase.caseID intValue] inCategory:category];
            [self addMedia:videosA withType:1 fromcase:[currentCase.caseID intValue] inCategory:category];
            if (imgs.count == 0) {
                FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                [database open];
                //            if (category == 0) {
                BOOL bookmarked = true;
                FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKCASE,currentCase.caseID]];
                while([resultsBookmarkedAlready next]) {
                    bookmarked = false;
                }
                if (bookmarked) {
                    [database executeUpdate:@"INSERT INTO UserBookmark (documentID, username, typeID) VALUES (?,?,0)",currentCase.caseID,usr];
                }
                //            } else {
                //                [database executeUpdate:@"INSERT INTO UserBookmark (documentID, username, typeID,categories) VALUES (?,?,0,?)",currentCase.caseID,usr,[NSString stringWithFormat:@"%d",category]];
                //            }
                
                [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"1",currentCase.caseID];
                [database close];
            }
            
        }else{
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            //            if (category == 0) {
            BOOL bookmarked = true;
            FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKCASE,currentCase.caseID]];
            while([resultsBookmarkedAlready next]) {
                bookmarked = false;
            }
            if (bookmarked) {
                [database executeUpdate:@"INSERT INTO UserBookmark (documentID, username, typeID) VALUES (?,?,0)",currentCase.caseID,usr];
            }
            //            } else {
            //                [database executeUpdate:@"INSERT INTO UserBookmark (documentID, username, typeID,categories) VALUES (?,?,0,?)",currentCase.caseID,usr,[NSString stringWithFormat:@"%d",category]];
            //            }
            
            [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"1",currentCase.caseID];
            [database close];
            
            if ([FCommon isIpad]) {
                if ([[[APP_DELEGATE casebookController] currentCase] caseID] == currentCase.caseID ) {
                    [[APP_DELEGATE casebookController] refreshBookmarkBtn];
                }
            } else{
                 FIFlowController *flow = [FIFlowController sharedInstance];
                if ([[flow caseOpened] caseID] == currentCase.caseID ) {
                    [[flow caseView] refreshBookmarkBtn];
                }
            }
            
            
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    }
}

+(void)addMedia:(NSMutableArray *)m withType:(int)type fromcase:(int)caseID inCategory:(int)category{
    if (m.count>0) {
        
        NSMutableArray *links =[[NSMutableArray alloc] init];
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                [links addObject:img.path];
              //TODO:  FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:caseID ofType:BOOKMARKCASE inCategory:category withLink:img.path];
               //TODO: [[APP_DELEGATE downloadList] addObject:headerImage];
                [[APP_DELEGATE imagesToDownload] addObject:img.path];
                [HelperBookmark countBookmarks:1];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                [links addObject:vid.path];
               //TODO: FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:caseID ofType:BOOKMARKCASE inCategory:category withLink:vid.path];
              //TODO:  [[APP_DELEGATE downloadList] addObject:headerImage];
                
                [[APP_DELEGATE videosToDownload] addObject:vid.path];
                [HelperBookmark countBookmarks:1];
            }
            [database close];
        }
        
    }
}



+(void)bookmarkMedia:(NSMutableArray *)m withType:(int)type{
    if (m.count>0) {
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                FMResultSet *mediaSelect = [database executeQuery:@"SELECT * FROM Media where mediaID=?  and mediaType=0"withArgumentsInArray:@[img.itemID]];
                BOOL flag = NO;
                while([mediaSelect next]) {
                    flag = YES;
                }
                if (!flag) {
                    [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,sort, deleted, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?)",img.itemID,img.title,img.path,pathTmp,img.description,@"0",@"1",img.sort, img.deleted, img.fileSize];
                    bookmarkedCount++;
                } else {
                    [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaType=?,sort=?, deleted=?, fileSize=? where mediaID=?",img.title,img.path,pathTmp,img.description,@"0",img.sort,img.itemID,img.deleted, img.fileSize ];
                }
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                NSArray *pathComp=[vid.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                FMResultSet *mediaSelect = [database executeQuery:@"SELECT * FROM Media where mediaID=? and mediaType=1"withArgumentsInArray:@[vid.itemID]];
                BOOL flag = NO;
                while([mediaSelect next]) {
                    flag = YES;
                }
                if (!flag) {
                    [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,time,mediaImage,sort, active, deleted, download, fileSize, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.title,vid.path,pathTmp,vid.description,@"1",@"1",vid.time,vid.mediaImage,vid.sort, vid.active, vid.deleted, vid.download, vid.filesize, vid.userPermissions];
                    bookmarkedCount++;
                } else {
                    [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaType=?,time=?,mediaImage=?,sort=?, userPermissions=?, active=?, deleted=?, download=?, fileSize=? where mediaID=?",vid.title,vid.path,pathTmp,vid.description,@"1",vid.time,vid.mediaImage,vid.sort, vid.userPermissions, vid.active, vid.deleted, vid.download, vid.filesize, vid.itemID];
                }
            }
            [database close];
        }
        
    }
}

/*select fotona po ko so bila pravice na videu
+(void) selectFotona: (int) category{
    NSMutableArray *list = [NSMutableArray new];
    
    FMDatabase *fotonaDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedFotona;
    [fotonaDatabase open];
    selectedFotona = [fotonaDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu WHERE  fotonaCategoryType=6 and active=1"]];//(fotonaCategoryType=4 OR fotonaCategoryType=6)
    while([selectedFotona next]) {
        FFotonaMenu* f=[[FFotonaMenu alloc] initWithDictionary:[selectedFotona resultDictionary]];
        if ([self checkFotona:f forCategory:category]) {
            [list addObject:f];
        }
    }
    [fotonaDatabase close];
    for (FFotonaMenu * menu in list) {
        if ([menu.fotonaCategoryType intValue] ==6) {
            if (![self bookmarked:[menu.categoryID intValue] withType:BOOKMARKPDF inCategory:category]) {
                if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[menu.categoryID intValue]] forCategory:category andType:BOOKMARKPDF]) {
                    FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[menu.categoryID intValue] ofType:BOOKMARKPDF inCategory:category withLink:[menu.pdfSrc stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
                    [[APP_DELEGATE downloadList] addObject:headerImage];
                    [[APP_DELEGATE pdfToDownload] addObject:menu.pdfSrc];
                    [HelperBookmark countBookmarks:1];
                }
                
            }
        }
    }
    
    [list removeAllObjects];
    
    [fotonaDatabase open];
    selectedFotona = [fotonaDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu WHERE  fotonaCategoryType=4 and active=1"]];//(fotonaCategoryType=4 OR fotonaCategoryType=6)
    while([selectedFotona next]) {
        FFotonaMenu* f=[[FFotonaMenu alloc] initWithDictionary:[selectedFotona resultDictionary]];
        [list addObject:f];
    }
    [fotonaDatabase close];
    for (FFotonaMenu * menu in list) {
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *videos = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media WHERE galleryID = %d and mediaType=1",[menu.videoGalleryID intValue]]];
        while([videos next]) {
            FVideo *f=[[FVideo alloc] init];
            [f setTitle:[videos stringForColumn:@"title"]];
            [f setItemID:[videos stringForColumn:@"mediaID"]];
            [f setUserType:[videos stringForColumn:@"userType"]];
            [f setUserSubType:[videos stringForColumn:@"userSubType"]];
            [f setBookmark:[videos stringForColumn:@"isBookmark"]];
            NSLog(@"%@",f.title);
            if ([f checkVideoForUser]) {
                if (![self bookmarked:[[videos stringForColumn:@"mediaID"] intValue] withType:BOOKMARKVIDEO inCategory:category]) {
//                    NSString *usr =[APP_DELEGATE currentLogedInUser].username;
//                    if (usr == nil) {
//                        usr =@"guest";
//                    }
//                    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%d and isBookmark=1 and mediaType=1",[[videos stringForColumn:@"mediaID"] intValue]]];
//                    BOOL flag=NO;
//                    while([resultsBookmarked next]) {
//                        flag=YES;
////                        NSLog(@"%@, %@",[resultsBookmarked stringForColumn:@"mediaID"],[resultsBookmarked stringForColumn:@"isBookmark"]);
//                    }
                    if ([f.bookmark isEqualToString:@"0"]) {
                        if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[[videos stringForColumn:@"mediaID"] intValue]] forCategory:category andType: BOOKMARKVIDEO]) {
                            FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[[videos stringForColumn:@"mediaID"] intValue] ofType:BOOKMARKVIDEO inCategory:category withLink:[videos stringForColumn:@"videoImage"]];
                            [[APP_DELEGATE downloadList] addObject:headerImage];
                            [[APP_DELEGATE imagesToDownload] addObject:[videos stringForColumn:@"videoImage"]];
                            FItemBookmark * headerImage2 = [[FItemBookmark alloc] initWithItemIDint:[[videos stringForColumn:@"mediaID"] intValue] ofType:BOOKMARKVIDEO inCategory:category withLink:[videos stringForColumn:@"path"]];
                            [[APP_DELEGATE downloadList] addObject:headerImage2];
                            [[APP_DELEGATE videosToDownload] addObject:[videos stringForColumn:@"path"]];
                            [HelperBookmark countBookmarks:2];
                        }
                    }
                    
                }
            }
            
            
        }
        [database close];
    }
} */

//Geting all pdfs and videos that can be bookmarked for user
+(void) selectFotona: (int) category{
    NSMutableArray *list = [NSMutableArray new];
    
    FMDatabase *fotonaDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedFotona;
    [fotonaDatabase open];
    selectedFotona = [fotonaDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu WHERE (fotonaCategoryType=4 OR fotonaCategoryType=6) and active=1"]];
    while([selectedFotona next]) {
        FFotonaMenu* f=[[FFotonaMenu alloc] initWithDictionary:[selectedFotona resultDictionary]];
        if ([self checkFotona:f forCategory:category]) {
            [list addObject:f];
        }
    }
    [fotonaDatabase close];
    for (FFotonaMenu * menu in list) {
        NSMutableArray *mediaArray = [NSMutableArray new];
        if ([menu.fotonaCategoryType intValue] ==6) {
            mediaArray = [menu pdfArray];
        } else {
            if ([menu.fotonaCategoryType intValue] ==4) {
                mediaArray = [menu videoArray];
            }
        }
        //TODO:
        for (FMedia *media in mediaArray) {
            if ([FCommon userPermission:[media userPermissions]]) {
                //TODO FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[menu.categoryID intValue] ofType:BOOKMARKPDF withLink:[[media path] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
               //TODO [[APP_DELEGATE downloadList] addObject:headerImage];
                [[APP_DELEGATE pdfToDownload] addObject:[media path]];
                [HelperBookmark countBookmarks:1];
            }
        }
        
        
        
        if ([menu.fotonaCategoryType intValue] ==6) {
            if (![self bookmarked:[menu.categoryID intValue] withType:BOOKMARKPDF inCategory:category]) {
                if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[menu.categoryID intValue]] forCategory:category andType:BOOKMARKPDF]) {
                    //TODO:FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[menu.categoryID intValue] ofType:BOOKMARKPDF inCategory:category withLink:[menu.pdfSrc stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
                   //TODO: [[APP_DELEGATE downloadList] addObject:headerImage];
                   //TODO: [[APP_DELEGATE pdfToDownload] addObject:menu.pdfSrc];
                    [HelperBookmark countBookmarks:1];
                }
                
            }
        } else {
            
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            //TODO:         if ([FCommon userPermission:[selected userPermissions]] && [FCommon checkItemPermissions:[selected userPermissions] ForCategory:[NSString stringWithFormat:@"%d",category]]) {

            
            
//            [database open];
//            FMResultSet *videos = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media WHERE galleryID = %d and mediaType=1",[menu.videoGalleryID intValue]]];
//            while([videos next]) {
//                if (![self bookmarked:[[videos stringForColumn:@"mediaID"] intValue] withType:BOOKMARKVIDEO inCategory:category]) {
//                    NSString *usr = [FCommon getUser];
//                    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%d and isBookmark=1 and mediaType=1",[[videos stringForColumn:@"mediaID"] intValue]]];
//                    BOOL flag=NO;
//                    while([resultsBookmarked next]) {
//                        flag=YES;
//                        NSLog(@"%@, %@",[resultsBookmarked stringForColumn:@"mediaID"],[resultsBookmarked stringForColumn:@"isBookmark"]);
//                    }
//                    if (!flag) {
//                        if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[[videos stringForColumn:@"mediaID"] intValue]] forCategory:category andType: BOOKMARKVIDEO]) {
//                            FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[[videos stringForColumn:@"mediaID"] intValue] ofType:BOOKMARKVIDEO inCategory:category withLink:[videos stringForColumn:@"mediaImage"]];
//                            [[APP_DELEGATE downloadList] addObject:headerImage];
//                            [[APP_DELEGATE imagesToDownload] addObject:[videos stringForColumn:@"mediaImage"]];
//                            FItemBookmark * headerImage2 = [[FItemBookmark alloc] initWithItemIDint:[[videos stringForColumn:@"mediaID"] intValue] ofType:BOOKMARKVIDEO inCategory:category withLink:[videos stringForColumn:@"path"]];
//                            [[APP_DELEGATE downloadList] addObject:headerImage2];
//                            [[APP_DELEGATE videosToDownload] addObject:[videos stringForColumn:@"path"]];
//                            [HelperBookmark countBookmarks:2];
//                        }
//                    }
//                    
//                }
//            }
            [database close];
            
        }
        
    }
    
}

+ (BOOL) bookmarkMedia: (FMedia *)media{
    BOOL bookmarked = false;
 
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT isBookmark FROM Media where mediaID=%d and isBookmark=1 and mediaType=%@",[[media itemID] intValue], [media mediaType]]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        FItemBookmark *pdfBookmarkItem =[[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media path]];
        [[APP_DELEGATE downloadList] addObject:pdfBookmarkItem];
        if ([[media mediaType] intValue] == [BOOKMARKPDF intValue]) {
            [[APP_DELEGATE pdfToDownload] addObject:[media path]];
        } else {
            if ([[media mediaType] intValue] == [BOOKMARKVIDEO intValue]) {
                [[APP_DELEGATE videosToDownload] addObject:[media path]];
            }
        }
        
        FItemBookmark *imageBookmarkItem = [[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media mediaImage]];
        [[APP_DELEGATE downloadList] addObject:imageBookmarkItem];
        [[APP_DELEGATE imagesToDownload] addObject:[media mediaImage]];
        
        [HelperBookmark countBookmarks:2];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
        bookmarked = true;

    }
    else{
        [self inserToDB:(FMDatabase *)database forUser:usr item:[NSString stringWithFormat:@"%d", [media.itemID intValue]] withType:[media mediaType] forCaseIDs:@"" andBookmarkType:BSOURCEFOTONA];
    }
    [database close];
    return bookmarked;

}

+(BOOL)checkFotona:(FFotonaMenu *)f forCategory:(int) category
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    if ([[[APP_DELEGATE currentLogedInUser] userTypeSubcategory] count]>0) {
        //TODO: predelava za pravice, treba pogledat a je med pravicami kategorija
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",f.categoryID,[NSString stringWithFormat:@"%d", category]]];
        while([results next]) {
            check=YES;
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

+(void)userBookmarked{
    NSString *usr = [FCommon getUser];
    NSMutableArray *users=[[[NSUserDefaults standardUserDefaults] objectForKey:@"userBookmarked"] mutableCopy];
    if (![users containsObject:usr]) {
        [users addObject:usr];
        [[NSUserDefaults standardUserDefaults] setObject:users forKey:@"userBookmarked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"DOWNLOADPROGRESS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

+(void) checkAllFiles:(NSString *)dlink {
    FItemBookmark * item;
    for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++){
        if ([[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString: dlink]) {
            item = [[APP_DELEGATE downloadList] objectAtIndex:i];
            [[APP_DELEGATE downloadList] removeObjectAtIndex:i];
            [APP_DELEGATE setBookmarkCountLeft:([APP_DELEGATE bookmarkCountLeft]-1)];
            if ([FCommon isIpad])
            {
                [[APP_DELEGATE settingsController] refreshStatusBar];
            } else
            {
                FIFlowController *flow = [FIFlowController sharedInstance];
                if (flow.fotonaSettings != nil) {
                    [[flow fotonaSettings] refreshStatusBar];
                }
            }
            
            break;
        }
    }
    NSString *fileUsr = [FCommon getUser];
    BOOL exists = true;
    BOOL alreadyBookmarked = true;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    if (item!=nil) {
        if ([item.type intValue] == [BOOKMARKNEWS intValue]) {
            for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                if (([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]])) {
                    exists = false;
                    break;
                }
            }
            if (exists) {
                FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[fileUsr,BOOKMARKNEWS,item.itemID]];
                while([resultsBookmarkedAlready next]) {
                    alreadyBookmarked = false;
                }
                if (alreadyBookmarked) {
                    [database executeUpdate:@"INSERT INTO UserBookmark (username,documentID,typeID) VALUES (?,?,?)",fileUsr,item.itemID,BOOKMARKNEWS];
                }
                
                [database executeUpdate:@"UPDATE News set isBookmark=? where newsID=?",@"1", item.itemID];
            }
            NSArray *pathComp=[dlink pathComponents];
            NSString *local=[[NSString stringWithFormat:@"%@/.Cases/%@",docDir,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[dlink lastPathComponent]];
            
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
                [[APP_DELEGATE imagesToDownload] removeObject:local];
            }
            
        } else {
            if ([item.type intValue] == [BOOKMARKCASE intValue]) {
                
                for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                    FItemBookmark * temp = [[APP_DELEGATE downloadList] objectAtIndex:i];
                    if (([temp.type isEqualToString:[item type]])&&([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]])) {
                        exists = false;
                        break;
                    }
                }
                if (exists) {
                    NSString *usr = [FCommon getUser];
                    // typeID 0-case 1-video 2-pdf
                    FMResultSet *selectedCases = [database executeQuery:@"SELECT * FROM Cases where caseID=?" withArgumentsInArray:@[item.itemID]];
                    FCase * selected;
                    while([selectedCases next]) {
                        selected =  [[FCase alloc] initWithDictionaryFromDB:[selectedCases resultDictionary]];
                    }
                    FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKCASE,item.itemID]];
                    while([resultsBookmarkedAlready next]) {
                        alreadyBookmarked = false;
                    }
                    if (alreadyBookmarked) {
                        [database executeUpdate:@"INSERT INTO UserBookmark (documentID, username, typeID) VALUES (?,?,0)",item.itemID,usr];
                    }
                    
                    if (selected.coverflow == nil || ![[selected coverflow] boolValue]) {
                        
                        
                        
                        NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:selected.caseID onView:nil];
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            // I get response as XML here and parse it in a function
                            
                            NSError *jsonError;
                            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                            NSString *c = [dic objectForKey:@"d"];
                            NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
                            FCase *caseObj=[[FCase alloc] initWithDictionaryFromServer:[NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                                         error:&jsonError]];
                            NSLog(@"%@",[jsonError localizedDescription]);
                            
                            //insertMedia TODO
                            NSMutableArray *imgs = [caseObj parseImages];
                            NSMutableArray *videosA = [caseObj parseVideosFromServer:NO];
                            
                            [self bookmarkMedia:imgs withType:0];
                            [self bookmarkMedia:videosA withType:1];
                            NSLog(@"Bookmarked %@",caseObj.title);
                            [database executeUpdate:@"UPDATE Cases set title=?,langID=?,coverTypeID=?,name=?,image=?,introduction=?,procedure=?,results=?,'references'=?,parameters=?,date=?,active=?,authorID=?,alloweInCoverFlow=?,isBookmark=?, deleted=?, download=?, userPermissions=?, galleryItemVideoIDs=?, galleryItemImagesIDs=? where caseID=?",caseObj.title,langID,caseObj.coverTypeID,caseObj.name,caseObj.image,caseObj.introduction,caseObj.procedure,caseObj.results,caseObj.references,caseObj.parameters,caseObj.date,caseObj.active,caseObj.authorID,caseObj.coverflow,@"1", caseObj.deleted, caseObj.download, caseObj.userPermissions, caseObj.galleryItemVideoIDs, caseObj.galleryItemImagesIDs, caseObj.caseID];
                        }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             NSLog(@"Cases bookmark failed %@",error.localizedDescription);
                                                             
                                                         }];
                        [operation start];
                        
                    }
                    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                    NSArray *pathComp=[dlink pathComponents];
                    NSString *local=[[NSString stringWithFormat:@"%@/.Cases/%@",docDir,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[dlink lastPathComponent]];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
                        [[APP_DELEGATE imagesToDownload] removeObject:local];
                        [[APP_DELEGATE videosToDownload] removeObject:local];
                    }
                    if ([FCommon isIpad]) {
                        if ([[[APP_DELEGATE casebookController] currentCase] caseID] == selected.caseID ) {
                            [[APP_DELEGATE casebookController] refreshBookmarkBtn];
                        }//TODO: dodat da pogleda na favorite in če je tm da refresha tisto celico
                    } else{
                        FIFlowController *flow = [FIFlowController sharedInstance];
                        if ([[flow caseOpened] caseID] == selected.caseID ) {
                            [[flow caseView] refreshBookmarkBtn];
                        }//TODO: dodat da pogleda na favorite in če je tm da refresha tisto celico
                    }
                }
            } else {
                if ([item.type intValue] == [BOOKMARKPDF intValue]) {
                    NSString *usr = [FCommon getUser];
                    // typeID 0-case 1-video 2-pdf
                    //check if both items were downloaded
                    BOOL pdfExists = true;
                    for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                        FItemBookmark * temp = [[APP_DELEGATE downloadList] objectAtIndex:i];
                        if (([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]]) &&([temp.type intValue] == [[item type] intValue]) ) {
                            pdfExists = false;
                            break;
                        }
                    }
                    if (pdfExists) {
                        FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKPDF,[NSString stringWithFormat:@"%d", [item.itemID intValue]]]];
                        while([resultsBookmarkedAlready next]) {
                            alreadyBookmarked = false;
                        }
                        if (alreadyBookmarked) {
                            [self inserToDB:(FMDatabase *)database forUser:usr item:[NSString stringWithFormat:@"%d", [item.itemID intValue]] withType:BOOKMARKPDF forCaseIDs:@"" andBookmarkType:BSOURCEFOTONA];
                            bookmarkedCount+=2;
                        }
                        FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where active=1 and mediaID=%@ AND isBookmark=1 AND mediaType=%@",[NSString stringWithFormat:@"%d", [item.itemID intValue]], MEDIAPDF]];
                        BOOL flag=NO;
                        while([resultsBookmarked next]) {
                            flag=YES;
                        }
                        if (!flag) {
                             [database executeUpdate:@"UPDATE Media set isBookmark=?  where mediaType=? AND  mediaID=?",@"1", MEDIAPDF,[NSString stringWithFormat:@"%d", [item.itemID intValue]]];
                        }
                        NSString *local= [FMedia  createLocalPathForLink:dlink andMediaType:MEDIAPDF];
                        
                        if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
                            [[APP_DELEGATE pdfToDownload] removeObject:local];
                            [[APP_DELEGATE imagesToDownload] removeObject:local];
                        }
                        if ([FCommon isIpad]) {
                            //TODO:refresh celice ne menuja [[APP_DELEGATE fotonaController] refreshMenu:item.link];
                        } else
                        {
                            FIFlowController *flow = [FIFlowController sharedInstance];
                            if (flow.fotonaTab != nil)
                            {
                                //TODO: nrdit, da osveži celico v pdf galeriji
                                //[[flow fotonaTab] refreshMenu:item.link];
                            }
                        }
                    }
                } else {
                    if ([item.type intValue] == [BOOKMARKVIDEO intValue]) {
                        NSString *usr = [FCommon getUser];
                        //treba pogledat, če je še kak item s tem idjem not kot pr casih
                        
                        BOOL videoExists = true;
                        for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                            FItemBookmark * temp = [[APP_DELEGATE downloadList] objectAtIndex:i];
                            if (([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]]) &&([temp.type intValue] == [[item type] intValue]) ) {
                                videoExists = false;
                                break;
                            }
                        }
                        if (videoExists) {
                            FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKVIDEO,[NSString stringWithFormat:@"%d", [item.itemID intValue]]]];
                            while([resultsBookmarkedAlready next]) {
                                alreadyBookmarked = false;
                            }
                            if (alreadyBookmarked) {
                                [self inserToDB:(FMDatabase *)database forUser:usr item:[NSString stringWithFormat:@"%d", [item.itemID intValue]] withType:BOOKMARKVIDEO forCaseIDs:@"" andBookmarkType:BSOURCEFOTONA];//TODO: pazit kak source se nasstavlja, če slučajno pride iz casa
                                bookmarkedCount+=2;
                            }
                            FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where active=1 and mediaID=%@ AND isBookmark=1 AND mediaType=%@",[NSString stringWithFormat:@"%d", [item.itemID intValue]], MEDIAVIDEO]];
                            BOOL flag=NO;
                            while([resultsBookmarked next]) {
                                flag=YES;
                            }
                            if (!flag) {
                                [database executeUpdate:@"UPDATE Media set isBookmark=?  where mediaType=? AND  mediaID=?",@"1", MEDIAVIDEO,[NSString stringWithFormat:@"%d", [item.itemID intValue]]];
                            }
                            NSString *local= [FMedia  createLocalPathForLink:dlink andMediaType:MEDIAVIDEO];

                            if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
                                [[APP_DELEGATE videosToDownload] removeObject:local];
                                [[APP_DELEGATE imagesToDownload] removeObject:local];
                            }
                            if ([FCommon isIpad]) {
                                //TODO:refresh celice ne menuja [[APP_DELEGATE fotonaController] refreshMenu:item.link];
                            } else
                            {
                                FIFlowController *flow = [FIFlowController sharedInstance];
                                if (flow.fotonaTab != nil)
                                {
                                    //TODO: nrdit, da osveži celico v pdf galeriji
                                    //[[flow fotonaTab] refreshMenu:item.link];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    [database close];
}

+(void) inserToDB:(FMDatabase *)database forUser:(NSString *)usr item:(NSString *)itemID withType:(NSString *) itemType forCaseIDs:(NSString *)caseIDs andBookmarkType:(int) bookmarkType{
    if (caseIDs == nil) {
        caseIDs = @"";
    }
    [database executeUpdate:@"INSERT INTO UserBookmark ('username',documentID,'typeID', 'caseIDs', bookmarkType) VALUES (?,?,?,?,?)",usr,itemID,itemType, caseIDs, [NSString stringWithFormat:@"%d", bookmarkType]];
}

+ (BOOL) checkItem:(NSString *) itemId forCategory:(int) category andType:(NSString *)type{
    for(FItemBookmark *item in [APP_DELEGATE downloadList]){
        if( [item.itemID isEqualToString:itemId] && [item.type isEqualToString:type]){
           //TODO: item.category =  [NSString stringWithFormat:@"%@,%d",item.category,category];
            return false;
        }
    }
    return true;
}

+(void)warning {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Some files might be missing and are not bookmarked" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)success{
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"ADDBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [APP_DELEGATE setBookmarkAll:false];
    [APP_DELEGATE setBookmarkAll:NO];
     NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
     [defaults setBool:false forKey:@"bookmarkAll"];
}

+ (void) countBookmarks:(float)add {
    [APP_DELEGATE setBookmarkCountAll:[APP_DELEGATE bookmarkCountAll]+add];
    [APP_DELEGATE setBookmarkCountLeft:[APP_DELEGATE bookmarkCountLeft]+add];
}

@end

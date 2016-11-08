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
#import "FDB.h"

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
                [self bookmarkNews:n];
            }
        }
    }
}

+(void) bookmarkNews: (FNews *) news{
    if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",(int)news.newsID] andType:BOOKMARKNEWS]) {
        NSString *url_Img_FULL = news.headerImageLink;
        [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
        FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:(int)news.newsID ofType:BOOKMARKNEWS fromSource:BSOURCEALL forCases:nil withLink:url_Img_FULL];
        [[APP_DELEGATE downloadList] addObject:headerImage];
        [HelperBookmark countBookmarks:1];
        for (int i =0; i<[news.imagesLinks count]; i++) {
            NSString *url_Img_FULL = [news.imagesLinks objectAtIndex:i];
            [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
            FItemBookmark *image = [[FItemBookmark alloc] initWithItemIDint:(int)news.newsID ofType:BOOKMARKNEWS fromSource:BSOURCEALL forCases:nil withLink:url_Img_FULL];
            [[APP_DELEGATE downloadList] addObject:image];
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
    FMDatabase *eventsDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedEvents;
    [eventsDatabase open];
    selectedEvents = [eventsDatabase executeQuery:[NSString stringWithFormat:@"SELECT eventID, categories FROM Events"]];
    while([selectedEvents next]) {
        c = [selectedEvents stringForColumn:@"categories"];
        categories =  [c componentsSeparatedByString:@","];
        eventID = [selectedEvents intForColumn:@"eventID"];
        [list setObject:categories forKey:@(eventID)];
    }
    [eventsDatabase close];
    FEvent *e;
    for (id eID in list.allKeys) {
        if ([[list objectForKey:eID] containsObject:[[NSNumber numberWithInt:category] stringValue]]) {
            if (![self bookmarked:[eID intValue] withType:BOOKMARKEVENTS inCategory:category]) {
                [eventsDatabase open];
                selectedEvents = [eventsDatabase executeQuery:@"SELECT * FROM Events where eventID=?" withArgumentsInArray:@[[[NSNumber numberWithInt:[eID intValue]] stringValue]]];
                while([selectedEvents next]) {
                    e=[[FEvent alloc] initWithDictionary:[selectedEvents resultDictionary]];
                }
                [eventsDatabase close];
                [self bookmarkEvent:e];
            }
        }
    }
}

+(void) bookmarkEvent: (FEvent *) event{
    NSString *eventUsr = [FCommon getUser];
    FMDatabase *eventsBookmarkDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [eventsBookmarkDatabase open];
    BOOL bookmark = true;
    FMResultSet *resultsBookmarkedAlready =  [eventsBookmarkDatabase executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[eventUsr,BOOKMARKEVENTS,[NSString stringWithFormat:@"%d", (int)event.eventID]]];
    while([resultsBookmarkedAlready next]) {
        bookmark = false;
    }
    if (bookmark) {
         [self insertToDB:eventsBookmarkDatabase forUser:eventUsr item:[NSString stringWithFormat:@"%d", (int)event.eventID] withType:BOOKMARKEVENTS forCaseIDs:@"" andBookmarkType:BSOURCEALL];
    }
    [eventsBookmarkDatabase executeUpdate:@"UPDATE Events set isBookmark=? where eventID=?",@"1", [NSString stringWithFormat:@"%ld", (long)event.eventID]];
    [eventsBookmarkDatabase close];
}


#pragma mark - Cases
+(void) selectCases: (int) category{
    NSMutableArray *list = [NSMutableArray new];
    FMDatabase *casesDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [casesDatabase open];
            FMResultSet *selectedCases = [casesDatabase executeQuery:@"SELECT * FROM Cases where active=1 AND download=1" withArgumentsInArray:@[[[NSNumber numberWithInt:category] stringValue]]];
    while([selectedCases next]) {
        FCase * selected =  [[FCase alloc] initWithDictionaryFromDB:[selectedCases resultDictionary]];
        if ([FCommon userPermission:[selected userPermissions]] && [FCommon checkItemPermissions:[selected userPermissions] ForCategory:[NSString stringWithFormat:@"%d",category]]) {
             [list addObject:selected];
        }
    }
    [casesDatabase close];
    
    for (FCase *sCase in list) {
        if (![self bookmarked:[[sCase caseID] intValue] withType:BOOKMARKCASE inCategory:category]) {
            [self bookmarkCase:sCase];
        }
    }
}

+ (void)bookmarkCase:(FCase*) currentCase {
    
    if ([HelperBookmark checkItem:[NSString stringWithFormat:@"%d",[currentCase.caseID intValue]] andType:BOOKMARKCASE]) {
        NSString *usr = [FCommon getUser];
        
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        BOOL bookmark = true;
        FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr,BOOKMARKCASE,currentCase.caseID]];
        while([resultsBookmarkedAlready next]) {
            bookmark = false;
        }
        if (bookmark) {
            [self insertToDB:database forUser:usr item:currentCase.caseID withType:BOOKMARKCASE forCaseIDs:@"" andBookmarkType:BSOURCECASE];
        }
        [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"1",currentCase.caseID];
        [database close];
        
        if (![[currentCase coverflow] boolValue]) {
            NSMutableArray *imgs = [currentCase parseImages];
            NSMutableArray *videosA = [currentCase parseVideosFromServer:NO];
            
            [self addMedia:imgs withType:MEDIAIMAGE fromcase:[currentCase.caseID intValue]];
            [self addMedia:videosA withType:MEDIAVIDEO fromcase:[currentCase.caseID intValue]];
          
        }else{
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


+(void)addMedia:(NSMutableArray *)m withType:(NSString *)type fromcase:(int)caseID{
    if (m.count>0) {
        NSMutableArray *links =[[NSMutableArray alloc] init];
        if ([type intValue]==[MEDIAIMAGE intValue]) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                [links addObject:img.path];
                FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:caseID ofType:type fromSource:BSOURCECASE forCases:[NSString stringWithFormat:@"%d",caseID] withLink:img.path];
                [[APP_DELEGATE downloadList] addObject:headerImage];
                [[APP_DELEGATE imagesToDownload] addObject:img.path];
                [HelperBookmark countBookmarks:1];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if([type intValue]==[MEDIAVIDEO intValue]){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                [links addObject:vid.path];
                FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:caseID ofType:type fromSource:BSOURCECASE forCases:[NSString stringWithFormat:@"%d",caseID] withLink:vid.path];
                [[APP_DELEGATE downloadList] addObject:headerImage];
                [[APP_DELEGATE videosToDownload] addObject:vid.path];
                [HelperBookmark countBookmarks:1];
            }
            [database close];
        }
        
    }
}




//Geting all pdfs and videos that can be bookmarked for user
+(void) selectFotona: (int) category{
    NSMutableArray *list = [NSMutableArray new];
    
    FMDatabase *fotonaDatabase = [FMDatabase databaseWithPath:DB_PATH];
    FMResultSet *selectedFotona;
    [fotonaDatabase open];
    selectedFotona = [fotonaDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu WHERE (fotonaCategoryType=4 OR fotonaCategoryType=6) and active=1"]];
    while([selectedFotona next]) {
        FFotonaMenu* f=[[FFotonaMenu alloc] initWithDictionary:[selectedFotona resultDictionary]];
        if ([FCommon checkItemPermissions:[f userPermissions] ForCategory:[NSString stringWithFormat:@"%d",category]]) {
            [list addObject:f];
        }
    }
    for (FFotonaMenu * menu in list) {
        NSMutableArray *mediaArray = [NSMutableArray new];
        if ([menu.fotonaCategoryType intValue] ==6 || [menu.fotonaCategoryType intValue] ==4) {
            mediaArray = [menu getMedia];
        }
        
        for (FMedia *media in mediaArray) {
            if ([FCommon checkItemPermissions:[media userPermissions] ForCategory:[NSString stringWithFormat:@"%d",category]]){
                
                NSString *usr = [FCommon getUser];
                FMResultSet *resultsBookmarked =  [fotonaDatabase executeQuery:[NSString stringWithFormat:@"SELECT isBookmark FROM Media where mediaID=%d and isBookmark=1 and mediaType=%@",[[media itemID] intValue], [media mediaType]]];
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
                    
                }
                else{
                    [self insertToDB:fotonaDatabase forUser:usr item:[NSString stringWithFormat:@"%d", [media.itemID intValue]] withType:[media mediaType] forCaseIDs:@"" andBookmarkType:BSOURCEFOTONA];
                }
            }
        }
        [fotonaDatabase close];
    }
}


+(void)saveBookmarkForMedia:(NSMutableArray *)m withType:(NSString *)type andSource:(int)source forCaseID:(NSString *)caseID{
    if (m.count>0) {
        NSString *usr = [FCommon getUser];
        BOOL alreadyBookmarked = true;
        NSString *cases = @"";
        if([type intValue] == [MEDIAVIDEO intValue] || [type intValue] == [MEDIAPDF intValue] || [type intValue] == [MEDIAIMAGE intValue]){
            NSString *bookmarType = BOOKMARKVIDEO;
            if([type intValue] == [MEDIAPDF intValue]){
                bookmarType = BOOKMARKPDF;
            } else {
                if([type intValue] == [MEDIAIMAGE intValue]){
                    bookmarType = BOOKMARKIMAGE;
                }
            }
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                alreadyBookmarked = NO;
                FMResultSet *resultsBookmarkedAlready =  [database executeQuery:@"SELECT * FROM UserBookmark WHERE username=? AND typeID=? AND documentID=? AND bookmarkType=?" withArgumentsInArray:@[usr,bookmarType,[NSString stringWithFormat:@"%d", [vid.itemID intValue]], [NSString stringWithFormat:@"%d", source]]];
                while([resultsBookmarkedAlready next]) {
                    alreadyBookmarked = YES;
                    cases = [resultsBookmarkedAlready valueForKey:@"caseIDs"];
                }
                
                //check and add if needed, for wich cases is item bookmarked
                if (source == BSOURCECASE) {
                    NSMutableArray *caseArray = [[FCommon stringToArray:cases withSeparator:@","] mutableCopy];
                    if (![caseArray containsObject:caseID]) {
                        [caseArray addObject:caseID];
                        cases = [FCommon arrayToString:caseArray withSeparator:@","];
                    }
                }
                
                //If not bookmarked yet insert else update
                if (alreadyBookmarked) {
                    [self updateDB:database forUser:usr item:[NSString stringWithFormat:@"%d", [vid.itemID intValue]] withType:bookmarType forCaseIDs:cases andBookmarkType:source];
                } else {
                    [self insertToDB:database forUser:usr item:[NSString stringWithFormat:@"%d", [vid.itemID intValue]] withType:bookmarType forCaseIDs:cases andBookmarkType:source];
                    bookmarkedCount+=2;
                }
                
                FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where active=1 and mediaID=%@ AND isBookmark=1 AND mediaType=%@",[NSString stringWithFormat:@"%d", [vid.itemID intValue]], type]];
                BOOL flag=NO;
                while([resultsBookmarked next]) {
                    flag=YES;
                }
                if (!flag) {
                    [database executeUpdate:@"UPDATE Media set isBookmark=?  where mediaType=? AND  mediaID=?",@"1", type,[NSString stringWithFormat:@"%d", [vid.itemID intValue]]];
                }
            }
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
        [self insertToDB:database forUser:usr item:[NSString stringWithFormat:@"%d", [media.itemID intValue]] withType:[media mediaType] forCaseIDs:@"" andBookmarkType:BSOURCEFOTONA];
    }
    [database close];
    return bookmarked;

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
                            
                            NSMutableArray *imgs = [caseObj parseImages];
                            NSMutableArray *videosA = [caseObj parseVideosFromServer:NO];
                            
                            [self saveBookmarkForMedia:imgs  withType:MEDIAIMAGE andSource:BSOURCECASE forCaseID:[caseObj caseID]];
                            [self saveBookmarkForMedia:videosA  withType:MEDIAVIDEO andSource:BSOURCECASE forCaseID:[caseObj caseID]];

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
                    // typeID 0-case 1-video 2-pdf
                    //check if both items were downloaded
                    BOOL pdfComplete = true;
                    for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                        FItemBookmark * temp = [[APP_DELEGATE downloadList] objectAtIndex:i];
                        if (([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]]) &&([temp.type intValue] == [[item type] intValue]) ) {
                            pdfComplete = false;
                            break;
                        }
                    }
                    if (pdfComplete) {
                        FMedia *pdf = [FDB getMediaWithId:[item itemID] andType:MEDIAPDF];

                      [self saveBookmarkForMedia:[NSMutableArray arrayWithObjects:pdf, nil] withType:MEDIAPDF andSource:BSOURCEFOTONA forCaseID:@""];
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
                    [database close];
                    if ([item.type intValue] == [BOOKMARKVIDEO intValue]) {
                        //treba pogledat, če je še kak item s tem idjem not kot pr casih
                        
                        BOOL videoComplete = true;
                        for (int i = 0; i < [[APP_DELEGATE downloadList] count]; i++) {
                            FItemBookmark * temp = [[APP_DELEGATE downloadList] objectAtIndex:i];
                            if (([[[[APP_DELEGATE downloadList] objectAtIndex:i] itemID] isEqualToString:[item itemID]])&& (![[[[APP_DELEGATE downloadList] objectAtIndex:i] link] isEqualToString:[item link]]) &&([temp.type intValue] == [[item type] intValue]) ) {
                                videoComplete = false;
                                break;
                            }
                        }
                        if (videoComplete) {
                            FMedia *vid = [FDB getMediaWithId:[item itemID] andType:MEDIAVIDEO];
                            [self saveBookmarkForMedia:[NSMutableArray arrayWithObjects:vid, nil] withType:MEDIAVIDEO andSource:BSOURCEFOTONA forCaseID:@""];
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

+(void) insertToDB:(FMDatabase *)database forUser:(NSString *)usr item:(NSString *)itemID withType:(NSString *) itemType forCaseIDs:(NSString *)caseIDs andBookmarkType:(int) bookmarkType{
    if (caseIDs == nil) {
        caseIDs = @"";
    }
    [database executeUpdate:@"INSERT INTO UserBookmark ('username',documentID,'typeID', 'caseIDs', bookmarkType) VALUES (?,?,?,?,?)",usr,itemID,itemType, caseIDs, [NSString stringWithFormat:@"%d", bookmarkType]];
}

+(void) updateDB:(FMDatabase *)database forUser:(NSString *)usr item:(NSString *)itemID withType:(NSString *) itemType forCaseIDs:(NSString *)caseIDs andBookmarkType:(int) bookmarkType{
    if (caseIDs == nil) {
        caseIDs = @"";
    }
    
    [database executeUpdate:@"UPDATE UserBookmark set caseIDs=? WHERE username=? AND typeID=? AND documentID=? AND bookmarkType=?",caseIDs, usr,itemType, itemID, bookmarkType];
}

+ (BOOL) checkItem:(NSString *) itemId andType:(NSString *)type{
    for(FItemBookmark *item in [APP_DELEGATE downloadList]){
        if( [item.itemID isEqualToString:itemId] && [item.type isEqualToString:type]){
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

@end

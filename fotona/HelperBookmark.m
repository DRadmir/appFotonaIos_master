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
#import "FMediaManager.h"
#import "FIFavoriteViewController.h"

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
            if (![self bookmarked:[nID intValue] withType:BOOKMARKNEWS]) {
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
        FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:(int)news.newsID ofType:BOOKMARKNEWS fromSource:BSOURCEALL forCases:nil withLink:url_Img_FULL withFileSize:0];
        [[APP_DELEGATE downloadList] addObject:headerImage];
        [HelperBookmark countBookmarks:1 withSize:[headerImage fileSize]];
        for (int i =0; i<[news.imagesLinks count]; i++) {
            NSString *url_Img_FULL = [news.imagesLinks objectAtIndex:i];
            [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
            FItemBookmark *image = [[FItemBookmark alloc] initWithItemIDint:(int)news.newsID ofType:BOOKMARKNEWS fromSource:BSOURCEALL forCases:nil withLink:url_Img_FULL withFileSize:0];
            [[APP_DELEGATE downloadList] addObject:image];
            [HelperBookmark countBookmarks:1  withSize:[image fileSize]];
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
            if (![self bookmarked:[eID intValue] withType:BOOKMARKEVENTS]) {
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
        if (![self bookmarked:[[sCase caseID] intValue] withType:BOOKMARKCASE]) {
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
            NSMutableArray *imgs = [currentCase parseImagesFromServer:NO];
            NSMutableArray *videosA = [currentCase parseVideosFromServer:NO];
            
            [self addMedia:imgs withType:MEDIAIMAGE fromcase:currentCase.caseID];
            [self addMedia:videosA withType:MEDIAVIDEO fromcase:currentCase.caseID];
          
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


+(void)addMedia:(NSMutableArray *)m withType:(NSString *)type fromcase:(NSString *)caseID{
    if (m.count>0) {
        if ([type intValue]==[MEDIAIMAGE intValue]) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                [self addImageToDownloadLis:img forCase:caseID];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if([type intValue]==[MEDIAVIDEO intValue]){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                [self addVideoToDownloadLis:vid forCase:caseID];}
            [database close];
        }
        
    }
}

+(void)addImageToDownloadLis:(FImage *)img forCase:(NSString *)caseID{
    FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[caseID intValue] ofType:MEDIAIMAGE fromSource:BSOURCECASE forCases:caseID withLink:img.path withFileSize:[[img fileSize] intValue]];
    [[APP_DELEGATE downloadList] addObject:headerImage];
    [[APP_DELEGATE imagesToDownload] addObject:img.path];
    [HelperBookmark countBookmarks:1  withSize:[headerImage fileSize]];
}

+(void)addVideoToDownloadLis:(FMedia *)video forCase:(NSString *)caseID{
    FItemBookmark *headerImage = [[FItemBookmark alloc] initWithItemIDint:[caseID intValue] ofType:MEDIAVIDEO fromSource:BSOURCECASE forCases:caseID withLink:video.path withFileSize:[[video filesize] intValue]];
    [[APP_DELEGATE downloadList] addObject:headerImage];
    [[APP_DELEGATE videosToDownload] addObject:video.path];
    FItemBookmark *imageBookmarkItem = [[FItemBookmark alloc] initWithItemIDint:[[video itemID] intValue] ofType:[video mediaType] fromSource:BSOURCECASE forCases:nil withLink:[video mediaImage] withFileSize:0];
    [[APP_DELEGATE downloadList] addObject:imageBookmarkItem];
    [[APP_DELEGATE imagesToDownload] addObject:[video mediaImage]];
    [HelperBookmark countBookmarks:2  withSize:[headerImage fileSize]];
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
                    FItemBookmark *pdfBookmarkItem =[[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media path]  withFileSize:[[media filesize] intValue]];
                    [[APP_DELEGATE downloadList] addObject:pdfBookmarkItem];
                    if ([[media mediaType] intValue] == [BOOKMARKPDF intValue]) {
                        [[APP_DELEGATE pdfToDownload] addObject:[media path]];
                    } else {
                        if ([[media mediaType] intValue] == [BOOKMARKVIDEO intValue]) {
                            [[APP_DELEGATE videosToDownload] addObject:[media path]];
                        }
                    }
                    
                    FItemBookmark *imageBookmarkItem = [[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media mediaImage] withFileSize:0];
                    [[APP_DELEGATE downloadList] addObject:imageBookmarkItem];
                    [[APP_DELEGATE imagesToDownload] addObject:[media mediaImage]];
                    
                    [HelperBookmark countBookmarks:2  withSize:[pdfBookmarkItem fileSize]];
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
        FItemBookmark *pdfBookmarkItem =[[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media path] withFileSize:[[media filesize] intValue]];
        [[APP_DELEGATE downloadList] addObject:pdfBookmarkItem];
        if ([[media mediaType] intValue] == [BOOKMARKPDF intValue]) {
            [[APP_DELEGATE pdfToDownload] addObject:[media path]];
        } else {
            if ([[media mediaType] intValue] == [BOOKMARKVIDEO intValue]) {
                [[APP_DELEGATE videosToDownload] addObject:[media path]];
            }
        }
        
        FItemBookmark *imageBookmarkItem = [[FItemBookmark alloc] initWithItemIDint:[[media itemID] intValue] ofType:[media mediaType] fromSource:BSOURCEFOTONA forCases:nil withLink:[media mediaImage] withFileSize:0];
        [[APP_DELEGATE downloadList] addObject:imageBookmarkItem];
        [[APP_DELEGATE imagesToDownload] addObject:[media mediaImage]];
        
        [HelperBookmark countBookmarks:2  withSize:[pdfBookmarkItem fileSize]];
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
            [APP_DELEGATE setBookmarkSizeLeft:([APP_DELEGATE bookmarkSizeLeft]-[item fileSize])];
            NSLog(@"Size left %f",[APP_DELEGATE bookmarkSizeLeft]);
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
                    [self insertToDB:database forUser:fileUsr item:item.itemID withType:BOOKMARKNEWS forCaseIDs:@"" andBookmarkType:BSOURCEALL];
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
                        [self insertToDB:database forUser:usr item:item.itemID withType:BOOKMARKCASE forCaseIDs:@"" andBookmarkType:BSOURCEALL];
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
                            
                            NSMutableArray *imgs = [caseObj parseImagesFromServer:NO];
                            NSMutableArray *videosA = [caseObj parseVideosFromServer:NO];
                            
                            [self saveBookmarkForMedia:imgs  withType:MEDIAIMAGE andSource:BSOURCECASE forCaseID:[caseObj caseID]];
                            [self saveBookmarkForMedia:videosA  withType:MEDIAVIDEO andSource:BSOURCECASE forCaseID:[caseObj caseID]];

                            NSLog(@"Bookmarked %@",caseObj.title);
                            [database executeUpdate:@"UPDATE Cases set title=?,langID=?,coverTypeID=?,name=?,image=?,introduction=?,procedure=?,results=?,'references'=?,parameters=?,date=?,active=?,authorID=?,alloweInCoverFlow=?,isBookmark=?, deleted=?, download=?, userPermissions=?, galleryItemVideoIDs=?, galleryItemImagesIDs=? where caseID=?",caseObj.title,langID,caseObj.coverTypeID,caseObj.name,caseObj.image,caseObj.introduction,caseObj.procedure,caseObj.results,caseObj.references,caseObj.parameters,caseObj.date,caseObj.active,caseObj.authorID,caseObj.coverflow,@"1", caseObj.deleted, caseObj.download, caseObj.userPermissions, caseObj.galleryItemVideoIDs, caseObj.galleryItemImagesIDs, caseObj.caseID];
                            
                           
                            [self refreshViewWithItem:selected.caseID forItemType:BOOKMARKCASE];


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
                        [self refreshViewWithItem:item.itemID forItemType:BOOKMARKPDF];
                    }
                } else {
                    [database close];
                    if ([item.type intValue] == [BOOKMARKVIDEO intValue]) {                        
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
                            [self refreshViewWithItem:item.itemID forItemType:BOOKMARKVIDEO];
                        }
                    }
                }
            }
        }
    }
    [database close];
}

+(void)refreshViewWithItem:(NSString *)itemID forItemType:(NSString *)itemType{
     FIFlowController *flow = [FIFlowController sharedInstance];
    if ([FCommon isIpad]) {
        if ([itemType intValue] == [BOOKMARKCASE intValue] && [[[[APP_DELEGATE casebookController] currentCase] caseID] intValue] == [itemID intValue] ) {
            [[APP_DELEGATE casebookController] refreshBookmarkBtn];
        } else {
            if ([[APP_DELEGATE tabBar] selectedIndex] == 2){
                UINavigationController *tempC = [[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:2] centerController];
                [(FFotonaViewController *)[tempC topViewController] refreshCellForMedia:itemID andMediaType:itemType];
            } else {
                if ([[APP_DELEGATE tabBar] selectedIndex] == 4){
//                    UINavigationController *tempC = [[[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:2] centerController];
//                    [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES forMedia:media];
               // TODO: favorites
                }
            }
        }
    } else{
        if ([itemType intValue] == [BOOKMARKCASE intValue] && [[[flow caseOpened] caseID] intValue] == [itemID intValue] ) {
            [[flow caseView] refreshBookmarkBtn];
        } else {
            if ([[flow lastOpenedView] isKindOfClass:[FIFavoriteViewController class]]) {
                FIFavoriteViewController *favorView =(FIFavoriteViewController *)[flow lastOpenedView];
                [favorView refreshCellWithItemID:itemID andItemType:itemType];
            }else {
                if ([[flow lastOpenedView] isKindOfClass:[FIGalleryViewController class]]) {
                    FIGalleryViewController *gallView =(FIGalleryViewController *)[flow lastOpenedView];
                    [gallView refreshCellWithItemID:itemID andItemType:itemType];
                }
            }
        }
    }
    
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

+ (void) countBookmarks:(float)add withSize:(int) size {
    [APP_DELEGATE setBookmarkCountAll:[APP_DELEGATE bookmarkCountAll]+add];
    [APP_DELEGATE setBookmarkCountLeft:[APP_DELEGATE bookmarkCountLeft]+add];
    [APP_DELEGATE setBookmarkSizeAll:[APP_DELEGATE bookmarkSizeAll]+size];
    [APP_DELEGATE setBookmarkSizeLeft:[APP_DELEGATE bookmarkSizeLeft]+size];
}

#pragma mark checkIfBookmarked


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

+(void)unbookmarkAll{
    NSString *currentUsr = [FCommon getUser];
    int x = 0;
    FMDatabase *localDatabase = [FMDatabase databaseWithPath:DB_PATH];
    [localDatabase open];
    FMResultSet *resultsBookmarked =  [localDatabase executeQuery:@"SELECT * FROM UserBookmark where username=?" withArgumentsInArray:@[currentUsr]];
    while([resultsBookmarked next]) {
        
        
        NSString *type = [resultsBookmarked stringForColumn:@"typeID"];
        FMResultSet *resultItem;
        BOOL still = NO;
        if ([type isEqualToString:BOOKMARKNEWS]) {// news
            [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKNEWS];
            resultItem = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=? and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKNEWS, nil]];
            while([resultItem next]) {
                still = YES;
            }
            if (!still) {//if not bookmaked anymore
                resultItem = [localDatabase executeQuery:@"SELECT * FROM News where newsID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKNEWS, nil]];
                while([resultItem next]) {
                    FNews *f=[[FNews alloc] initWithDictionary:[resultItem resultDictionary]];
                    [localDatabase executeUpdate:@"UPDATE News set isBookmark=? where newsID=?",@"0", [NSString stringWithFormat:@"%ld", (long)f.newsID]];
                    if ([f.rest isEqualToString:@"1"]) {
                        NSString *downloadFilename = [NSString stringWithFormat:@"%@%@",docDir,f.localImage];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:downloadFilename error:&error];
                        x++;
                        for (int i =0; i<[f.localImages count]; i++) {
                            downloadFilename = [NSString stringWithFormat:@"%@%@",docDir,[f.localImages objectAtIndex:i]];
                            [fileManager removeItemAtPath:downloadFilename error:&error];
                            x++;
                        }
                    }
                }
            }
        } else {
            if ([type isEqualToString:BOOKMARKEVENTS]) {//events
                [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,BOOKMARKEVENTS];
                resultItem = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=? and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"],BOOKMARKEVENTS, nil]];
                while([resultItem next]) {
                    still = YES;
                }
                if (!still) {
                    [localDatabase executeUpdate:@"UPDATE Events set isBookmark=? where eventID=?",@"0", [NSString stringWithFormat:@"%@", [resultsBookmarked stringForColumn:@"documentID"]]];
                }
                
            } else {
                if ([type isEqualToString:BOOKMARKVIDEO] || [type isEqualToString:BOOKMARKPDF]) {//video and pdf
                    [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr,type];
                    FMResultSet *results =  [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",[resultsBookmarked stringForColumn:@"documentID"],type]];
                    BOOL flag=NO;
                    while([results next]) {
                        flag=YES;
                    }
                    if (!flag) {
                        [localDatabase executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",[resultsBookmarked stringForColumn:@"documentID"]];
                        FMResultSet *results2 = [localDatabase executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ order by sort",[resultsBookmarked stringForColumn:@"documentID"]]];
                        
                        while([results2 next]) {
                            NSString *downloadFilename = [FMedia createLocalPathForLink:[results2 stringForColumn:@"path"] andMediaType:type];
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSError *error;
                            [fileManager removeItemAtPath:downloadFilename error:&error];
                            x++;
                            NSArray *pathComp=[[results2 stringForColumn:@"mediaImage"] pathComponents];
                            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[results2 stringForColumn:@"mediaImage"] lastPathComponent]];
                            [fileManager removeItemAtPath:pathTmp error:&error];
                            x++;
                        }
                    }
                    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                } else {
                    //case
                    [localDatabase executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[resultsBookmarked stringForColumn:@"documentID"],currentUsr, BOOKMARKCASE,nil];
                    BOOL bookmarked = NO;
                    
                    FMResultSet *results = [localDatabase executeQuery:@"SELECT * FROM UserBookmark where typeID=? and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:BOOKMARKCASE,[resultsBookmarked stringForColumn:@"documentID"], nil]];
                    while([results next]) {
                        bookmarked = YES;
                    }
                    FMResultSet *selectedCases = [localDatabase executeQuery:@"SELECT * FROM Cases where caseID=?" withArgumentsInArray:@[[resultsBookmarked stringForColumn:@"documentID"]]];
                    FCase * selected;
                    while([selectedCases next]) {
                        selected =  [[FCase alloc] initWithDictionaryFromDB:[selectedCases resultDictionary]];
                    }
                    
                    if (!bookmarked) {
                        if ([[selected coverflow] boolValue]) {
                            [localDatabase executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"0",selected.caseID];
                            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                        }
                        else{
                            [localDatabase executeUpdate:@"DELETE FROM Cases WHERE caseID=?",selected.caseID];
                            [localDatabase executeUpdate:@"INSERT INTO Cases (caseID,title, coverTypeID,name,image,active,authorID,isBookmark,alloweInCoverFlow, deleted, download, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?)",selected.caseID,selected.title,selected.coverTypeID,selected.name,selected.image,selected.active,selected.authorID,@"0",selected.coverflow,selected.deleted, selected.download, selected.userPermissions];
                            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                            x+=[selected getImages].count;
                            x+=[selected getVideos].count * 2;
                            for (FMedia *vid in [selected getVideos]) {
                                [self removeBookmarkForMedia:vid andType:MEDIAVIDEO forBookmarkType:BSOURCECASE];
                            }
                            for (FImage *image in [selected getImages]) {
                                [self removeBookmarkForImage:image andType:MEDIAIMAGE forBookmarkType:BSOURCECASE];
                            }
                            [[[FUpdateContent alloc]init] addMediaWhithout:[selected parseImagesFromServer:NO] withType:0];
                            [[[FUpdateContent alloc]init] addMediaWhithout:[selected parseVideosFromServer:NO] withType:1];
                        }
                    }
                }
            }
        }
        
    }
    [localDatabase close];
    NSLog(@"Unbookmarked items: %d",x);
    NSLog(@"Unbookmarking complete");
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEDBULKBOOKMARKS", nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}



#pragma mark - Remove Bookmark

+(void)removeBookmarkForMedia:(FMedia *)media andType:(NSString *)itemType forBookmarkType:(int)bookType{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    NSString *cases = @"";
    BOOL delete = YES;
    BOOL remove = YES;
     FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=? AND bookmarkType=?" withArgumentsInArray:@[usr, itemType, [media itemID],[NSString stringWithFormat:@"%d", bookType]]];
    BOOL stillBookmarked=NO;
    while([resultsBookmarked next]) {
        stillBookmarked=YES;
        cases =[resultsBookmarked stringForColumn:@"caseIDs"];
    }
    if (stillBookmarked) {
        if (bookType == BSOURCECASE) {
            NSMutableArray *casesArray = [[FCommon stringToArray:cases withSeparator:@","] mutableCopy];
            if([casesArray containsObject:[media itemID]]){
                [casesArray removeObject:[media itemID]];
            }
            cases = [FCommon arrayToString:casesArray withSeparator:@","];
            if (![cases isEqualToString:@""]) {
                delete = NO;
            }
        }
        
        if (delete) {
            [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? AND username=? AND typeID=? AND bookmarkType=?",[media itemID],usr,itemType, [NSString stringWithFormat:@"%d", bookType]];
        } else {
            [database executeUpdate:@"DELETE UserBookmark  set caseIDs=? WHERE documentID=? AND username=? AND typeID=? AND bookmarkType=?",cases,[media itemID],usr,itemType, [NSString stringWithFormat:@"%d", bookType]];
        }
        
        FMResultSet *resultsRemove = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=? AND bookmarkType=?" withArgumentsInArray:@[usr, itemType, [media itemID],[NSString stringWithFormat:@"%d", bookType]]];
        while([resultsRemove next]) {
            remove = NO;
        }
        if (remove) {
             [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=? AND mediaType=?",@"0",[resultsBookmarked stringForColumn:@"documentID"], itemType];
            NSString *downloadFilename = [FMedia createLocalPathForLink:[media path] andMediaType:itemType];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:downloadFilename error:&error];
            NSArray *pathComp=[[media mediaImage] pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[media mediaImage] lastPathComponent]];
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];

    
    [self refreshViewWithItem:media.itemID forItemType:itemType];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

+(void)removeBookmarkForImage:(FImage *)image andType:(NSString *)itemType forBookmarkType:(int)bookType{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    NSString *cases = @"";
    BOOL delete = YES;
    BOOL remove = YES;
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=? AND bookmarkType=?" withArgumentsInArray:@[usr, itemType, [image itemID],[NSString stringWithFormat:@"%d", bookType]]];
    BOOL stillBookmarked=NO;
    while([resultsBookmarked next]) {
        stillBookmarked=YES;
        cases =[resultsBookmarked stringForColumn:@"caseIDs"];
    }
    if (stillBookmarked) {
        if (bookType == BSOURCECASE) {
            NSMutableArray *casesArray = [[FCommon stringToArray:cases withSeparator:@","] mutableCopy];
            if([casesArray containsObject:[image itemID]]){
                [casesArray removeObject:[image itemID]];
            }
            cases = [FCommon arrayToString:casesArray withSeparator:@","];
            if (![cases isEqualToString:@""]) {
                delete = NO;
            }
        }
        
        if (delete) {
            [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? AND username=? AND typeID=? AND bookmarkType=?",[image itemID],usr,itemType, [NSString stringWithFormat:@"%d", bookType]];
        } else {
            [database executeUpdate:@"DELETE UserBookmark  set caseIDs=? WHERE documentID=? AND username=? AND typeID=? AND bookmarkType=?",cases,[image itemID],usr,itemType, [NSString stringWithFormat:@"%d", bookType]];
        }
        
        FMResultSet *resultsRemove = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=? AND bookmarkType=?" withArgumentsInArray:@[usr, itemType, [image itemID],[NSString stringWithFormat:@"%d", bookType]]];
        while([resultsRemove next]) {
            remove = NO;
        }
        if (remove) {
            [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=? AND mediaType=?",@"0",[resultsBookmarked stringForColumn:@"documentID"], itemType];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            NSArray *pathComp=[[image path] pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[image path] lastPathComponent]];
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    [self refreshViewWithItem:image.itemID forItemType:itemType];
    
    
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

+(void)removeBookmarkedCase:(FCase *)caseToRemove
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? AND username=? AND typeID=?",caseToRemove.caseID,usr,BOOKMARKCASE,nil];
    BOOL bookmarked = NO;
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where typeID=? AND documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:BOOKMARKCASE,caseToRemove.caseID, nil]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    
    if (!bookmarked) {
        [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"0",caseToRemove.caseID];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
        if (![[caseToRemove coverflow] boolValue]) {
            for (FMedia *vid in caseToRemove.video) {
                [self removeBookmarkForMedia:vid andType:MEDIAVIDEO forBookmarkType:BSOURCECASE];
            }
            for (FImage *image in caseToRemove.images) {
                [self removeBookmarkForImage:image andType:MEDIAIMAGE forBookmarkType:BSOURCECASE];
            }
        }
    }
    [self refreshViewWithItem:caseToRemove.caseID forItemType:BOOKMARKCASE];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}


@end

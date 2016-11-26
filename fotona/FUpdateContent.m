

#import "FUpdateContent.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "AFNetworking.h"
#import "FNews.h"
#import "FCaseCategory.h"
#import "FCase.h"
#import "FImage.h"
#import "FMedia.h"
#import "FAuthor.h"
#import "FDocument.h"
#import "MBProgressHUD.h"
#import "FFotonaMenu.h"
#import "FDownloadManager.h"
#import "Logger.h"
#import "FDB.h"
#import "FMediaManager.h"

@implementation FUpdateContent

@synthesize hudView;
@synthesize parent;

int endDate = 365;
float timeOutInterval = 180;
int removeHudNumber = 8;//how many downloads need to finish - 8

+(FUpdateContent *)shared{
    return [[FUpdateContent alloc] init];
}

-(void)updateContent:(UIViewController *)viewForHud{
    [Logger LogInfo:@"Start of logging" inObject:self];
    [self setParent:viewForHud];
    updateCounter=0;
    success=0;
    [self updateDisclaimer];
    [self updateNews];
    [self updateEvents];
    [self setCasesFlag];
    [self updateCaseCategories];
    [self updateAuthors];
    [self updateDocuments];
    [self updateFotonaTab];
    [self updateCases];
    [[FDownloadManager shared] prepareForDownloadingFiles];
    
}


#pragma mark News


-(void)updateNews
{
    NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"newsLastUpdate"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",FOTONAWEBSERVICE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postString;
    if ([lastUpdate isEqualToString:@""]) {
        postString = [NSString stringWithFormat:@"cmd=nws"];
    } else{
        lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@":"
                                                           withString:@"%3A"];
        lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@" "
                                                           withString:@"+"];
        postString = [NSString stringWithFormat:@"cmd=nws&d=%@", lastUpdate];
    }
    
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *dic = [[NSDictionary alloc] init];
        dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:&error];
        [self clearOldNews];
        [self parseNews:dic];
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"news failed %@",error.localizedDescription);
                                         [Logger LogError:@"news failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
}

-(void)parseNews:(NSDictionary *)dicNews
{
    
    int newsCount = 5;
    
    if([FCommon isGuest]){
        newsCount = 5;
    }
    else{
        newsCount = 5;
    }
    NSMutableArray *newsArray=[[NSMutableArray alloc] init];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    if([[dicNews valueForKey:@"msg"] isEqualToString:@"Success"]){
        NSArray *allNews=[dicNews objectForKey:@"values"];
        NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"newsLastUpdate"];
        if ([lastUpdate isEqualToString:@""]) {
            for (NSDictionary *n in allNews) {
                if ([[n valueForKey:@"active"] boolValue]) {
                    if ([n valueForKey:@"newsID"] != 0) {
                        if ([[n valueForKey:@"active"] boolValue]) {
                            NSDate *fromDate;
                            NSDate *toDate;
                            
                            NSCalendar *calendar = [NSCalendar currentCalendar];
                            
                            fromDate = [df dateFromString:[n valueForKey:@"date"]];
                            toDate =  [df dateFromString: [self currentTimeForNewsEvents]];
                            
                            NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                                       fromDate:fromDate toDate:toDate options:0];
                            
                            if (([difference day]>=0)&& ([difference day]<=endDate)) {
                                FNews *news;
                                
                                if(newsArray.count < newsCount){
                                    news=[[FNews alloc] initWithDictionaryDB:n WithRest:@"0" andBookmarked:@"0"];
                                }
                                else{
                                    news=[[FNews alloc] initWithDictionaryDB:n WithRest:@"1" andBookmarked:@"0"];
                                }
                                [newsArray addObject:news];
                            }
                            
                        }
                    }
                }
            }
        } else {//if news already exist in DB
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (NSDictionary *n in allNews) {
                if ([n valueForKey:@"newsID"] != 0) { //sometimes news have id 0 - those to be ignored
                    if ([[n valueForKey:@"active"] boolValue]) {
                        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where newsID=%@;", [n valueForKey:@"newsID"]]];
                        BOOL flag=NO;
                        NSString *online =@"";
                        NSString *bookmark =@"";
                        while([results next]) {
                            flag=YES;
                            online = [results stringForColumn:@"rest"];
                            bookmark = [results stringForColumn:@"isBookmark"];
                        }
                        FNews *news;
                        if (flag) {//if exist only update
                            news=[[FNews alloc] initWithDictionaryDB:n WithRest:online andBookmarked:bookmark];
                            [newsArray addObject:news];
                        }
                        else { //adding new news and deleting images from news over number 12
                            news=[[FNews alloc] initWithDictionaryDB:n WithRest:@"0" andBookmarked:@"0"];
                            //checking if there are already 12 news or not
                            NSUInteger count = [database  intForQuery:@"SELECT COUNT(*) FROM News"];
                            if (count>12) {
                                FMResultSet *resultsOffline = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where rest=%@ ORDER BY newsID ASC",@"0"]];
                                while([resultsOffline next]) {
                                    FNews *f;
                                    f=[[FNews alloc] initWithDictionary:[resultsOffline resultDictionary]];
                                    FNews * fDB;
                                    fDB= [[FNews alloc] initWithDictionaryToDB:f WithRest:@"1" andBookmarked:f.bookmark];
                                    [newsArray addObject:fDB];
                                    
                                    //if news already in array because of change from ws, change only rest
                                    for (FNews *c in newsArray) {
                                        if (c.newsID == fDB.newsID) {
                                            c.rest = @"1";
                                            [newsArray removeObject:fDB];
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            NSDate *fromDate;
                            NSDate *toDate;
                            
                            NSCalendar *calendar = [NSCalendar currentCalendar];
                            
                            fromDate = [df dateFromString:news.nDate];
                            toDate =  [df dateFromString: [self currentTimeForNewsEvents]];
                            NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                                       fromDate:fromDate toDate:toDate options:0];
                            
                            if (([difference day]>=0) && ([difference day]<=endDate)) {
                                [newsArray addObject:news];
                            }
                        }
                        
                    } else {
                        //if not active delete from db
                        [database executeUpdate:@"delete from News where newsID=?",[[NSNumber numberWithLong:[n valueForKey:@"newsID"]]stringValue]];
                        [self deleteNewsForUserTypes:[[NSNumber numberWithLong:[n valueForKey:@"newsID"]]stringValue]];
                    }
                }
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }
    }
    if (newsArray.count>0) {
        [self addNewsInDB:newsArray];
    }
    
    NSString *today=[self currentTimeInLjubljana];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"newsLastUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addNewsInDB:(NSMutableArray *)news
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FNews *fNews in news) {
        
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where newsID=%d;", (int)fNews.newsID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO News (newsID,title,langID,description,text,active,date,isReaded,headerImage,headerImageLink,images,imagesLinks,categories,rest,isBookmark) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[NSString stringWithFormat:@"%d", (int)fNews.newsID],fNews.title,langID,fNews.description,fNews.text, fNews.activeDB,fNews.nDate,@"0",fNews.headerImageDB, fNews.headerImageLink,fNews.imagesDB,fNews.imagesLinksDB,fNews.categoriesDB,fNews.rest, fNews.bookmark];
            
        }else
        {
            [database executeUpdate:@"UPDATE News set title=?,langID=?,description=?,text=?,active=?,date=?,headerImage=?, headerImageLink=?,images=?,imagesLinks=?,categories=?,rest=?,isBookmark=? where newsID=?",fNews.title,langID,fNews.description,fNews.text,fNews.activeDB,fNews.nDate,fNews.headerImageDB,fNews.headerImageLink,fNews.imagesDB, fNews.imagesLinksDB,fNews.categoriesDB,fNews.rest,fNews.bookmark,[NSString stringWithFormat:@"%d", (int)fNews.newsID]];
            
            [self deleteNewsForUserTypes:[[NSNumber numberWithLong:fNews.newsID]stringValue]];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

-(void)deleteNewsForUserTypes:(NSString *)nID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"delete from NewsInUserType where newsID=?",nID];
    [database executeUpdate:@"delete from NewsInUserSubType where newsID=?",nID];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

-(void)addNews:(NSString *)nId inUserType:(NSString *)t
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    [database executeUpdate:@"INSERT INTO NewsInUserType (newsID,userType) VALUES (?,?)",nId,t];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    
    [database close];
}

-(void)addNews:(NSString *)nId inUserSubType:(NSString *)st
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    [database executeUpdate:@"INSERT INTO NewsInUserSubType (newsID,userSubType) VALUES (?,?)",nId,st];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    
    [database close];
}

-(void) clearOldNews{
    NSMutableArray *delete = [NSMutableArray new];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News"]];
    while([results next]) {
        FNews *f;
        f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        fromDate = [df dateFromString:f.nDate];
        toDate =  [df dateFromString: [self currentTimeForNewsEvents]];
        
        NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                   fromDate:fromDate toDate:toDate options:0];
        
        if ([difference day]>endDate) {
            [delete addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    for (FNews *f in delete) {
        NSString *usr = [FCommon getUser];
        
        [database executeUpdate:@"delete from News where newsID=?",[[NSNumber numberWithLong:f.newsID]stringValue]];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@ AND userName=%@",[[NSNumber numberWithLong:f.newsID]stringValue],BOOKMARKNEWS,usr]];
        BOOL flag = NO;
        while([results next]) {
            flag = YES;
        }
        if (flag) {
            [database executeUpdate:@"delete from UserBookmark where documentID=? AND typeID=? AND userName=?",[[NSNumber numberWithLong:f.newsID]stringValue],BOOKMARKNEWS,usr];
        }
    }
    
}
#pragma mark Events

-(void) updateEvents
{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    
    NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"eventsLastUpdate"];
    //@"28.03.2015 08:29:02";//
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FOTONAWEBSERVICE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postString;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"eventsLastUpdate"]) {
        postString = [NSString stringWithFormat:@"cmd=xhb"];
    } else{
        lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@":"
                                                           withString:@"%3A"];
        lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@" "
                                                           withString:@"+"];
        postString = [NSString stringWithFormat:@"cmd=xhb&d=%@",lastUpdate];
    }
    
    
    
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operationEvent1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operationEvent1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationEvent1, id responseObject) {
        NSError *error;
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operationEvent1 responseData] options:NSJSONReadingMutableLeaves error:&error];
        NSMutableArray *fevents=[[NSMutableArray alloc] init];
        if([[dic valueForKey:@"msg"] isEqualToString:@"Success"]){
            NSArray *eventsTemp = [dic objectForKey:@"values"];
            for (NSDictionary *d in eventsTemp) {
                if ([d valueForKey:@"eventID"] != 0) {
                    
                    if (![[d valueForKey:@"active"] boolValue]) {
                        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                        [database open];
                        [database executeUpdate:@"delete from Events where eventID=?",[[NSNumber numberWithLong:[d valueForKey:@"eventID"]]stringValue]];
                        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                        [database close];
                    } else{
                        NSDate *fromDate;
                        NSDate *toDate;
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        
                        
                        fromDate = [df dateFromString:[d valueForKey:@"date"]];
                        toDate =  [df dateFromString: [self currentTimeForNewsEvents]];
                        
                        NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                                   fromDate:toDate toDate:fromDate options:0];
                        
                        
                        fromDate =  [df dateFromString:[d valueForKey:@"dateTo"]];
                        toDate = [df dateFromString: [self currentTimeForNewsEvents]];
                        
                        NSDateComponents *difference2 = [calendar components:NSDayCalendarUnit
                                                                    fromDate:toDate toDate:fromDate options:0];
                        
                        
                        if ((([difference day]>=0)&& ([difference day]<366)) || ([difference2 day]>0)) {
                            FEvent *e=[[FEvent alloc] initWithDictionaryDB:d];
                            [fevents addObject:e];
                        }
                        
                    }
                }
            }
        }
        
        NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"eventsLastUpdate"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FOTONAWEBSERVICE]];
        NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url];
        NSString *postString2;
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"eventsLastUpdate"]) {
            postString2 = [NSString stringWithFormat:@"cmd=wsh"];
        } else{
            lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@":"
                                                               withString:@"%3A"];
            lastUpdate = [lastUpdate stringByReplacingOccurrencesOfString:@" "
                                                               withString:@"+"];
            postString2 = [NSString stringWithFormat:@"cmd=wsh&d=%@",lastUpdate];
        }
        
        [request2 setHTTPBody:[postString2 dataUsingEncoding:NSUTF8StringEncoding]];
        [request2 setHTTPMethod:@"POST"];
        [request2 addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        AFHTTPRequestOperation *operationEvent2 = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operationEvent2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationEvent2, id responseObject) {
            NSError *error;
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operationEvent2 responseData] options:NSJSONReadingMutableLeaves error:&error];
            if([[dic valueForKey:@"msg"] isEqualToString:@"Success"]){
                NSArray *eventsTemp2 = [dic objectForKey:@"values"];
                for (NSDictionary *d in eventsTemp2) {
                    if ([d valueForKey:@"eventID"] != 0) {
                        if (![[d valueForKey:@"active"] boolValue]) {
                            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
                            [database open];
                            [database executeUpdate:@"delete from Events where eventID=?",[[NSNumber numberWithLong:[d valueForKey:@"eventID"]]stringValue]];
                            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
                            [database close];
                        } else{
                            NSDate *fromDate;
                            NSDate *toDate;
                            NSCalendar *calendar = [NSCalendar currentCalendar];
                            
                            toDate=  [df dateFromString: [self currentTimeForNewsEvents]];
                            fromDate= [df dateFromString:[d valueForKey:@"date"]];
                            
                            NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:toDate toDate:fromDate options:0];
                            
                            
                            
                            toDate = [df dateFromString: [self currentTimeForNewsEvents]];
                            fromDate =  [df dateFromString:[d valueForKey:@"dateTo"]];
                            
                            
                            NSDateComponents *difference2 = [calendar components:NSDayCalendarUnit
                                                                        fromDate:toDate toDate:fromDate  options:0];
                            
                            
                            
                            if ((([difference day]>=0)&& ([difference day]<366)) || ([difference2 day]>0)) {
                                FEvent *e2=[[FEvent alloc] initWithDictionaryDB:d];
                                [fevents addObject:e2];
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
            //date sorting
            eventsArray = [fevents sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSDate *first = [df dateFromString:[(FEvent*)a eventdate]];
                NSDate *second = [df dateFromString:[(FEvent*)b eventdate]];
                return [first compare:second];
            }];
            
            [self addEventsInDB:eventsArray];
            [self clearOldEvents];
            updateCounter++;
            success++;
            if (updateCounter==removeHudNumber) {
                [self removeHud];
            }
            
        }
                                               failure:^(AFHTTPRequestOperation *operationEvent1, NSError *error) {
                                                   NSLog(@"events2 failed %@",error.localizedDescription);
                                                   [Logger LogError:@"events2 failed" withError:error inObject:self];
                                                   updateCounter++;
                                                   if (updateCounter==removeHudNumber) {
                                                       [self removeHud];
                                                   }
                                                   
                                               }];
        [operationEvent2 start];
    }
                                           failure:^(AFHTTPRequestOperation *operationEvent1, NSError *error) {
                                               NSLog(@"events1 failed %@",error.localizedDescription);
                                               [Logger LogError:@"events1 failed" withError:error inObject:self];
                                               updateCounter++;
                                               if (updateCounter==removeHudNumber) {
                                                   [self removeHud];
                                               }
                                               
                                           }];
    
    
    [operationEvent1 start];
}

-(void)addEventsInDB:(NSMutableArray *)events
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FEvent *fEvent in events) {
        
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Events where eventID=%d;", (int)fEvent.eventID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO Events (eventID,title,description,date,text,type,categories,images,dateTo, mobileFeatured) VALUES (?,?,?,?,?,?,?,?,?,?)",[NSString stringWithFormat:@"%d", (int)fEvent.eventID],fEvent.title,fEvent.eventplace,fEvent.eventdate, fEvent.text,[NSString stringWithFormat:@"%d", (int)fEvent.typeE],fEvent.eventcategoriesDB,fEvent.eventImagesDB, fEvent.eventdateTo, fEvent.mobileFeaturedDB];
            
        }else
        {
            [database executeUpdate:@"UPDATE Events set title=?,description=?,date=?,text=?,type=?,categories=?,images=?,dateTo=?, mobileFeatured=?  where eventID=?",fEvent.title,fEvent.eventplace,fEvent.eventdate,fEvent.text,[NSString stringWithFormat:@"%d", (int)fEvent.typeE],fEvent.eventcategoriesDB,fEvent.eventImagesDB,fEvent.eventdateTo, fEvent.mobileFeaturedDB,[NSString stringWithFormat:@"%d", (int)fEvent.eventID]];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    NSString *today=[self currentTimeInLjubljana];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"eventsLastUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) clearOldEvents{
    NSMutableArray *delete = [NSMutableArray new];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Events"]];
    while([results next]) {
        FEvent *f;
        f=[[FEvent alloc] initWithDictionary:[results resultDictionary]];
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        fromDate = [df dateFromString:f.eventdate];
        toDate =  [df dateFromString: [self currentTimeForNewsEvents]];
        
        
        
        NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                   fromDate:toDate toDate:fromDate options:0];
        
        //check if dateTo is still avaliable
        toDate = [df dateFromString: [self currentTimeForNewsEvents]];
        fromDate =  [df dateFromString:f.eventdateTo];
        
        
        NSDateComponents *difference2 = [calendar components:NSDayCalendarUnit
                                                    fromDate:toDate toDate:fromDate options:0];
      //  NSLog(@"%d, %d, %@",[difference day],[difference2 day], f.title);
        if (([difference day]<0) && ([difference2 day]<=0)) {
            [delete addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    
    for (FEvent *f in delete) {
        NSString *usr = [FCommon getUser];
        
        [database executeUpdate:@"delete from Events where eventID=?",[[NSNumber numberWithLong:f.eventID]stringValue]];
        FMResultSet *results = [database executeQuery:@"SELECT * FROM UserBookmark where documentID=? AND typeID=? AND username=?" withArgumentsInArray:[NSArray arrayWithObjects:@"100",BOOKMARKEVENTS,@"guest", nil]];//[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@ AND username=%@",[[NSNumber numberWithLong:f.eventID]stringValue],BOOKMARKEVENTS,usr]];
        BOOL flag = NO;
        while([results next]) {
            flag = YES;
        }
        if (flag) {
            [database executeUpdate:@"delete from UserBookmark where documentID=? AND typeID=? AND username=?",[[NSNumber numberWithLong:f.eventID]stringValue],BOOKMARKEVENTS,usr];
        }
    }
    [database close];
    
}


#pragma mark Cases

-(void)setCasesFlag{
    casesFlag=0;
}

-(void)updateCaseCategories
{
    NSString *requestData;
    
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"dateUpdated\":\"%@\"}",langID,[[NSUserDefaults standardUserDefaults] objectForKey:@"caseCategoriesLastUpdate"]];
    //
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKCASECATEGORY] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        //        NSLog(@"%@",[operation responseString]);
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        [self parseCaseCategories:dic];
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"CC failed %@",error.description);
                                         NSLog(@"CC failed %@",operation.response.description);
                                         [Logger LogError:@"CC failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
}
-(void)parseCaseCategories:(NSDictionary *)dicCC
{
    NSMutableArray *ccArray=[[NSMutableArray alloc] init];
    NSArray *allCC=[dicCC objectForKey:@"d"];
    for (NSDictionary *c in allCC) {
        FCaseCategory *cc=[[FCaseCategory alloc] initWithDictionary:c];
        [ccArray addObject:cc];
        
    }
    if (ccArray.count>0) {
        
        NSString *today=[self currentTimeInLjubljana];
        
        [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"caseCategoriesLastUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self addCaseCategoriesInDB:ccArray];
        
    }
    
}

-(void)addCaseCategoriesInDB:(NSMutableArray *)ccArray
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FCaseCategory *cc in ccArray) {
        
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM CaseCategories where categorieID=%@;",cc.categoryID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO CaseCategories (categorieID,categorieIDPrev,title,langID,sort,active) VALUES (?,?,?,?,?,?)",cc.categoryID,cc.categoryIDPrev,cc.title,langID,cc.sort,cc.active];
        }else
        {
            [database executeUpdate:@"UPDATE CaseCategories set categorieIDPrev=?,title=?,langID=?,sort=?,active=? where categorieID=?",cc.categoryIDPrev,cc.title,langID,cc.sort,cc.active,cc.categoryID];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    casesFlag++;
    if (casesFlag==2) {
        //        [self setCaseInCategories];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
}

-(void)updateCases
{
    NSString *requestData;
    
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"dateUpdated\":\"%@\"}",langID,[[NSUserDefaults standardUserDefaults] objectForKey:@"casesLastUpdate"]];
    
    //
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKCASES]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        [self parseCases:dic];
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Cases failed %@",error.localizedDescription);
                                         [Logger LogError:@"Cases failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    [operation start];
}

-(void)parseCases:(NSDictionary *)dicCases
{
    NSMutableArray *casesArray=[[NSMutableArray alloc] init];
    NSArray *allCaces=[dicCases objectForKey:@"d"];
    for (NSDictionary *c in allCaces) {
        FCase *caseObj=[[FCase alloc] initWithDictionaryFromServer:c];
        [casesArray addObject:caseObj];
    }
    [APP_DELEGATE setCaseArray:casesArray];
    if (casesArray.count>0) {
        NSString *today=[self currentTimeInLjubljana];
        [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"casesLastUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self addCasesInDB:casesArray];
    }
    
}


-(void)addCasesInDB:(NSMutableArray *)caseArray
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FCase *c in caseArray) {
        if ([c active] ) {
            FMResultSet *resultsBookmarked = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark WHERE documentID=%@ AND typeID=%@", c.caseID, BOOKMARKCASE]];
            NSString *bookmarked=@"0";
            while([resultsBookmarked next]) {
                bookmarked=@"1";
            }
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@;",c.caseID]];
            BOOL flag=NO;
            while([results next]) {
                flag=YES;
            }
            BOOL download = NO;
            if ([bookmarked isEqualToString:@"1"] || [[c coverflow] isEqualToString:@"1"]) {
                download = YES;
            }
            
            [FDB updateMedia:[c parseImagesFromServer:YES] andType:MEDIAIMAGE  andDownload:download forCase:c.caseID];
            [FDB updateMedia:[c parseVideosFromServer:YES] andType:MEDIAVIDEO  andDownload:download forCase:c.caseID];
            if ([c.coverflow boolValue] || [bookmarked boolValue]) {
                if (!flag) {
                    [database executeUpdate:@"INSERT INTO Cases (caseID,title,langID,coverTypeID,name,image,introduction,procedure,results,'references',parameters,date,active,authorID,isBookmark,alloweInCoverFlow, deleted, download, userPermissions, galleryItemVideoIDs, galleryItemImagesIDs) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",c.caseID,c.title,langID,c.coverTypeID,c.name,c.image,c.introduction,c.procedure,c.results,c.references,c.parameters,c.date,c.active,c.authorID,bookmarked,c.coverflow, c.deleted, c.download, c.userPermissions, c.galleryItemVideoIDs, c.galleryItemImagesIDs];


                    [self setCase:c.caseID InCategories:c.categories];
                }else
                {
                    [self deleteCasesFromCategories:c.caseID];
                    if ([c.deleted isEqualToString:@"1"]) {
                        [FDB removeCaseWithID:c.caseID];
                    } else {
                        
                        [database executeUpdate:@"UPDATE Cases set title=?,langID=?,coverTypeID=?,name=?,image=?,introduction=?,procedure=?,results=?,'references'=?,parameters=?,date=?,active=?,authorID=?,alloweInCoverFlow=?,isBookmark=?, deleted=?, download=?, userPermissions=?, galleryItemVideoIDs=?, galleryItemImagesIDs=? where caseID=?",c.title,langID,c.coverTypeID,c.name,c.image,c.introduction,c.procedure,c.results,c.references,c.parameters,c.date,c.active,c.authorID,c.coverflow,bookmarked, c.deleted, c.download, c.userPermissions, c.galleryItemVideoIDs, c.galleryItemImagesIDs, c.caseID];
                        [self setCase:c.caseID InCategories:c.categories];
                    }
                }
            } else {
                if (!flag) {
                    [database executeUpdate:@"INSERT INTO Cases (caseID,title,langID,coverTypeID,name,image,introduction,procedure,results,'references',parameters,date,active,authorID,isBookmark,alloweInCoverFlow, deleted, download, userPermissions, galleryItemVideoIDs, galleryItemImagesIDs) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",c.caseID,c.title,langID,c.coverTypeID,c.name,c.image,c.introduction,c.procedure,c.results,c.references,c.parameters,c.date,c.active,c.authorID,bookmarked,c.coverflow, c.deleted, c.download, c.userPermissions, c.galleryItemVideoIDs, c.galleryItemImagesIDs];

                    [self setCase:c.caseID InCategories:c.categories];
                }else
                {
                    [self deleteCasesFromCategories:c.caseID];
                    if ([c.deleted isEqualToString:@"1"]) {
                        [FDB removeCaseWithID:c.caseID];
                    } else {
                        [database executeUpdate:@"UPDATE Cases set title=?,langID=?,coverTypeID=?,name=?,image=?,introduction=?,procedure=?,results=?,'references'=?,parameters=?,date=?,active=?,authorID=?,alloweInCoverFlow=?,isBookmark=?, deleted=?, download=?, userPermissions=?, galleryItemVideoIDs=?, galleryItemImagesIDs=? where caseID=?",c.title,langID,c.coverTypeID,c.name,c.image,c.introduction,c.procedure,c.results,c.references,c.parameters,c.date,c.active,c.authorID,c.coverflow,bookmarked, c.deleted, c.download, c.userPermissions, c.galleryItemVideoIDs, c.galleryItemImagesIDs, c.caseID];
                        [self setCase:c.caseID InCategories:c.categories];

                    }
                }
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

-(void)deleteCasesFromCategories:(NSString *)cID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"delete from CasesInCategories where caseID=?",cID];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}

-(void)setCase:(NSString *)caseID InCategories:(NSMutableArray *)catIDArray
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (NSString *catID in catIDArray) {
        [database executeUpdate:@"INSERT INTO CasesInCategories (caseID,categorieID) VALUES (?,?)",caseID,catID];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}


-(void)addMedia:(NSMutableArray *)m withType:(int)type{
    if (m.count>0) {
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,sort, deleted, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?)",img.itemID,img.title,img.path,pathTmp,img.description,@"0",@"0",img.sort, img.deleted, img.fileSize];
                
                [[APP_DELEGATE imagesToDownload] addObject:img.path];
                
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                NSArray *pathComp=[vid.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,time,mediaImage,sort, active, deleted, download, fileSize, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.title,vid.path,pathTmp,vid.description,@"1",@"1",vid.time,vid.mediaImage,vid.sort, vid.active, vid.deleted, vid.download, vid.filesize, vid.userPermissions];

                [[APP_DELEGATE videosToDownload] addObject:vid.path];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }
        
    }
}
//adding images and videos without downloading them
-(void)addMediaWhithout:(NSMutableArray *)m withType:(int)type{
    if (m.count>0) {
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,sort, deleted, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?)",img.itemID,img.title,img.path,pathTmp,img.description,@"0",@"0",img.sort, img.deleted, img.fileSize];
                //                [img downloadFile:img.path inFolder:@"/.Cases"];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                NSArray *pathComp=[vid.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,time,mediaImage,sort, active, deleted, download, fileSize, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.title,vid.path,pathTmp,vid.description,@"1",@"0",vid.time,vid.mediaImage,vid.sort, vid.active, vid.deleted, vid.download, vid.filesize, vid.userPermissions];
                //                [vid downloadFile:vid.path inFolder:@"/.Cases"];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        }
        
    }
}
//update video and images
-(void)updateMedia:(NSMutableArray *)m withType:(int)type idArray:(NSMutableArray*)arrayID{
    NSString *bookmark=@"0";
    if (m.count>0) {
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        if (type==0) {
            //            for (FImage *img in m) {
            //
            //                FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@;",img.itemID]];
            //                BOOL flag=NO;
            //                while([results next]) {
            //                    flag=YES;
            //                    bookmark = [results objectForColumnName:@"isBookmark"];
            //                }
            //                if (!flag) {
            //                    NSArray *pathComp=[img.path pathComponents];
            //                    NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
            //                    [database executeUpdate:@"INSERT INTO Media (mediaID,galleryID,title,path,localPath,description,mediaType,isBookmark) VALUES (?,?,?,?,?,?,?,?)",img.itemID,img.galleryID,img.title,img.path,pathTmp,img.description,@"0",@"0"];
            //
            //                } else {
            //                    NSString *pathTmp = [results objectForColumnName:@"localPath"];
            //                    if ([bookmark boolValue]) {
            //
            //                        NSFileManager *fileManager = [NSFileManager defaultManager];
            //                        NSError *error;
            //                        [fileManager removeItemAtPath:[results objectForColumnName:@"localPath"] error:&error];
            //                        NSArray *pathComp=[img.path pathComponents];
            //                        pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
            //                        [[APP_DELEGATE videosToDownload] addObject:pathTmp];
            //                    }
            //                    [database executeUpdate:@"UPDATE Media set galleryID=?,title=?,path=?,localPath=?,description=?,mediaType=? where mediaID=?",img.galleryID,img.title,img.path,pathTmp,img.description,@"0",img.itemID];
            //
            //            }
            //            }
        }else{
            if(type==1){
                
                for (FMedia *vid in m) {
                    NSString *pathTmp = @"";
                    NSArray *pathComp;
                    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@",vid.itemID]];
                    BOOL flag=NO;
                    while([results next]) {
                        flag=YES;
                        bookmark = [results objectForColumnName:@"isBookmark"];
                        pathComp=[[results objectForColumnName:@"path"] pathComponents];
                        pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                        
                    }
                    if (!flag) {
                        pathComp=[vid.path pathComponents];
                        pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                        
                        [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,time,mediaImage,sort, active, deleted, download, fileSize, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.title,vid.path,pathTmp,vid.description,@"1",@"0",vid.time,vid.mediaImage,vid.sort, vid.active, vid.deleted, vid.download, vid.filesize, vid.userPermissions];
                        
                        if ([arrayID containsObject:vid.itemID ])
                        {
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSError *error;
                            [fileManager removeItemAtPath:pathTmp error:&error];
                            NSArray *pathComp=[vid.path pathComponents];
                            pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                            [[APP_DELEGATE videosToDownload] addObject:vid.path];
                            [[APP_DELEGATE imagesToDownload] addObject:vid.mediaImage];
                            [arrayID removeObject:vid.itemID];
                            [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"1",vid.itemID];
                        }
                        
                    } else {
                        
                        if ([bookmark boolValue]) {
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSError *error;
                            [fileManager removeItemAtPath:pathTmp error:&error];
                            NSArray *pathComp=[vid.path pathComponents];
                            pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                            [[APP_DELEGATE videosToDownload] addObject:vid.path];
                            [[APP_DELEGATE imagesToDownload] addObject:vid.mediaImage];
                        }
                        [database executeUpdate:@"UPDATE Media set title=?,path=?,localPath=?,description=?,mediaType=?,time=?,mediaImage=?,sort=?, userPermissions=?, active=?, deleted=?, download=?, fileSize=? where mediaID=?",vid.title,vid.path,pathTmp,vid.description,@"1",vid.time,vid.mediaImage,vid.sort, vid.userPermissions, vid.active, vid.deleted, vid.download, vid.filesize, vid.itemID];
                    }
                }
                
            }
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
}


#pragma mark Authors
-(void)updateAuthors
{
    NSString *requestData;
    
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"dateUpdated\":\"%@\"}",langID,[[NSUserDefaults standardUserDefaults] objectForKey:@"authorsLastUpdate"]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WEBSERVICE, LINKAUTHORS]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        //        NSLog(@"Authors %@",[operation responseString]);
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        NSArray *allAutors=[dic valueForKey:@"d"];
        NSMutableArray *authors=[[NSMutableArray alloc] init];
        for (NSDictionary *d in allAutors) {
            FAuthor *author=[[FAuthor alloc] initWithDictionary:d];
            [authors addObject:author];
        }
        if (authors.count>0) {
            
            NSString *today=[self currentTimeInLjubljana];
            
            [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"authorsLastUpdate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self addAuthorsInDB:authors];
        }
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Authors failed %@",error.localizedDescription);
                                         [Logger LogError:@"Authors failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
}

-(void)addAuthorsInDB:(NSMutableArray *)authArr
{
    NSArray *pathComp = [NSArray new];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FAuthor *a in authArr) {
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author where authorID=%@",a.authorID]];
        BOOL flag=NO;
        while([results next]) {
            pathComp=[[results objectForColumnName:@"image"] pathComponents];
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO Author (authorID,name,langID,image,imageLocal,cv,active) VALUES (?,?,?,?,?,?,?)",a.authorID,a.name,langID,a.image,a.imageLocal,a.cv,a.active];
            //            [a downloadFile:a.image inFolder:@".Authors"];
            [[APP_DELEGATE authorsImageToDownload] addObject:[a.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            
        }else
        {
            
            NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Authors",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[pathComp objectAtIndex:pathComp.count-1] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:downloadFilename error:&error];
            [database executeUpdate:@"UPDATE Author set name=?,langID=?,image=?,imageLocal=?,cv=?,active=? where authorID=?",a.name,langID,a.image,a.imageLocal,a.cv,a.active,a.authorID];
            
            [[APP_DELEGATE authorsImageToDownload] addObject:[a.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
}



//http://fotona.com.rosebloom.arvixe.com/rest/WebService.asmx/GetAllDocuments
#pragma mark Documents
-(void)updateDocuments
{
    NSString *requestData;
    
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"dateUpdated\":\"%@\"}",langID,[[NSUserDefaults standardUserDefaults] objectForKey:@"documentsLastUpdate"]];
    
    //
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKDOCUMENTS]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        //        NSLog(@"DOC: %@",[operation responseString]);
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        [self parseDoc:dic];
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"DOC failed %@",error.localizedDescription);
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
}
-(void)parseDoc:(NSDictionary *)dicDoc
{
    NSMutableArray *docArray=[[NSMutableArray alloc] init];
    NSArray *allDoc=[dicDoc objectForKey:@"d"];
    //    NSLog(@"count %lu",(unsigned long)allNews.count);
    for (NSDictionary *d in allDoc) {
        FDocument *docObj=[[FDocument alloc] initWithDictionary:d];
        [docArray addObject:docObj];
        
    }
    if (docArray.count>0) {
        
        NSString *today=[self currentTimeInLjubljana];
        [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"documentsLastUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self addDocInDB:docArray];
        
    }
}


-(void)addDocInDB:(NSMutableArray *)docArray
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FDocument *d in docArray) {
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Documents where documentID=%@;",d.documentID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        if (!flag) {
            [database executeUpdate:@"INSERT INTO Documents (documentID,title,langID,iconType,description,isLink,link,src,active, bookmark, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?)",d.documentID,d.title,langID,d.iconType,d.description,d.isLink,d.link,d.src,d.active, d.bookmark, d.userPermissions];

        }else{
            [database executeUpdate:@"UPDATE Documents set title=?,langID=?,iconType=?,description=?,isLink=?,link=?,src=?,active=?, userPermission=? where documentID=?",d.title,langID,d.iconType,d.description,d.isLink,d.link,d.src,d.active, d.userPermissions,d.documentID];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}




#pragma mark FotonaTab

-(void)updateFotonaTab
{
    NSString *requestData;
    
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"dateUpdated\":\"%@\"}", langID, [[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaLastUpdate"]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKFOTONATAB]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        //        NSLog(@"Fotona1: %@",[operation responseString]);
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        NSArray *allAutors=[dic valueForKey:@"d"];
        NSMutableArray *fMenu=[[NSMutableArray alloc] init];
        for (NSDictionary *d in allAutors) {
            FFotonaMenu *menu=[[FFotonaMenu alloc] initWithDictionaryFromServer:d];
            [fMenu addObject:menu];
                    }
        if (fMenu.count>0) {
            
            NSString *today=[self currentTimeInLjubljana];
            
            [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"fotonaLastUpdate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self addFotonaMenuInDB:fMenu];
        }
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Fotona1: failed %@",error.localizedDescription);
                                         [Logger LogError:@"Fotona1 failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
}

-(void)addFotonaMenuInDB:(NSMutableArray *)menuArr
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    for (FFotonaMenu *m in menuArr) {
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where categoryID=%@;",m.categoryID]];
        BOOL flag=NO;
        while([results next]) {
            flag=YES;
        }
        
        [FDB updateMedia:m.pdfArray andType:MEDIAPDF andDownload:NO forCase:nil];
        [FDB updateMedia:m.videoArray andType:MEDIAVIDEO andDownload:NO forCase:nil];

        if (!flag) {

            [database executeUpdate:@"INSERT INTO FotonaMenu (categoryID,categoryIDPrev,langID,title,fotonaCategoryType,description,text,caseID,externalLink,active,sort,icon,isBookmark, userPermissions, galleryItemIDs, deleted) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",m.categoryID,m.categoryIDPrev,langID,m.title,m.fotonaCategoryType,m.description,m.text,m.caseID,m.externalLink,m.active,m.sort,m.iconName,@"0", m.userPermissions,m.galleryItemIDs,m.deleted];
        }else{
            if ([m.deleted isEqualToString:@"1"]) {
                [FDB removeFotonaMenuWithID:m.categoryID];
            } else {
                [database executeUpdate:@"UPDATE FotonaMenu set categoryIDPrev=?,langID=?,title=?,fotonaCategoryType=?,description=?,text=?,caseID=?,externalLink=?,active=?,sort=?,icon=?, userPermissions=?, galleryItemIDs=?, deleted=? WHERE categoryID=?",m.categoryIDPrev,langID,m.title,m.fotonaCategoryType,m.description,m.text,m.caseID,m.externalLink,m.active,m.sort,m.iconName,m.userPermissions,m.galleryItemIDs,m.deleted,m.categoryID];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}


-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder
{
    fileUrl=[fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[[fileUrl lastPathComponent] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]]]) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        [request setTimeoutInterval:1200];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[[request URL] lastPathComponent]];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", path);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@| %@", error,fileUrl);
            //alert
            
        }];
        
        [operation start];
    }
}

- (void) updateDisclaimer {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WEBSERVICE, LINKDISCLAIMER]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:timeOutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        NSString *disclaimer=[dic objectForKey:@"d"];
        NSError *jsonError;
        NSData *objectData = [disclaimer dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&jsonError];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:[json objectForKey:@"short"] forKey:@"disclaimerShort"];
        [defaults setObject:[json objectForKey:@"long"] forKey:@"disclaimerLong"];
        [defaults synchronize];
        
        
        updateCounter++;
        success++;
        if (updateCounter==removeHudNumber) {
            [self removeHud];
        }
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Disclaimer failed %@, %f",error.localizedDescription, operation.request.timeoutInterval);
                                         [Logger LogError:@"Disclaimer failed" withError:error inObject:self];
                                         updateCounter++;
                                         if (updateCounter==removeHudNumber) {
                                             [self removeHud];
                                         }
                                     }];
    
    [operation start];
    
    
}


-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    
    if (success<updateCounter) {
        UIAlertView *av;
        if([APP_DELEGATE logingEnabled])
        {
          av =[[UIAlertView alloc] initWithTitle:@"" message:@"Problem with content update!" delegate:parent cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again",@"Send report", nil];
        } else
        {
            av=[[UIAlertView alloc] initWithTitle:@"" message:@"Problem with content update!" delegate:parent cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        }
        
        [av setTag:0];
        [av show];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"updated" forKey:@"lastUpdate"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[FDownloadManager shared] prepareForDownloadingFiles];
    if (![APP_DELEGATE loginShown]) {
        [MBProgressHUD hideAllHUDsForView:parent.view animated:YES];
        id<UpdateDelegate> strongDelegate = self.updateDelegate;
        if ([strongDelegate respondsToSelector:@selector(updateProcess)])
        {
            [strongDelegate updateProcess];
        }
        [[APP_DELEGATE imagesToDownload]removeAllObjects];
        [[APP_DELEGATE videosToDownload]removeAllObjects];
        [[APP_DELEGATE pdfToDownload]removeAllObjects];
        [[APP_DELEGATE authorsImageToDownload]removeAllObjects];
    }
    
    
    
}


-(NSString *)currentTimeInLjubljana
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

-(NSString *)currentTimeForNewsEvents
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}



@end

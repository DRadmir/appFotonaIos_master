//
//  FNews.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FNews.h"
#import "FMDatabase.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"

@implementation FNews
@synthesize newsID;
@synthesize title;
@synthesize description;
@synthesize text;
@synthesize active;
@synthesize nDate;
@synthesize isReaded;
@synthesize headerImage;
@synthesize images;
@synthesize imagesLinks;
@synthesize categories;
@synthesize rest;
@synthesize headerImageLink;

//db
@synthesize activeDB;
@synthesize isReadedDB;
@synthesize imagesDB;
@synthesize imagesLinksDB;
@synthesize categoriesDB;
@synthesize headerImageDB;

@synthesize bookmark;


@synthesize localImage;
@synthesize localImages;

-(id)init
{
    self=[super init];
    if (self) {
    }
    
    
    return self;
}
-(id)initWithDictionaryDB:(NSDictionary *)dic WithRest:(NSString *)online andBookmarked:(NSString *)bookmark
{
    self=[super init];
    if (self) {
        
        [self setNewsID:[[dic valueForKey:@"newsID"]  integerValue]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setText:[dic valueForKey:@"text"]];
        [self setActiveDB:[NSString stringWithFormat:@"%hhd",[[dic valueForKey:@"active"] boolValue]]];
        [self setIsReadedDB:[NSString stringWithFormat:@"%hhd",[[dic valueForKey:@"isReaded"] boolValue]]];
        [self setNDate:[dic valueForKey:@"date"]];
        NSString *temp = @"";
        NSMutableArray * download = [NSMutableArray new];
        NSString *url_Img_FULL = [dic valueForKey:@"headerImage"];
        NSArray *pathComp=[url_Img_FULL pathComponents];
        NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[url_Img_FULL lastPathComponent]];
        
        [self setHeaderImageDB:pathTmp];
        if ([online isEqualToString:@"0"] || [bookmark isEqualToString:@"1"]) {
            //[download addObject:url_Img_FULL];
            [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
        }
        temp = @"";
        for (int i =0; i<[[dic valueForKey:@"images"] count]; i++) {
            if (i>0) {
                temp=[temp stringByAppendingString:@","];
            }
            
            NSString *url_Img_FULL = [[dic valueForKey:@"images"] objectAtIndex:i];
            NSArray *pathComp=[url_Img_FULL pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[url_Img_FULL lastPathComponent]];
            
            temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%@",pathTmp]];
            if ([online isEqualToString:@"0"] || [bookmark isEqualToString:@"1"]) {
                // [download addObject:url_Img_FULL];
                [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
                
            }
        }
        [self setImagesDB:temp];
        //[[FDownloadManager shared] downloadImages:download];
        // saving links for the images
        [self setHeaderImageLink:[dic valueForKey:@"headerImage"]];
        
        NSString *temp3 = @"";
        for (int i =0; i<[[dic valueForKey:@"images"] count]; i++) {
            if (i>0) {
                temp3=[temp3 stringByAppendingString:@","];
            }
            temp3= [temp3 stringByAppendingString:[NSString stringWithFormat:@"%@",  [[dic valueForKey:@"images"] objectAtIndex:i]]];
        }
        [self setImagesLinksDB:temp3];
        
        NSString *temp2 = @"";
        for (int i =0; i<[[dic valueForKey:@"categories"] count]; i++) {
            if (i>0) {
                temp2 = [temp2 stringByAppendingString:@","];
            }
            temp2 =[temp2 stringByAppendingString:[[[dic valueForKey:@"categories"] objectAtIndex:i] stringValue]];
        }
        [self setCategoriesDB:temp2];
        [self setRest:online];
        [self setBookmark:bookmark];
    }
    return self;
}




-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        NSMutableArray *tempA = [[NSMutableArray alloc]init];
        NSString *temp = @"";
        [self setNewsID:[[dic valueForKey:@"newsID"]  integerValue]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setText:[dic valueForKey:@"text"]];
        [self setActive:[[dic valueForKey:@"active"] boolValue]];
        [self setNDate:[dic valueForKey:@"date"]];
        
        NSString *usr = [FCommon getUser];
        
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *resultsRead = [database executeQuery:@"SELECT * FROM NewsRead where userName=? and  newsID=?" withArgumentsInArray:@[usr, [dic valueForKey:@"newsID"]]];
        
        BOOL flag=NO;
        while([resultsRead next]) {
            flag=YES;
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
        [self setIsReaded:flag];
        
        [self setLocalImage:[dic valueForKey:@"headerImage"]];
        temp = [dic valueForKey:@"images"];
        NSMutableArray *tempB = [temp componentsSeparatedByString:@","];
        [self setLocalImages:tempB];
        
        
        [self setHeaderImageLink:[dic valueForKey:@"headerImageLink"]];
        tempA =  [[[dic valueForKey:@"imagesLinks"] componentsSeparatedByString:@","] mutableCopy];
        [self setImagesLinks:tempA];
        
        tempA = nil;
        temp = [dic valueForKey:@"categories"];
        tempA =  [[temp componentsSeparatedByString:@","] mutableCopy];
        
        [self setCategories:tempA];
        [self setRest:[dic valueForKey:@"rest"]];
        [self setBookmark:[dic valueForKey:@"isBookmark"]];
        if ([self.rest isEqualToString:@"0"] || [HelperBookmark bookmarked:self.newsID withType:BOOKMARKNEWS]) {
            
            UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",docDir,self.localImage]];
            [self setHeaderImage:img];
            
            NSMutableArray *tempB = self.localImages;
            NSMutableArray *tempA = [[NSMutableArray alloc]init];
            for (int i=0; i<tempB.count; i++) {
                UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",docDir,[tempB objectAtIndex:i]]]; // [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[tempB objectAtIndex:i]]]];
                if (img != nil) {
                    [tempA addObject:img];
                }
                
            }
            if ([tempA count]<1) {
                UIImage *img =[UIImage imageNamed:@"featured_news"];
                [tempA addObject:img];
                }
            [self setImages:tempA];
        } else {
            [self setImages:nil];
            [self setHeaderImage:nil];
        }
        
    }
    return self;
}

-(id)initWithDictionaryToDB:(FNews *)news WithRest:(NSString *)online andBookmarked:(NSString *)bookmark {
    self=[super init];
    if (self) {
        
        [self setNewsID:news.newsID];
        [self setTitle:news.title];
        [self setDescription:news.description];
        [self setText:news.text];
        [self setActiveDB:[NSString stringWithFormat:@"%hhd",news.active]];
        [self setIsReadedDB:[NSString stringWithFormat:@"%hhd",news.isReaded]];
        [self setNDate:news.nDate];
        NSString *temp = @"";
        // saving links for the images
        [self setHeaderImageLink:news.headerImageLink];
        for (int i =0; i<[news.imagesLinks count]; i++) {
            if (i>0) {
                temp=[temp stringByAppendingString:@","];
            }
            temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%@",  [news.imagesLinks objectAtIndex:i]]];
        }
        [self setImagesLinksDB:temp];
        
        NSString *temp2 = @"";
        for (int i =0; i<[news.categories count]; i++) {
            if (i>0) {
                temp2 = [temp2 stringByAppendingString:@","];
            }
            if([[news.categories objectAtIndex:i]isKindOfClass:[NSString class]]){
                temp2 =[temp2 stringByAppendingString:[news.categories objectAtIndex:i]];
            } else {
                temp2 =[temp2 stringByAppendingString:[[news.categories objectAtIndex:i] stringValue]];
            }
            
        }
        
        [self setHeaderImageDB:news.localImage];
        for (int i =0; i<[news.localImages count]; i++) {
            if (i>0) {
                temp=[temp stringByAppendingString:@","];
            }
            temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%@",  [news.images objectAtIndex:i]]];
        }
        [self setImagesDB:temp];
        
        [self setCategoriesDB:temp2];
        [self setRest:online];
        [self setBookmark:bookmark];
    }
    return self;
    
}

#pragma mark - Adding images

+(NSMutableArray*)getImages:(NSMutableArray *)newsArray fromStart:(int)startIndex forNumber:(int)number
{

        for (int c=0; c<number; c++) {
            UIImage *img;
            if ([HelperBookmark bookmarked:[[newsArray objectAtIndex:startIndex+c] newsID] withType:BOOKMARKNEWS]) {
                NSString * header =[[newsArray objectAtIndex:startIndex+c] localImage];
                img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",docDir,header]];
            } else {
                NSString * header =[[newsArray objectAtIndex:startIndex+c] headerImageLink];
                if (header == nil || [header isEqualToString:@""] || (![APP_DELEGATE connectedToInternet])) {
                    img = [UIImage imageNamed:@"related_news"]; 
                } else {
                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",  header];
                    img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                    
                }
            }
            
            [[newsArray objectAtIndex:startIndex+c] setHeaderImage:img];
            NSMutableArray *temp = [[NSMutableArray alloc]init];
            FNews *sf = [newsArray objectAtIndex:startIndex+c];
            if ([[sf rest] isEqualToString:@"1"] && ![HelperBookmark bookmarked:sf.newsID withType:BOOKMARKNEWS]) {
                if ([sf imagesLinks].count>0) {
                    
                    for (int i=0; i<[sf imagesLinks].count; i++){
                        NSString * featured =[[sf imagesLinks] objectAtIndex:i];
                        if (featured == nil || [featured isEqualToString:@""] || (![APP_DELEGATE connectedToInternet])) {
                            img = [UIImage imageNamed:@"featured_news"];
                            [temp addObject: img];
                            break;
                        } else {
                            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:featured]]];//fetching image from link
                            if (img != nil){
                                [temp addObject: img];
                                
                            }
                            else {
                                img = [UIImage imageNamed:@"featured_news"];
                                [temp addObject: img];
                                break;
                            }
                        }
                    }
                    [sf setImages:temp];
                } else{
                    img = [UIImage imageNamed:@"featured_news"];
                    [[sf images] addObject: img];
                }
                if([APP_DELEGATE connectedToInternet] && [sf images].count>0)
                    [sf setRest:@"0"];
            } else {
                for (int i=0; i<[sf localImages].count; i++){
                    NSString * header =[[sf localImages] objectAtIndex:i];
                    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",docDir,header]];//fetching image from link
                    if (img != nil){
                        [temp addObject: img];
                    } else {
                        img = [UIImage imageNamed:@"featured_news"];
                        [temp addObject: img];
                    }
                    
                }
                [sf setImages:temp];
            }
            [newsArray replaceObjectAtIndex:startIndex+c withObject:sf];
        }
      
    

    return newsArray;
}

@end

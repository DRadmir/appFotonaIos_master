//
//  FDB.h
//  fotona
//
//  Created by Janos on 22/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNews.h"
#import "FCase.h"
#import "FFotonaMenu.h"
#import "FAuthor.h"
#import "FVideo.h"
#import "FMDatabase.h"

@interface FDB : NSObject

+(NSMutableArray *)getCasesForCarouselFromDB;

+(FAuthor *)getAuthorWithID:(NSString *)authID;
+(UIImage *)getAuthorImage:(NSString *)authID;
+(NSMutableArray *)getAuthors;

+(FCase *)getCaseForFotona:(NSString *)caseID;
+(NSMutableArray *)getCasebookMenu;
+(NSMutableArray *)getCaseCategoryWithPrev:(NSString *)prev;
+(NSMutableArray *)getCasesWithCategoryID:(NSString *)catID;
+(NSMutableArray *)getCasesWithAuthorID:(NSString *)authorID;
+(FCase *)getCaseWithID:(NSString *)caseID;
+(NSMutableArray *)getAlphabeticalCasesForBookmark:(NSString *)category;
+(void) removeBookmarkedCase:(FCase *) caseToRemove;

+(NSMutableArray *)getNewsSortedDateFromDB;
+(void)setNewsRead:(FNews *) news;
+(NSMutableArray *)getNewsForCategory:(NSString *)category;

+(NSArray *)getEventsFromDB;
+(NSMutableArray *)getEventsForCategory:(NSString *)category;

+(NSMutableArray  *) fillEventsWithCategory:(NSInteger) ci andType:(NSInteger) ti andMobile:(BOOL) mobile;
+(NSMutableArray *)getNewsForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(NSMutableArray *)getCasesForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;

+(NSMutableArray *)getVideosForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(NSMutableArray *)getVideosWithGallery:(NSString *)videoGalleryID;
+(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory;
+(void) removeBookmarkedVideo:(FVideo *)videoToRemove;

+(NSMutableArray *)getFotonaMenu:(NSString *)catID;
+(NSMutableArray *)getPDFForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(NSMutableArray *)getPDFForCategory:(NSString *)category;

+(BOOL)checkFotonaForUserSearch:(NSString *)fc;
+(BOOL)checkFotonaForUser:(FFotonaMenu *)f;
+(BOOL)checkFotonaForUser:(FFotonaMenu *)f andCategory:(NSString *)category;

+(BOOL)checkIfBookmarkedForDocumentID:(NSString *)documentID andType:(NSString *)type;

+(void)removeFromBookmarkForDocumentID:(NSString *)documentID;

@end

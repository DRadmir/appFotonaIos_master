//
//  FDB.h
//  fotona
//
//  Created by Janos on 22/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FNews.h"
#import "FCase.h"
#import "FFotonaMenu.h"
#import "FAuthor.h"
#import "FMedia.h"
#import "FMDatabase.h"

@interface FDB : NSObject

+(UIImage *)getAuthorImage:(NSString *)authID;
+(FAuthor *)getAuthorWithID:(NSString *)authID;
+(NSMutableArray *)getAuthors;


+(NSMutableArray *)getCasesForCarouselFromDB;
+(NSMutableArray *)getCasesForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(FCase *)getCaseForFotona:(NSString *)caseID;
+(FCase *)getCaseWithID:(NSString *)caseID;
+(NSMutableArray *)getCasesWithCategoryID:(NSString *)catID;
+(NSMutableArray *)getCasesWithAuthorID:(NSString *)authorID;
+(NSMutableArray *)getAlphabeticalCasesForBookmark:(NSString *)category;

+(void)removeBookmarkedCase:(FCase *) caseToRemove;
+(void)removeCaseWithID:(NSString *)fotonaID;

+(NSMutableArray *)getCasebookMenu;
+(NSMutableArray *)getCaseCategoryWithPrev:(NSString *)prev;


+(NSArray *)getEventsFromDB;
+(NSMutableArray *)getEventsForCategory:(NSString *)category;
+(NSMutableArray  *) fillEventsWithCategory:(NSInteger) ci andType:(NSInteger) ti andMobile:(BOOL) mobile;


+(NSMutableArray *)getNewsForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;


+(NSMutableArray *)getNewsSortedDateFromDB;
+(NSMutableArray *)getNewsForCategory:(NSString *)category;
+(void)setNewsRead:(FNews *) news;


+(NSMutableArray *)getVideosForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(NSMutableArray *)getVideosFromArray:(NSString *)videoGalleryID;
+(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory;
+(void)removeBookmarkedVideo:(FMedia *)videoToRemove;


+(NSMutableArray *)getFotonaMenu:(NSString *)catID;
+(NSMutableArray *)getPDFForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(void)removeFotonaMenuWithID:(NSString *)fotonaID;

+(BOOL)checkIfBookmarkedForDocumentID:(NSString *)documentID andType:(NSString *)type;
+(void)removeFromBookmarkForDocumentID:(NSString *)documentID;

+(void)addMedia:(NSMutableArray *)m withType:(int)type andDownload:(BOOL) toDownload;
+(void)updateMedia:(NSMutableArray *)mediaArray andType:(NSString *) type;
+(NSMutableArray *)getMediaForGallery:(NSString *)galleryItems withMediType: (NSString *)mediaType;
+(FMedia *)getMediaWithId:(NSString *) videoId andType: (NSString *)mediaType;

+(void) addTooFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(void) removeFromFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(BOOL) checkIfFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(NSMutableArray *) getAllFavoritesForUser;

@end

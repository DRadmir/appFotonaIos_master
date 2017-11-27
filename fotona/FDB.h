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

+(void)removeCaseWithID:(NSString *)fotonaID;

+(NSMutableArray *)getCasebookMenu;
+(NSMutableArray *)getCaseCategoryWithPrev:(NSString *)prev;


+(NSMutableArray *)getEventsForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;
+(NSArray *)getEventsFromDB;
+(NSMutableArray *)getEventsForCategory:(NSString *)category;
+(NSMutableArray  *) fillEventsWithCategory:(NSInteger) ci andType:(NSInteger) ti andMobile:(BOOL) mobile;


+(NSMutableArray *)getNewsForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database;


+(NSMutableArray *)getNewsSortedDateFromDB;
+(NSMutableArray *)getNewsForCategory:(NSString *)category;
+(void)setNewsRead:(FNews *) news;

+(NSMutableArray *)getFotonaForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database userPermissions:(NSString *) userP;

+(NSMutableArray *)getVideosForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database userPermissions:(NSString *) userP;
+(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory;


+(BOOL)checkIfBookmarkedForDocumentID:(NSString *)documentID andType:(NSString *)type;


+(void)addMedia:(NSMutableArray *)m withType:(int)type andDownload:(BOOL) toDownload;
+(void)updateMedia:(NSMutableArray *)mediaArray andType:(NSString *) type  andDownload:(BOOL)download forCase:(NSString *) caseID;
+(FMedia *)getMediaWithId:(NSString *) videoId andType: (NSString *)mediaType;
+(NSMutableArray *)getMediaForGallery:(NSString *)galleryItems withMediType: (NSString *)mediaType;
+(void) removeBookmarkedMedia:(FMedia *)media;
+(void)removeFromBookmarkForMediaID:(NSString *)mediaID withMediaType:(NSString *)mediaType;

+(NSMutableArray *)getFotonaMenu:(NSString *)catID;
+(NSMutableArray *)getPDFForSearchFromDB:(NSString *) searchTxt withDatabase:(FMDatabase *) database userPermissions:(NSString *) userP;
+(void)removeFotonaMenuWithID:(NSString *)fotonaID;
+(void)removeFotonaMenuDeleted;

+(void) addTooFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(void) removeFromFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(BOOL) checkIfFavoritesItem:(int) documentID ofType:(NSString *) typeID;
+(NSMutableArray *) getAllFavoritesForUser;

+(NSMutableArray *)getDocuments;

+ (void) copyDatabaseIfNeeded;
@end

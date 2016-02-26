//
//  FDownloadManager.h
//  fotona
//
//  Created by Dejan Krstevski on 5/20/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "FAppDelegate.h"
#import "UpdateDelegate.h"

@interface FDownloadManager : NSObject <DownloadManagerDelegate, UpdateDelegate>


+(FDownloadManager *) shared;


@property (strong, nonatomic) DownloadManager *downloadManager;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSInteger downloadErrorCount;
@property (nonatomic) NSInteger downloadSuccessCount;

@property (nonatomic, weak) id <UpdateDelegate> updateDelegate;

-(void)prepareForDownloadingFiles;

-(void)downloadImages:(NSMutableArray *)imagesURL;
-(void)downloadVideos:(NSMutableArray *)videosURL;
-(void)downloadPDF:(NSString *)pdfURL;
-(BOOL)checkDownload:(NSString *)filePath;
-(void) cancelDownload;
-(void)startDownload;
-(void)downloadAuthorsImage:(NSMutableArray *)imagesURL;



@end
static FDownloadManager *_shared;
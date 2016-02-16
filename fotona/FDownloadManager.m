//
//  FDownloadManager.m
//  fotona
//
//  Created by Dejan Krstevski on 5/20/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FDownloadManager.h"
#import "FAppDelegate.h"
#import "HelperBookmark.h"
#import "MBProgressHUD.h"
#import "FCommon.h"
#import "FIFlowController.h"

@implementation FDownloadManager


+(FDownloadManager *)shared
{
    if (_shared == nil) {
        _shared = [[FDownloadManager alloc] init];
    }
    return _shared;
}

-(void)prepareForDownloadingFiles
{
    if (self.downloadManager == nil) {
        self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    self.downloadSuccessCount=0;
    self.downloadErrorCount=0;
    [self downloadAuthorsImage];
    [self downloadImages];
    [self downloadPDF];
    [self downloadVideos];
    [self startDownload];
    
}

-(void)downloadAuthorsImage
{
    NSString *folder=@".Authors";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in [APP_DELEGATE authorsImageToDownload]) {
        NSArray *pathComp=[fileUrl pathComponents];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if ([self checkDownload:fileUrl]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl]];
        }
        
    }
}

-(void)downloadImages
{
    NSString *folder=@".Cases";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in [APP_DELEGATE imagesToDownload]) {
        // NSLog(@"%@",fileUrl);
        NSArray *pathComp=[fileUrl pathComponents];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
            
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if ([self checkDownload:fileUrl]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl]];
        }
        
    }
    
}

-(void)downloadImages:(NSMutableArray *)imagesURL
{
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    NSString *folder=@".Cases";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in imagesURL) {
        NSArray *pathComp=[fileUrl pathComponents];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if ([self checkDownload:fileUrl]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl]];
        }
    }
    [self startDownload];
}



-(void)downloadVideos
{
    NSString *folder=@".Cases";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in [APP_DELEGATE videosToDownload]) {
        NSArray *pathComp=[fileUrl pathComponents];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        
        if ([self checkDownload:fileUrl]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl]];
        }
    }
}

-(void)downloadVideos:(NSMutableArray *)videosURL
{
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    NSString *folder=@".Cases";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in videosURL) {
        NSArray *pathComp=[fileUrl pathComponents];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        
        if ([self checkDownload:fileUrl]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl]];
        }
    }
    [self startDownload];
}


-(void)downloadPDF
{
    NSString *folder=@".PDF";
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    for (NSString *fileUrl in [APP_DELEGATE pdfToDownload]) {
        NSArray *pathComp=[fileUrl pathComponents];
        NSString *fileUrl1=[fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
            NSError *err;
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
        }
        
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        
        if ([self checkDownload:fileUrl1]) {
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl1]];
        }
    }
}

-(void)downloadPDF:(NSString *)pdfURL
{
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    NSString *folder=@".PDF";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    
    
    NSString *fileUrl2=[pdfURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[pdfURL lastPathComponent]];
    
    if ([self checkDownload:fileUrl2]) {
        [self.downloadManager addDownloadWithFilename:downloadFilename URL:[NSURL URLWithString:fileUrl2]];
    }
    
    [self startDownload];
}

-(void)startDownload
{
    
    [[APP_DELEGATE downloadManagerArray] addObject:self];
    self.startDate = [NSDate date];
    self.downloadManager.maxConcurrentDownloads = [self.downloadManager.downloads count];
    if ([APP_DELEGATE bookmarkAll]) {
        self.downloadManager.maxConcurrentDownloads = 3;
        NSLog(@"%lu",(unsigned long)[self.downloadManager.downloads count]);
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
    }
    
    [self.downloadManager start];
    
}

-(void) cancelDownload
{
    [self.downloadManager cancelAll];
}

#pragma mark DownloadManager


- (void)didFinishLoadingAllForManager:(DownloadManager *)downloadManager
{
    if ([APP_DELEGATE bookmarkAll]) {
        if (downloadManager.downloads.count == 0){
            if([APP_DELEGATE bookmarkCountLeft]==0) {
                [[APP_DELEGATE downloadList] removeAllObjects];
                [APP_DELEGATE setBookmarkCountLeft:0];
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
                [HelperBookmark success];//DONE LAST
                
            } else {
                [HelperBookmark warning];
                [[APP_DELEGATE downloadList] removeAllObjects];
                [APP_DELEGATE setBookmarkCountLeft:0];
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
            }
            
        }
    }
    
    if ([APP_DELEGATE loginShown]) {
        UIViewController *parent = self.updateDelegate;
        //[MBProgressHUD hideAllHUDsForView:parent.view animated:YES];
        id<UpdateDelegate> strongDelegate = self.updateDelegate;
        if ([strongDelegate respondsToSelector:@selector(updateProcess)])
        {
            [strongDelegate updateProcess];
        }
        [[APP_DELEGATE imagesToDownload]removeAllObjects];
        [[APP_DELEGATE videosToDownload]removeAllObjects];
        [[APP_DELEGATE pdfToDownload]removeAllObjects];
        [[APP_DELEGATE authorsImageToDownload]removeAllObjects];
        [APP_DELEGATE setLoginShown:false];
    }
    
    NSLog(@"All download compleated");
    [[APP_DELEGATE downloadManagerArray] removeObject:self];
}

// optional method to indicate that individual download completed successfully
//
// In this view controller, I'll keep track of a counter for entertainment purposes and update
// tableview that's showing a list of the current downloads.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
{
    //    self.downloadSuccessCount++;
    //    if ([APP_DELEGATE bookmarkAll] ) {
    //        [[APP_DELEGATE settingsController] setBookmarkCountLeft:([[APP_DELEGATE settingsController] bookmarkCountLeft]-1)];
    //        [[APP_DELEGATE settingsController] refreshStatusBar];
    //
    //    }
    
    
    //    NSLog(@"Successful %@  = %d",download.filename,(int)self.downloadSuccessCount);
}

// optional method to indicate that individual download failed
//
// In this view controller, I'll keep track of a counter for entertainment purposes and update
// tableview that's showing a list of the current downloads.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
{
    NSLog(@"%s %@ error=%@", __FUNCTION__, download.filename, download.error);
    
    self.downloadErrorCount++;
    
}

// optional method to indicate progress of individual download
//
// In this view controller, I'll update progress indicator for the download.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
{
    
}

-(BOOL)checkDownload:(NSString *)filePath{
    NSString * temp;
    for (Download *download in self.downloadManager.downloads) {
        temp = [[download url] absoluteString];
        if ([filePath isEqualToString: temp ]) {
            if ([APP_DELEGATE bookmarkCountLeft] > self.downloadManager.downloads.count) {
                [APP_DELEGATE setBookmarkCountLeft:[APP_DELEGATE bookmarkCountLeft]-1];
                [APP_DELEGATE setBookmarkCountAll:[APP_DELEGATE bookmarkCountAll]-1];
            }
            
            return NO;
        }
    }
    
    return YES;
}


@end

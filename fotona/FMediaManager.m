//
//  FMediaManager.m
//  fotona
//
//  Created by Janos on 03/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FMediaManager.h"
#import "FMDatabase.h"


@implementation FMediaManager

+(void)deleteMedia:(NSMutableArray *)array andType:(int)t andFromDB:(BOOL) fromDB
{
   
    if (t==0) {
        for (FImage *img in array) {
            [self deleteImage:img];
            
        }
    } else {
        if (t==1){
            for (FMedia *vid in array) {
                [self deleteVideo:vid];
            }
        } else {
            if (t==2){
                for (FMedia *pdf in array) {
                    [self deletePDF:pdf];
                }
            }
        }
    }
    
    if(fromDB){
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        if (t==0) {
            for (FImage *img in array) {
                [database executeUpdate:@"delete from Media where mediaID=? AND mediaType=0",[img itemID]];
            }
        } else {
            if (t==1 || t==2){
                for (FMedia *media in array) {
                    [database executeUpdate:@"delete from Media where mediaID=? AND mediaType=?",[media itemID], [media mediaType]];
                }
            }
        }

        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
    
    
}

+(void) deleteImage:(FImage *)image{
    NSArray *pathComp=[image.path pathComponents];
    NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,FOLDERIMAGE,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[image.path lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:pathTmp error:&error];
}

+(void) deleteVideo:(FMedia *)video{
    NSArray *pathComp=[video.path pathComponents];
    NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,FOLDERVIDEO,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[video.path lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:pathTmp error:&error];
}

+(void) deletePDF:(FMedia *)pdf{
    NSString* pdfSrc = [pdf path];
    NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,FOLDERPDF] stringByAppendingPathComponent:[pdfSrc lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:downloadFilename error:&error];
}



@end

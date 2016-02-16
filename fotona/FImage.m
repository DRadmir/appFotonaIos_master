//
//  FImage.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FImage.h"
#import "FAppDelegate.h"
#import "AFNetworking.h"
#import "FMDatabase.h"

@implementation FImage
@synthesize itemID;
@synthesize galleryID;
@synthesize title;
@synthesize path;
@synthesize localPath;
@synthesize description;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setItemID:[dic valueForKey:@"itemID"]];
        [self setGalleryID:[dic valueForKey:@"galleryID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setPath:[dic valueForKey:@"path"]];
        [self setPath:[self.path stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setLocalPath:@""];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setSort:[dic valueForKey:@"sort"]];
    }
    
    return self;
}

-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    NSArray *pathComp=[fileUrl pathComponents];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]) {
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] withIntermediateDirectories:YES attributes:nil error:&err];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]]]];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2],[fileUrl lastPathComponent]]]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        [request setTimeoutInterval:1200];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[request URL] lastPathComponent]];
        NSString *pathTmpLocal = [[NSString stringWithFormat:@"%@/%@",folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[request URL] lastPathComponent]];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:pathTmp append:NO];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:pathTmp]];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", pathTmp);
            [self setLocalPath:pathTmpLocal];
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            [database executeUpdate:@"UPDATE Media set localPath=? where mediaID=?",pathTmpLocal,self.itemID];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    }else{
        NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",folder,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:pathTmp]];

        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        [database executeUpdate:@"UPDATE Media set localPath=? where mediaID=?",pathTmp,self.itemID];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
    
    
}

@end

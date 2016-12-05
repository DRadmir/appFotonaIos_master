//
//  FMedia.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FMedia.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "FIFlowController.h"

@implementation FMedia
@synthesize itemID;
@synthesize title;
@synthesize path;
@synthesize description;
@synthesize localPath;
@synthesize mediaImage;
@synthesize sort;
@synthesize userPermissions;
@synthesize deleted;
@synthesize filesize;
@synthesize download;
@synthesize mediaType;
@synthesize time;
@synthesize bookmark;
@synthesize active;

-(id)initWithDictionaryFromServer:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setItemID:[dic valueForKey:@"customGalleryItemID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        NSString *pathUpdated = [[dic valueForKey:@"path"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [self setPath:[pathUpdated stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setLocalPath:@""];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setMediaImage:[dic valueForKey:@"mediaImage"]];
        [self setSort:[dic valueForKey:@"sort"]];
        [self setFilesize:[dic valueForKey:@"fileSize"]];
        [self setUserPermissions:[dic valueForKey:@"userPermissions"]];
        if ([[dic valueForKey:@"download"] boolValue]) {
            [self setDownload:@"1"];
        } else {
            [self setDownload:@"0"];
        }
        if ([[dic valueForKey:@"deleted"] boolValue]) {
            [self setDeleted:@"1"];
        } else {
            [self setDeleted:@"0"];
        }
        if ([[dic valueForKey:@"active"] boolValue]) {
            [self setActive:@"1"];
        } else {
            [self setActive:@"0"];
        }
        [self setTime:[dic valueForKey:@"imageCapturedTime"]];
        [self setMediaType:[dic valueForKey:@"galleryType"]];
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setItemID:[dic valueForKey:@"mediaID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setPath:[dic valueForKey:@"path"]];
        [self setPath:[self.path stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setLocalPath:[dic valueForKey:@"localPath"]];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setBookmark:[dic valueForKey:@"isBookmark"]];
        [self setMediaImage:[dic valueForKey:@"mediaImage"]];
        [self setSort:[dic valueForKey:@"sort"]];
        [self setDeleted:[dic valueForKey:@"deleted"]];
        [self setFilesize:[dic valueForKey:@"fileSize"]];
        [self setUserPermissions:[dic valueForKey:@"userPermissions"]];
        [self setDownload:[dic valueForKey:@"download"]];
        [self setActive:[dic valueForKey:@"active"]];
        [self setMediaType:[dic valueForKey:@"mediaType"]];
        [self setTime:[dic valueForKey:@"time"]];
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
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:pathTmp append:NO];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:pathTmp]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", pathTmp);
            [self setLocalPath:pathTmp];
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            [database executeUpdate:@"UPDATE Media set localPath=? where mediaID=?",pathTmp,self.itemID];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    }
    
    
}

-(NSDate *) formateDate:(NSString *) stringDate{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater dateFromString:stringDate];
}


+(void) openMedia:(FMedia *)media
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.mediaToOpen = media;
    flow.galToOpen = [NSString stringWithFormat:@"%@",[media itemID]];
    flow.fromSearch = true;
    if (flow.fotonaMenu != nil)
    {
        [[[flow fotonaMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    if (flow.lastIndex != 2) {
        flow.lastIndex = 2;
        [flow.tabControler setSelectedIndex:2];
    } else {
        [flow.fotonaTab openGalleryFromSearch:flow.galToOpen andReplace:YES andType:[media mediaType]];
    }
    
}
+(NSString *) createLocalPathForLink:(NSString *)link andMediaType:(NSString *)mediaType{
    NSString *local = @"";
    if ([mediaType intValue] == [MEDIAVIDEO intValue]) {
        NSArray *pathComp=[link pathComponents];
        local=[[NSString stringWithFormat:@"%@/.Cases/%@",docDir,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[link lastPathComponent]];
    } else {
        if ([mediaType intValue] == [MEDIAPDF intValue]) {
            local=[NSString stringWithFormat:@"%@.PDF/%@",docDir,[link lastPathComponent]];
        } else {
            if ([mediaType intValue] == [MEDIAIMAGE intValue]) {
                NSArray *pathComp=[link pathComponents];
                local=[[NSString stringWithFormat:@"%@/.Cases/%@",docDir,[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[link lastPathComponent]];
            }
        }
    }
    return local;
}



    @end

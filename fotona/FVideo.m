//
//  FVideo.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FVideo.h"
#import "AFNetworking.h"
#import "FMDatabase.h"

@implementation FVideo
@synthesize itemID;
@synthesize videoGalleryID;
@synthesize title;
@synthesize path;
@synthesize description;
@synthesize localPath;
@synthesize videoImage;
@synthesize sort;
@synthesize dateUpdated;
@synthesize userSubType;
@synthesize userType;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setItemID:[dic valueForKey:@"itemID"]];
        [self setVideoGalleryID:[dic valueForKey:@"galleryID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setPath:[dic valueForKey:@"path"]];
        [self setPath:[self.path stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setLocalPath:@""];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setBookmark:[dic valueForKey:@"bookmark"]];
        [self setTime:[dic valueForKey:@"cropedTime"]];
        [self setVideoImage:[dic valueForKey:@"videoImage"]];
        [self setSort:[dic valueForKey:@"sort"]];
        [self setDateUpdated:[self formateDate:[dic valueForKey:@"dateUpdated"]]];
        [self setUserSubType:[dic valueForKey:@"allowedUserSubTypes"]];
        [self setUserType:[dic valueForKey:@"allowedUserTypes"]];
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

//če gleda glede na pravice na videu
//-(BOOL)checkVideoForUser
//{
//    NSString *tempUser = [self.userType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    tempUser = [tempUser stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    tempUser = [tempUser stringByReplacingOccurrencesOfString:@")" withString:@""];
//    tempUser = [tempUser stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    NSString *tempUserSub = [self.userSubType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@")" withString:@""];
//    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//   
//
//    if (tempUser.length > 0) {
//        NSArray *userT =   [tempUser componentsSeparatedByString:@","];
//        FUser *currentUser = [APP_DELEGATE currentLogedInUser];
//        if (currentUser.userType.intValue == 2  ) {
//             NSArray *userSubT =   [tempUserSub componentsSeparatedByString:@","];
//            for (int i=0; i<currentUser.userTypeSubcategory.count; i++) {
//                NSString *t = [NSString stringWithFormat:@"%@", currentUser.userTypeSubcategory[i]];
//                if ([userSubT containsObject: t]) {
//                    return true;
//                }
//            }
//        } else{
//            NSString *t = [NSString stringWithFormat:@"%@", currentUser.userType];
//            if ([userT containsObject:t]) {
//                return true;
//            }
//            
//        }
//    }
//    
//        return false;
//    }





-(BOOL)checkVideoForCategory :(NSString *)category
{
    //dodat, da če je usertype na videu enak 0 in kategorija enako 0 ga doda
    if ([category isEqualToString:@"0"]) {
         NSString *tempUserSub = [self.userType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@"(" withString:@""];
        tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@")" withString:@""];
        tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray *userSubT =   [tempUserSub componentsSeparatedByString:@","];
        if ([userSubT containsObject: category]) {
            return true;
        }

    } else
    {
    NSString *tempUserSub = [self.userSubType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@"(" withString:@""];
    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@")" withString:@""];
    tempUserSub = [tempUserSub stringByReplacingOccurrencesOfString:@" " withString:@""];

            NSArray *userSubT =   [tempUserSub componentsSeparatedByString:@","];
                if ([userSubT containsObject: category]) {
                    return true;
                }
    }
    return false;
}


    @end

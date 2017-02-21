//
//  FCommon.m
//  fotona
//
//  Created by Janos on 19/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FCommon.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "FGoogleAnalytics.h"
#import "FDownloadManager.h"
#import "FDB.h"

@implementation FCommon

#pragma mark - Device
+(BOOL)isIpad
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        return true;
    } else
    {
        return false;
    }
}

+(BOOL)isOrientationLandscape{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        return true;
    else
        return false;
}

#pragma mark - Time

+(NSString *)currentTimeInLjubljana
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd-MM-yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

#pragma mark - User

+(NSString *)getUser{
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;
    if (usr == nil) {
        usr =@"guest";
    }
    return usr;
}

+(BOOL)isGuest
{
    if([[FCommon getUser] isEqualToString:@"guest"] || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3 || [[FCommon getUser] caseInsensitiveCompare:@"dummyguest"] == NSOrderedSame ){
        
        return true;
    }else
    {
        return false;
    }
    
}

#pragma mark - ImageView

+(UIImageView *)imageCutWithRect:(CGRect) rect
{
    UIImageView *img=[[UIImageView alloc] initWithFrame:rect];
    img.layer.cornerRadius = img.frame.size.height /2;
    img.layer.masksToBounds = YES;
    img.layer.borderWidth = 0;
    [img setContentMode:UIViewContentModeScaleAspectFill];
    
    return img;
}

#pragma mark - Video




+(void)playVideo:(FMedia *)video  onViewController:(UIViewController *)viewController isFromCoverflow:(BOOL)coverFlow{
    [FGoogleAnalytics writeGAForItem:[video title] andType:GAFOTONAVIDEOINT];
    BOOL downloaded = YES;
    NSString *local= [FMedia  createLocalPathForLink:[video path] andMediaType:MEDIAVIDEO];
    
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:local];
    }
    
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:local] && downloaded && (flag || coverFlow)) {
        [FCommon playVideoFromURL:local onViewController:viewController localSaved:YES];
    }else
    {
        if([ConnectionHelper connectedToInternet]){
            
            [FCommon playVideoFromURL:video.path onViewController:viewController localSaved:NO];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

+(void) playVideoFromURL:(NSString * )url onViewController:(UIViewController *) viewController localSaved:(BOOL) isLocalSaved{
     NSURL *videoURL=[NSURL URLWithString:url];
    if (isLocalSaved) {
        videoURL=[NSURL fileURLWithPath:url];
    }
    AVQueuePlayer * player = [[AVQueuePlayer alloc] initWithURL:videoURL];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = player;

    [viewController presentViewController:controller animated:YES completion:nil];
    [player play];
}

#pragma mark - Permissions

+(BOOL)userPermission:(NSString*)permissions{
    NSArray *ary = [permissions componentsSeparatedByString:@";"];
    int ut = [[APP_DELEGATE currentLogedInUser].userType intValue];
    
    if ((ut == 0 ) || (ut == 3 ))
    {
        if ([[ary objectAtIndex:ut] intValue] == ut) {
            return true;
        }
    }
    else{
        NSArray *subtypes = [APP_DELEGATE currentLogedInUser].userTypeSubcategory;
        NSArray *arySubPermissions = [[ary objectAtIndex:ut] componentsSeparatedByString:@","];
        for (NSString *subType in subtypes) {
            NSString *st = [NSString stringWithFormat:@"%@",subType];
            if ([arySubPermissions containsObject:st]) {
                return true;
            }
        }
    }
    return false;
}

+(BOOL)checkItemPermissions:(NSString *) permissions ForCategory:(NSString *)category
{
     NSArray *ary = [permissions componentsSeparatedByString:@";"];
    int ut = [[APP_DELEGATE currentLogedInUser].userType intValue];
    if ([category isEqualToString:@"0"]) {//all
        return true;
    } else //just one category
    {
               NSMutableArray *arySubPermissions = [NSMutableArray new];
        if ((ut == 0 ) || (ut == 3 )){
            //rights for all users
            NSArray *arySubPermissions1 = [[ary objectAtIndex:1] componentsSeparatedByString:@","];
            NSArray *arySubPermissions2 = [[ary objectAtIndex:2] componentsSeparatedByString:@","];
            NSArray *arySubPermissions4 = [[ary objectAtIndex:4] componentsSeparatedByString:@","];

            [arySubPermissions addObjectsFromArray:arySubPermissions1];
            [arySubPermissions addObjectsFromArray:arySubPermissions2];
            [arySubPermissions addObjectsFromArray:arySubPermissions4];
        } else {
            arySubPermissions = [[[ary objectAtIndex:ut] componentsSeparatedByString:@","] mutableCopy];
        }
            
        if ([arySubPermissions containsObject: category]) {
            return true;
        }
    }
    return false;
}

+(NSString *)getUserPermissionsForDBWithColumnName:(NSString *)columnName{
    NSMutableArray *sql = [[NSMutableArray alloc] initWithObjects:@"%",@"%",@"%",@"%",@"%", nil];
    FUser *user = [APP_DELEGATE currentLogedInUser];
    if (user.userTypeSubcategory == nil || user.userTypeSubcategory.count == 0) {
        sql[[user.userType intValue]] = [[NSString alloc] initWithFormat:@"%@%@", user.userType,@"%"];
    }else {
        if (user.userTypeSubcategory.count == 1) {
            sql[[user.userType intValue]] = [FCommon handlePermissionLocationTypes:user index:0];
        }else {
            NSMutableArray *compoundStatement = [[NSMutableArray alloc] initWithCapacity:user.userTypeSubcategory.count];
            for (int i = 0; i <user.userTypeSubcategory.count; i++){
                sql[[user.userType intValue]] = [FCommon handlePermissionLocationTypes:user index:i];
                compoundStatement[i] = [[NSString alloc] initWithFormat:@"'%@'", [self arrayToString:sql withSeparator:@";"]];
            }
            NSString *delimiter =  [[NSString alloc] initWithFormat:@" OR %@ LIKE ", columnName];
            return [[NSString alloc] initWithFormat:@"( %@ LIKE %@ )", columnName, [self arrayToString:compoundStatement withSeparator:delimiter]];
        }
    }
    
    return [[NSString alloc] initWithFormat:@"%@ LIKE '%@'", columnName, [self arrayToString:sql withSeparator:@";"]];
}

+(NSString *)handlePermissionLocationTypes:(FUser *)user index:(int)index{
    if([user.userTypeSubcategory[index] intValue] == 1)
        return [[NSString alloc] initWithFormat:@"%@%@", user.userTypeSubcategory[index], @"%"];
    else if([user.userTypeSubcategory[index] intValue] == 3)
        return [[NSString alloc] initWithFormat:@"%@%@", @"%", user.userTypeSubcategory[index]];
    else
        return [[NSString alloc] initWithFormat:@"%@%@%@", @"%", user.userTypeSubcategory[index], @"%"];
}

#pragma mark - String/Array

+(NSString *)arrayToString:(NSMutableArray *)array withSeparator:(NSString *)separator{
    if (![array isKindOfClass:[NSNull class]] && [array count] > 0) {
        NSString *string = array[0];
        for (int i= 1; i<array.count; i++) {
            string = [NSString stringWithFormat:@"%@%@%@",string, separator, array[i]];
        }
        return string;
    }
    return @"";
}

+(NSArray *)stringToArray:(NSString *)string withSeparator:(NSString *)separator{
    NSArray *array = [[NSArray alloc] init];
    NSString *stringToSplit = [NSString stringWithFormat:@"%@",string];
    if (![stringToSplit isEqualToString:@"<null>"] && ![stringToSplit isEqualToString:@""] && ![stringToSplit isKindOfClass:[NSNull class]]) {
        array = [stringToSplit componentsSeparatedByString:separator];
    }
    return array;
}



@end

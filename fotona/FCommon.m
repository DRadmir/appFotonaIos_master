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

+(void)playVideoOnIphone:(FMedia *)video  onViewController:(UIViewController *)viewController{
    [FGoogleAnalytics writeGAForItem:[video title] andType:GAFOTONAVIDEOINT];
    BOOL downloaded = YES;
    NSString *local= [FMedia  createLocalPathForLink:[video path] andMediaType:MEDIAVIDEO];
    
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:local];
    }
    
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:local] && downloaded && flag) {
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
        NSArray *arySubPermissions = [[ary objectAtIndex:ut] componentsSeparatedByString:@","];
        if ([arySubPermissions containsObject: category]) {
            return true;
        }
    }
    return false;
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
    if (![stringToSplit isEqualToString:@""]) {
        array = [stringToSplit componentsSeparatedByString:separator];
    }
    return array;
}



@end

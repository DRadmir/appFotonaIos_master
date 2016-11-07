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

@implementation FCommon

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

+(NSString *)currentTimeInLjubljana
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd-MM-yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

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


+(UIImageView *)imageCutWithRect:(CGRect) rect
{
    UIImageView *img=[[UIImageView alloc] initWithFrame:rect];
    img.layer.cornerRadius = img.frame.size.height /2;
    img.layer.masksToBounds = YES;
    img.layer.borderWidth = 0;
    [img setContentMode:UIViewContentModeScaleAspectFill];
    
    return img;
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
    if (![string isEqualToString:@""]) {
        array = [string componentsSeparatedByString:separator];
    }
    return array;
}

@end

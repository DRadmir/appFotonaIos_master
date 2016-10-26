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

//TODO: dodat metodo ki preverja če je guest oz dummyuser/dummyguest -> vrne true oz false
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

+(void) playVideoFromURL:(NSString * )url onViewController:(UIViewController *) viewController{
    NSURL *videoURL=[NSURL URLWithString:url];
    AVQueuePlayer * player = [[AVQueuePlayer alloc] initWithURL:videoURL];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = player;
    [viewController presentViewController:controller animated:YES completion:nil];
    [player play];
}

+(NSString *)arrayToString:(NSMutableArray *)array withSeparator:(NSString *)separator{
    if ([array count] > 0) {
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

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


+(UIImageView *)imageCutWithRect:(CGRect) rect
{
    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
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

@end

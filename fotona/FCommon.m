//
//  FCommon.m
//  fotona
//
//  Created by Janos on 19/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FCommon.h"

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



@end

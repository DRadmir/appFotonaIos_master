//
//  UIColor+Hex.m
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorFromHex:(NSString *)hexStrig
{
    CGFloat alpha, red, blue, green;
    alpha = 1.0f;
    red   = [self stringToCGFloat:[hexStrig substringWithRange: NSMakeRange(0, 2)]];
    green = [self stringToCGFloat:[hexStrig substringWithRange: NSMakeRange(2, 2)]];
    blue  = [self stringToCGFloat:[hexStrig substringWithRange: NSMakeRange(4, 2)]];
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

+ (CGFloat) stringToCGFloat: (NSString *) code
{
    unsigned hexComponent;
    [[NSScanner scannerWithString: code] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+(UIColor *)lightBackgroundColor{
    return [UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
}

@end

//
//  UIColor+Hex.h
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+(UIColor *) colorFromHex: (NSString *) hexStrig;
+(UIColor *)lightBackgroundColor;
@end

//
//  HelperString.h
//  fotona
//
//  Created by Janos on 27/11/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperString : NSObject

+ (NSString *) toHtmlEvent: (NSString *)text;
+ (NSString *) toHtml: (NSString *)text;
+ (NSAttributedString *) toAttributedNews: (NSString *)text;
+ (NSAttributedString *) toAttributedCase: (NSString *)text;
+ (NSString *)toHtmlEventIPhone:(NSString *)text;
+ (NSString *)toHtmlIphone:(NSString *)text;
@end

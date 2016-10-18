//
//  FCommon.h
//  fotona
//
//  Created by Janos on 19/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

@interface FCommon : NSObject

+(BOOL) isIpad;
+(NSString *)currentTimeInLjubljana;
+(NSString *)getUser;

+(UIImageView *)imageCutWithRect:(CGRect) rect;

+(void) playVideoFromURL:(NSString * )url onViewController:(UIViewController *) viewController;

+(BOOL) isGuest;
@end

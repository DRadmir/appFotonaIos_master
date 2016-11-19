//
//  FCommon.h
//  fotona
//
//  Created by Janos on 19/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

@interface FCommon : NSObject

+(BOOL) isIpad;
+(BOOL)isOrientationLandscape;

+(NSString *)currentTimeInLjubljana;

+(NSString *)getUser;
+(BOOL) isGuest;

+(UIImageView *)imageCutWithRect:(CGRect) rect;


+(void)playVideoOnIphone:(FMedia *) video onViewController:(UIViewController *)viewController;
+(void) playVideoFromURL:(NSString * )url onViewController:(UIViewController *) viewController  localSaved:(BOOL) isLocalSaved;


+(BOOL)userPermission:(NSString*)permissions;
+(BOOL)checkItemPermissions:(NSString *) permissions ForCategory:(NSString *)category;


+(NSString *)arrayToString:(NSMutableArray *) array withSeparator:(NSString *) separator;
+(NSArray *)stringToArray:(NSString *) string withSeparator:(NSString *)separator;
@end

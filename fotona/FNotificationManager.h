//
//  FNotificationManager.h
//  fotona
//
//  Created by Janos on 19/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNotificationManager : NSObject

+(void) openNotification:(NSString *)url ofType:(int)type;

+(void) setActiveNotificationa:(NSString *)active;
+(NSString *)getActiveNotification;


@end

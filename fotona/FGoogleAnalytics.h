//
//  FGoogleAnalytics.h
//  fotona
//
//  Created by Janos on 13/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGoogleAnalytics : NSObject

+(void)writeGAForItem:(NSString *)title andType:(int) type;


@end

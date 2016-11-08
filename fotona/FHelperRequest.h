//
//  FHelperRequest.h
//  fotona
//
//  Created by Janos on 11/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHelperRequest : NSObject

+(NSMutableURLRequest *) requestToGetCaseByID:(NSString *) caseID onView:(UIView *)view;
    
+(void) setDeviceData:(NSString *) _deviceData;

+(void)sendDeviceData;

@end

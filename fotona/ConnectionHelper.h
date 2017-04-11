//
//  ConnectionHelper.h
//  fotona
//
//  Created by Janos on 16/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

@interface ConnectionHelper : NSObject

+ (BOOL)connectedToInternet;

+ (BOOL)connectedToBoth;
+ (BOOL)connectedToWifi;

+(void)setWifiOnlyConnection:(BOOL)status;
+(BOOL)getWifiOnlyConnection;

@end

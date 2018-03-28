//
//  ConnectionHelper.m
//  fotona
//
//  Created by Janos on 16/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "ConnectionHelper.h"
#import "Reachability.h"

@implementation ConnectionHelper

static BOOL wifiOnlyConnection;
static BOOL mobileDataConnection;

+ (BOOL)connectedToInternet{
    if (wifiOnlyConnection && mobileDataConnection) {
        return self.connectedToWifi;
    } else {
        return self.connectedToBoth;
    }
}

+ (BOOL)connectedToBoth
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

+ (BOOL)connectedToWifi
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
        return NO;
    }
    return !(networkStatus == NotReachable);
}

+(BOOL)connectedToMobileData
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWWAN) {
        return NO;
    }
    return !(networkStatus == NotReachable);
}

+(void)setWifiOnlyConnection:(BOOL)status{
    wifiOnlyConnection = status;
}

+(BOOL)getWifiOnlyConnection{
    return wifiOnlyConnection;
}

+(void)setMobileDataConnection:(BOOL)status {
    mobileDataConnection = status;
}

+(BOOL)getMobileDataConnection:(BOOL)status {
    return mobileDataConnection;
}

@end

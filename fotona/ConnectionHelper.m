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

+ (BOOL)isConnected
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        return !(networkStatus == NotReachable);
    }

@end

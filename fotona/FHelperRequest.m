//
//  FHelperRequest.m
//  fotona
//
//  Created by Janos on 11/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FHelperRequest.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FUser.h"
#import "FNotificationManager.h"


@implementation FHelperRequest

static NSString *deviceData;
static FUser *lastSent;
static NSString *lastActiveState;


#pragma mark - Case
+(NSMutableURLRequest *) requestToGetCaseByID:(NSString *) caseID onView:(UIView *)view{
    if (view != nil) {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.labelText = @"Opening case";
        [hud show:YES];

    }
    NSString *requestData;
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"caseID\":\"%@\",\"dateUpdated\":\"%@\"}",langID, caseID, @"01.01.2000 10:36:20"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKCASEBYID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:180];
    return request;
}


+(NSMutableURLRequest *) requestToGetCaseFromNotification:(NSString *) notificationUrl{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, notificationUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
    [request setTimeoutInterval:180];
    return request;
}

#pragma mark - Device

+(void)setDeviceData:(NSString *)_deviceData{
    deviceData = _deviceData;
    [self sendDeviceData];
    
}

+(void)sendDeviceData{
    FUser *u = [APP_DELEGATE currentLogedInUser];
    NSString *active = [FNotificationManager getActiveNotification];
    if (deviceData != nil && u!=nil && (lastSent == nil || ![lastSent.username isEqualToString: u.username] || (lastActiveState == nil) || !([lastActiveState isEqualToString:active]))) {
       
        //if user changes set notification to active
        if (![lastSent.username isEqualToString: u.username]) {
            active =@"1";
            [FNotificationManager setActiveNotificationa:active];
        }
        lastSent = u;
        lastActiveState = active;
        NSString *requestData =[NSString stringWithFormat:@"%@,\"active\":%@,\"fotUserType\":%@,\"fotUserSubType\":\"%@\"}",deviceData,active,[u userType],[FCommon arrayToString:[[u userTypeSubcategory] mutableCopy] withSeparator:@";"]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WEBSERVICE, LINKWRITEDEVICE]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:globalAccessToken forHTTPHeaderField:@"access_key"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // I get response as XML here and parse it in a function
            NSLog(@"Push success %@",[operation responseString]);
            
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Push failed %@",error.localizedDescription);
                                             
                                         }];
        
        [operation start];
    }
   

}

@end

//
//  FHelperRequest.m
//  fotona
//
//  Created by Janos on 11/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FHelperRequest.h"
#import "MBProgressHUD.h"

@implementation FHelperRequest

+(NSMutableURLRequest *) requestToGetCaseByID:(NSString *) caseID onView:(UIView *)view{
    if (view != nil) {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.labelText = @"Opening case";
        [hud show:YES];

    }
    NSString *requestData;
    requestData =[NSString stringWithFormat:@"{\"langID\":\"%@\",\"caseID\":\"%@\",\"access_token\":\"%@\",\"dateUpdated\":\"%@\"}",langID, caseID, globalAccessToken, @"01.01.2000 10:36:20"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@GetCaseById",webService]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:180];
    return request;
}


@end

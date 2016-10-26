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


@end

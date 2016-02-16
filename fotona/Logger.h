//
//  Logger.h
//  Wallet
//
//  Created by Hypnos on 18/11/14.
//  Copyright (c) 2014 Hypnos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+(void)LogDebug:(NSString*)message inObject:(NSObject *)objectReference;
+(void)LogDebug:(NSString*)message inClass:(Class)class;

+(void)LogInfo:(NSString*)message inObject:(NSObject *)objectReference;
+(void)LogInfo:(NSString*)message inClass:(Class)class;

+(void)LogError:(NSString*)message inObject:(NSObject *)objectReference;
+(void)LogError:(NSString*)message inClass:(Class)class;

+(void)LogError:(NSString*)message withException:(NSException *)exception inObject:(NSObject *)objectReference;
+(void)LogError:(NSString*)message withException:(NSException *)exception inClass:(Class)class;
+(void)LogError:(NSString*)message withError:(NSError *)error inObject:(NSObject *)objectReference;
+(void)LogError:(NSString*)message withError:(NSError *)error inClass:(Class)class;

+(void) writeToLogContent:(NSString *)content;
+(NSString *) getLog;
@end

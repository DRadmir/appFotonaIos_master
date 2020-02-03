//
//  Logger.m
//  Wallet
//
//  Created by Hypnos on 18/11/14.
//  Copyright (c) 2014 Hypnos. All rights reserved.
//

#import "Logger.h"

@implementation Logger

+(void)LogDebug:(NSString*)message inObject:(NSObject *)objectReference
{
    [self LogInfo:message inClass:[objectReference class]];
}
+(void)LogDebug:(NSString*)message inClass:(Class)class
{
    NSLog(@"DEBUG: %@ in %@.", message, NSStringFromClass(class));
}

+(void)LogInfo:(NSString*)message inObject:(NSObject *)objectReference
{
    [self LogInfo:message inClass:[objectReference class]];
}
+(void)LogInfo:(NSString*)message inClass:(Class)class
{
    NSLog(@"INFO: %@ in %@.", message, NSStringFromClass(class));
}


+(void)LogError:(NSString*)message inObject:(NSObject *)objectReference
{
    [self LogError:message inClass:[objectReference class]];
}
+(void)LogError:(NSString*)message inClass:(Class)class
{
    [self logErrorWithLogDescription:[NSString stringWithFormat:@"ERROR: %@ in %@.", message, NSStringFromClass(class)]];
}


+(void)LogError:(NSString*)message withException:(NSException *)exception inObject:(NSObject *)objectReference
{
    [self LogError:message withException:exception inClass:[objectReference class]];
}
+(void)LogError:(NSString*)message withException:(NSException *)exception inClass:(Class)class
{
    [self logErrorWithLogDescription:[NSString stringWithFormat:@"ERROR: %@ with exception=%@ stackTrace=%@ in %@.",
          message, exception.description, [exception callStackSymbols], class?class:@""]];
}
+(void)LogError:(NSString*)message withError:(NSError *)error inObject:(NSObject *)objectReference
{
    [self LogError:message withError:error inClass:[objectReference class]];
}
+(void)LogError:(NSString*)message withError:(NSError *)error inClass:(Class)class
{
    NSString *userInfoString = [error userInfo] ? [[error userInfo] description] : @"";
    
    [self logErrorWithLogDescription:[NSString stringWithFormat:@"ERROR: %@ with error=%@ userInfo=%@ in %@.",
          message, [error description], userInfoString, class]];
}


+(void) logErrorWithLogDescription:(NSString *)errorDescription
{
//    NSString *logContent = [NSString stringWithFormat: @"[%@] Error in Waye2Pay inSystem:%@, deviceName:%@, deviceModel:%@, appVersion:%@, appVersionBuild:%@, Error:%@ ",
//          [NSDate date],
//          self.appDelegate.systemName,
//          self.appDelegate.deviceName,
//          self.appDelegate.deviceModel,
//          self.appDelegate.applicationVersion,
//          self.appDelegate.applicationVersionBuild,
//          errorDescription];
//    
//    NSLog(@"%@", logContent);
    
    [self writeToLogContent:errorDescription];
}

#define LOG_FILENAME @"log.txt"
+(void) writeToLogContent:(NSString *)content
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //add new line to context
    content = [content stringByAppendingString:@"\n"];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory, LOG_FILENAME];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileName])
    {
        //save content to the documents directory
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
    else
    {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        // move to the end of the file
        [fileHandle seekToEndOfFile];
        // convert the string to an NSData object
        NSData *textData = [content dataUsingEncoding:NSUTF8StringEncoding];
        // write the data to the end of the file
        [fileHandle writeData:textData];
        // clean up
        [fileHandle closeFile];
    }
}

+(NSString *) getLog
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory, LOG_FILENAME];
    
    //clear file content
    //[[NSFileManager defaultManager] createFileAtPath:fileName contents:[NSData data] attributes:nil];
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    return content;
}


@end

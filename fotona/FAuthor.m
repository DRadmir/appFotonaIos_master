//
//  FAuthor.m
//  fotona
//
//  Created by Dejan Krstevski on 4/4/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FAuthor.h"
#import "FAppDelegate.h"
#import "AFNetworking.h"
#import "FMDatabase.h"

@implementation FAuthor
@synthesize authorID;
@synthesize name;
@synthesize image;
@synthesize imageLocal;
@synthesize cv;
@synthesize active;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setAuthorID:[dic valueForKey:@"authorID"]];
        [self setName:[dic valueForKey:@"name"]];
        [self setImage:[dic valueForKey:@"image"]];
         NSArray *pathComp=[self.image pathComponents];
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Authors",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[self.image lastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        [self setImageLocal:downloadFilename];
        [self setImage:[self.image stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setCv:[dic valueForKey:@"cv"]];
        [self setActive:[dic valueForKey:@"active"]];
    }
    return self;
}

-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:folder]];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[fileUrl lastPathComponent]]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[fileUrl lastPathComponent]] error:nil];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[[request URL] lastPathComponent]];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        [self setImageLocal:path];
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        [database executeUpdate:@"UPDATE Author set imageLocal=? where authorID=?",path,self.authorID];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

-(NSString *)getImage
{
    if ([self.imageLocal isEqualToString:@""]) {
        return self.image;
    }
    else
    {
        NSArray *pathComp=[self.image pathComponents];
        NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Authors",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[self.image lastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        return downloadFilename;
    }
}

@end

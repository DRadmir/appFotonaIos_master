//
//  FUser.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FUser.h"
#import "FMDatabase.h"
#import "FAppDelegate.h"

@implementation FUser
@synthesize userID;
@synthesize username;
@synthesize password;
@synthesize firstName;
@synthesize lastName;
@synthesize userType;
@synthesize userTypeSubcategory;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setUserID:[dic valueForKey:@"ID"]];
        [self setUsername:[dic valueForKey:@"username"]];
        [self setPassword:@"YES"];
        [self setFirstName:[dic valueForKey:@"firstName"]];
        [self setLastName:[dic valueForKey:@"lastName"]];
        [self setUserType:[dic valueForKey:@"userType"]];
        [self setUserTypeSubcategory:[dic objectForKey:@"userTypeSubcategory"]];
    }
    
    
    return self;
}

//get user from DB
+(FUser *)getUser:(NSString *)_username
{
    FUser *usr=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM User where username='%@'",_username]];
    while([results next]) {
        usr=[[FUser alloc] init];
        [usr setUserID:[results stringForColumn:@"userID"]];
        [usr setUsername:[results stringForColumn:@"username"]];
        [usr setPassword:[results stringForColumn:@"password"]];
        [usr setFirstName:[results stringForColumn:@"firstName"]];
        [usr setLastName:[results stringForColumn:@"lastName"]];
        [usr setUserType:[results stringForColumn:@"userType"]];
        [usr setUserTypeSubcategory:[[results stringForColumn:@"userTypeSubcategory"] componentsSeparatedByString:@","]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return usr;
}

//save user to DB
+(void)addUserInDB:(FUser *)usr
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM User where userID=%@;",usr.userID]];
    BOOL flag=NO;
    while([results next]) {
        flag=YES;
    }
    
    if (!flag) {
        [database executeUpdate:@"INSERT INTO User (userID,username,password,firstName,lastName,userType,userTypeSubcategory) VALUES (?,?,?,?,?,?,?)",usr.userID,usr.username,usr.password,usr.firstName,usr.lastName,usr.userType,[usr.userTypeSubcategory componentsJoinedByString:@","]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}



@end

//
//  FUser.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FUser : NSObject
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *userType;
@property (nonatomic, retain) NSArray *userTypeSubcategory;

-(id)initWithDictionary:(NSDictionary *)dic;

+(FUser *)getUser:(NSString *)_username;
+(void)addUserInDB:(FUser *)usr;

@end

//
//  FSession.h
//  fotona
//
//  Created by Dejan Krstevski on 4/5/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSession : NSObject
@property (nonatomic, retain) NSString *sessionID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *parameters;
@property (nonatomic, retain) NSString *images;
@property (nonatomic, retain) NSString *procedureID;
@property (nonatomic, retain) NSString *patientID;
@end

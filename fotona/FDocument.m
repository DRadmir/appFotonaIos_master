//
//  FDocument.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FDocument.h"

@implementation FDocument
@synthesize documentID;
@synthesize title;
@synthesize iconType;
@synthesize description;
@synthesize isLink;
@synthesize link;
@synthesize src;
@synthesize active;
@synthesize bookmark;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setDocumentID:[dic valueForKey:@"documentID"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setIconType:[dic valueForKey:@"iconType"]];
        [self setDescription:[dic valueForKey:@"description"]];
        [self setIsLink:[dic valueForKey:@"isLink"]];
        [self setLink:[dic valueForKey:@"link"]];
        [self setSrc:[dic valueForKey:@"src"]];
        [self setSrc:[self.src stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"]];
        [self setActive:[dic valueForKey:@"active"]];
        [self setAllowedUserTypes:[dic objectForKey:@"allowedUserTypes"]];
        [self setAllowedUserSubTypes:[dic objectForKey:@"allowedUserSubTypes"]];
    }
    
    
    return self;
}

@end

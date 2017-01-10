//
//  FCaseCategory.m
//  Fotona
//
//  Created by Dejan Krstevski on 4/1/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FCaseCategory.h"

@implementation FCaseCategory
@synthesize categoryID;
@synthesize categoryIDPrev;
@synthesize title;
@synthesize sort;
@synthesize deleted;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        [self setCategoryID:[dic valueForKey:@"categoryID"]];
        [self setCategoryIDPrev:[dic valueForKey:@"categoryIDPrev"]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setSort:[dic valueForKey:@"sort"]];
        [self setActive:[dic valueForKey:@"active"]];
        [self setDeleted:[dic valueForKey:@"deleted"]];
        [self setSortInt:[[dic valueForKey:@"sort"] intValue]];
    }
    return self;
}

@end

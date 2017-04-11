//
//  FItemFavorite.m
//  fotona
//
//  Created by Janos on 07/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FItemFavorite.h"

@implementation FItemFavorite

@synthesize itemID;
@synthesize typeID;


-(FItemFavorite *)initWithDictionary:(NSDictionary *)dictionary{
    FItemFavorite *f=[[FItemFavorite alloc] init];
    [f setItemID:[dictionary valueForKey:@"documentID"]];
    [f setTypeID:[dictionary valueForKey:@"typeID"]];
    return f;
}

@end

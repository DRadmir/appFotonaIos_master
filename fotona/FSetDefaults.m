//
//  FSetDefaults.m
//  fotona
//
//  Created by Janos on 16/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FSetDefaults.h"

@implementation FSetDefaults


+(void)setDefaults
{
    //setup for initial update
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"newsLastUpdate"]) {
        [defaults setObject:@"" forKey:@"newsLastUpdate"];
    }
    if (![defaults objectForKey:@"caseCategoriesLastUpdate"]) {
        [defaults setObject:@"" forKey:@"caseCategoriesLastUpdate"];
    }
    if (![defaults objectForKey:@"casesLastUpdate"]) {
        [defaults setObject:@"" forKey:@"casesLastUpdate"];
    }
    if (![defaults objectForKey:@"authorsLastUpdate"]) {
        [defaults setObject:@"" forKey:@"authorsLastUpdate"];
    }
    if (![defaults objectForKey:@"documentsLastUpdate"]) {
        [defaults setObject:@"" forKey:@"documentsLastUpdate"];
    }
    if (![defaults objectForKey:@"fotonaLastUpdate"]) {
        [defaults setObject:@"" forKey:@"fotonaLastUpdate"];
    }
    
    [defaults synchronize];

}

@end

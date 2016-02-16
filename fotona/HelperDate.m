//
//  HelperDate.m
//  fotona
//
//  Created by Janos on 19/06/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "HelperDate.h"

@implementation HelperDate

+ (NSString *)formatedDate:(NSString *)date{

    
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    NSDate * tempDate = [dateFormater dateFromString:date];

    [dateFormater setDateFormat:@"dd MMM yyyy"];
    [dateFormater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSString *returnDate = [dateFormater stringFromDate:tempDate];
    
    return returnDate;
    
}
@end

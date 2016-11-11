//
//  FItemFavorite.h
//  fotona
//
//  Created by Janos on 07/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FItemFavorite : NSObject

@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *typeID;



- (FItemFavorite *) initWithDictionary:(NSDictionary *) dictionary;

@end

//
//  FMediaManager.h
//  fotona
//
//  Created by Janos on 03/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FImage.h"
#import "FMedia.h"

@interface FMediaManager : NSObject

+(void)deleteMedia:(NSMutableArray *)array andType:(int)t andFromDB:(BOOL) fromDB;
+(void) deleteImage:(FImage *)image;
+(void) deleteVideo:(FMedia *)video;
+(void) deletePDF:(FMedia *)pdf;
@end

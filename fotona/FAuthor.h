//
//  FAuthor.h
//  fotona
//
//  Created by Dejan Krstevski on 4/4/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAuthor : NSObject
@property (nonatomic, retain) NSString *authorID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *imageLocal;
@property (nonatomic, retain) NSString *cv;
@property (nonatomic, retain) NSString *active;

-(id)initWithDictionary:(NSDictionary *)dic;
-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder;
@end

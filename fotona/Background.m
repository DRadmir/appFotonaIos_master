//
//  Background.m
//
//  Created by Peter on 08/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "Background.h"

@implementation Background


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO; // Enable transparency
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self setBackgroundColor:self.backgroundTint];
    
    [self.backgroundColor setFill];
    UIRectFill(rect);
    
    // If highlight exists, punch a hole through background.
    if (!CGRectIsEmpty(self.highlight)) {
        CGRect holeRectIntersection = CGRectIntersection(self.highlight, rect);
        [[UIColor clearColor] setFill];
        UIRectFill(holeRectIntersection);
    }
}
@end

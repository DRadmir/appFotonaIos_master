//
//  UIView+Border.h
//  Wave2pay
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Border)

+ (CAGradientLayer *)gradientLayerWith:(UIColor *)firstColor secondColor:(UIColor *)secondColor andSize:(CGSize)size;

- (void)applyShadowWithColor:(UIColor *)color opacity:(float)opacity andOffset:(CGSize)offset;

- (void)rasterize;


- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

@end

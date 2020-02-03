//
//  UIView+Border.m
//  Wave2pay
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

+ (CAGradientLayer *)gradientLayerWith:(UIColor *)firstColor secondColor:(UIColor *)secondColor andSize:(CGSize)size
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame  = (CGRect) {{0, 0}, size};
    gradient.colors = [NSArray arrayWithObjects:(id) firstColor.CGColor, (id) secondColor.CGColor, nil];
    
    return gradient;
}

- (void)applyShadowWithColor:(UIColor *)color opacity:(float)opacity andOffset:(CGSize)offset
{
    self.layer.shadowColor   = color.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowOffset  = offset;
    self.layer.shadowRadius  = 1;
}

- (void)rasterize
{
    self.layer.shouldRasterize    = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}


#pragma mark - border

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}


@end

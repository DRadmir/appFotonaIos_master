//
//  CustomLayout.h
//  Collection
//
//  Created by Lion User on 09/08/2013.
//  Copyright (c) 2013 Dejan Atanasov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;

@end

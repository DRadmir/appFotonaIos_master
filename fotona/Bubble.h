//
//  Bubble.h
//
//  Simple help bubble implementation, able of displaying text bubble
//  Only one style of text is possible with this bubble.
//
//  Created by Peter on 08/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Caret) {
    TOP_LEFT=0,
    TOP_CENTER=4,
    TOP_RIGHT=8,
    RIGHT_TOP=1,
    RIGHT_CENTER=5,
    RIGHT_BOTTOM=9,
    BOTTOM_LEFT=2,
    BOTTOM_CENTER=6,
    BOTTOM_RIGHT=10,
    LEFT_TOP=3,
    LEFT_CENTER=7,
    LEFT_BOTTOM=11
};

@protocol BubbleDelegate;

@interface Bubble : UIView

@property (nonatomic, weak) id<BubbleDelegate> delegate;

@property (strong, nonatomic) NSString *text;
@property (nonatomic) UIColor *fontColor;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIEdgeInsets textContentInset;

@property (nonatomic) UIColor *tint;
@property (nonatomic) CGRect bubble;
@property (nonatomic) CGRect highlight;
@property (nonatomic) NSInteger cornerRadius;
@property (nonatomic) BOOL displayShaddow;
@property (nonatomic) Caret caretPosition;
@property (nonatomic) CGFloat caretSize;
@property (nonatomic) CGFloat caretOffset;

-(void)setPositionOfCaret:(CGPoint)caretTip withCaretFrom:(Caret)position;
-(void)setSize:(CGSize)bubbleSize;

@end

@protocol BubbleDelegate <NSObject>

- (void)bubbleRequestedExit:(Bubble*)bubbleObject;

@end
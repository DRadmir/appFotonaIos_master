//
//  BubbleControler.m
//
//  Created by Peter on 08/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "BubbleControler.h"


@interface BubbleControler()

@property (nonatomic, strong) NSMutableArray* bubbles;
@property (nonatomic) Bubble* currentBubble;
@property (nonatomic) Background* bg;

@end

@implementation BubbleControler

#pragma mark - Initializers and setters
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBlockUserInteraction:YES];
        [self setBackgroundTint:[UIColor blackColor]];
        [self setBackgroundAlpha:.5];
    }
    return self;
}

-(NSMutableArray*) bubbles
{
    if(!_bubbles)
    {
        _bubbles = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _bubbles;
}

#pragma mark - Public methods
-(void)addBubble:(Bubble*)bubble
{
    bubble.delegate = self;
    [bubble setFrame:self.frame];
    [self.bubbles addObject:bubble];
}

#pragma mark - Control flow of bubbles
- (void)bubbleRequestedExit:(Bubble*)bubbleObject
{
    // Fade current buble out and select next one in queue
    [UIView animateWithDuration:0.3
                     animations:^{bubbleObject.alpha = 0.0;}
                     completion:^(BOOL finished){ [bubbleObject removeFromSuperview];
                     [self displayNextBubble];}];
    
    id<BubbleControlerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(bubbleRequestedExit:)])
    {
        [strongDelegate bubbleRequestedExit];
    }
    
}

-(void)displayNextBubble
{
    if (self.bubbles.count>0)
    {
        // Pop first bubble from stack
        self.currentBubble = [self.bubbles objectAtIndex:0];
        [self.bubbles removeObjectAtIndex:0];
        self.currentBubble.alpha = 0;
        
        // Remove old background replace with new
        [self.bg removeFromSuperview];
        self.bg = [[Background alloc] initWithFrame:self.frame];
        [self.bg setHighlight:self.currentBubble.highlight];
        [self.bg setBackgroundTint:self.backgroundTint];
        [self.bg setAlpha:self.backgroundAlpha];
        
        [self addSubview:self.bg];
        
        [self addSubview:self.currentBubble];
        [UIView animateWithDuration:0.3
                         animations:^{self.currentBubble.alpha = 1.0;}
                         completion:^(BOOL finished){ }];
    }
    else
    {
        // Close this
        [UIView animateWithDuration:0.3
                         animations:^{self.alpha = 0.0;}
                         completion:^(BOOL finished){[self removeFromSuperview];}];
    }
}

#pragma mark - Override methods from UIView
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!self.blockUserInteraction && !CGRectContainsPoint(self.currentBubble.bubble, point))
    {
        return NO;
    }
    return YES;
}

- (void)drawRect:(CGRect)rect
{
    [self displayNextBubble];
}
@end

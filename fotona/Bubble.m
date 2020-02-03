//
//  Bubble.m
//
//  Created by Peter on 08/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "Bubble.h"

@implementation Bubble
// Simple helper method for converting degrees to radians
static inline double radians (double degrees) {return degrees * M_PI/180;}

#pragma mark - Initializers and setters
-(id)init
{
    self = [super init];
    if(self)
    {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setBubble: CGRectMake(0, 0, 35, 35)];
        [self setCornerRadius: 2];
        [self setTint: [UIColor whiteColor]];
        [self setFontColor: [UIColor blackColor]];
        [self setFont: [UIFont fontWithName:@"HelveticaNeue" size:12]];
        [self setTextContentInset: UIEdgeInsetsMake(0,0,0,0)];
        [self setCaretPosition: TOP_CENTER];
        [self setDisplayShaddow: NO];
        [self setCaretSize:10];
        [self setCaretOffset:25];
        
        // Add tap listener
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)bubble:(CGRect)bubble
{
    _bubble = bubble;
    
    // Make sure minimum size is always set
    if(_bubble.size.width < 35) _bubble.size.width = 35;
    if(_bubble.size.height < 35) _bubble.size.height = 35;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    
//    if(CGRectContainsPoint(self.bubble, location))
//    {
        id<BubbleDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(bubbleRequestedExit:)])
        {
            [strongDelegate bubbleRequestedExit:self];
        }
//    }
}

// Override this method if you want more custom text display (title / image / whatever)
-(void)setUpTextView
{
    UITextView* text = [[UITextView alloc] initWithFrame:[self getContentBounds]];
    [text setEditable:NO];
    [text setSelectable:NO];
    [text setBackgroundColor:[UIColor clearColor]];
    
    [text setTextContainerInset:self.textContentInset];
    [text setFont:self.font];
    [text setText:self.text];
    [text setTextColor:self.fontColor];
    
    CGFloat topCorrect = ([text bounds].size.height - [text contentSize].height * [text zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    [text setContentOffset:(CGPoint){.x = 0, .y = -topCorrect}];
    
    [self addSubview:text];
}

-(void) setBubblePositionFromCaretLocation:(CGPoint)caretTip
{
    CGPoint origin = caretTip;
    
    switch (self.caretPosition) {
        case TOP_LEFT:
            origin.x += -((self.caretOffset + self.caretSize / 2));
            break;
        case TOP_CENTER:
            origin.x += -(self.bubble.size.width/2);
            break;
        case TOP_RIGHT:
            origin.x += -(self.bubble.size.width - (self.caretOffset + self.caretSize /2));
            break;
        case RIGHT_TOP:
            origin.x +=  -(self.bubble.size.width);
            origin.y +=  -(self.caretOffset + self.caretSize / 2);
            break;
        case RIGHT_CENTER:
            origin.x +=  -(self.bubble.size.width);
            origin.y +=  -(self.bubble.size.height/2);
            break;
        case RIGHT_BOTTOM:
            origin.x +=  -(self.bubble.size.width);
            origin.y +=  -(self.bubble.size.height - (self.caretOffset + self.caretSize /2));
            break;
        case BOTTOM_LEFT:
            origin.x +=  -((self.caretOffset + self.caretSize / 2));
            origin.y +=  -(self.bubble.size.height);
            break;
        case BOTTOM_CENTER:
            origin.x +=  -(self.bubble.size.width/2);
            origin.y +=  -(self.bubble.size.height);
            break;
        case BOTTOM_RIGHT:
            origin.x +=  -(self.bubble.size.width - (self.caretOffset + self.caretSize /2));
            origin.y +=  -(self.bubble.size.height);
            break;
        case LEFT_TOP:
            origin.y +=  -(self.caretOffset + self.caretSize / 2);
            break;
        case LEFT_CENTER:
            origin.y +=  -(self.bubble.size.height/2);
            break;
        case LEFT_BOTTOM:
            origin.y +=  -(self.bubble.size.height - (self.caretOffset + self.caretSize /2));
            break;
    }
    
    CGRect newPosition = CGRectMake(origin.x, origin.y, self.bubble.size.width, self.bubble.size.height);
    [self setBubble:newPosition]; // Set new position
}

-(CGPoint)getCaretLocation
{
    CGPoint location;

    switch (self.caretPosition) {
        case TOP_LEFT:
            location.x = self.bubble.origin.x + (self.caretOffset + self.caretSize /2);
            location.y = self.bubble.origin.y+self.caretSize;
            break;
        case TOP_CENTER:
            location.x = self.bubble.origin.x + (self.bubble.size.width/2);
            location.y = self.bubble.origin.y+self.caretSize;
            break;
        case TOP_RIGHT:
            location.x = self.bubble.origin.x + self.bubble.size.width - (self.caretOffset + self.caretSize /2);
            location.y = self.bubble.origin.y+self.caretSize;
            break;
        case RIGHT_TOP:
            location.x = self.bubble.origin.x + self.bubble.size.width - self.caretSize;
            location.y = self.bubble.origin.y + (self.caretOffset + self.caretSize /2);
            break;
        case RIGHT_CENTER:
            location.x = self.bubble.origin.x + self.bubble.size.width - self.caretSize;
            location.y = self.bubble.origin.y + (self.bubble.size.height/2);
            break;
        case RIGHT_BOTTOM:
            location.x = self.bubble.origin.x + self.bubble.size.width - self.caretSize;;
            location.y = self.bubble.origin.y + self.bubble.size.height - (self.caretOffset + self.caretSize /2);
            break;
        case BOTTOM_LEFT:
            location.x = self.bubble.origin.x + (self.caretOffset + self.caretSize /2);
            location.y = self.bubble.origin.y + self.bubble.size.height - self.caretSize;
            break;
        case BOTTOM_CENTER:
            location.x = self.bubble.origin.x + (self.bubble.size.width/2);
            location.y = self.bubble.origin.y + self.bubble.size.height - self.caretSize;
            break;
        case BOTTOM_RIGHT:
            location.x = self.bubble.origin.x + self.bubble.size.width - (self.caretOffset + self.caretSize /2);
            location.y = self.bubble.origin.y + self.bubble.size.height - self.caretSize;
            break;
        case LEFT_TOP:
            location.x = self.bubble.origin.x + self.caretSize;
            location.y = self.bubble.origin.y + (self.caretOffset + self.caretSize /2);
            break;
        case LEFT_CENTER:
            location.x = self.bubble.origin.x + self.caretSize;
            location.y = self.bubble.origin.y + (self.bubble.size.height/2);
            break;
        case LEFT_BOTTOM:
            location.x = self.bubble.origin.x + self.caretSize;
            location.y = self.bubble.origin.y + self.bubble.size.height - (self.caretOffset + self.caretSize /2);
            break;
    }
    return location;
}

- (CGRect)getContentBounds
{
    CGRect body = self.bubble;
    
    if(self.caretPosition % 4 == 0) // Caret on top
    {
        body.size.height-=self.caretSize;
        body.origin.y+=self.caretSize;
    }
    else if(self.caretPosition % 4 == 1) // Caret on right
    {
        body.size.width -=self.caretSize;
    }
    else if(self.caretPosition % 4 == 2) // Caret on bottom
    {
        body.size.height-=self.caretSize;
    }
    else if(self.caretPosition % 4 == 3) // Caret on left
    {
        body.size.width -=self.caretSize;
        body.origin.x += self.caretSize;
    }
    return body;
}
#pragma mark - Public methods
-(void)setPositionOfCaret:(CGPoint)caretTip withCaretFrom:(Caret)position
{
    [self setCaretPosition:position];
    [self setBubblePositionFromCaretLocation:caretTip];
}

-(void)setSize:(CGSize)size
{
    CGRect newSize = CGRectMake(self.bubble.origin.x, self.bubble.origin.y, size.width, size.height);
    [self setBubble:newSize];
}



#pragma mark - Drawing of UI elements
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.tint.CGColor);
    
    // Rectangle
    [self drawBox:context];
    
    // Triangle Caret
    [self drawCaret:context];
    
    // Display textview
    [self setUpTextView];
}

-(void)drawCaret:(CGContextRef)context
{
    CGPoint location = [self getCaretLocation];
    // Push on matrix stack
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, location.x, location.y);
    CGContextRotateCTM(context, radians((self.caretPosition % 4) * 90)); // Possible rotations 0,90,180,270 degrees
    
    CGContextMoveToPoint(context, -self.caretSize, 0);
    CGContextAddLineToPoint(context, self.caretSize, 0);
    CGContextAddLineToPoint(context, 0, -self.caretSize);
    CGContextAddLineToPoint(context, -self.caretSize, 0);
    
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);

}

-(void)drawBox:(CGContextRef)context
{
    // Push on matrix stack
    CGContextSaveGState(context);
    
    if(self.displayShaddow)
    {
        CGContextSetShadow(context, CGSizeMake(0, 5), 10);
    }
    // Rectangle with rounded corners
    [[UIBezierPath bezierPathWithRoundedRect:[self getContentBounds] cornerRadius:self.cornerRadius] fill];
    
    CGContextRestoreGState(context);
}


@end

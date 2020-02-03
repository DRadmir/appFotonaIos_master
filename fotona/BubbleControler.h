//
//  BubbleControler.h
//
// Bubble controler, handles bubble switching, animation and user actions.
// If information about which bubble was allready seen, make sure you implement
// delegate for this controler
//
//  Created by Peter on 08/04/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bubble.h"
#import "Background.h"

@protocol BubbleControlerDelegate;

@interface BubbleControler : UIView <BubbleDelegate>

@property (nonatomic, weak) id<BubbleControlerDelegate> delegate;

@property (nonatomic) BOOL blockUserInteraction;
@property (nonatomic) UIColor *backgroundTint;
@property (nonatomic) CGFloat backgroundAlpha;

-(void)addBubble:(Bubble*)bubble;
-(void)displayNextBubble;

@end

@protocol BubbleControlerDelegate <NSObject>

- (void)bubbleRequestedExit; // This will be trigered in order as bubbles were added to this controler

@end

// Examples of use:

/*
 // Example 1: simple bubble, closed after user clicks on bubble
 // Instantiate this view only after viewDidAppear has finished
 // The helper will be of size of current view where this is used
 BubbleControler *bub = [[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
 
 Bubble *b1 = [[Bubble alloc] init];
 
 // Make bubble caret appear under the viewElementOutlet
 CGPoint loc = _viewElementOutlet.frame.origin;
 loc.y += _viewElementOutlet.frame.size.height;
 
 [b1 setHighlight:_viewElementOutlet.frame];
 [b1 setTextContentInset: UIEdgeInsetsMake(8,0,0,0)];
 [b1 setSize:CGSizeMake(170, 100)];
 [b1 setPositionOfCaret:loc withCaretFrom:TOP_LEFT];
 [b1 setText:@"Text in this bubble"];
 [b1 setDisplayShaddow:YES];
 
 [bub addBubble:b1];
 [self.view addSubview:bub];
 */

/*
 // Example 2: 2 Bubbles shown in view, all other controls are enabled
 // Instantiate this view only after viewDidAppear has finished
 // The helper will be of size of current view where this is used
 
 BubbleControler *bub = [[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
 [bub setBlockUserInteraction:NO];
 [bub setBackgroundTint:[UIColor clearColor]]; // No background
 
 Bubble *b1 = [[Bubble alloc] init];
 // Calculate point of caret
 CGPoint loc = _viewElementOutlet.frame.origin;
 loc.x += _viewElementOutlet.frame.size.width / 2; // Center
 loc.y += _viewElementOutlet.frame.size.height; // Bottom
 
 // Set buble size and position (first size, then position!!)
 [b1 setSize:CGSizeMake(170, 100)];
 [b1 setPositionOfCaret:loc withCaretFrom:TOP_LEFT];
 [b1 setCaretSize:15]; // If on tablet, we want a bigger bubble caret
 
 // Set font, paddings and text
 [b1 setTextContentInset: UIEdgeInsetsMake(16,8,0,0)]; // Set paddings
 [b1 setText:@"Example text. \nPossible use of new lines."];
 [b1 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]]; // Default font is helvetica-neue, size 12
 
 // Set bubble and text color
 [b1 setTint:[UIColor blackColor]];
 [b1 setFontColor:[UIColor whiteColor]];
 
 // Show shaddow
 [b1 setDisplayShaddow:YES];
 
 // Add buble to controler
 [bub addBubble:b1];
 
 // Small buble that appears as message dialog.
 Bubble *b2 = [[Bubble alloc] init];
 [b2 setCornerRadius:5];
 // Set bubble position and size directly as rectangle
 [b2 setBubble:CGRectMake(self.view.frame.size.width / 2 - 150, self.view.frame.size.height / 2 -150, 300, 300)];
 
 // Remove caret, makes it appear as dialog
 [b2 setCaretSize:0];
 
 // Set font, paddings and text
 [b2 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
 [b2 setTextContentInset: UIEdgeInsetsMake(20,20,20,20)]; // Set paddings
 [b2 setText:@"If caret size is set to 0, this bubble can become simple information dialog, where user can dismiss it.\n\n\nSome simple messages may be displayed here, but it is not advised.\nTest of tab formating: \n\t-line one\n\t-line two\n\t-line three"];
 
 // Show shaddow
 [b2 setDisplayShaddow:YES];
 
 // Add bubble to controler
 [bub addBubble:b2];
 
 [self.view addSubview:bub];
 */

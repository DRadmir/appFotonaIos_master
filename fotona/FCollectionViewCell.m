//
//  FCollectionViewCell.m
//  fotona
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FCollectionViewCell.h"
#import "UIView+Border.h"
#import "FEventViewController.h"
#import "HelperDate.h"

@implementation FCollectionViewCell
{
    NSMutableArray *cellEvents;
}

//@synthesize titleFrame;
//@synthesize dateLbl;
//@synthesize signNew;
//@synthesize imgView;
//@synthesize newsCell;
@synthesize eventCell;

@synthesize aboutCell;
@synthesize aboutDesc;
@synthesize aboutDescView;




@synthesize eventCategoryImage;

static int category = 0;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    category = 0;
}


-(void)fillData{
    cellEvents = [[NSMutableArray alloc] init];
    if(category>0){
        int ci=0;
        NSString *str = nil;
        str = [[NSString alloc] initWithFormat:@"%d",category];
        for (int i=0; i<3; i++) {
            [(UIImageView *)[self.eventCategoryImage objectAtIndex:i] setHidden:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(viewEventClick:)];
            [(UIView*)[self.eventView objectAtIndex:i] removeGestureRecognizer:tap];
            for (int j=ci; j<self.events.count; j++) {
                
                [(UILabel *)[self.eventTitle objectAtIndex:i] setText:@""];
                
                [(UILabel *)[self.eventDate objectAtIndex:i] setText: @""];
                [(UILabel *)[self.eventLocation objectAtIndex:i] setText:@""];

                if([[[self.events objectAtIndex:j] eventcategories] containsObject:str] && [[self.events objectAtIndex:j] mobileFeatured]){
                    [(UIImageView *)[self.eventCategoryImage objectAtIndex:i] setHidden:NO];
                    NSString * img = [[self.events objectAtIndex:i] getDot:category];
                    [(UIImageView *)[self.eventCategoryImage objectAtIndex:i] setImage:[UIImage imageNamed:img]];
                    [(UILabel *)[self.eventTitle objectAtIndex:i] setText:[[self.events objectAtIndex:j] title]];
                    
                    [(UILabel *)[self.eventDate objectAtIndex:i] setText: [[HelperDate formatedDate:[[self.events objectAtIndex:j] eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[[self.events objectAtIndex:j] eventdateTo]]]]];
                    [(UILabel *)[self.eventLocation objectAtIndex:i] setText:[[self.events objectAtIndex:j] eventplace]];
                    [(UIView*)[self.eventView objectAtIndex:i] addBottomBorderWithColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0] andWidth:1];
                    
                    
                    [(UIView*)[self.eventView objectAtIndex:i] setTag:500+i];
                    [(UIView*)[self.eventView objectAtIndex:i] addGestureRecognizer:tap];
                    [cellEvents addObject:[NSNumber numberWithInt:j]];
                    ci=j+1;
                    break;
                }
            }
        }
        
    } else {
        int j=0;
        for (int i=0; i<self.events.count; i++) {
            if ([[self.events objectAtIndex:i] mobileFeatured]) {
                [(UIImageView *)[self.eventCategoryImage objectAtIndex:j] setHidden:NO];
                NSString * img = [[self.events objectAtIndex:i] getDot];
                [(UIImageView *)[self.eventCategoryImage objectAtIndex:j] setImage:[UIImage imageNamed:img]];
                [(UILabel *)[self.eventTitle objectAtIndex:j] setText:[[self.events objectAtIndex:i] title]];
                
                [(UILabel *)[self.eventDate objectAtIndex:j] setText: [[HelperDate formatedDate:[[self.events objectAtIndex:i] eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[[self.events objectAtIndex:i] eventdateTo]]]]];
                [(UILabel *)[self.eventLocation objectAtIndex:j] setText:[[self.events objectAtIndex:i] eventplace]];
                [(UIView*)[self.eventView objectAtIndex:j] addBottomBorderWithColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0] andWidth:1];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(viewEventClick:)];
                [(UIView*)[self.eventView objectAtIndex:j] setTag:500+j];
                [(UIView*)[self.eventView objectAtIndex:j] addGestureRecognizer:tap];
                [cellEvents addObject:[NSNumber numberWithInt:i]];
                j++;
                if (j==3) {
                    break;
                }
            }
           
        }
    }
}

- (IBAction)moreEvents:(id)sender {
    [[APP_DELEGATE tabBar] setSelectedIndex:1];
}

-(void)buttonTouchedGreen:(id)sender
{
    [self allButtonsRed];
    [[self greenBtn] setImage:[UIImage imageNamed:@"event_surgery_red.pdf"] forState:UIControlStateNormal];
    [sender setSelected:NO];
}
-(void)buttonTouchedBlue:(id)sender
{
    [self allButtonsRed];
    [[self blueBtn] setImage:[UIImage imageNamed:@"event_dental_red.pdf"] forState:UIControlStateNormal];
    [sender setSelected:NO];
}
-(void)buttonTouchedPink:(id)sender
{
    [self allButtonsRed];
    [[self pinkBtn] setImage:[UIImage imageNamed:@"event_gyno_red.pdf"] forState:UIControlStateNormal];
    [sender setSelected:NO];
}
-(void)buttonTouchedOrange:(id)sender
{
    [self allButtonsRed];
    [[self orangeBtn] setImage:[UIImage imageNamed:@"event_aesthetics_red.pdf"] forState:UIControlStateNormal];
    [sender setSelected:NO];
}
-(void)buttonTouchedGrey:(id)sender
{
    [self allButtonsRed];
    [[self allBtn] setImage:[UIImage imageNamed:@"event_all_red.pdf"] forState:UIControlStateNormal];
    [sender setSelected:NO];
}

-(void)allButtonsRed{
    
    [[self greenBtn] setImage:[UIImage imageNamed:@"event_surgery_gray.pdf"] forState:UIControlStateSelected];
    [[self greenBtn] setSelected:YES];
    
    [[self blueBtn] setImage:[UIImage imageNamed:@"event_dental_gray.pdf"] forState:UIControlStateSelected];
    [[self blueBtn] setSelected:YES];
    
    [[self pinkBtn] setImage:[UIImage imageNamed:@"event_gyno_gray.pdf"] forState:UIControlStateSelected];
    [[self pinkBtn] setSelected:YES];
    
    [[self orangeBtn] setImage:[UIImage imageNamed:@"event_aesthetics_gray.pdf"] forState:UIControlStateSelected];
    [[self orangeBtn]  setSelected:YES];
    
    [[self allBtn] setImage:[UIImage imageNamed:@"event_all_gray.pdf"] forState:UIControlStateSelected];
    [[self allBtn]  setSelected:YES];
    
}


- (IBAction)dotButtonAction:(id)sender {
    if ([self greenBtn].touchInside) {
        category = 4;[self buttonTouchedGreen:_greenBtn];
    } else if ([self blueBtn].touchInside) {
        category = 1;[self buttonTouchedBlue:_blueBtn];
    } else if ([self pinkBtn].touchInside) {
        category = 3;[self buttonTouchedPink:_pinkBtn];
    } else if ([self orangeBtn].touchInside) {
        category = 2;[self buttonTouchedOrange:_orangeBtn];
    } else {
        category = 0;[self buttonTouchedGrey:_allBtn];
    }
    [self fillData];
    
}

//click on event cell
-(void)viewEventClick:(UITapGestureRecognizer *)recognizer {
    NSUInteger viewIndex = recognizer.view.tag - 500;
    UILabel *temp = [self.eventTitle objectAtIndex:viewIndex];
    if (![temp.text isEqualToString:@""]) {
        int indexEvent = [[cellEvents objectAtIndex:viewIndex] intValue];
        [APP_DELEGATE setEventTemp:[self.events objectAtIndex:indexEvent]];
        [[APP_DELEGATE tabBar] setSelectedIndex:1];
        FEventViewController * tempEventVC = [[[APP_DELEGATE tabBar] viewControllers] objectAtIndex:1];
        [tempEventVC  openPopupOutside];
    }
}

@end

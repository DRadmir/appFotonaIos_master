//
//  FIFeaturedTableViewCell.m
//  fotona
//
//  Created by Janos on 23/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIFeaturedEventTableViewCell.h"
#import "FEvent.h"
#import "HelperDate.h"
#import "FIFeaturedSingleEventViewController.h"
#import "FDB.h"


@implementation FIFeaturedEventTableViewCell

@synthesize items;
@synthesize eventsCarousel;

static int category = 0;
BOOL wrap;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    eventsCarousel.delegate = self;
    eventsCarousel.dataSource = self;
    
}
-(void)buttonTouchedGreen:(id)sender
{
        [self allButtonsRed];
        [[self btnGreen] setImage:[UIImage imageNamed:@"event_surgery_red.pdf"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    }
-(void)buttonTouchedBlue:(id)sender
{
        [self allButtonsRed];
        [[self btnBlue] setImage:[UIImage imageNamed:@"event_dental_red.pdf"] forState:UIControlStateNormal];
        [sender setSelected:NO];
     }


-(void)buttonTouchedPink:(id)sender
{
        [self allButtonsRed];
        [[self btnPink] setImage:[UIImage imageNamed:@"event_gyno_red.pdf"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    
}

-(void)buttonTouchedOrange:(id)sender
{
        [self allButtonsRed];
        [[self btnOrange] setImage:[UIImage imageNamed:@"event_aesthetics_red.pdf"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    
}

-(void)buttonTouchedGrey:(id)sender
{
    
        [self allButtonsRed];
        [[self btnGrey] setImage:[UIImage imageNamed:@"event_all_red.pdf"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    }

-(void)allButtonsRed{
    
    [[self btnGreen] setImage:[UIImage imageNamed:@"event_surgery_gray.pdf"] forState:UIControlStateSelected];
    [[self btnGreen] setSelected:YES];
    
    [[self btnBlue] setImage:[UIImage imageNamed:@"event_dental_gray.pdf"] forState:UIControlStateSelected];
    [[self btnBlue] setSelected:YES];
    
    [[self btnPink] setImage:[UIImage imageNamed:@"event_gyno_gray.pdf"] forState:UIControlStateSelected];
    [[self btnPink] setSelected:YES];
    
    [[self btnOrange] setImage:[UIImage imageNamed:@"event_aesthetics_gray.pdf"] forState:UIControlStateSelected];
    [[self btnOrange]  setSelected:YES];
    
    [[self btnGrey] setImage:[UIImage imageNamed:@"event_all_gray.pdf"] forState:UIControlStateSelected];
    [[self btnGrey]  setSelected:YES];
    
}

- (IBAction)selectCategory:(id)sender {
    
    if ([self btnGreen].touchInside) {
        category = 4;[self buttonTouchedGreen:_btnGreen];
    } else if ([self btnBlue].touchInside) {
        category = 1;[self buttonTouchedBlue:_btnBlue];
    } else if ([self btnPink].touchInside) {
        category = 3;[self buttonTouchedPink:_btnPink];
    } else if ([self btnOrange].touchInside) {
        category = 2;[self buttonTouchedOrange:_btnOrange];
    } else {
        category = 0;[self buttonTouchedGrey:_btnGrey];
    }
    [self fillDataiPhone];

    
}

- (IBAction)showMoreEvents:(id)sender {
    [self.parent.tabBarController setSelectedIndex:1];
    
}

-(void)fillDataiPhone{

    [self setUp];
    eventsCarousel.type = iCarouselTypeLinear;
    [eventsCarousel reloadData];
}

#pragma mark - iCarousel methods

- (void)setUp
{
    //set up data
    wrap = NO;
    
    self.items = [FDB fillEventsWithCategory:category andType:0 andMobile:true];
}
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
   
    
    FIFeaturedSingleEventViewController * card = [[FIFeaturedSingleEventViewController alloc] initWithNibName:@"FIFeaturedSingleEventViewController" bundle:nil];
    
    FEvent *e = self.items[index];
    card.lblTitle.text = [e.title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    card.event = e;
    card.category = category;
    card.parent = self;
    view = card.view;
  
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, eventsCarousel.frame.size.height)];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 210, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:10.0f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * eventsCarousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return 1.0f;
        }
        case iCarouselOptionFadeMax:
        {
            if (eventsCarousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}




#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [APP_DELEGATE setEventTemp:items[index]];
    [self.parent.tabBarController setSelectedIndex:1];
    
}


@end

//
//  FIFeaturedTableViewCell.h
//  fotona
//
//  Created by Janos on 23/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIFeaturedViewController.h"

@interface FIFeaturedEventTableViewCell : UITableViewCell <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnGrey;
@property (strong, nonatomic) IBOutlet UIButton *btnGreen;
@property (strong, nonatomic) IBOutlet UIButton *btnBlue;
@property (strong, nonatomic) IBOutlet UIButton *btnOrange;
@property (strong, nonatomic) IBOutlet UIButton *btnPink;
@property (strong, nonatomic) IBOutlet iCarousel *eventsCarousel;

@property (nonatomic, retain) NSMutableArray *items;


@property (strong, nonatomic) NSArray *events;

@property (strong, nonatomic) FIFeaturedViewController *parent;



- (IBAction)selectCategory:(id)sender;
- (IBAction)showMoreEvents:(id)sender;

- (void)fillDataiPhone;


@end

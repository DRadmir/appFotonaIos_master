//
//  FIFeaturedViewController.h
//  fotona
//
//  Created by Janos on 22/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "FIBaseView.h"

@interface FIFeaturedViewController : FIBaseView <iCarouselDataSource, iCarouselDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) NSMutableArray *items;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carouselHeight;


@property (strong, nonatomic) IBOutlet UIView *viewNewsEvent;
@property (strong, nonatomic) IBOutlet UITableView *tableViewFeatured;
@property (nonatomic,retain) NSMutableArray *newsArray;
@property (nonatomic,retain) NSArray *eventsArray;

-(void)openNews;
@end

//
//  FIFeaturedSingleEventViewController.h
//  fotona
//
//  Created by Janos on 31/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEvent.h"
#import "FIFeaturedEventTableViewCell.h"

@interface FIFeaturedSingleEventViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageDot;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreEvents;

@property (nonatomic,retain) FEvent *event;
@property (nonatomic) int category;
@property (strong, nonatomic) FIFeaturedEventTableViewCell *parent;

@end

//
//  FIFeaturedNewsTableViewCell.h
//  fotona
//
//  Created by Janos on 04/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNews.h"
#import "FIFeaturedViewController.h"


@interface FIFeaturedNewsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgViewNewsCell;
@property (strong, nonatomic) IBOutlet UILabel *lblDateNewsCell;
@property (strong, nonatomic) IBOutlet UILabel *lblTitleNewsCell;
@property (strong, nonatomic) IBOutlet UITextField *signNewNewsCell;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *lblAbout;


@property (strong, nonatomic) IBOutlet UIView *topViewContentView;

@property (strong, nonatomic) FNews* news;
@property (nonatomic) BOOL related;
@property (strong, nonatomic) FIFeaturedViewController *parent;
@property (nonatomic) BOOL enabled;

- (void) fillCell;

@end

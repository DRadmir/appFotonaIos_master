//
//  FCarousel.h
//  fotona
//
//  Created by Janos on 22/07/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCarousel : UIViewController


@property (nonatomic, strong) NSString* date;
@property (nonatomic, strong) NSString* caseTitle;
@property (nonatomic, strong) NSString* name;
@property (nonatomic) int type;
@property (nonatomic, strong) UIImage* background;
@property (nonatomic, strong) UIImage* image;

@property (weak, nonatomic) IBOutlet UIImageView *carouselBackground;
@property (weak, nonatomic) IBOutlet UIImageView *carouselDoctorImage;
@property (weak, nonatomic) IBOutlet UILabel *carouselDoctorName;
@property (weak, nonatomic) IBOutlet UILabel *carouselType;
@property (weak, nonatomic) IBOutlet UILabel *carouselDate;
@property (weak, nonatomic) IBOutlet UILabel *carouselCaseTitle;


@end

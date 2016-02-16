//
//  FICarousel.h
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCase.h"

@interface FICarousel : UIViewController

@property (nonatomic, strong) NSString* date;
@property (nonatomic, strong) NSString* caseTitle;
@property (nonatomic, strong) NSString* name;
@property (nonatomic) int type;
@property (nonatomic, strong) UIImage* background;
@property (nonatomic, strong) UIImage* image;

@property (strong, nonatomic) IBOutlet UIImageView *carouselBackground;
@property (strong, nonatomic) IBOutlet UIImageView *carouselDoctorImage;
@property (strong, nonatomic) IBOutlet UILabel *carouselDoctorName;
@property (strong, nonatomic) IBOutlet UILabel *carouselType;
@property (strong, nonatomic) IBOutlet UILabel *carouselDate;
@property (strong, nonatomic) IBOutlet UILabel *carouselCaseTitle;

@property(strong,nonatomic) FCase* caseCard;



@end

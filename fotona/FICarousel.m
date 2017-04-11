//
//  FICarousel.m
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FICarousel.h"
#import "UIView+Border.h"
#import "HelperDate.h"

@interface FICarousel ()

@end

@implementation FICarousel

@synthesize caseCard;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.carouselBackground.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%@.png",[caseCard coverTypeID]]];
    
    self.carouselCaseTitle.text = [caseCard title];
    self.carouselDate.text = [HelperDate formatedDate:[APP_DELEGATE timestampToDateString:[caseCard date]]];
    self.carouselDoctorName.text = [NSString stringWithFormat:@"%@",[caseCard name]];
    
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = [[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor];
    switch ([[caseCard coverTypeID] intValue]) {
        case 1:
            self.carouselType.text = @"   Dentistry";
            self.carouselType.backgroundColor = [UIColor colorWithRed:0.345 green:0.702 blue:0.824 alpha:1];
            break;
        case 2:
            self.carouselType.text = @"   Aesthetics";
            self.carouselType.backgroundColor = [UIColor colorWithRed:0.902 green:0.678 blue:0.424 alpha:1];
            break;
        case 3:
            self.carouselType.text = @"   Gynecology";
            self.carouselType.backgroundColor = [UIColor colorWithRed:0.875 green:0.325 blue:0.549 alpha:1];
            break;
        default:
            NSLog(@"Icarousel error, wrong type");
            break;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

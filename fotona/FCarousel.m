//
//  FCarousel.m
//  fotona
//
//  Created by Janos on 22/07/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FCarousel.h"
#import "UIView+Border.h"
#import "HelperDate.h"

@interface FCarousel ()

@end

@implementation FCarousel


- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.view setFrame:CGRectMake(0, 0, 320, 140)];
   // [self.carouselBackground setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    // Do any additional setup after loading the view from its nib.
    self.carouselBackground.image = self.background;
    self.carouselDoctorImage.image = self.image;
    self.carouselCaseTitle.text = self.caseTitle;
    self.carouselDate.text = [HelperDate formatedDate:self.date];
    self.carouselDoctorName.text = self.name;
    
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = [[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor];
    switch (self.type) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

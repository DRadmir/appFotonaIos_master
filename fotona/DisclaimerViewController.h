//
//  DisclaimerViewController.h
//  fotona
//
//  Created by Janos on 18/11/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMainViewController_iPad.h"
#import "FMainViewController.h"

@interface DisclaimerViewController : UIViewController
{

    IBOutlet UIScrollView *disclaimerScrollView;
    IBOutlet UIButton *btnDecline;
    IBOutlet UIButton *btnAccept;
}

@property (nonatomic, strong) FMainViewController_iPad *parentiPad;
@property (nonatomic, strong) FMainViewController *parentiPhone;

- (IBAction)btnAcceptClick:(id)sender;
- (IBAction)btnDeclineClick:(id)sender;


@end

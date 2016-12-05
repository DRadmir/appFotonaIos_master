//
//  FTutorialViewController.h
//  fotona
//
//  Created by Ares on 05/12/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMainViewController_iPad.h"
#import "FMainViewController.h"

@interface FTutorialViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@property (strong, nonatomic) IBOutlet UITableView *tutorialTableView;

@property (nonatomic, strong) FMainViewController_iPad *parentiPad;
@property (nonatomic, strong) FMainViewController *parentiPhone;

- (IBAction)closeTutorial:(id)sender;
@end

//
//  FTutorialViewController.m
//  fotona
//
//  Created by Ares on 05/12/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FTutorialViewController.h"
#import "FTutorialTableViewCell.h"

@interface FTutorialViewController ()

@end

@implementation FTutorialViewController

@synthesize tutorialTableView;
@synthesize okBtn;

@synthesize parentiPad;
@synthesize parentiPhone;

- (void)viewDidLoad {
    [super viewDidLoad];
    tutorialTableView.dataSource = self;
    tutorialTableView.delegate = self;
    
    tutorialTableView.estimatedRowHeight = 20;
    tutorialTableView.rowHeight = UITableViewAutomaticDimension;
    
    tutorialTableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Tutorial View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FTutorialTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FTutorialTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell.lblTutorial setText:NSLocalizedString(@"STARTDISCLAIMER", nil)];
    [cell.imageView setImage:[UIImage imageNamed:@""]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}


- (IBAction)closeTutorial:(id)sender {
        if (parentiPad == nil)
        {
    
            [parentiPhone showFeatured];
            [self removeFromParentViewController];
        } else
        {
            [parentiPad showFeatured];
        }

}
@end

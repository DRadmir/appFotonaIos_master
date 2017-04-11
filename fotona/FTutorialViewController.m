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
{
    UILabel *tutorialLbl;

}

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
    
    okBtn.layer.cornerRadius = 3;
    okBtn.layer.borderWidth = 1;
    okBtn.layer.borderColor = okBtn.tintColor.CGColor;
    
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
    cell.indexPath=indexPath;
    [cell tutorialView];
    
//        if (indexPath.row == 0) {
//            [cell.lblTutorial setText:NSLocalizedString(@"ADDTOFAVORITES", nil)];
//            //cell.imageView.image = [UIImage imageNamed:@"favorites_add.pdf"];
//           // [cell.imageView setImage:[UIImage imageNamed:@"favorites_add.pdf"]];
//            UIImage *image = [UIImage imageNamed:@"favorites_add.pdf"];
//            cell.imageView.image = image;
//            return cell;
//        }else if (indexPath.row == 1){
//            [cell.lblTutorial setText:NSLocalizedString(@"REMOVEFROMFAVORITES", nil)];
//            [cell.imageView setImage:[UIImage imageNamed:@"favorites_remove.pdf"]];
//        }else if (indexPath.row == 2){
//            [cell.lblTutorial setText:NSLocalizedString(@"ADDTODOWNLOAD", nil)];
//            [cell.imageView setImage:[UIImage imageNamed:@"download_add"]];
//        }else if (indexPath.row == 3){
//            [cell.lblTutorial setText:NSLocalizedString(@"REMOVEFROMDOWNLOAD", nil)];
//            [cell.imageView setImage:[UIImage imageNamed:@"download_remove"]];
//        }
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

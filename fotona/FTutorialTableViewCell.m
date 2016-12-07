//
//  FTutorialTableViewCell.m
//  fotona
//
//  Created by Ares on 05/12/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FTutorialTableViewCell.h"

@implementation FTutorialTableViewCell

@synthesize lblTutorial;
@synthesize imgViewTutorial;
@synthesize indexPath;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)tutorialView

{
    if (indexPath.row == 0) {
        [self.lblTutorial setText:NSLocalizedString(@"ADDTOFAVORITES", nil)];
        //cell.imageView.image = [UIImage imageNamed:@"favorites_add.pdf"];
        [self.imgViewTutorial setImage:[UIImage imageNamed:@"favorites_add.pdf"]];
    }else if (indexPath.row == 1){
        [self.lblTutorial setText:NSLocalizedString(@"REMOVEFROMFAVORITES", nil)];
        [self.imgViewTutorial setImage:[UIImage imageNamed:@"favorites_remove.pdf"]];
    }else if (indexPath.row == 2){
        [self.lblTutorial setText:NSLocalizedString(@"ADDTODOWNLOAD", nil)];
        [self.imgViewTutorial setImage:[UIImage imageNamed:@"download_add"]];
    }else if (indexPath.row == 3){
        [self.lblTutorial setText:NSLocalizedString(@"REMOVEFROMDOWNLOAD", nil)];
        [self.imgViewTutorial setImage:[UIImage imageNamed:@"download_remove"]];
    }

    
//    if (indexPath.row == 0) {
//        [cell.lblTutorial setText:NSLocalizedString(@"ADDTOFAVORITES", nil)];
//        [cell.imageView setImage:[UIImage imageNamed:@"favorites_add.pdf"]];
//    }else if (indexPath.row == 1){
//        [cell.lblTutorial setText:NSLocalizedString(@"REMOVEFROMFAVORITES", nil)];
//        [cell.imageView setImage:[UIImage imageNamed:@"favorites_remove.pdf"]];
//    }else if (indexPath.row == 2){
//        [cell.lblTutorial setText:NSLocalizedString(@"ADDTODOWNLOAD", nil)];
//        [cell.imageView setImage:[UIImage imageNamed:@"download_add.pdf"]];
//    }else if (indexPath.row == 3){
//        [cell.lblTutorial setText:NSLocalizedString(@"REMOVEFROMDOWNLOAD", nil)];
//        [cell.imageView setImage:[UIImage imageNamed:@"download_remove.pdf"]];
//    }
//
}


@end

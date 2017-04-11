//
//  FCaseGalleryView.h
//  fotona
//
//  Created by Janos on 14/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FIFavoriteViewController.h"
#import "FFavoriteViewController.h"

@interface FCaseGalleryView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imgAuthor;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UILabel *lblAuthorName;
@property (strong, nonatomic) IBOutlet UILabel *lblCaseType;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadRemove;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteRemove;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) FCase *caseToShow;
@property (strong, nonatomic) FItemFavorite *item;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;
@property (strong, nonatomic) FFavoriteViewController *parentIpad;
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;


- (void) setContentForCase:(FCase *)fcase;
- (IBAction)favoriteRemove:(id)sender;
- (IBAction)favoriteAdd:(id)sender;
- (IBAction)downloadRemove:(id)sender;
- (IBAction)downloadAdd:(id)sender;

@end

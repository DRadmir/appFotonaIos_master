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

@interface FCaseGalleryView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imgAuthor;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UILabel *lblAuthorName;
@property (strong, nonatomic) IBOutlet UILabel *lblCaseType;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnDownladRemove;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteRemove;

@property (strong, nonatomic) FCase *caseToShow;
@property (strong, nonatomic) FItemFavorite *item;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;//TODO: dodat ipad parenta
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;


- (void) showCase:(FCase *)fcase;
- (IBAction)favoriteRemove:(id)sender;
- (IBAction)favoriteAdd:(id)sender;
- (IBAction)downloadRemove:(id)sender;
- (IBAction)downloadAdd:(id)sender;

@end

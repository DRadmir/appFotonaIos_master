//
//  FFotonaVideoView.h
//  fotona
//
//  Created by Ares on 11/01/17.
//  Copyright © 2017 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FMedia.h"
#import "FIFavoriteViewController.h"
#import "FFavoriteViewController.h"


@interface FFotonaVideoView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imgThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadRemove;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteRemove;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;
@property (strong, nonatomic) FFavoriteViewController *parentIpad;
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;

@property (nonatomic) NSString *type;
@property (strong, nonatomic) FMedia *cellMedia;


- (IBAction)downloadAdd:(id)sender;
- (IBAction)downloadRemove:(id)sender;
- (IBAction)favoriteAdd:(id)sender;
- (IBAction)favoriteRemove:(id)sender;

-(void)setContentForMedia:(FMedia *)media andMediaType:(NSString *)mediaType andConnection:(BOOL)connected;
-(void)reloadVideoThumbnail:(UIImage *)img;

@end

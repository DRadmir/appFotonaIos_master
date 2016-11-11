//
//  FFotonaGalleryView.h
//  fotona
//
//  Created by Janos on 17/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FMedia.h"
#import "FIFavoriteViewController.h"

@interface FFotonaGalleryView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imgThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadRemove;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnFavoriteRemove;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;//TODO: dodat ipad parenta
@property (strong, nonatomic) NSIndexPath *index;

@property (nonatomic) NSString *type;
@property (strong, nonatomic) FMedia *cellMedia;


- (IBAction)downloadAdd:(id)sender;
- (IBAction)downloadRemove:(id)sender;
- (IBAction)favoriteAdd:(id)sender;
- (IBAction)favoriteRemove:(id)sender;

-(void)setContentForMedia:(FMedia *)media andMediaType:(NSString *)mediaType;
-(void)reloadVideoThumbnail:(UIImage *)img;

@end

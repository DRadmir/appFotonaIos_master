//
//  FIVideoGalleryTableViewCell.h
//  fotona
//
//  Created by Janos on 22/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FVideo.h"
#import "FIVideoGalleryViewController.h"

@interface FIVideoGalleryTableViewCell : UITableViewCell <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnBookmark;
@property (strong, nonatomic) IBOutlet UIButton *btnUnbookmark;
@property (strong, nonatomic) IBOutlet UIImageView *imgVideoThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoTitle;
@property (strong, nonatomic) FIVideoGalleryViewController *parent;

@property (strong, nonatomic) FVideo *video;

-(void)fillCell;
- (IBAction)addToBookmark:(id)sender;
- (IBAction)removeFromBookmark:(id)sender;

@end

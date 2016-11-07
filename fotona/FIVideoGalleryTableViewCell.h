//
//  FIVideoGalleryTableViewCell.h
//  fotona
//
//  Created by Janos on 22/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//





//TODO odstrant ta dva classa

#import <UIKit/UIKit.h>
#import "FMedia.h"
#import "FIGalleryViewController.h"

@interface FIVideoGalleryTableViewCell : UITableViewCell <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnBookmark;
@property (strong, nonatomic) IBOutlet UIButton *btnUnbookmark;
@property (strong, nonatomic) IBOutlet UIImageView *imgVideoThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoTitle;
@property (strong, nonatomic) FIGalleryViewController *parent;

@property (strong, nonatomic) FMedia *media;

-(void)fillCell;
- (IBAction)addToBookmark:(id)sender;
- (IBAction)removeFromBookmark:(id)sender;

@end

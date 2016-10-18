//
//  FIVideoGalleryViewController.h
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FVideo.h"

@interface FIVideoGalleryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString* galleryID;
@property (strong, nonatomic) NSString* category;

@property (strong, nonatomic) IBOutlet UITableView *videoGalleryTableView;


-(void) loadGallery;
-(void) reloadCells:(NSString *)videoToReload;
-(void) openVideo:(FVideo *) video;

@end

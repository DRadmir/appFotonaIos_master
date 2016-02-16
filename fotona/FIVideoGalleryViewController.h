//
//  FIVideoGalleryViewController.h
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FIVideoGalleryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString* galleryID;
@property (strong, nonatomic) NSString* category;

@property (strong, nonatomic) IBOutlet UITableView *videoGalleryTableView;
@property (nonatomic,retain) MPMoviePlayerViewController *moviePlayer;


-(void) loadGallery;
-(void) reloadCells:(NSString *)videoToReload;

@end

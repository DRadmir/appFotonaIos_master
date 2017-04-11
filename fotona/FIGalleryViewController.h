//
//  FIVideoGalleryViewController.h
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMedia.h"
#import "FIBaseView.h"

@interface FIGalleryViewController : FIBaseView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString* galleryItems;
@property (strong, nonatomic) NSString* galleryType;
@property (strong, nonatomic) NSString* category;

@property (strong, nonatomic) IBOutlet UITableView *videoGalleryTableView;


-(void) loadGallery;
-(void) reloadCells:(NSString *)videoToReload;
-(void) openVideo:(FMedia *) video;

-(void) refreshCellWithItemID:(NSString *)itemID andItemType:(NSString *) itemType;

@end

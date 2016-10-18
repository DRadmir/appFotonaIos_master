//
//  FFotonaGalleryView.m
//  fotona
//
//  Created by Janos on 17/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FFotonaGalleryView.h"
#import "FDB.h"

@implementation FFotonaGalleryView

@synthesize imgThumbnail;
@synthesize lblDesc;
@synthesize lblTitle;
@synthesize btnDownloadAdd;
@synthesize btnDownloadRemove;
@synthesize btnFavoriteAdd;
@synthesize btnFavoriteRemove;

@synthesize type;
@synthesize video;

- (IBAction)downloadAdd:(id)sender {
}

- (IBAction)downloadRemove:(id)sender {
}

- (IBAction)favoriteAdd:(id)sender {
}

- (IBAction)favoriteRemove:(id)sender {
}

-(void)setContentForFavorite:(FItemFavorite *)favorite{
    if ([[favorite typeID] isEqualToString:BOOKMARKVIDEO]) {
        video = [FDB getVideoWithId:[favorite itemID]];
        [lblTitle setText:[video title]];
        type = BOOKMARKVIDEOINT;
    } else {
        
    }
}
@end

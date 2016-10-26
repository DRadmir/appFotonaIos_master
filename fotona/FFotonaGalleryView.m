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

@synthesize parentIphone;
@synthesize index;
@synthesize type;
@synthesize cellVideo;

#pragma mark - Layout

-(void)setContentForVideo:(FMedia *)video{
    cellVideo = video;
    type = BOOKMARKVIDEO;

    [lblTitle setText:[video title]];
    [btnFavoriteRemove setHidden:YES];
   
    if([FDB checkIfBookmarkedForDocumentID:[video itemID] andType:type]){
        btnDownloadRemove.hidden = false;
        btnDownloadAdd.hidden = true;
    } else {
        btnDownloadRemove.hidden = true;
        btnDownloadAdd.hidden = false;
    }


    //    [cell fillCell];
    //    cell.parent = self;
    //
    //    [[cell imgVideoThumbnail] setClipsToBounds:YES];
    //    //[[cell imgVideoThumbnail] setContentMode:UIViewContentModeCenter];
    //
    //    FVideo *vid= [videoArray objectAtIndex:indexPath.row];
    //
    //    [cell setVideo:vid];
    //    NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:vid.itemID];
    //    UIImage *img = [preloadGalleryMoviesImages objectForKey:videoKey];
    //    [[cell imgVideoThumbnail] setImage:img];
}

-(void)reloadVideoThumbnail:(UIImage *)img{
    [imgThumbnail setImage:img];
}

#pragma mark - Buttons

- (IBAction)downloadAdd:(id)sender {
}

- (IBAction)downloadRemove:(id)sender {
}

- (IBAction)favoriteAdd:(id)sender {
    [FDB addTooFavoritesItem:[[cellVideo itemID] intValue] ofType:BOOKMARKVIDEO];
    btnFavoriteRemove.hidden = false;
    btnFavoriteAdd.hidden = true;
}

- (IBAction)favoriteRemove:(id)sender {
    [FDB removeFromFavoritesItem:[[cellVideo itemID] intValue] ofType:BOOKMARKVIDEO];
    if (parentIphone != nil) {
        [parentIphone deleteRowAtIndex:index];
    }
    btnFavoriteRemove.hidden = true;
    btnFavoriteAdd.hidden = false;
}

@end

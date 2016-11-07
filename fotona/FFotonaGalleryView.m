//
//  FFotonaGalleryView.m
//  fotona
//
//  Created by Janos on 17/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FFotonaGalleryView.h"
#import "FDB.h"
#import "HelperBookmark.h"

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
@synthesize cellMedia;

#pragma mark - Layout

-(void)setContentForMedia:(FMedia *)media andMediaType:(NSString *)mediaType{
    cellMedia = media;
    type = mediaType;


    [lblTitle setText:[media title]];
    [lblDesc setText:[media description]];
    [btnFavoriteRemove setHidden:YES];
   
    if([FDB checkIfBookmarkedForDocumentID:[media itemID] andType:type]){
        btnDownloadRemove.hidden = false;
        btnDownloadAdd.hidden = true;
    } else {
        btnDownloadRemove.hidden = true;
        btnDownloadAdd.hidden = false;
    }
    if([FDB checkIfFavoritesItem: [[media itemID] intValue] ofType:type]){
        btnFavoriteRemove.hidden = false;
        btnFavoriteAdd.hidden = true;
    } else {
        btnFavoriteRemove.hidden = true;
        btnFavoriteAdd.hidden = false;
    }
}

-(void)reloadVideoThumbnail:(UIImage *)img{
    NSData *data1 = UIImagePNGRepresentation(img);
    NSData *data2 = UIImagePNGRepresentation(imgThumbnail.image);
    if (![data1 isEqual:data2]) {
        [imgThumbnail setImage:img];

    }
}

#pragma mark - Buttons

- (IBAction)downloadAdd:(id)sender {
    if ([type intValue] == [MEDIAPDF intValue] || [type intValue] == [MEDIAVIDEO intValue]) {
        if ([HelperBookmark bookmarkMedia:cellMedia]) {
            btnDownloadAdd.enabled = false;
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"BOOKMARKING", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"ADDBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            btnDownloadRemove.hidden = false;
            btnDownloadAdd.hidden = true;
        }
    }
}

- (IBAction)downloadRemove:(id)sender {
}

- (IBAction)favoriteAdd:(id)sender {
    [FDB addTooFavoritesItem:[[cellMedia itemID] intValue] ofType:[cellMedia mediaType]];
    btnFavoriteRemove.hidden = false;
    btnFavoriteAdd.hidden = true;
}

- (IBAction)favoriteRemove:(id)sender {
    [FDB removeFromFavoritesItem:[[cellMedia itemID] intValue] ofType:[cellMedia mediaType]];
    if (parentIphone != nil) {
        [parentIphone deleteRowAtIndex:index];
    }
    btnFavoriteRemove.hidden = true;
    btnFavoriteAdd.hidden = false;
}

@end

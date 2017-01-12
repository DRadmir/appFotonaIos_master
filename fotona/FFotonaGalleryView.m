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
#import "UIColor+Hex.h"
#import "FDownloadManager.h"

@implementation FFotonaGalleryView

@synthesize imgThumbnail;
@synthesize lblDesc;
@synthesize lblTitle;
@synthesize btnDownloadAdd;
@synthesize btnDownloadRemove;
@synthesize btnFavoriteAdd;
@synthesize btnFavoriteRemove;
@synthesize containerView;

@synthesize parentIpad;
@synthesize parentIphone;
@synthesize index;
@synthesize type;
@synthesize cellMedia;

@synthesize enabled;
#pragma mark - Layout

-(void)setContentForMedia:(FMedia *)media andMediaType:(NSString *)mediaType{
    cellMedia = media;
    type = mediaType;
    btnDownloadAdd.enabled = YES;
    
    [lblTitle setText:[media title]];
    [lblDesc setText:[media description]];
   
    if([FDB checkIfBookmarkedForDocumentID:[media itemID] andType:type]){
        btnDownloadRemove.hidden = NO;
        btnDownloadAdd.hidden = YES;
    } else {
        btnDownloadRemove.hidden = YES;
        if ([ConnectionHelper connectedToInternet]) {
            [btnDownloadAdd setHidden:NO];
        } else {
            [btnDownloadAdd setHidden:YES];
        }
    }
    
    if([FDB checkIfFavoritesItem: [[media itemID] intValue] ofType:type]){
        btnFavoriteRemove.hidden = NO;
        btnFavoriteAdd.hidden = YES;
    } else {
        btnFavoriteRemove.hidden = YES;
        btnFavoriteAdd.hidden = NO;
    }
    if ([FCommon isIpad]) {
        [containerView setBackgroundColor:[UIColor lightBackgroundColor]];
    } else {
        [containerView setBackgroundColor:[UIColor whiteColor]];
    }
    
    //if not accessible change alpha
    if (([[media bookmark] isEqualToString:@"0"] || [media bookmark] == nil) && ![ConnectionHelper connectedToInternet]) {
        enabled = false;
        [lblTitle setAlpha:DISABLEDCOLORALPHA];
        [imgThumbnail setAlpha:DISABLEDCOLORALPHA];
        [lblDesc setAlpha:DISABLEDCOLORALPHA];
        
    } else {
        enabled = true;
        [lblTitle setAlpha:1];
        [imgThumbnail setAlpha:1];
        [lblDesc setAlpha:1];

    }
    [imgThumbnail setImage:[UIImage imageNamed:@"no_thunbail"]];
  

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
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"BOOKMARKING", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (IBAction)downloadRemove:(id)sender {
    
    [HelperBookmark removeBookmarkForMedia:cellMedia andType:[cellMedia mediaType] forBookmarkType:BSOURCEFOTONA];
}

- (IBAction)favoriteAdd:(id)sender {
    [FDB addTooFavoritesItem:[[cellMedia itemID] intValue] ofType:[cellMedia mediaType]];
    btnFavoriteRemove.hidden = NO;
    btnFavoriteAdd.hidden = YES;
}

- (IBAction)favoriteRemove:(id)sender {
    [FDB removeFromFavoritesItem:[[cellMedia itemID] intValue] ofType:[cellMedia mediaType]];
    if (parentIphone != nil) {
        [parentIphone deleteRowAtIndex:index];
    } else {
        if (parentIpad != nil) {
            [parentIpad deleteRowAtIndex:index];
        }
    }
    btnFavoriteRemove.hidden = YES;
    btnFavoriteAdd.hidden = NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"BOOKMARKING", nil)]) {
        if ([type intValue] == [MEDIAPDF intValue] || [type intValue] == [MEDIAVIDEO intValue]) {
            if ([HelperBookmark bookmarkMedia:cellMedia]) {
                btnDownloadAdd.enabled = NO;
                 [[FDownloadManager shared] prepareForDownloadingFiles];
            } else {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"ADDBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                btnDownloadRemove.hidden = NO;
                btnDownloadAdd.hidden = YES;
            }
        }
    }
}


@end

//
//  FGalleryCollectionViewCell.m
//  fotona
//
//  Created by Janos on 14/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FGalleryCollectionViewCell.h"
#import "FDB.h"
#import "FHelperThumbnailImg.h"
#import "UIColor+Hex.h"

@implementation FGalleryCollectionViewCell

@synthesize caseToShow;
@synthesize item;
@synthesize parentIpad;
@synthesize index;
@synthesize enabled;
@synthesize cellViewCase;
@synthesize cellViewFotona;
@synthesize cellViewVideo;
@synthesize cellMedia;


- (void)awakeFromNib {
    [super awakeFromNib];
 
}

-(void)setContentForCase:(FCase *)fcase{
    
    cellViewCase = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:0];
    for (UIView *subView in [self.contentView subviews]) {
        [subView removeFromSuperview];
    }
    [[self contentView] addSubview: cellViewCase];
    [cellViewCase setFrame:[[self contentView] bounds]];
    enabled = true;
    [cellViewCase setItem:item];
    [cellViewCase setIndex:index];
    [cellViewCase setParentIphone:nil];
    [cellViewCase setParentIpad:parentIpad];
    [cellViewCase setContentForCase:fcase];
    enabled = cellViewCase.enabled;
}

-(void)setContentForFavorite:(FItemFavorite *)fitem forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath andConnected:(BOOL)connected{
    if ([[fitem typeID] intValue] == BOOKMARKVIDEOINT || [[fitem typeID] intValue] == BOOKMARKPDFINT) {
        FMedia * media =[FDB getMediaWithId:[fitem itemID] andType:[fitem typeID]];
        [self setContentForMedia:media forColectionView:collectionView onIndex:indexPath andConnected:connected];
        if (media.thumbnail == nil ){
            [FHelperThumbnailImg getThumbnailForMedia:media onTableView:nil orCollectionView:collectionView withIndex:indexPath];
        }
    }
}

-(void)setContentForMedia:(FMedia *)media forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath andConnected:(BOOL)connected{
    cellMedia = media;
    enabled = true;;
    for (UIView *subView in [self.contentView subviews]) {
        [subView removeFromSuperview];
    }
    
        if ([media.mediaType intValue] == [MEDIAVIDEO intValue]) {
            if (cellViewVideo == nil) {
                cellViewVideo = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:2];
            }
            [cellViewVideo setParentIphone:nil];
            [cellViewVideo setParentIpad:parentIpad];
            [cellViewVideo setIndex:index];
            [[self contentView] addSubview: cellViewVideo];
            [cellViewVideo setFrame:[[self contentView] bounds]];
            [cellViewVideo setContentForMedia:media andMediaType:[media mediaType] andConnection:connected];
            enabled = cellViewVideo.enabled;
        } else {
            if (cellViewFotona == nil) {
                cellViewFotona = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:1];
            }
            [cellViewFotona setParentIphone:nil];
            [cellViewFotona setParentIpad:parentIpad];
            [cellViewFotona setIndex:index];
            [[self contentView] addSubview: cellViewFotona];
            [cellViewFotona setFrame:[[self contentView] bounds]];
            [cellViewFotona setContentForMedia:media andMediaType:[media mediaType] andConnection:connected];
            enabled = cellViewFotona.enabled;
        }

    if (media.thumbnail == nil ){
        [FHelperThumbnailImg getThumbnailForMedia:media onTableView:nil orCollectionView:collectionView withIndex:indexPath];
    }    
    
}

-(void)refreshCollectionMediaThumbnail:(UIImage *)img{
    if ([cellMedia.mediaType intValue] == [MEDIAVIDEO intValue]) {
       [cellViewVideo reloadVideoThumbnail:img];
    } else {
        [cellViewFotona reloadVideoThumbnail:img];
    }
}


@end

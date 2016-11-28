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
}

-(void)setContentForFavorite:(FItemFavorite *)fitem forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath{
    if ([[fitem typeID] intValue] == BOOKMARKVIDEOINT || [[fitem typeID] intValue] == BOOKMARKPDFINT) {
        FMedia * media =[FDB getMediaWithId:[fitem itemID] andType:[fitem typeID]];
        [self setContentForMedia:media forColectionView:collectionView onIndex:indexPath];
        [FHelperThumbnailImg getThumbnailForMedia:media onTableView:nil orCollectionView:collectionView withIndex:indexPath];
    }
}

-(void)setContentForMedia:(FMedia *)media forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath{
    enabled = true;;
    for (UIView *subView in [self.contentView subviews]) {
        [subView removeFromSuperview];
    }
    if (cellViewFotona == nil) {
        cellViewFotona = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:1];
    }
    [cellViewFotona setParentIphone:nil];
    [cellViewFotona setParentIpad:parentIpad];
    [cellViewFotona setIndex:index];
    [[self contentView] addSubview: cellViewFotona];
    [cellViewFotona setFrame:[[self contentView] bounds]];
    [cellViewFotona setContentForMedia:media andMediaType:[media mediaType]];
    if ([[media bookmark] isEqualToString:@"0"] && ![ConnectionHelper connectedToInternet]) {
        enabled = false;
    }
    [FHelperThumbnailImg getThumbnailForMedia:media onTableView:nil orCollectionView:collectionView withIndex:indexPath];
    
    
}

-(void)refreshMediaThumbnail:(UIImage *)img{
    [cellViewFotona reloadVideoThumbnail:img];
}


@end

//
//  FGalleryCollectionViewCell.h
//  fotona
//
//  Created by Janos on 14/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FFavoriteViewController.h"
#import "FCaseGalleryView.h"
#import "FFotonaGalleryView.h"
#import "FFotonaVideoView.h"
#import "FMedia.h"

@interface FGalleryCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) FCase *caseToShow;
@property (strong, nonatomic) FItemFavorite *item;
@property (strong, nonatomic) FFavoriteViewController *parentIpad;
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;
@property (strong, nonatomic) FCaseGalleryView *cellViewCase;
@property (strong, nonatomic) FFotonaGalleryView *cellViewFotona;
@property (strong, nonatomic) FFotonaVideoView *cellViewVideo;
@property (strong, nonatomic) FMedia *cellMedia;

-(void)setContentForCase:(FCase *)fcase;

-(void)setContentForFavorite:(FItemFavorite *)fitem forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath;

-(void)setContentForMedia:(FMedia *) video forColectionView:(UICollectionView *)collectionView onIndex:(NSIndexPath *)indexPath;

-(void)refreshCollectionMediaThumbnail:(UIImage *)img;

@end

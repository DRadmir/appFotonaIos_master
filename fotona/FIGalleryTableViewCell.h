//
//  FIGalleryTableViewCell.h
//  fotona
//
//  Created by Janos on 10/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FIFavoriteViewController.h"
#import "FCaseGalleryView.h"
#import "FFotonaGalleryView.h"
#import "FMedia.h"

@interface FIGalleryTableViewCell : UITableViewCell

@property (strong, nonatomic) FCase *caseToShow;
@property (strong, nonatomic) FItemFavorite *item;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;//TODO: dodat ipad parenta
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;
@property (strong, nonatomic) FCaseGalleryView *cellViewCase;
@property (strong, nonatomic) FFotonaGalleryView *cellViewFotona;


-(void)setContentForCase:(FCase *)fcase;

-(void)setContentForFavorite:(FItemFavorite *)fitem forTableView:(UITableView *)tableView onIndex:(NSIndexPath *)indexPath;

-(void)setContentForMedia:(FMedia *) video forTableView:(UITableView *)tableView onIndex:(NSIndexPath *)indexPath;

-(void)refreshMediaThumbnail:(UIImage *)img;

@end

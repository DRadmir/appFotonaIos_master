//
//  FIGalleryTableViewCell.m
//  fotona
//
//  Created by Janos on 10/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIGalleryTableViewCell.h"
#import "FDB.h"
#import "FHelperThumbnailImg.h"

@implementation FIGalleryTableViewCell
@synthesize caseToShow;
@synthesize item;
@synthesize parentIphone;
@synthesize index;
@synthesize enabled;
@synthesize cellViewCase;
@synthesize cellViewFotona;

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setContentForCase:(FCase *)fcase{
   
    cellViewCase = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:0];
    [[self contentView] addSubview: cellViewCase];
    enabled = true;
    [cellViewCase setItem:item];
    [cellViewCase setIndex:index];
    [cellViewCase setParentIphone:parentIphone];
    [cellViewCase setParentIpad:nil];
    [cellViewCase setContentForCase:fcase];
}

-(void)setContentForFavorite:(FItemFavorite *)fitem forTableView:(UITableView *)tableView onIndex:(NSIndexPath *)indexPath{
    if ([[fitem typeID] intValue] == BOOKMARKVIDEOINT || [[fitem typeID] intValue] == BOOKMARKPDFINT) {
        FMedia * media =[FDB getMediaWithId:[fitem itemID] andType:[fitem typeID]];
        [self setContentForMedia:media forTableView:tableView onIndex:indexPath];
        [FHelperThumbnailImg getThumbnailForMedia:media onTableView:tableView orCollectionView:nil withIndex:indexPath];
    }
}

-(void)setContentForMedia:(FMedia *)media forTableView:(UITableView *)tableView onIndex:(NSIndexPath *)indexPath{
    enabled = true;;
    if (cellViewFotona == nil) {
        cellViewFotona = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:1];
        [cellViewFotona setParentIphone:parentIphone];
        [cellViewFotona setParentIpad:nil];
         [cellViewFotona setIndex:index];
        [[self contentView] addSubview: cellViewFotona];
    }
    [cellViewFotona setContentForMedia:media andMediaType:[media mediaType]];
    if ([[media bookmark] isEqualToString:@"0"] && ![ConnectionHelper connectedToInternet]) {
        enabled = false;
    }
     [FHelperThumbnailImg getThumbnailForMedia:media onTableView:tableView orCollectionView:nil withIndex:indexPath];
}

-(void)refreshMediaThumbnail:(UIImage *)img{
    [cellViewFotona reloadVideoThumbnail:img];
}

@end

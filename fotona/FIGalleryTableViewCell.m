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
    [cellViewCase setContentForCase:fcase];
}

-(void)setContentForFavorite:(FItemFavorite *)fitem forTableView:(UITableView *)tableView onIndex:(NSIndexPath *)indexPath{
    if ([[fitem typeID] intValue] == BOOKMARKVIDEOINT || [[fitem typeID] intValue] == BOOKMARKPDFINT) {
        FMedia * media =[FDB getMediaWithId:[fitem itemID] andType:[fitem typeID]];
        [self setContentForMedia:media];
        [FHelperThumbnailImg getThumbnailForMedia:media onTableView:tableView withIndex:indexPath];
    }
}

-(void)setContentForMedia:(FMedia *)media{
    enabled = true;;
    if (cellViewFotona == nil) {
         cellViewFotona = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:1];
         [[self contentView] addSubview: cellViewFotona];
    }
    [cellViewFotona setContentForMedia:media andMediaType:[media mediaType]];
    if ([[media bookmark] isEqualToString:@"0"] && ![APP_DELEGATE connectedToInternet]) {
        enabled = false;
    }

}

-(void)refreshMediaThumbnail:(UIImage *)img{
    [cellViewFotona reloadVideoThumbnail:img];
}

@end

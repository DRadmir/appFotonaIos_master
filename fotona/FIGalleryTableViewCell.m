//
//  FIGalleryTableViewCell.m
//  fotona
//
//  Created by Janos on 10/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIGalleryTableViewCell.h"
#import "FDB.h"

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

-(void)setContentForFotona:(FItemFavorite *)fitem{
    if ([[fitem typeID] intValue] == BOOKMARKVIDEOINT) {
        FMedia * video =[FDB getVideoWithId:[fitem itemID]];
        [self setContentForVideo:video];
    }
}

-(void)setContentForVideo:(FMedia *)video{
    if (cellViewFotona == nil) {
         cellViewFotona = [[[NSBundle mainBundle] loadNibNamed:@"FGalleryView" owner:self options:nil] objectAtIndex:1];
         [[self contentView] addSubview: cellViewFotona];
    }
    [cellViewFotona setContentForVideo:video];
}

-(void)refreshVideoThumbnail:(UIImage *)img{
    [cellViewFotona reloadVideoThumbnail:img];
}

@end

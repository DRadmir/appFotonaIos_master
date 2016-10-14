//
//  FFavoriteCaseTableViewCell.h
//  fotona
//
//  Created by Janos on 10/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FItemFavorite.h"
#import "FIFavoriteViewController.h"
#import "FCaseGalleryView.h"

@interface FFavoriteCaseTableViewCell : UITableViewCell

@property (strong, nonatomic) FCase *caseToShow;
@property (strong, nonatomic) FItemFavorite *item;
@property (strong, nonatomic) FIFavoriteViewController *parentIphone;//TODO: dodat ipad parenta
@property (strong, nonatomic) NSIndexPath *index;
@property (nonatomic) BOOL enabled;
@property (strong, nonatomic) FCaseGalleryView *cellView;


- (void) showCase:(FCase *)fcase;


@end

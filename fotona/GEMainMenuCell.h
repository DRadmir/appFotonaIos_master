//
//  GEMainMenuCell.h
//  GibExplorer
//
//  Created by Dejan Krstevski on 2/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMedia.h"
#import "FBookmarkViewController.h"
#import "FFotonaViewController.h"

@interface GEMainMenuCell : UICollectionViewCell<UIActionSheetDelegate>

@property (nonatomic,retain) UIImageView *image;
@property (nonatomic,retain) UIView *transparentView;
@property (nonatomic,retain) UILabel *titleLbl;
@property (nonatomic,retain) UIButton *bookmarkBtn;
@property (nonatomic,retain) UIButton *bookmarkRemoveBtn;

@property (nonatomic,retain) FBookmarkViewController *parent;
@property (nonatomic,retain) FFotonaViewController *parentFotona;

@property (nonatomic, retain) FMedia* video;


@end

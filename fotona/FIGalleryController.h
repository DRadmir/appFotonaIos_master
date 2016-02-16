//
//  FIGalleryController.h
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EBPhotoPagesController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FNews.h"
#import "FEvent.h"

@interface FIGalleryController : NSObject <EBPhotoPagesDelegate,EBPhotoPagesDataSource>

@property (strong, nonatomic) UIViewController *parent;
@property (strong, nonatomic) UIScrollView *scrollViewGallery;
@property (strong, nonatomic) NSArray *imagesArray;
@property (strong, nonatomic) NSArray *videosArray;
@property (nonatomic,retain) MPMoviePlayerViewController *moviePlayer;

@property (nonatomic) int type;

-(void) createGalleryWithImages:(NSArray *)images andVideos:(NSArray *) videos forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height;
-(void) createGalleryWithImagesForNews:(FNews *)newsGallery forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height andBottomHeight:(NSLayoutConstraint *)bottomHeight;
-(void) createGalleryWithImagesForEvent:(FEvent *)eventGallery forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height andBottomHeight:(NSLayoutConstraint *)bottomHeight;

@end

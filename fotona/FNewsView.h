//
//  FNewsView.h
//  fotona
//
//  Created by Janos on 12/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNews.h"

@interface FNewsView : UIViewController{
int beforeOrient;
}

@property (strong, nonatomic) IBOutlet UIView *newsView;
@property (strong, nonatomic) IBOutlet UIScrollView *newsScrollView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *newsRelatedView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *newsRelatedImage;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *newsRelatedTitle;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *newsRelatedDate;
@property (strong, nonatomic) IBOutlet UIScrollView *newsImageScroll;
@property (strong, nonatomic) IBOutlet UITextView *newsText;
@property (strong, nonatomic) IBOutlet UILabel *newsTitle;
@property (strong, nonatomic) IBOutlet UILabel *newsDate;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollImagesViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollImagesViewBottom;

@property (nonatomic) FNews *news;
@property (nonatomic) NSMutableArray *newsArray;

-(void) openNews:(FNews *)news andNewsArray:(NSMutableArray *)newsArray;
@end

//
//  FGalleryViewController.h
//  fotona
//
//  Created by Dejan Krstevski on 6/6/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDLabelView.h"
#import "FSession.h"

@interface FGalleryViewController : UIViewController <UIAlertViewDelegate,UIScrollViewDelegate>
{
    IBOutlet UIButton *deleteBtn;
    IBOutlet UIScrollView *imageScroll;
    NSMutableArray *imageViews;
    NSMutableArray *titleViews;
    NSMutableArray *descriptionViews;
    NSMutableArray *pinchRecognizers;
    NSMutableArray *tmpViewsArray;;

}
@property (nonatomic, retain) NSMutableArray *images;
@property (assign) int index;
@property (assign) BOOL allowDelete;
@property (assign) BOOL isShowroom;

@property (nonatomic,retain) FSession *session;

-(id)initWithImages:(NSMutableArray *)imgs index:(int)i allowDelete:(BOOL)del;
-(id)initWithSession:(FSession *)s allowDelete:(BOOL)del;

@end

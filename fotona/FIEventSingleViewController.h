//
//  FIEventSingleViewController.h
//  fotona
//
//  Created by Janos on 29/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIBaseView.h"
#import "FEvent.h"
#import "FIGalleryController.h"

@interface FIEventSingleViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property (strong, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) IBOutlet UIWebView *textWebView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imagesScrollViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textWebViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imagesScrollBottomSpace;

@property (nonatomic) FEvent *eventToOpen;
@property (strong, nonatomic)  FIGalleryController *gallery;


- (void)fillView;

@end

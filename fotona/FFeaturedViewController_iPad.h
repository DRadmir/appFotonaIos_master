//
//  FFeaturedViewController.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCollectionViewCell.h"
#import "iCarousel.h"
#import "FNews.h"
#import "FDLabelView.h"


@interface FFeaturedViewController_iPad : UIViewController <iCarouselDataSource, iCarouselDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate>//,UIImagePickerControllerDelegate
{
    IBOutlet UIScrollView *newsScroll;
    UIView *column1;
    UIView *column2;

    
    IBOutlet UIView *mainScroll;
    
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *feedbackBtn;
    
    float screenWidth;
    long currentOrientation;
    
    //news popoup
    UIView *bck;
    UIView *settingsView;
    IBOutlet UIButton *popupCloseBtn;

    int beforeOrient;
    BOOL firstRun;
    
    IBOutlet UIView *disclaimerView;
    
    
    IBOutlet UIScrollView *disclaimerScrollView;

    IBOutlet UIButton *btnAccept;
    IBOutlet UIButton *btnDecline;
}
@property (nonatomic, retain) FNews *openNews;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *frameview;

@property (strong, nonatomic) UIPopoverController *popover;

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@property (nonatomic,retain) NSMutableArray *newsArray;
@property (nonatomic,retain) NSMutableArray *eventsArray;




@property (strong, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIScrollView *aboutScrollView;
//@property (weak, nonatomic) IBOutlet FDLabelView *aboutContent;
@property (weak, nonatomic) IBOutlet FDLabelView *aboutTitle;
@property (weak, nonatomic) IBOutlet UITextView *aboutDescription;


//-(IBAction)openCamera:(id)sender;

- (IBAction)openSettings:(id)sender;


- (void)openNews:(FNews *)news;

- (void)setNewsReaded:(NSString *)nID;


@end

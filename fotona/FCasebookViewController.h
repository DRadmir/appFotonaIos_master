//
//  FCasebookViewController.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCase.h"
#import "FDLabelView.h"
#import <QuickLook/QuickLook.h>
#import "IIViewDeckController.h"
#import "FSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EBPhotoPagesController.h"


@interface FCasebookViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UINavigationControllerDelegate,UISearchBarDelegate,UIAlertViewDelegate,EBPhotoPagesDelegate,EBPhotoPagesDataSource, UIActionSheetDelegate>
{
    IBOutlet UIButton *feedbackBtn;
    IBOutlet UIButton *menuBtn;
    
    IBOutlet UILabel *menuTitle;
    IBOutlet UITableView *menuTable;
    IBOutlet UIView *menuHeader;
    IBOutlet UIButton *back;
    
    IBOutlet UIView *header;
    
    IBOutlet UIView *caseView;
    IBOutlet UIView *exCaseView;
    
    

    IBOutlet UIView *galleryView;
    
    
    IBOutlet UIImageView *authorImg;
    IBOutlet UIImageView *fotonaImg;
    
    
    //case outlets
    IBOutlet UILabel *authorNameLbl;
    IBOutlet UILabel *dateLbl;
    IBOutlet UILabel *titleLbl;
    IBOutlet UILabel *introductionTitle;
    IBOutlet UIButton *images;
    IBOutlet UIButton *videos;
    
    IBOutlet UIButton *disclaimerBtn;
    
    IBOutlet UIScrollView *imagesScroll;
    //parameters
    IBOutlet UIScrollView *parametersScrollView;
    IBOutlet UIView *headerTableParameters;
    IBOutlet UIView *tableParameters;
    IBOutlet UIView *parametersConteiner;
    IBOutlet UIButton *expandBtn;
    BOOL isExpanded;
    IBOutlet UIView *additionalInfo;
    BOOL flagParameters;
    
        
    IBOutlet UIButton *addBookmarks;
    IBOutlet UIButton *removeBookmarks;
    
    IBOutlet UIButton *addToFavorite;
    IBOutlet UIButton *removeFavorite;

    
    IBOutlet UIScrollView *caseScroll;
    
    IBOutlet UIView *contentModeView;
    IBOutlet FDLabelView *cTitleLbl;
    IBOutlet FDLabelView *cDescriptionLbl;
    IBOutlet UIScrollView *contentModeScrollView;
    
    NSString *imageName;
    UIImagePickerController *imagePicker;
    int caseTittleFlag;
    
    int beforeOrient;
    
   
     UIView *bck;
    UIView *settingsView;
}

@property (strong, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *popupCloseBtn;



@property (nonatomic, retain) FCase *currentCase;
@property (nonatomic, retain) FCase *prevCase;
@property (assign) BOOL flagCarousel;

@property (nonatomic,retain) NSMutableArray *menuItems;
@property (nonatomic,retain) NSMutableArray *casesInMenu;
@property (nonatomic,retain) NSMutableArray *menuTitles;
@property (nonatomic,retain) NSMutableArray *menuIcons;
@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic, retain) NSMutableArray *allCasesInMenu;

@property (nonatomic, retain) NSString *selectedIcon;



-(void)openCase;
-(void)setCaseOutlets;
-(void)setPatameters;


-(IBAction)expand:(id)sender;

-(IBAction)backBtn:(id)sender;
-(IBAction)menu:(id)sender;


- (IBAction)addToBookmarks:(id)sender;
- (IBAction)removeFromBookmarks:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)closeSettings:(id)sender;
- (IBAction)addToFavorite:(id)sender;
- (IBAction)removeFavorite:(id)sender;


- (IBAction)showDisclaimer:(id)sender;
-(void) openDisclaimer;
- (void) refreshBookmarkBtn;

@end

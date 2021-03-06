#import <UIKit/UIKit.h>
#import "FCase.h"
#import "FDLabelView.h"
#import <QuickLook/QuickLook.h>
#import "IIViewDeckController.h"
#import "FSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EBPhotoPagesController.h"

@interface FFavoriteViewController : UIViewController <UINavigationControllerDelegate,UISearchBarDelegate,UIAlertViewDelegate,EBPhotoPagesDelegate,EBPhotoPagesDataSource>
{
    NSString *pathToPDF;
    
    IBOutlet UIButton *feedbackBtn;

    
    IBOutlet UIView *header;
    
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
    
    NSString *imageName;
    UIImagePickerController *imagePicker;
    int caseTittleFlag;
    
    int beforeOrient;
    
    UIView *bck;
    
    IBOutlet UIView *contentVideoModeView;
    IBOutlet FDLabelView *cvTitleLbl;
    IBOutlet FDLabelView *cvDescriptionLbl;
    
    NSMutableArray *videoBtns;
    UIView *settingsView;
    
    IBOutlet UIView *customToolbar;
    
}

@property (strong, nonatomic) NSMutableArray *mediaArray;

@property(weak,nonatomic) IBOutlet UICollectionView *contentsVideoModeCollectionView;

@property (weak, nonatomic) IBOutlet UIView *caseView;

@property (strong, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *popupCloseBtn;

@property (nonatomic, retain) FCase *currentCase;
@property (nonatomic, retain) FCase *prevCase;
@property (assign) BOOL flagCarousel;

@property (nonatomic) int showView;

//View for disclaimer
@property (strong, nonatomic) IBOutlet UIView *helpView;
@property (weak, nonatomic) IBOutlet UIScrollView *helpScrollView;
@property (weak, nonatomic) IBOutlet FDLabelView *helpTitle;
@property (weak, nonatomic) IBOutlet FDLabelView *helpContent;

@property(strong, nonatomic) UIViewController *lastOpenedFavoriteVC;


-(void)openCaseWithID:(NSString *)caseID;
-(void)setCaseOutlets;
-(void)setPatameters;

-(IBAction)expand:(id)sender;

- (IBAction)addToBookmarks:(id)sender;
- (IBAction)removeFromBookmarks:(id)sender;

- (IBAction)addToFavorite:(id)sender;
- (IBAction)removeFavorite:(id)sender;


- (IBAction)openSettings:(id)sender;
- (IBAction)closeSettings:(id)sender;

-(void)openContentWithTitle:(NSString *)title;

- (IBAction)showDisclaimer:(id)sender;

-(void)deleteRowAtIndex:(NSIndexPath *) index;
- (void) refreshCellForMedia:(NSString *)mediaID andMediaType:(NSString *)mediaType;
- (void) refreshBookmarkBtn;
@end

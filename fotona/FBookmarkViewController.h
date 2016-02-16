
#import <UIKit/UIKit.h>
#import "FCase.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FDLabelView.h"
#import <QuickLook/QuickLook.h>
#import "IIViewDeckController.h"
#import "FSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FEvent.h"
#import "FNews.h"

#import "EBPhotoPagesController.h"


@interface FBookmarkViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UINavigationControllerDelegate,UISearchBarDelegate,UIAlertViewDelegate,EBPhotoPagesDelegate,EBPhotoPagesDataSource>//,UIImagePickerControllerDelegate
{
    NSString *pathToPDF;
    
    IBOutlet UIButton *feedbackBtn;
    IBOutlet UIButton *menuBtn;

    
    IBOutlet UILabel *menuTitle;
    IBOutlet UITableView *menuTable;
    IBOutlet UIView *menuHeader;
    IBOutlet UIButton *back;
    
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
    
        
    IBOutlet UIButton *removeBookmarks;
    
    IBOutlet UIScrollView *caseScroll;
    
    
    UIImage *imageToSave;
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
@property (strong, nonatomic) NSMutableArray *videoArray;

@property(weak,nonatomic) IBOutlet UICollectionView *contentsVideoModeCollectionView;

@property (weak, nonatomic) IBOutlet UIView *caseView;

@property (strong, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *popupCloseBtn;

@property (nonatomic,retain) MPMoviePlayerViewController *moviePlayer;


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
@property (nonatomic) int showView;

@property (strong, nonatomic) IBOutlet UIView *helpView;
@property (weak, nonatomic) IBOutlet UIScrollView *helpScrollView;
@property (weak, nonatomic) IBOutlet FDLabelView *helpTitle;
@property (weak, nonatomic) IBOutlet FDLabelView *helpContent;

//event
@property (strong, nonatomic) IBOutlet UIScrollView *eventView;
@property (weak, nonatomic) IBOutlet UIImageView *eventImg;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLbl;
@property (strong, nonatomic) IBOutlet UIWebView *eventText;
@property (strong, nonatomic) IBOutlet UIScrollView *eventImagesScroll;

-(void)openCase;
-(void)setCaseOutlets;
-(void)setPatameters;


-(IBAction)expand:(id)sender;

-(IBAction)backBtn:(id)sender;
-(IBAction)menu:(id)sender;


- (IBAction)removeFromBookmarks:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)closeSettings:(id)sender;

-(NSMutableArray *)getVideos;
-(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory;

-(void)openContentWithTitle:(NSString *)title;
-(void)openHelp;


-(void)setVideos;
-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t;

- (IBAction)showDisclaimer:(id)sender;

-(void) openEvent:(FEvent*) event fromCategory:(int) category;
-(void) openNews:(FNews*) news;
@end

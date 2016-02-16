

#import <UIKit/UIKit.h>
#import "FEventViewCell.h"
#import "EBPhotoPagesController.h"

@interface FEventViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIAlertViewDelegate,UISearchBarDelegate,EBPhotoPagesDelegate,EBPhotoPagesDataSource>
{
    
    IBOutlet UIButton *popupCloseBtn;
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *feedbackBtn;
    
    IBOutlet UIView *navBarCustom;
    
    
    IBOutlet UISegmentedControl *type;
    IBOutlet UISegmentedControl *category;
    IBOutlet UITableView *tableView;
    
   // UIScrollView *eventToShow;
    UIView *settingsView;
    IBOutlet UIScrollView *eventImagesScroll;
   // IBOutlet UIView *scroolViewContainer;
    
    int beforeOrient;
   
}
@property (weak, nonatomic) IBOutlet UIView *mainTableView;

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) IBOutlet FEventViewCell *customCell;

@property (strong, nonatomic) IBOutlet UIScrollView *popEvent;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *popupTitleLbl;
@property (weak, nonatomic) IBOutlet UIView *popupEventText;
@property (weak, nonatomic) IBOutlet UIImageView *popupImg;
@property (weak, nonatomic) IBOutlet UILabel *popupDate;
@property (strong, nonatomic) IBOutlet UIWebView *popupText;


- (IBAction)categorySelect:(id)sender;
- (IBAction)closePopupEventView:(id)sender;
- (void)openPopupOutside;
- (IBAction)openSettings:(id)sender;



@end

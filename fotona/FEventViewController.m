

#import "FEventViewController.h"
#import "GEMainMenuCell.h"
#import "AFNetworking.h"
#import "FAppDelegate.h"
#import "FDocument.h"
#import "FMDatabase.h"
#import "FSearchViewController.h"
#import "FFeaturedViewController_iPad.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FEvent.h"
#import "FSettingsViewController.h"
#import "FImage.h"
#import "HelperDate.h"
#import "HelperString.h"
#import "FDB.h"

@interface FEventViewController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webViewHeight;

@end

@implementation FEventViewController{
    NSArray *eventsTable;
    NSArray *tableData;
    FEvent *openEvent;
    int ci;
    int ti;
    FSettingsViewController *settingsController;
}
@synthesize popover;
@synthesize customCell = _customCell;

@synthesize closeBtn;
@synthesize popEvent;
@synthesize popupTitleLbl;
@synthesize popupImg;
@synthesize popupDate;
@synthesize popupText;

@synthesize mainTableView;

#define OPENVIEW 1000
#define CLOSEVIEW 0
#define SETTINGSVIEW 2000


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setTitle:@"Events"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"events.png"]];
    }
    return self;
    
}

- (void)viewDidLoad
{
    ci = 0;
    [APP_DELEGATE setClosedEvents:NO];
    beforeOrient=[APP_DELEGATE currentOrientation];
    [super viewDidLoad];
    //feedback
    [feedbackBtn addTarget:APP_DELEGATE action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    //search
    FSearchViewController *searchVC=[[FSearchViewController alloc] init];
    [searchVC setParent:self];
    popover=[[UIPopoverController alloc] initWithContentViewController:searchVC];
    
    popupText.delegate = self;
    settingsController = [APP_DELEGATE settingsController];
    //swipe closing news
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(closeEvent:)];
    [popEvent addGestureRecognizer:swipeRecognizer];
    UISwipeGestureRecognizer *swipeRecognizerS = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(closeEvent:)];
    [settingsView addGestureRecognizer:swipeRecognizerS];
    //tab closing news
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabEvent:)
                                                 name:@"CloseOnTabEvents"
                                               object:nil];
    
    tableView.estimatedRowHeight = 360;
    tableView.rowHeight = UITableViewAutomaticDimension;
    [tableView setNeedsLayout];
    [tableView layoutIfNeeded];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tabBarItem setImage:[UIImage imageNamed:@"events_red.png"]];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    eventsTable = [APP_DELEGATE eventArray];
    if ([APP_DELEGATE closedEvents]) {
        [self getEventsFromDB];
        [APP_DELEGATE setClosedEvents:NO];
    }
    tableData = [FDB fillEventsWithCategory:0 andType:0 andMobile:false];
    [tableView reloadData];
    

}


-(void)viewDidAppear:(BOOL)animated
{
    beforeOrient=[APP_DELEGATE currentOrientation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.tabBarItem setImage:[UIImage imageNamed:@"events.png"]];
}


#pragma mark Search

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Text: %@",searchText);
    if ([searchText isEqualToString:@""]) {
        [popover dismissPopoverAnimated:YES];
    }else
    {
        [(FSearchViewController *)popover.contentViewController setSearchTxt:searchText];
        [(FSearchViewController *)popover.contentViewController search];
        [[(FSearchViewController *)popover.contentViewController tableSearch] reloadData];
        if (![popover isPopoverVisible]) {
            [popover presentPopoverFromRect:searchBar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    beforeOrient=[APP_DELEGATE currentOrientation];
    if (toInterfaceOrientation!=UIInterfaceOrientationPortrait) {
        [popEvent setFrame:CGRectMake(0,65, self.view.frame.size.height, 654)];
        [settingsView setFrame:CGRectMake(0,65, self.view.frame.size.height, 654)];
    }else{
        [popEvent setFrame:CGRectMake(0,65, self.view.frame.size.height, 910)];
         [settingsView setFrame:CGRectMake(0,65, self.view.frame.size.height, 910)];
    }
    [settingsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    NSLog(@"parent: %f",settingsView.frame.size.width);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
        
    }
    [APP_DELEGATE rotatePopupSearchedNewsInView:self.view];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
       return [tableData count];
}

//creating events
- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // FEventViewCell *cell =  [FEventViewCell fillCell:indexPath fromArray:tableData andCategory: ci andOwner:self ];
    FEventViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FEventViewCell" owner:self options:nil] objectAtIndex:0];
    NSString * img =@"";
    if (ci==0) {
        img = [[tableData objectAtIndex:indexPath.row] getDot];
    } else{
        img = [[tableData objectAtIndex:indexPath.row] getDot:ci];
    }
    [cell.dotImg setImage:[UIImage imageNamed:img]];
    cell.title.text = [[[tableData objectAtIndex:indexPath.row] title] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    cell.date.text = [[HelperDate formatedDate:[[tableData objectAtIndex:indexPath.row] eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[[tableData objectAtIndex:indexPath.row] eventdateTo]]]];
    
    cell.place.text = [[tableData objectAtIndex:indexPath.row] eventplace];
    return cell;
    return cell;
}

//click on event
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [popupTitleLbl setText:[[[tableData objectAtIndex:indexPath.row] title] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    openEvent =[tableData objectAtIndex:indexPath.row] ;
    

    NSString *htmlString= [HelperString toHtmlEvent:[[tableData objectAtIndex:indexPath.row] text]];//[NSString stringWithFormat:@"<html><body><style>p{margin-top: 27px;margin-bottom: 27px; line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} td{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} li{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} ul{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} strong{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</body></html>", [[tableData objectAtIndex:indexPath.row] text]];

    [popupText loadHTMLString:htmlString baseURL:nil];
    popupDate.text = [[[tableData objectAtIndex:indexPath.row] eventdate] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [[tableData objectAtIndex:indexPath.row] eventdateTo]]];
    NSString * img =@"";
    if (ci==0) {
        img = [[tableData objectAtIndex:indexPath.row] getDot];
    } else{
        img = [[tableData objectAtIndex:indexPath.row] getDot:ci];
    }
    [self addImageScroll:[tableData objectAtIndex:indexPath.row]];
    [popupImg setImage:[UIImage imageNamed:img]];
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [popEvent setFrame:CGRectMake(0,65, 1024, 654)];
    }else
    {
        [popEvent setFrame:CGRectMake(0,65, 768, 910)];
    }
    
    [mainTableView setHidden:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view addSubview:popEvent];
    [popupCloseBtn setHidden:NO];
    [popEvent setContentOffset:CGPointMake(0, -popEvent.contentInset.top) animated:YES];
    
}

//filtering needed events from all

- (IBAction)categorySelect:(id)sender {
    ti=[type selectedSegmentIndex];
    ci=[category selectedSegmentIndex];
    tableData = [FDB fillEventsWithCategory:ci andType:ti andMobile:false];
    [tableView setContentOffset: CGPointZero animated:YES];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (IBAction)closePopupEventView:(id)sender {

[self closeViewsAnimated];
}

-(void)openPopupOutside{
    
    openEvent = [APP_DELEGATE eventTemp];
    popupDate.text = [[HelperDate formatedDate:[openEvent eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[openEvent eventdateTo] ]]];
    NSString * img =@"";
    if (ci==0) {
        img = [openEvent getDot];
    } else{
        img = [openEvent getDot:ci];
    }
    
    [popupImg setImage:[UIImage imageNamed:img]];
    
    [popupTitleLbl setText:[[openEvent title]stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    NSString *htmlString= [HelperString toHtmlEvent:[openEvent text]];
    
    [popupText loadHTMLString:htmlString baseURL:nil];
   
   
    [self addImageScroll:openEvent];
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [popEvent setFrame:CGRectMake(0,65, 1024, 654)];
    }else
    {
        [popEvent setFrame:CGRectMake(0,65, 768, 910)];
    }

    [mainTableView setHidden:YES];
    [mainTableView setTag:CLOSEVIEW];
    [APP_DELEGATE setEventTemp:nil];
    [self.view addSubview:popEvent];
    [popupCloseBtn setHidden:NO];
    [popEvent setContentOffset:CGPointMake(0, -popEvent.contentInset.top) animated:YES];
    
}


-(void)openSettings:(id)sender
{
    [settingsBtn setEnabled:NO];
   
    [popupCloseBtn setHidden:NO];
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 654)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
    }else
    {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 910)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
    }
    settingsController.contentWidth.constant = self.view.frame.size.width;
   
    [settingsView addSubview:settingsController.view];

    if (mainTableView.isHidden) {
        popEvent.hidden=YES;
        popEvent.tag=OPENVIEW;
    }
    else{
        [mainTableView setHidden:YES];
        mainTableView.tag=OPENVIEW;
    }
    settingsView.tag = SETTINGSVIEW;
    [self.view addSubview:settingsView];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
    [settingsView setHidden:NO];
}

- (void) addImageScroll:(FEvent *) showEvent{
    
    openEvent = showEvent;
    int x=0;
    for (UIView *v in eventImagesScroll.subviews) {
        [v removeFromSuperview];
    }
    NSMutableArray *imgs=[openEvent eventImages];
    
    for (int i=0;i<imgs.count;i++){
        //todo dodat da odpira bookmark slike oz slike shranjene na napravi ne iz baze
        NSLog(@"imgs");
        UIImage *img=[UIImage imageWithContentsOfFile: [imgs objectAtIndex:i]];
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(x, 0, 150, 150)]; //size of images in menu--------
        [tmpImg setClipsToBounds:YES];
        x=x+160;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:img forState:UIControlStateNormal];
                [tmpImg setTag:i];
                [tmpImg.imageView setContentMode:UIViewContentModeScaleToFill];
                [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                [eventImagesScroll addSubview:tmpImg];
            });
            
        });
    }
    if (imgs.count>0) {
        [eventImagesScroll setContentSize:CGSizeMake(160*(imgs.count)-10, 180)];
        [eventImagesScroll setContentOffset:CGPointZero animated:YES];
        self.scrollViewHeight.constant=180;
        self.scrollViewBottomSpace.constant=15;
        [eventImagesScroll setHidden:NO];
    } else{
        self.scrollViewHeight.constant=0;
        self.scrollViewBottomSpace.constant=0;
        [eventImagesScroll setHidden:YES];
        [eventImagesScroll setContentSize:CGSizeMake(0, 0)];
    }

    
    [eventImagesScroll setContentOffset:CGPointZero animated:YES];
}
-(IBAction)openGallery:(id)sender
{
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self photoAtIndex:[sender tag]];
    [self presentViewController:photoPagesController animated:YES completion:nil];
}

#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < [openEvent eventImages].count){
        return YES;
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            image = [UIImage imageWithContentsOfFile:[openEvent eventImages][index]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                handler(image);
            });
        });
        
        
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
attributedCaptionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSAttributedString *))handler{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSString *))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        FImage *photo = [UIImage imageWithContentsOfFile:[openEvent eventImages][index]];
        
        
        //        handler(@[photo.description]);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index{}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index{}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index{}

#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
 shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
   return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    return NO;
}




- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return NO;
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
    if (beforeOrient!=[APP_DELEGATE currentOrientation]) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    }
}

#pragma mark webView

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    self.webViewHeight.constant = frame.size.height;

}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


-(void)getEventsFromDB
{
    NSMutableArray *events=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Events ORDER BY title ASC"]];
    while([results next]) {
        FEvent *f=[[FEvent alloc] initWithDictionary:[results resultDictionary]];
        [events addObject:f];
        
    }
    
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    tableData = [events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [df dateFromString:[(FEvent*)a eventdate]];
        NSDate *second = [df dateFromString:[(FEvent*)b eventdate]];
        return [first compare:second];
    }];
    
    [APP_DELEGATE setEventArray:tableData];
}

#pragma mark closeEvent

-(IBAction)closeEvent:(UISwipeGestureRecognizer *)recognizer {
    [self closeViewsAnimated];
}



- (void)closeOnTabEvent:(NSNotification *)n {
    [self closeViewsAnimated];
}

-(void) closeViewsAnimated{
    
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    if (settingsView.tag==SETTINGSVIEW) {
        [UIView animateWithDuration:0.3 animations:^{
            [mainTableView setHidden:NO];
            CGRect newFrame = settingsView.frame;
            newFrame.origin.x += self.view.frame.size.width;
            settingsView.frame = newFrame;
            
        } completion:^(BOOL finished) {
            settingsView.tag=CLOSEVIEW;
            [settingsView removeFromSuperview];
            CGRect newFrame = settingsView.frame;
            newFrame.origin.x -= self.view.frame.size.width;
            settingsView.frame = newFrame;
            [settingsView setHidden:YES];
        }];
        
        
    }
    if (popEvent.tag==OPENVIEW) {
        popEvent.hidden=NO;
        popEvent.tag=CLOSEVIEW;
        
    } else{
        [UIView animateWithDuration:0.3 animations:^{
            [mainTableView setHidden:NO];
            CGRect newFrame = popEvent.frame;
            newFrame.origin.x += self.view.frame.size.width;
            popEvent.frame = newFrame;
            [popupCloseBtn setHidden:YES];
        } completion:^(BOOL finished) {
            [popEvent removeFromSuperview];
            [popupCloseBtn setHidden:YES];
        }];
    }
    
    [settingsBtn setEnabled:YES];
}


@end

#import "FFavoriteViewController.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "FCaseCategory.h"
#import "NSString+HTML.h"
#import "FUpdateContent.h"
#import "FImage.h"
#import "FMedia.h"
#import "FAuthor.h"
#import "FGalleryViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "FMainViewController.h"
#import "FSettingsViewController.h"
#import "FGalleryCollectionViewCell.h"
#import "FDownloadManager.h"
#import "FFeaturedViewController_iPad.h"
#import "HelperString.h"
#import "FDB.h"
#import "FMediaManager.h"
#import "FGoogleAnalytics.h"
#import "FIPDFViewController.h"
#import "HelperBookmark.h"


@interface FFavoriteViewController ()
{
    int numberOfSpaces;//between texts introduction, procedure ...
    int success;
    int numberOfImages;
    int rotate;
    BOOL caseClose;
    BOOL pdfClose;
    BOOL disclaimerClose;
    BOOL showGallery;
    BOOL videoFromCase;
    FSettingsViewController *settingsController;
    UIPanGestureRecognizer *swipeRecognizerB;
    NSMutableArray *imagesList;
    FIPDFViewController *pdfViewController;
}

@property (nonatomic, strong)UIImage *defaultVideoImage;
@end

@implementation FFavoriteViewController
@synthesize currentCase;
@synthesize prevCase;
@synthesize flagCarousel;
@synthesize popover;
@synthesize popupCloseBtn;
@synthesize caseView;
@synthesize mediaArray;
@synthesize showView;
@synthesize helpContent;
@synthesize helpScrollView;
@synthesize helpTitle;
@synthesize helpView;
@synthesize lastOpenedFavoriteVC;
@synthesize contentsVideoModeCollectionView;

#define OPENVIEW 1000
#define CLOSEVIEW 0

static NSString * const reuseIdentifier = @"FGalleryCollectionViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setTitle:NSLocalizedString(@"FAVORITESTABTITLE", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"favorites.png"]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    //feedback
    [feedbackBtn addTarget:APP_DELEGATE action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    //search
    FSearchViewController *searchVC=[[FSearchViewController alloc] init];
    [searchVC setParent:self];
    popover=[[UIPopoverController alloc] initWithContentViewController:searchVC];
    
    isExpanded=NO;
    
    //video collection view
    [self.contentsVideoModeCollectionView setBackgroundColor:[UIColor whiteColor]];
    [contentVideoModeView setHidden:YES];
    [self.contentsVideoModeCollectionView registerClass:[FGalleryCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [caseView setTag:OPENVIEW];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabBookmarks:)
                                                 name:@"CloseOnTabBookmarks"
                                               object:nil];
    
    settingsController = [APP_DELEGATE settingsController];
    
    imagesList = [[NSMutableArray alloc] init];
    
    if ([FCommon isOrientationLandscape]) {
        [exCaseView setFrame:CGRectMake(0,65, 1024, 655)];
    }
    else
    {
        [exCaseView setFrame:CGRectMake(0,65, 768, 909)];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"favorites_red.png"]];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    if (!exCaseView.isHidden) {
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@",[currentCase caseID] ]];
        while([results next]) {
            currentCase.bookmark = [results stringForColumn:@"isBookmark"];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [FGoogleAnalytics writeGAForItem:nil andType:GAFAVORITETABINT];
    
    mediaArray = [FDB getAllFavoritesForUser];
    
    [self.contentsVideoModeCollectionView reloadData];
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    [APP_DELEGATE setFavoriteController:self];
    
    if (!videoFromCase) {
        [self openContentWithTitle:NSLocalizedString(@"FAVORITESTABTITLE", nil)];
    }
    videoFromCase = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    flagCarousel=NO;
    [self.tabBarItem setImage:[UIImage imageNamed:@"favorites_grey.png"]];
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

#pragma mark - Showing gallery
-(void)openContentWithTitle:(NSString *)title
{
    mediaArray = [FDB getAllFavoritesForUser];
    if (mediaArray.count > 0) {
        [cvTitleLbl setText:title];
        if ([FCommon isOrientationLandscape])
            [contentVideoModeView setFrame:CGRectMake(0,65, 1024, 650)];
        else
            [contentVideoModeView setFrame:CGRectMake(0,65, 768, 909)];
        [popupCloseBtn setHidden:YES];
        [contentVideoModeView setTag:OPENVIEW];
        [caseView setTag:CLOSEVIEW];
        [helpView setTag:CLOSEVIEW];
        if (contentVideoModeView.isHidden) {
            [self.contentsVideoModeCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.view addSubview:contentVideoModeView];
            [contentVideoModeView setHidden:NO];
        }
        [self.contentsVideoModeCollectionView reloadData];
        [caseView setHidden:YES];
        [helpView setHidden:YES];
        [fotonaImg setHidden:YES];
    } else{
        [caseView setHidden:NO];
        [contentVideoModeView setHidden:YES];
        [contentVideoModeView removeFromSuperview];
        [fotonaImg setHidden:NO];
    }
}


#pragma mark - UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FItemFavorite *item = mediaArray[indexPath.row];
    FGalleryCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setIndex:indexPath];
    [cell setParentIpad:self];
    [cell setItem:item];
    
    if ([[item typeID] intValue] == BOOKMARKCASEINT) {
        FCase *caseToShow = [FDB getCaseWithID:[item itemID]];
        [cell setContentForCase:caseToShow];
        return cell;
    } else {
        if ([[item typeID] intValue] == BOOKMARKVIDEOINT || [[item typeID] intValue] == BOOKMARKPDFINT) {
            [cell setContentForFavorite:item forColectionView:collectionView onIndex:indexPath];
            return cell;
        }
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FItemFavorite *item = mediaArray[indexPath.row];
    if (((FGalleryCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath]).enabled) {
        switch ([[item typeID] intValue]) {
            case BOOKMARKCASEINT:
                [self openCaseWithID:[item itemID]];
                break;
            case BOOKMARKVIDEOINT:
            case BOOKMARKPDFINT:
                [self openMedia:[item itemID]  andType:[item typeID]];
                break;
            default:
                break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([FCommon isOrientationLandscape]){
        return CGSizeMake(440, 192);
    }
    else
        return CGSizeMake(330, 144);
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mediaArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - Media

-(void)openMedia:(NSString *)mediaID  andType:(NSString *)mediaType{
    FMedia *media = [FDB getMediaWithId:mediaID andType:mediaType];
    if ([[media mediaType] intValue] == [MEDIAVIDEO intValue]) {
        [FCommon playVideo:media onViewController:self isFromCoverflow:NO];
    } else {
        if ([[media mediaType] intValue] == [MEDIAPDF intValue]) {
            [self openPDF:media];
        }
    }
}



-(void) openPDF:(FMedia *)pdf{
    
    if (pdfViewController == nil) {
        pdfViewController = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"pdfViewController"];
    }
    [pdfViewController.view setTag:OPENVIEW];
    if ([FCommon isOrientationLandscape])
        [pdfViewController.view setFrame:CGRectMake(0,65, 1024, 650)];
    else
        [pdfViewController.view setFrame:CGRectMake(0,65, 768, 909)];
    pdfViewController.ipadFotonaParent = nil;
    pdfViewController.ipadFavoriteParent = self;
    pdfViewController.pdfMedia = pdf;
    [popupCloseBtn setHidden:NO];
    lastOpenedFavoriteVC = pdfViewController;
    [self.view  addSubview:pdfViewController.view];
}

#pragma mark - Settings

- (IBAction)openSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    [self.settingsBtn setEnabled:NO];
    [popupCloseBtn setHidden:NO];
    [settingsView addSubview:settingsController.view];
    
    if ([FCommon isOrientationLandscape]) {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 654)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
    }else
    {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 910)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
    }
    settingsController.contentWidth.constant = self.view.frame.size.width;
    
    [settingsView addSubview:settingsController.view];
    if (caseView.tag==OPENVIEW) {
        [caseView setHidden:YES];
    } else {
        if (pdfViewController.view.tag==OPENVIEW) {
            [pdfViewController.view setHidden:YES];
        }
    }
    [contentVideoModeView setHidden:YES];
    [helpView setHidden:YES];
    [self.view addSubview:settingsView];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
    [settingsView setHidden:NO];
}

- (IBAction)closeSettings:(id)sender {
    caseClose = NO;
    pdfClose = NO;
    disclaimerClose = NO;
    showGallery = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (caseView.tag==OPENVIEW) {
            if (caseView.isHidden) {
                caseView.hidden=NO;
                showGallery = NO;
            } else {
                caseClose = YES;
            }
        } else{
            
            if (pdfViewController.view.tag==OPENVIEW) {
                if (pdfViewController.view.isHidden) {
                    pdfViewController.view.hidden=NO;
                    showGallery = NO;
                } else {
                    pdfClose = YES;
                }
                
            } else{
                if (helpView.tag==OPENVIEW) {
                    if (helpView.isHidden) {
                        helpView.hidden=NO;
                        showGallery = NO;
                    } else {
                        disclaimerClose = YES;
                    }
                    
                }
            }
        }
        if (caseClose || pdfClose ) {
            [popupCloseBtn setHidden:YES];
            [contentVideoModeView setTag:OPENVIEW];
        }
    } completion:^(BOOL finished) {
        if (pdfClose) {
            [lastOpenedFavoriteVC.view removeFromSuperview];
            lastOpenedFavoriteVC = nil;
        } else {
            if (caseClose) {
                [exCaseView removeFromSuperview];
                [contentVideoModeView setHidden:NO];
                [caseView setHidden:YES];
            } else {
                if (disclaimerClose) {
                    [helpView setHidden:YES];
                    [caseView setHidden:NO];
                    [helpView removeFromSuperview];
                    [helpView setTag:CLOSEVIEW];
                    [caseView setTag:OPENVIEW];
                }
            }
        }
        if (showGallery) {
            [contentVideoModeView setHidden:disclaimerClose];
        }
        [settingsView removeFromSuperview];
        [self.settingsBtn setEnabled:YES];
        [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
        [settingsView setHidden:YES];
    }];
    
}


#pragma mark - Case

-(void)openCaseWithID:(NSString *)caseID
{
    [popupCloseBtn setHidden:NO];
    [caseView setTag:OPENVIEW];
    NSString *usr = [FCommon getUser];
    
    [caseScroll removeGestureRecognizer:swipeRecognizerB];
    
    BOOL bookmarked = NO;
    [caseScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=0 and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:usr, currentCase.caseID, nil]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@",caseID]];
    while([results next]) {
        currentCase = [[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
    }
    
    if ([FDB checkIfFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE]) {
        [removeFavorite setHidden:NO];
        [addToFavorite setHidden:YES];
    } else {
        [removeFavorite setHidden:YES];
        [addToFavorite setHidden:NO];
    }
    
    if ([FDB checkIfBookmarkedForDocumentID:[currentCase caseID]  andType:BOOKMARKCASE]){//[[currentCase bookmark] boolValue]) {
        [addBookmarks setHidden:YES];
        [removeBookmarks setHidden:NO];
    } else{
        if ([ConnectionHelper connectedToInternet]) {
            [addBookmarks setHidden:NO];
        } else {
            [addBookmarks setHidden:YES];
        }
        [removeBookmarks setHidden:YES];
    }


    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if (![currentCase isEqual:prevCase]) {
        NSLog(@"%@",currentCase.coverTypeID);
        [tableParameters setHidden:YES];
        [fotonaImg setHidden:YES];
        [caseScroll addSubview:exCaseView];
        
        [self.view bringSubviewToFront:header];
        [images setImage:nil forState:UIControlStateNormal];
        [videos setImage:nil forState:UIControlStateNormal];
        for (UIView *v in imagesScroll.subviews) {
            [v removeFromSuperview];
        }
        
        
        for (UIView *v in additionalInfo.subviews) {
            [v setFrame:CGRectMake(38, 0, v.frame.size.width, 0)];
            if ([v isKindOfClass:[FDLabelView class]]) {
                [(FDLabelView *)v setText:@""];
            }
        }
    }
    
    flagParameters=NO;
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
    [additionalInfo setFrame:CGRectMake(0, additionalInfo.frame.origin.y, self.view.frame.size.width, 231)];
    if (![currentCase isEqual:prevCase]) {
        [caseScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    numberOfSpaces=0;
    [self setCaseOutlets];
    [self setPatameters];
    [self setPrevCase:currentCase];
    [exCaseView setHidden:NO];
    
    
   }

-(void)setCaseOutlets
{
    [FGoogleAnalytics writeGAForItem:[currentCase title] andType:GACASEINT];
    if (![currentCase isEqual:prevCase]) {
        for (UIView *v in additionalInfo.subviews) {
            if ([v isKindOfClass:[FDLabelView class]]) {
                [v removeFromSuperview];
            }
        }
    }
    
    authorImg.layer.cornerRadius = authorImg.frame.size.height /2;
    authorImg.layer.masksToBounds = YES;
    authorImg.layer.borderWidth = 0;
    
    [authorImg setImage: [FDB getAuthorImage:[currentCase authorID]]];
    [authorNameLbl setText:[currentCase name]];
    [dateLbl setText:[APP_DELEGATE timestampToDateString:[currentCase date]]];
    [titleLbl setText:[currentCase title]];
    [titleLbl setNumberOfLines:0];
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        if(caseTittleFlag==0)
        {
            caseTittleFlag=1;
            
        }
    }
    
    NSString * title = @"";
    NSMutableAttributedString *allAdditionalInfo=[[NSMutableAttributedString alloc] init];
    NSString *check=[[currentCase introduction] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase introduction] && ![check isEqualToString:@""]) {
        [introductionTitle setHidden:NO];
        
        
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<p>Introduction</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        numberOfSpaces++;
        
        [introductionTitle setFrame:CGRectMake(38, 15, self.view.frame.size.width-76, 0)];
        [introductionTitle setNumberOfLines:0];
        [introductionTitle setTextAlignment:NSTextAlignmentJustified];
        
        NSString *htmlString=[currentCase introduction];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        title = @"<br/><br/>";
        
    }
    
    
    
    check=[[currentCase procedure] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase procedure] && ![check isEqualToString:@""]) {
        
        numberOfSpaces++;
        
        title =[title stringByAppendingString:@"<br/><p>Procedure</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        NSString *htmlString=[currentCase procedure];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
    }
    
    
    
    check=[[currentCase results] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase results] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        title =[title stringByAppendingString:@"<br/><p>Results</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[currentCase results];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
    }
    
    check=[[currentCase references] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase references] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        title =[title stringByAppendingString:@"<br/><p>References</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[currentCase references];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
        
    }
    
    //DISCLAMER
    numberOfSpaces++;
    title =[title stringByAppendingString:@"<br/><p>Disclamer</p><br/>"];
    NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
    [allAdditionalInfo appendAttributedString:titleAttrStr];
    
    //[self getDisclamer:true]
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerShort"]  dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:10];
    [style setAlignment:NSTextAlignmentJustified];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, attrStr.length)];
    [allAdditionalInfo appendAttributedString:attrStr];
    
    numberOfSpaces++;
    
    
    introductionTitle.attributedText=allAdditionalInfo;
    [introductionTitle sizeToFit];
    
    //[additionalInfo setFrame:CGRectMake(introductionTitle.frame.origin.x,introductionTitle.frame.origin.y, introductionTitle.frame.size.width,introductionTitle.frame.size.height+125)];
    
    if ([additionalInfo isHidden]) {
        [additionalInfo setHidden:NO];
    }
    
    
    int x=0;
    if (![currentCase isEqual:prevCase]) {
        NSMutableArray *vidArr= [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            vidArr=[currentCase getVideos];
        } else{
            vidArr = [currentCase video];
        }
        for (int i=0;i<[vidArr count];i++) {
            FMedia *vid=[vidArr objectAtIndex:i];
            UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
            [tmpImg setFrame:CGRectMake(x, 0, 200, 200)];
            [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:NO];
            x=x+210;
            
            dispatch_queue_t queue = dispatch_queue_create("Video queue", NULL);
            dispatch_async(queue, ^{
                //code to be executed in the background
                NSURL *videoURL;
                NSString *localPath = [FMedia createLocalPathForLink:vid.path andMediaType:MEDIAVIDEO];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                    videoURL= [NSURL URLWithString:vid.path] ;
                }else{
                    videoURL=[NSURL fileURLWithPath:localPath];
                }
                
                AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
                AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                generate1.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                CMTime time = CMTimeMakeWithSeconds([vid.time integerValue], 1);
                CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
                UIImage *image=one;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //code to be executed on the main thread when background task is finished
                    [tmpImg setImage:image forState:UIControlStateNormal];
                    [tmpImg setTag:i];
                    [tmpImg addTarget:self action:@selector(openVideo:) forControlEvents:UIControlEventTouchUpInside];
                    [imagesScroll addSubview:tmpImg];
                    UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(x-210, 200, 190, 20)];
                    [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                    [videoName setText:vid.title];
                    [videoName setTextAlignment:NSTextAlignmentCenter];
                    [imagesScroll addSubview:videoName];
                });
            });
        }
        
        int xS=210*(int)[vidArr count];
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            imgs=[currentCase getImages];
        } else{
            imgs = [currentCase images];
        }
        
        
        for (int i=0;i<imgs.count;i++){
            FImage *img=[imgs objectAtIndex:i];
            UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
            [tmpImg setFrame:CGRectMake(xS, 0, 200, 200)];
            [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:YES];
            xS=xS+210;
            dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
            dispatch_async(queue, ^{
                //code to be executed in the background
                UIImage *image;
                NSString *pathTmp = [FMedia createLocalPathForLink:img.path andMediaType:MEDIAIMAGE];
                if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                    
                }else{
                    image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL URLWithString:pathTmp]]];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    //code to be executed on the main thread when background task is finished
                    [tmpImg setImage:image forState:UIControlStateNormal];
                    [tmpImg setTag:i];
                    [tmpImg addTarget:self action:@selector(openGalleryCase:) forControlEvents:UIControlEventTouchUpInside];
                    [imagesScroll addSubview:tmpImg];
                    UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(xS-210, 200, 190, 20)];
                    [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                    [videoName setText:img.title];
                    [videoName setTextAlignment:NSTextAlignmentCenter];
                    [imagesScroll addSubview:videoName];
                });
                
            });
        }
        if ((imgs.count>0) || ([vidArr count]>0)) {
            [imagesScroll setHidden:NO];
            [imagesScroll setContentSize:CGSizeMake(210*(imgs.count+vidArr.count)-10, 230)];
            [imagesScroll setContentOffset:CGPointZero animated:YES];
            [galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 230)];
            
        } else{
            [galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 0)];
            [imagesScroll setHidden:YES];
            [imagesScroll setContentSize:CGSizeMake(0, 0)];
        }
    }
}

-(void)setPatameters
{
    if (![currentCase isEqual:prevCase]) {
        for (UIView *v in parametersScrollView.subviews) {
            if ([v isKindOfClass:[UILabel class]]) {
                [v removeFromSuperview];
            }        }
        for (UIView *v in tableParameters.subviews) {
            if ([v isKindOfClass:[UILabel class]] || v.tag==100) {
                [v removeFromSuperview];
            }
        }
    }
    
    int allDataCount=0;
    int allDataObjectAtIndex0Count=0;
    
    int y=0;
    if (currentCase.parameters && currentCase.parameters != (id)[NSNull null] && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=0 && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=3) {
        NSArray*allData=[NSJSONSerialization JSONObjectWithData:[currentCase.parameters dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        
        NSMutableArray *allDataM=[allData mutableCopy];
        //        if (allDataM.count<5) {
        [expandBtn setHidden:YES];
        //        }
        
        int j=0;
        //        int tableheight=0;
        for (NSArray *arr in allDataM){
            int x=0;
            int rowHeight=0;
            //            int rowWidth=200;
            for (int i=0; i<arr.count; i++) {
                NSString *htmlString=[arr objectAtIndex:i];
                NSString *s=htmlString;
                if ([htmlString rangeOfString:@"cm&sup2;"].location!=NSNotFound) {
                    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                    s=[attrStr string];
                }
                
                if (i==0) {
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(38, y, 200, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
                    [lbl setTextColor:[UIColor colorWithRed:73.0/255.0 green:73.0/255 blue:73.0/255.0 alpha:1.0]];
                    [lbl setText:s];
                    lbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
                    [lbl setNumberOfLines:0];
                    
                    lbl.fdTextAlignment=FDTextAlignmentLeft;
                    lbl.fdLabelFitAlignment = FDLabelFitAlignmentTop;
                    lbl.lineHeightScale = 1.00;
                    
                    lbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
                    lbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
                    [lbl setLineBreakMode:NSLineBreakByTruncatingTail];
                    
                    if(j==0)
                    {
                        [lbl setTextColor:[UIColor whiteColor]];
                    }
                    if (rowHeight<lbl.frame.size.height) {
                        rowHeight=lbl.frame.size.height;
                    }
                    [tableParameters addSubview:lbl];
                    
                }else{
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(x, y, 160, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
                    [lbl setText:s];
                    
                    lbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
                    [lbl setNumberOfLines:0];
                    
                    lbl.fdTextAlignment=FDTextAlignmentLeft;
                    lbl.fdLabelFitAlignment = FDLabelFitAlignmentTop;
                    lbl.lineHeightScale = 1.00;
                    [lbl setLineBreakMode:NSLineBreakByTruncatingTail];
                    
                    lbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
                    lbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
                    
                    if(j==0)
                    {
                        lbl.contentInset = UIEdgeInsetsMake(10.0, 0.0, 6.0, 0.0);
                        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
                        [lbl setTextColor:[UIColor whiteColor]];
                    }
                    if (rowHeight<lbl.frame.size.height) {
                        rowHeight=lbl.frame.size.height;
                    }
                    [UIView beginAnimations:@"expand" context:nil];
                    [UIView setAnimationDuration:0.4];
                    [UIView setAnimationDelegate:self];
                    [parametersScrollView addSubview:lbl];
                    [UIView commitAnimations];
                    x+=167;
                }
                
            }
            y+=rowHeight;
            if (j>0) {
                UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 0.5)];
                [line setBackgroundColor:[UIColor lightGrayColor]];
                [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [line setTag:100];
                [tableParameters addSubview:line];
            }else
            {
                [headerTableParameters setFrame:CGRectMake(0, 0, self.view.frame.size.width, rowHeight)];
            }
            j++;
        }
        
        allDataCount=(int)[allData count];
        allDataObjectAtIndex0Count=(int)[[allData objectAtIndex:0] count];
    }
    
    [tableParameters setHidden:NO];
    
    if (allDataCount>0) {
        [tableParameters setFrame:CGRectMake(tableParameters.frame.origin.x, tableParameters.frame.origin.y, tableParameters.frame.size.width, y+40)];
    }
    else
    {
        [tableParameters setFrame:CGRectMake(tableParameters.frame.origin.x, tableParameters.frame.origin.y, tableParameters.frame.size.width, 0)];
    }
    [parametersScrollView setFrame:CGRectMake(parametersScrollView.frame.origin.x, parametersScrollView.frame.origin.y, parametersScrollView.frame.size.width, y)];
    if (allDataCount>0) {
        [parametersConteiner setFrame:CGRectMake(parametersConteiner.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height+40, parametersConteiner.frame.size.width, tableParameters.frame.size.height)];
    }else
    {
        [parametersConteiner setFrame:CGRectMake(parametersConteiner.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height, parametersConteiner.frame.size.width, 0)];
    }
    
    
    [parametersScrollView setContentSize:CGSizeMake(167*(allDataObjectAtIndex0Count-1), tableParameters.frame.size.height-40)];
    //setting the size of image gallery
    if (galleryView.frame.size.height>0) {
        [galleryView setFrame:CGRectMake(0, parametersConteiner.frame.origin.y+parametersConteiner.frame.size.height+20, self.view.frame.size.width, 230)];
    } else {
        [galleryView setFrame:CGRectMake(0, parametersConteiner.frame.origin.y+parametersConteiner.frame.size.height, self.view.frame.size.width, 0)];
    }
    
    [self setContentSize];
    
}

-(void)setContentSize
{
    [imagesScroll setFrame:CGRectMake(imagesScroll.frame.origin.x, imagesScroll.frame.origin.y, self.view.frame.size.width-76, imagesScroll.frame.size.height)];
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
    [additionalInfo setFrame:CGRectMake(0, 658, self.view.frame.size.width, 231)];
    [introductionTitle sizeToFit];
    float additionalInfoH=introductionTitle.frame.size.height+100;
    
    [additionalInfo setFrame:CGRectMake(additionalInfo.frame.origin.x, galleryView.frame.origin.y+galleryView.frame.size.height+20, self.view.frame.size.width,additionalInfoH)];
    [disclaimerBtn setHidden:NO];
    if ([FCommon isOrientationLandscape]) {
        [disclaimerBtn setFrame:CGRectMake(225, introductionTitle.frame.size.height-15, 99, 40)];
    }else
    {
        [disclaimerBtn setFrame:CGRectMake(480, introductionTitle.frame.size.height-15, 99, 40)];
    }
    
    [additionalInfo addSubview:disclaimerBtn ];
    [exCaseView setFrame:CGRectMake(0, 0, self.view.frame.size.width, additionalInfo.frame.origin.y+additionalInfo.frame.size.height)];
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
    
    [contentVideoModeView setHidden:YES];
    [caseView setTag:OPENVIEW];
    [caseView setHidden:NO];
    [helpView setTag:CLOSEVIEW];
    [helpView setHidden:YES];
}


- (IBAction)removeFromBookmarks:(id)sender {
    
    [removeBookmarks setHidden:YES];
    if ([ConnectionHelper connectedToInternet]) {
        [addBookmarks setHidden:NO];
    } else {
        [addBookmarks setHidden:YES];
    }
    [HelperBookmark removeBookmarkedCase:currentCase];
}

- (IBAction)addToBookmarks:(id)sender {
    if ([ConnectionHelper getWifiOnlyConnection]) {
        [self bookmarkCase];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:self.view];
    }
}

- (void) refreshBookmarkBtn  {
    [addBookmarks setHidden:YES];
    [removeBookmarks setHidden:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex > -1) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"OK"]) {
            [self bookmarkCase];
        }
        if ([buttonTitle isEqualToString:NSLocalizedString(@"CHECKWIFIONLYBTN", nil)]) {
            [ConnectionHelper setWifiOnlyConnection:TRUE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
            //            [ wifiSwitch setOn:YES animated:YES];
            [self bookmarkCase];
        }
    }
}

-(void) bookmarkCase{
    if([ConnectionHelper connectedToInternet] || [[currentCase coverflow] boolValue]){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"BOOKMARKING", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"BOOKMARKING", nil)]) {
        [HelperBookmark bookmarkCase:currentCase];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    }
}


- (IBAction)addToFavorite:(id)sender {
    [FDB addTooFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE];
    [removeFavorite setHidden:NO];
    [addToFavorite setHidden:YES];
    [self refreshCollection];
}

- (IBAction)removeFavorite:(id)sender {
    [FDB removeFromFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE];
    [removeFavorite setHidden:YES];
    [addToFavorite setHidden:NO];
    [self refreshCollection];
}


-(void)expand:(id)sender
{
    flagParameters=!flagParameters;
    [self setPatameters];
}


-(IBAction)openVideo:(id)sender
{
    videoFromCase = YES;
    FMedia *vid=[[currentCase getVideos] objectAtIndex:[sender tag]];
    BOOL coverflow = [[currentCase coverflow] isEqualToString:@"1"] ? YES : NO;
    [FCommon playVideo:vid onViewController:self isFromCoverflow:coverflow];
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
    if(index <imagesList.count){ //[currentCase getImages].count){//TODO P
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
        FImage *img =[imagesList objectAtIndex:index];
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            NSString *pathTmp = [NSString stringWithFormat:@"%@%@",docDir,img.localPath];
            if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                
            }else{
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL fileURLWithPath:pathTmp]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                handler(image);
            });
        });
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
attributedCaptionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSAttributedString *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        DEMOPhoto *photo = self.photos[index];
    //        if(self.simulateLatency){
    //            sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //        }
    //
    //        handler(photo.attributedCaption);
    //    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        FImage *photo = [imagesList objectAtIndex:index];
        
        if (![photo.description isEqualToString:@""]) {
            NSMutableAttributedString *mutString=[[NSMutableAttributedString alloc] initWithData:[[NSString stringWithFormat:@"%@<br/>%@",photo.title,photo.description] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            handler([mutString string]);
        }else{
            handler(photo.title);
        }
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        FImage *photo = [currentCase getImages][index];
    //
    ////        handler(photo.description);
    //    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        DEMOPhoto *photo = self.photos[index];
    //        if(self.simulateLatency){
    //            sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //        }
    //
    //        handler(photo.tags);
    //    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        FImage *photo = [imagesList objectAtIndex:index];
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler
{
    //    DEMOPhoto *photo = self.photos[index];
    //    if(self.simulateLatency){
    //        sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //    }
    //
    //    handler(photo.comments.count);
}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index
{
    //    DEMOPhoto *photo = self.photos[index];
    //    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    //    [remainingComments removeObject:deletedComment];
    //    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    DEMOPhoto *photo = self.photos[index];
    //    NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:photo.tags];
    //    id<EBPhotoTagProtocol> tagData = [tagPopover dataSource];
    //    [remainingTags removeObject:tagData];
    //    [photo setTags:[NSArray arrayWithArray:remainingTags]];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    //    NSLog(@"Delete photo at index %li", (long)index);
    //    DEMOPhoto *deletedPhoto = self.photos[index];
    //    NSMutableArray *remainingPhotos = [NSMutableArray arrayWithArray:self.photos];
    //    [remainingPhotos removeObject:deletedPhoto];
    //    [self setPhotos:remainingPhotos];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo
{
    //    NSLog(@"add new tag %@", tagText);
    //
    //    DEMOPhoto *photo = self.photos[index];
    //
    //    DEMOTag *newTag = [DEMOTag tagWithProperties:@{
    //                                                   @"tagPosition" : [NSValue valueWithCGPoint:tagLocation],
    //                                                   @"tagText" : tagText}];
    //
    //    NSMutableArray *mutableTags = [NSMutableArray arrayWithArray:photo.tags];
    //    [mutableTags addObject:newTag];
    //
    //    [photo setTags:[NSArray arrayWithArray:mutableTags]];
    
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index
{
    //    DEMOComment *newComment = [DEMOComment
    //                               commentWithProperties:@{@"commentText": comment,
    //                                                       @"commentDate": [NSDate date],
    //                                                       @"authorImage": [UIImage imageNamed:@"guestAv.png"],
    //                                                       @"authorName" : @"Guest User"}];
    //    [newComment setUserCreated:YES];
    //
    //    DEMOPhoto *photo = self.photos[index];
    //    [photo addComment:newComment];
    //
    //    [controller setComments:photo.comments forPhotoAtIndex:index];
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
    if (beforeOrient!=[APP_DELEGATE currentOrientation]) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [self setContentSize];
        [UIView commitAnimations];
    }
}


#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    //        return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledTagging){
    //        return NO;
    //    }
    
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
 shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    //We assume all comment objects used in the demo are of type DEMOComment
    //    DEMOComment *demoComment = (DEMOComment *)comment;
    //
    //    if(demoComment.isUserCreated){
    //        //Demo user can only delete his or her own comments.
    //        return YES;
    //    }
    //
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    //        return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledCommenting){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledActivities){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledMiscActions){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledDelete){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledDeleteForTags){
    //        return NO;
    //    }
    //
    //    return YES;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    if(index > 0){
    //        return YES;
    //    }
    //
    //    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return NO;
}


#pragma mark - Disclaimer

- (IBAction)showDisclaimer:(id)sender {
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [helpView setFrame:CGRectMake(0, 65, 1024, 650)];
        [helpScrollView setFrame:CGRectMake(0, 0, 1024, 650)];
    }else
    {
        [helpView setFrame:CGRectMake(0, 65, 768, 909)];
        [helpScrollView setFrame:CGRectMake(0, 0, 768, 909)];
    }
    [helpView setTag:OPENVIEW];
    [caseView setTag:CLOSEVIEW];
    [contentVideoModeView setTag:CLOSEVIEW];
    [self.view  addSubview:helpView];
    [caseView setHidden:YES];
    [helpView setHidden:NO];
    [contentVideoModeView setHidden:YES];
    [helpTitle setText:@"Disclaimer"];
    
    helpContent.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.00];
    helpContent.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    helpContent.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    helpContent.minimumScaleFactor = 0.50;
    helpContent.numberOfLines = 0;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [helpContent setText:attrStr.string];
    helpContent.shadowColor = nil; // fill your color here
    helpContent.shadowOffset = CGSizeMake(0.0, -1.0);
    helpContent.lineHeightScale = 1.00;
    helpContent.fixedLineHeight = 24.00;
    helpContent.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
    helpContent.fdAutoFitMode=FDAutoFitModeAutoHeight;
    helpContent.fdTextAlignment=FDTextAlignmentJustify;
    helpContent.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    helpContent.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    [helpScrollView setContentSize:CGSizeMake(768, helpContent.frame.origin.y+helpContent.frame.size.height+20)];
}

- (void)closeOnTabBookmarks:(NSNotification *)n {
    exCaseView.hidden=YES;
    helpView.hidden = YES;
    if (pdfViewController != nil) {
        [pdfViewController.view removeFromSuperview];
    }
    [self openContentWithTitle:NSLocalizedString(@"FAVORITESTABTITLE", nil)];
}

#pragma mark - Rest

-(IBAction)logout:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation!=UIInterfaceOrientationPortrait) {
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 654)];
    }else{
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 910)];
    }
    [settingsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!self.viewDeckController.leftController.view.isHidden) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
        fotonaImg.frame = newFrame;
    }
    
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else{
        [APP_DELEGATE setCurrentOrientation:0];
    }
    
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    [APP_DELEGATE rotatePopupSearchedNewsInView:self.view];
    
    if (currentCase) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [self setContentSize];
        [UIView commitAnimations];
    }
    [self.view bringSubviewToFront:[self.view viewWithTag:1000]];
}

-(void)deleteRowAtIndex:(NSIndexPath *) index{
    mediaArray = [FDB getAllFavoritesForUser];
    [contentsVideoModeCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject: index]];
    [self openContentWithTitle:NSLocalizedString(@"FAVORITESTABTITLE", nil)];
}

#pragma mark - Refresh

- (void) refreshCellForMedia:(NSString *)mediaID andMediaType:(NSString *)mediaType{
    if (mediaArray.count >0) {
        for (int i = 0; i<[mediaArray count]; i++){
            FItemFavorite *item = mediaArray[i];
            if ([[item itemID] intValue]== [mediaID intValue] && [[item typeID] intValue] == [mediaType intValue]) {
                NSIndexPath *index = [NSIndexPath  indexPathForItem:i inSection:0];
                [contentsVideoModeCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:index, nil]];
                break;
            }
        }
    }
}

-(void) refreshCollection{
    mediaArray = [FDB getAllFavoritesForUser];
    [contentsVideoModeCollectionView reloadData];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"end");
}



@end

//
//  FFotonaViewController.m
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FFotonaViewController.h"
#import "FMDatabase.h"
#import "MBProgressHUD.h"
#import "FCasebookViewController.h"
#import "FDocument.h"
#import "FFolderViewController.h"
#import "AFNetworking.h"
#import "IIViewDeckController.h"
#import "NSString+HTML.h"
#import "FMedia.h"
#import <AVFoundation/AVFoundation.h>
#import "FSettingsViewController.h"
#import "FDownloadManager.h"
#import "FTabBarController.h"
#import "HelperString.h"
#import "FGoogleAnalytics.h"
#import "FHelperThumbnailImg.h"
#import "FGalleryCollectionViewCell.h"
#import "FDB.h"
#import "FIPDFViewController.h"

@interface FFotonaViewController (){
    bool fotonaHidden;
    UITapGestureRecognizer *fotonaTap;
    int numberOfImages;
    int stateHelper;
    int rotate;
    BOOL direction;
    FSettingsViewController *settingsController;
    float w;
    NSArray *mediaArray;
    NSMutableArray *downloading;
    FIPDFViewController *pdfViewController;
    UIViewController *lastOpenedController;
    BOOL openFromSearch;
    FMedia *mediaFromSearch;
    BOOL enabled;
}

@end

@implementation FFotonaViewController
@synthesize fotonaImg;
@synthesize popover;
@synthesize containerView;
@synthesize videos;
@synthesize item;
@synthesize popupCloseBtn;
@synthesize openVideoGal;
@synthesize cDescription;

//cell identifier
static NSString * const reuseIdentifier = @"FGalleryCollectionViewCell";


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
        [self setTitle:NSLocalizedString(@"FOTONATABTITLE", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"fotona_red.png"]];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //feedback
    [feedbackBtn addTarget:APP_DELEGATE action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    //search
    FSearchViewController *searchVC=[[FSearchViewController alloc] init];
    [searchVC setParent:self];
    popover=[[UIPopoverController alloc] initWithContentViewController:searchVC];
    
    
    
    //video collection view
    [contentsVideoModeCollectionView setBackgroundColor:[UIColor whiteColor]];
    [contentsVideoModeCollectionView registerClass:[FGalleryCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    [self.view setNeedsDisplay];
    stateHelper = 0;
    [self.viewDeckController openLeftView];
    CGRect newFrame = fotonaImg.frame;
    if ([FCommon isOrientationLandscape])
        newFrame.origin.x -= 105;
    else
        newFrame.origin.x -=  160;
    rotate = 1;
    fotonaImg.frame = newFrame;
    direction = TRUE;
    
    //swipe closing menu
    UIPanGestureRecognizer *swipeRecognizerB = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(swipeMenuFotona:)];
    
    [containerView addGestureRecognizer:swipeRecognizerB];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabFotona:)
                                                 name:@"CloseOnTabFotona"
                                               object:nil];
    if (!openVideoGal) {//if nil
        openVideoGal = NO;
    }
    
    settingsController = [APP_DELEGATE settingsController];
    
    if (self.bookmarkMenu == nil) {
        self.bookmarkMenu = [NSMutableDictionary new];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (!settingsView.isHidden && settingsView != nil) {
        [self closeSettings:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait) {
        // Do something when in landscape
        [self.viewDeckController setLeftSize:1024-320];
    }else
    {
        [self.viewDeckController setLeftSize:768-320];
    }
    [contentsVideoModeCollectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    BOOL fimg =self.viewDeckController.leftController.view.isHidden;
    if (!openVideoGal) {
        [self.viewDeckController openLeftView];
    } else{
        [self.viewDeckController closeLeftView];
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
        fotonaImg.frame = newFrame;
    }
    
    [self.viewDeckController setLeftSize:self.view.frame.size.width-320];
    
    if (w!=self.view.frame.size.width) {
        if (!self.viewDeckController.leftController.view.isHidden) {
            CGRect newFrame = fotonaImg.frame;
            newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
            fotonaImg.frame = newFrame;
        }
    }
    
    if (self.viewDeckController.leftController.view.isHidden != fimg) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
        fotonaImg.frame = newFrame;
        rotate = 1;
        direction = TRUE;
    }
    
    openVideoGal = NO;
    
    if (openFromSearch) {
        openFromSearch = NO;
        [self openMediaFromSearch:mediaFromSearch];
    }
    
    [APP_DELEGATE setFotonaController:self];
    
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


-(void)openMenu:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x += rotate * 180;
        rotate = -rotate;
        fotonaImg.frame = newFrame;
        [self.viewDeckController toggleLeftViewAnimated:YES];
        direction = !direction;
        
    } completion:^(BOOL finished) {
    }];
}

-(void) openMediaFromSearch:(FMedia *)media {
    [self closeMenu];
    [fotonaImg setHidden:YES];
    [self openContentWithTitle:@"From search" description:@"" media: [NSMutableArray arrayWithObjects:media, nil] andMediaType:[media mediaType]];
    [self openMedia:media];
}

-(void) setOpenGal:(BOOL)og forMedia:(FMedia *)media
{
    openFromSearch = YES;
    self.openVideoGal = og;
    mediaFromSearch = media;
}


#pragma mark Open

-(void)externalLink:(NSString *)link
{
    if([ConnectionHelper connectedToInternet]){
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
        if (orientation!=UIInterfaceOrientationPortrait){
            [webContentView setFrame:CGRectMake(0, 0, 1024, 653)];
            [webView setFrame:CGRectMake(0, 43, 1024, 610)];
            [webViewToolbar setFrame:CGRectMake(0, -1, 1024, 44)];
        }else
        {
            [webContentView setFrame:CGRectMake(0, 0, 768, 909)];
            [webView setFrame:CGRectMake(0, 43, 768, 866)];
            [webViewToolbar setFrame:CGRectMake(0, -1, 768, 44)];
        }
        
        [webContentView setHidden:NO];
        [webView setHidden:NO];
        [webViewToolbar setHidden:NO];
        
        for (UIView *v in containerView.subviews) {
            [v removeFromSuperview];
        }
        [containerView addSubview:webContentView];
        
        NSURLRequest *req=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[link stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
        [webView setDelegate:self];
        [webView loadRequest:req];
        [self.view bringSubviewToFront:customToolbar];
        
        
    }else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    mediaArray = [NSArray new];
}

-(void)openContentWithTitle:(NSString *)title description:(NSString *)description
{
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [contentVideoModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentsVideoModeCollectionView setFrame:CGRectMake(0, 89, 1024, 564)];
        [webView setFrame:CGRectMake(0, 43, 1024, 610)];
        [webViewToolbar setFrame:CGRectMake(0, -1, 1024, 44)];
    }else
    {
        [contentModeView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentVideoModeView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentsVideoModeCollectionView setFrame:CGRectMake(0, 89, 768, 820)];
        [webView setFrame:CGRectMake(0, 43, 768, 866)];
        [webViewToolbar setFrame:CGRectMake(0, -1, 768, 44)];
    }
    [contentModeView setHidden:NO];
    [contentModeScrollView setHidden:NO];
    [contentVideoModeView setHidden:NO];
    [contentsVideoModeCollectionView setHidden:NO];
    [webView setHidden:NO];
    [webViewToolbar setHidden:NO];
    
    for (UIView *v in containerView.subviews) {
        [v removeFromSuperview];
    }
    [containerView addSubview:contentModeView];
    [cTitleLbl setText:title];
    
    NSString *htmlString=[HelperString toHtml:description];
    [cDescription loadHTMLString:htmlString baseURL:nil];
    
    [self.view bringSubviewToFront:customToolbar];
    
}

-(void)openContentWithTitle:(NSString *)title description:(NSString *)description media:(NSMutableArray *)menuMediaArray andMediaType:(NSString *)mediaType
{
    mediaArray = menuMediaArray;
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [contentVideoModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentsVideoModeCollectionView setFrame:CGRectMake(0, 89, 1024, 564)];
    }else
    {
        [contentModeView setFrame:CGRectMake(0, 0, 750, 909)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentVideoModeView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentsVideoModeCollectionView setFrame:CGRectMake(0, 89, 768, 820)];
    }
    
    
    [contentVideoModeView setHidden:NO];
    [contentModeView setHidden:NO];
    [contentModeScrollView setHidden:NO];
    [contentsVideoModeCollectionView setHidden:NO];
    
    //reload collection with new items
    [contentsVideoModeCollectionView reloadData];
    
    //preload movie images
    numberOfImages = [menuMediaArray count];
    
    for (UIView *v in containerView.subviews) {
        [v removeFromSuperview];
    }
    for (UIView *v in contentVideModeScrollView.subviews) {
        [v removeFromSuperview];
    }

    [containerView addSubview:contentVideoModeView];
    if (mediaArray.count > 0) {
        [FHelperThumbnailImg preloadImage:menuMediaArray mediaType:mediaType forTableView:nil orCollectionView:contentsVideoModeCollectionView onIndex:nil];
    }
    
    [cvTitleLbl setText:title];
    [contentVideModeScrollView addSubview:cvTitleLbl];
    
    if (![description isEqualToString:@""]) {
        cvDescriptionLbl.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.00];
        cvDescriptionLbl.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        cvDescriptionLbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        cvDescriptionLbl.minimumScaleFactor = 0.50;
        cvDescriptionLbl.numberOfLines = 0;
        
        NSString *htmlString=description;
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [cvDescriptionLbl setText:attrStr.string];
        cvDescriptionLbl.shadowColor = nil; // fill your color here
        cvDescriptionLbl.shadowOffset = CGSizeMake(0.0, -1.0);
        cvDescriptionLbl.lineHeightScale = 1.00;
        cvDescriptionLbl.fixedLineHeight = 24.00;
        cvDescriptionLbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
        cvDescriptionLbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
        cvDescriptionLbl.fdTextAlignment=FDTextAlignmentJustify;
        cvDescriptionLbl.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
        cvDescriptionLbl.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        [contentVideModeScrollView addSubview:cvDescriptionLbl];
    }
    [contentVideModeScrollView addSubview:contentsVideoModeCollectionView];
    [contentsVideoModeCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view bringSubviewToFront:customToolbar];
    }


-(void) playVideo: (FMedia *) video{
    [FCommon playVideo:video onViewController:self isFromCoverflow:NO];
}

-(void)openPreloaded
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]]]];
    }
    
    NSMutableArray *arr=[FDB getDocuments];
    for (FDocument *d in arr) {
        [self downloadFile:d.src inFolder:@"/Preloaded" type:7];
    }
    
    NSArray *contentArr=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]] error:nil];
    
    FFolderViewController *folder=[[FFolderViewController alloc] init];
    [folder setFolderContent:[contentArr mutableCopy]];
    [folder setSubFolder:@"/Preloaded"];
    [self.navigationController pushViewController:folder animated:YES];
}

-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder] ]];
    }
    
    NSString *localPdf=[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[fileUrl lastPathComponent]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:localPdf];
    }
    
    if ((![[NSFileManager defaultManager] fileExistsAtPath:localPdf]) && (!downloaded)) {
        if([ConnectionHelper connectedToInternet]){
            [self externalLink:fileUrl];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

#pragma mark WebView

-(void)webViewDidStartLoad:(UIWebView *)webView{
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
    [webView addSubview:hud];
    hud.labelText = NSLocalizedString(@"LOADINGWEBPAGE", nil);
    [hud show:YES];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"LOADINGWEBPAGEERROR", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

#pragma mark UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mediaArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FGalleryCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setContentForMedia:mediaArray[indexPath.row] forColectionView:collectionView onIndex:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    openVideoGal = YES;
    [self.viewDeckController closeLeftView];
    FMedia *media=[mediaArray objectAtIndex:[indexPath row]];
    [self openMedia:media];
}

-(void) openMedia:(FMedia *) mediaToOpen{
    if ([[mediaToOpen mediaType] intValue] == [MEDIAVIDEO intValue]){
        [self playVideo:mediaToOpen];
    } else {
        [self openPDF:mediaToOpen];
    }
}

//collection cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([FCommon isOrientationLandscape]){
        return CGSizeMake(440, 192);
    }
    else
        return CGSizeMake(330, 144);
    }

#pragma mark - PDF

-(void) openPDF:(FMedia *)pdf{
    if (pdfViewController == nil) {
        pdfViewController = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"pdfViewController"];
    }
    pdfViewController.ipadFotonaParent = self;
    pdfViewController.ipadFavoriteParent = nil;
    pdfViewController.pdfMedia = pdf;
    [popupCloseBtn setHidden:NO];
    [menuBtn setHidden:YES];
    lastOpenedController = pdfViewController;
    [containerView addSubview:pdfViewController.view];
}

#pragma mark - Refresh

- (void) refreshCellForMedia:(NSString *)mediaID andMediaType:(NSString *)mediaType{
    if (mediaArray.count >0) {
        for (int i = 0; i<[mediaArray count]; i++){
            FMedia *media = mediaArray[i];
            if ([[media itemID] intValue]== [mediaID intValue]) {
                NSIndexPath *index = [NSIndexPath  indexPathForItem:i inSection:0];
                [contentsVideoModeCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:index, nil]];
                break;
            }
        }
    }
}


#pragma mark Settings

- (IBAction)openSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    for (UIView *v in containerView.subviews) {
        [v setHidden:YES];
    }
    [self.settingsBtn setEnabled:NO];
    fotonaHidden = fotonaImg.isHidden;
    [fotonaImg setHidden:YES];
    [popupCloseBtn setHidden:NO];
    [menuBtn setHidden:YES];
    if ([FCommon isOrientationLandscape]) {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
    }else
    {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
    }
    settingsController.contentWidth.constant = self.view.frame.size.width;
    
    [settingsView addSubview:settingsController.view];
    [containerView addSubview:settingsView];
    [settingsView setHidden:NO];
    lastOpenedController = settingsController;
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
}

- (IBAction)closeSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckLeftSide;
    for (UIView *v in containerView.subviews) {
        [v setHidden:NO];
    }
    if (lastOpenedController != nil && [lastOpenedController isKindOfClass:[FIPDFViewController class]]) {
        [pdfViewController.view removeFromSuperview];
        [popupCloseBtn setHidden:YES];
        [menuBtn setHidden:NO];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [popupCloseBtn setHidden:YES];
            [menuBtn setHidden:NO];
            CGRect newFrame = settingsView.frame;
            newFrame.origin.x += self.view.frame.size.width;
            settingsView.frame = newFrame;
        } completion:^(BOOL finished) {
            
            [fotonaImg setHidden:fotonaHidden];
            [settingsView removeFromSuperview];
            [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
            [self.settingsBtn setEnabled:YES];
            [settingsView setHidden:YES];
        }];

    }
    lastOpenedController = nil;
}

#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 654)];
    }else
    {
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
    
    [APP_DELEGATE rotatePopupSearchedNewsInView:self.view];
    
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
    
    [self.viewDeckController setLeftSize:self.view.frame.size.width-320];
    
    [self.view bringSubviewToFront:customToolbar];
}

#pragma mark swipeMenu

-(IBAction)swipeMenuFotona:(UIPanGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint vel = [recognizer velocityInView:containerView];
        if (self.viewDeckController.leftController.view.isHidden) {
            if (vel.x > 0 && !direction)
            {
                // user dragged towards the right
                CGRect newFrame = fotonaImg.frame;
                newFrame.origin.x += rotate * 180;
                rotate = -rotate;
                fotonaImg.frame = newFrame;
                [self.viewDeckController toggleLeftViewAnimated:YES];
                direction = TRUE;
                
            }
        } else{
            if (vel.x < 0  && direction)
            {
                // user dragged towards the left
                CGRect newFrame = fotonaImg.frame;
                newFrame.origin.x += rotate * 180;
                rotate = -rotate;
                fotonaImg.frame = newFrame;
                [self.viewDeckController toggleLeftViewAnimated:YES];
                direction = FALSE;
            }
        }
        
    } completion:^(BOOL finished) {
    }];
}

- (void)closeOnTabFotona:(NSNotification *)n {
    for (UIView *v in containerView.subviews) {
        [v setHidden:YES];
    }
    [fotonaImg setHidden:NO];
    CGRect newFrame = fotonaImg.frame;
    newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
    fotonaImg.frame = newFrame;
    rotate = 1;
    [[APP_DELEGATE main_ipad].fotonaMenu resetViewAnime:YES];
    [self.viewDeckController openLeftView];
    direction = TRUE;
}

-(void)closeMenu{
    if (direction) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x +=  180;
        rotate = -1;
        fotonaImg.frame = newFrame;
        direction = FALSE;
    }
}

@end

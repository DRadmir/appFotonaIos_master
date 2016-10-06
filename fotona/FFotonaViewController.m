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
#import "FVideo.h"
#import <AVFoundation/AVFoundation.h>
#import "GEMainMenuCell.h"
#import "FSettingsViewController.h"
#import "FDownloadManager.h"
#import "BubbleControler.h"
#import "FTabBarController.h"
#import "HelperString.h"

@interface FFotonaViewController (){
    bool fotonaHidden;
    UITapGestureRecognizer *fotonaTap;
    int numberOfImages;
    BubbleControler *bubbleCFotona;
    Bubble *b3;
    Bubble *b4;
    int stateHelper;
    int rotate;
    BOOL direction;
    FSettingsViewController *settingsController;
    float w;
    //BOOL openVideoGal;
    NSArray *videoArray;
    NSMutableArray *downloading;
}
@property (nonatomic, strong)UIImage *defaultVideoImage;

@end

@implementation FFotonaViewController
@synthesize allItems;
@synthesize menuItems;
@synthesize menuTitles;
@synthesize fotonaImg;
@synthesize popover;
@synthesize containerView;
@synthesize videos;
@synthesize moviePlayer;
@synthesize item;
@synthesize defaultVideoImage = _defaultVideoImage;
@synthesize popupCloseBtn;
@synthesize openVideoGal;
@synthesize cDescription;
@synthesize PDFToOpen;
@synthesize openPDF;


//cell identifier
static NSString * const reuseIdentifier = @"Cell";


//preload movies
NSMutableDictionary *preloadGalleryMoviesImages; //of [galleryId+" "+imageIndex] = UIImage
NSString *currentVideoGalleryId;


//default image in video gallery
-(UIImage *)defaultVideoImage
{
    if (!_defaultVideoImage) {
        
        _defaultVideoImage = [UIImage imageNamed:@"no_thunbail"];
        
        CGSize size = CGSizeMake( 300, 167);
        UIGraphicsBeginImageContext(size);
        
        CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
        [_defaultVideoImage drawInRect:imgBorder];
        
        _defaultVideoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return _defaultVideoImage;
}


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
        [self setTitle:@"Fotona"];
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
    
    
    menuTitles=[NSMutableArray arrayWithObjects:@"Menu", nil];
    [menuTitle setText:[menuTitles lastObject]];
    allItems=[[NSMutableArray alloc] init];
    [allItems addObject:[self getFotonaMenu:nil]];
    [back setHidden:YES];
    
    menuItems=[allItems lastObject];
    
    //video collection view
    [contentsVideoModeCollectionView setBackgroundColor:[UIColor whiteColor]];
    [contentsVideoModeCollectionView registerClass:[GEMainMenuCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    preloadGalleryMoviesImages = [[NSMutableDictionary alloc] init];
    [self.view setNeedsDisplay];
    stateHelper = 0;
    [self.viewDeckController openLeftView];
    CGRect newFrame = fotonaImg.frame;
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
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
    if (openVideoGal == nil) {
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
    NSLog(@"test5");
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
    NSString *usr = [FCommon getUser];
    
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
    
    [bubbleCFotona removeFromSuperview];
    bubbleCFotona = nil;
    
    [self showBubbles];
    openVideoGal = NO;
    
    if (openPDF) {
        [self openPDFFromSearch];
    }
    
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


#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] title]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFotonaMenu *clicked=[menuItems objectAtIndex:indexPath.row];
    NSMutableArray *newItems=[self getFotonaMenu:clicked.categoryID];
    if (newItems.count>0) {
        [back setHidden:NO];
        [allItems addObject:newItems];
        menuItems=[allItems lastObject];
        [menuTitles addObject:[clicked title]];
        [menuTitle setText:[menuTitles lastObject]];
        [table reloadData];
    }else
    {
        //logic open screen
        if ([[clicked fotonaCategoryType] isEqualToString:@"2"]) {
            //external link
            [self externalLink:[clicked externalLink]];
        }
        if ([[clicked fotonaCategoryType] isEqualToString:@"3"]) {
            //case
            FCase *item = [self getCase:[clicked caseID]];
            [(FCasebookViewController *)[[self.tabBarController viewControllers] objectAtIndex:1] setCurrentCase:item];
            [(FCasebookViewController *)[[self.tabBarController viewControllers] objectAtIndex:1] setFlagCarousel:YES];
            [self.tabBarController setSelectedIndex:1];
        }
        if ([[clicked fotonaCategoryType] isEqualToString:@"4"]) {
            //video+content
            
        }
        if ([[clicked fotonaCategoryType] isEqualToString:@"5"]) {
            //content
        }
        if ([[clicked fotonaCategoryType] isEqualToString:@"6"]) {
            //pdf
            [self downloadFile:[NSString stringWithFormat:@"%@",[clicked pdfSrc]] inFolder:@".PDF" type:6];
        }
        if ([[clicked fotonaCategoryType] isEqualToString:@"7"]) {
            //preloaded
            [self openPreloaded];
        }
        
    }
}

-(NSMutableArray *)getDocuments
{
    NSMutableArray *doc=[[NSMutableArray alloc] init];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Documents where active=1"]];
    while([results next]) {
        FDocument *f=[[FDocument alloc] init];
        [f setDocumentID:[results stringForColumn:@"documentID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setIconType:[results stringForColumn:@"iconType"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setIsLink:[results stringForColumn:@"isLink"]];
        [f setLink:[results stringForColumn:@"link"]];
        [f setSrc:[results stringForColumn:@"src"]];
        [f setActive:[results stringForColumn:@"active"]];
        
        [doc addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return doc;
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
        if([APP_DELEGATE connectedToInternet]){
            [self externalLink:fileUrl];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }else
    {
        NSLog(@"file exists %@",[fileUrl lastPathComponent]);
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if (t==6) {
            [self openPDF:path];
        }
        
    }
    
}



-(void)downloadFileFromSearch:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t withCategoryID:(NSString*)cID
{
    [fotonaImg setHidden:YES];
    [self downloadFile:fileUrl inFolder:folder type:t withCategoryID:cID];
    
}



-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t withCategoryID:(NSString*)cID
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]];
    }
    NSString *localPdf=[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[fileUrl lastPathComponent]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:localPdf];
    }
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKPDF, cID]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if (([[NSFileManager defaultManager] fileExistsAtPath:localPdf]) && (downloaded) && flag) {
        NSLog(@"file exists %@",[fileUrl lastPathComponent]);
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if (t==6) {
            [self openPDF:path];
        }
        
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            [self externalLink:fileUrl];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
}


-(void)openPDF:(NSString *)path
{
    pathToPDF=path;
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    [[previewController.navigationController navigationBar] setHidden:YES];
    // start previewing the document at the current section index
    previewController.currentPreviewItemIndex = 0;
    
    [self  presentViewController:previewController animated:YES completion:nil];
    videoArray = [NSArray new];
}


- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1; //assuming your code displays a single file
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:pathToPDF]; //path of the file to be displayed
}

-(void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    [self.viewDeckController openLeftView];
}

-(IBAction)backBtn:(id)sender
{
    [allItems removeLastObject];
    menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
    [table reloadData];
    [menuTitles removeLastObject];
    [menuTitle setText:[menuTitles lastObject]];
    if (allItems.count==1) {
        [back setHidden:YES];
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
        if (stateHelper<2) {
            [bubbleCFotona removeFromSuperview];
            bubbleCFotona = nil;
            [self showBubbles];
        }
    }];
    
    
    
}

#pragma mark DB

-(NSMutableArray *)getFotonaMenu:(NSString *)catID
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results;
    if (catID) {
        results= [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where categoryIDPrev=%@",catID]];
    }else{
        results= [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenu where categoryIDPrev is null"]];
    }
    
    while([results next]) {
        FFotonaMenu *f=[[FFotonaMenu alloc] init];
        [f setCategoryID:[results stringForColumn:@"categoryID"]];
        [f setCategoryIDPrev:[results stringForColumn:@"categoryIDPrev"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setFotonaCategoryType:[results stringForColumn:@"fotonaCategoryType"]];
        [f setDescription:[results stringForColumn:@"description"]];
        [f setText:[results stringForColumn:@"text"]];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setPdfSrc:[results stringForColumn:@"pdfSrc"]];
        [f setExternalLink:[results stringForColumn:@"externalLink"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setIconName:[results stringForColumn:@"icon"]];
        [menu addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return menu;
}

-(FCase *)getCase:(NSString *)caseID{
    FCase *f=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and caseID=%@",caseID]];
    while([results next]) {
        f=[[FCase alloc] init];
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if ([APP_DELEGATE checkGuest]) {
        if ([f.allowedForGuests isEqualToString:@"1"]) {
            return f;
        }
    } else {
        return f;
    }
    return nil;
}


#pragma mark Open

-(void)externalLink:(NSString *)link
{
    //    [table setHidden:YES];
    //    [menuHeader setHidden:YES];
    if([APP_DELEGATE connectedToInternet]){
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
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    videoArray = [NSArray new];
    
    
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
    //NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [cDescription loadHTMLString:htmlString baseURL:nil];
    
    [self.view bringSubviewToFront:customToolbar];
    
    
}

-(void)openContentWithTitle:(NSString *)title description:(NSString *)description videoGallery:(NSString *)galleryID videos:(NSMutableArray *)videosArray
{
    //    NSLog(@"videos desc %@",description);
    currentVideoGalleryId = galleryID;
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [contentVideoModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentsVideoModeCollectionView setFrame:CGRectMake(0, 89, 1024, 564)];
    }else
    {
        [contentModeView setFrame:CGRectMake(0, 0, 768, 909)];
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
    numberOfImages = [videosArray count];
    
    
    
    for (UIView *v in containerView.subviews) {
        [v removeFromSuperview];
    }
    for (UIView *v in contentVideModeScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    [containerView addSubview:contentVideoModeView];
    if (videosArray.count > 0) {
        [self preloadMoviesImage:videosArray videoGalleryId:galleryID];
    }
    
    [cvTitleLbl setText:title];
    [contentVideModeScrollView addSubview:cvTitleLbl];
    
    
    //    cDescriptionLbl=[[FDLabelView alloc] initWithFrame:CGRectMake(38, 209, 710, 211)];
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

-(IBAction)openVideo:(id)sender
{
    FVideo *vid=[videos objectAtIndex:[sender tag]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:vid.localPath];
    }
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKVIDEO, [vid itemID]]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:vid.localPath] && downloaded && flag) {
        NSString* strurl =vid.localPath;
        NSURL *videoURL=[NSURL fileURLWithPath:strurl];
        moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        [moviePlayer.moviePlayer play];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            NSString* strurl =vid.path;
            NSURL *videoURL=[NSURL URLWithString:strurl];
            moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
}

-(void)openVideoFromSearch:(FVideo *)video
{
    
    if (!self.viewDeckController.leftController.view.isHidden) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x += rotate * 180;
        rotate = -rotate;
        fotonaImg.frame = newFrame;
        [self.viewDeckController toggleLeftViewAnimated:YES];
        direction = FALSE;
        
    }
    
    openVideoGal = YES;
    
    
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:video.localPath];
    }
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKVIDEO, [video itemID]]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:video.localPath] && downloaded && flag) {
        NSString* strurl =video.localPath;
        NSURL *videoURL=[NSURL fileURLWithPath:strurl];
        moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        });
        [moviePlayer.moviePlayer play];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            NSString* strurl =video.path;
            NSURL *videoURL=[NSURL URLWithString:strurl];
            moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            });
            [moviePlayer.moviePlayer play];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
}


-(void)openPreloaded
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]]]];
    }
    
    NSMutableArray *arr=[self getDocuments];
    for (FDocument *d in arr) {
        [self downloadFile:d.src inFolder:@"/Preloaded" type:7];
    }
    
    NSArray *contentArr=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Preloaded",[APP_DELEGATE userFolderPath]] error:nil];
    
    FFolderViewController *folder=[[FFolderViewController alloc] init];
    [folder setFolderContent:[contentArr mutableCopy]];
    [folder setSubFolder:@"/Preloaded"];
    [self.navigationController pushViewController:folder animated:YES];
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
    videoArray = [item getVideos];
    return videoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //videoArray = [item getVideos];
    
    GEMainMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.parentFotona = self;
    [[cell image] setClipsToBounds:YES];
    [[cell image] setContentMode:UIViewContentModeCenter];
    
    FVideo *vid= [videoArray objectAtIndex:indexPath.row];
    
    [[cell titleLbl] setText:vid.title]; //text under video
    [cell.titleLbl setNumberOfLines:2];
    //    [cell.titleLbl sizeToFit];
    
    //    [cell.titleLbl setTextAlignment:NSTextAlignmentCenter];
    [cell setVideo:vid];
    BOOL bookmarked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKVIDEO, vid.itemID]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [[cell bookmarkBtn] setEnabled: true];
    if (bookmarked) {
        
        [cell.bookmarkBtn setHidden: YES];
        
        [cell.bookmarkRemoveBtn setHidden: NO];
    } else {
        for (NSString *v  in [APP_DELEGATE bookmarkingVideos]) {
            if ([v isEqualToString:vid.itemID]) {
                [[cell bookmarkBtn] setEnabled: false];
            }
        }
        [cell.bookmarkBtn setHidden: NO];
        [cell.bookmarkRemoveBtn setHidden: YES];
    }
    
    [database close];
    
    NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:currentVideoGalleryId videoId:vid.itemID];
    UIImage *img = [preloadGalleryMoviesImages objectForKey:videoKey];
    [[cell image] setImage:img];
    
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    openVideoGal = YES;
    [self.viewDeckController closeLeftView];
    videoArray = [item getVideos];
    FVideo *vid=[videoArray objectAtIndex:[indexPath row]];
    
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:vid.localPath];
    }
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKVIDEO, [vid itemID]]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:vid.localPath] && downloaded && flag) {
        NSString* strurl =vid.localPath;
        NSURL *videoURL=[NSURL fileURLWithPath:strurl];
        moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        [moviePlayer.moviePlayer play];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            NSString* strurl =vid.path;
            NSURL *videoURL=[NSURL URLWithString:strurl];
            moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 320); //velikost gemainmenucell
}

-(NSString *)getpreloadGalleryMoviesImagesKeyWithGalleryId:(NSString *)galleryId videoId:(NSString *)videoId
{
    return [NSString stringWithFormat:@"%@_%@", galleryId, videoId];
}

- (void) refreshCell:(int) index{
    if (videoArray.count >0) {
        FVideo *video=[[FVideo alloc] init];
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%d order by sort",index]];
        while([results next]) {
            [video setItemID:[results stringForColumn:@"mediaID"]];
            [video setTitle:[results stringForColumn:@"title"]];
            [video setPath:[results stringForColumn:@"path"]];
            [video setLocalPath:[results stringForColumn:@"localPath"]];
            [video setVideoGalleryID:[results stringForColumn:@"galleryID"]];
            [video setDescription:[results stringForColumn:@"description"]];
            [video setTime:[results stringForColumn:@"time"]];
            [video setVideoImage:[results stringForColumn:@"videoImage"]];
            [video setSort:[results stringForColumn:@"sort"]];
            [video setUserType:[results stringForColumn:@"userType"]];
            [video setUserSubType:[results stringForColumn:@"userSubType"]];
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
        
        bool contains = false;
        int indexArray = -1;
        for (FVideo* v in videoArray) {
            if ([v.itemID isEqualToString:video.itemID]) {
                contains = true;
                indexArray = [videoArray indexOfObject:v];
                break;
            }
        }
        
        
        if (contains)
        {
            [[APP_DELEGATE bookmarkingVideos] removeObject:video.itemID];
            NSArray* tempArray = [NSArray arrayWithObjects: [NSIndexPath indexPathForRow:indexArray inSection:0], nil];
            [contentsVideoModeCollectionView reloadItemsAtIndexPaths:tempArray];
            video.bookmark = @"1";
            
        }
    }
}

- (void) refreshCellUnbookmark:(int) index{
    if (videoArray.count >0) {
        FVideo *video=[[FVideo alloc] init];
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%d order by sort",index]];
        while([results next]) {
            [video setItemID:[results stringForColumn:@"mediaID"]];
            [video setTitle:[results stringForColumn:@"title"]];
            [video setPath:[results stringForColumn:@"path"]];
            [video setLocalPath:[results stringForColumn:@"localPath"]];
            [video setVideoGalleryID:[results stringForColumn:@"galleryID"]];
            [video setDescription:[results stringForColumn:@"description"]];
            [video setTime:[results stringForColumn:@"time"]];
            [video setVideoImage:[results stringForColumn:@"videoImage"]];
            [video setSort:[results stringForColumn:@"sort"]];
            [video setUserType:[results stringForColumn:@"userType"]];
            [video setUserSubType:[results stringForColumn:@"userSubType"]];
        }
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
        
        bool contains = false;
        int indexArray = -1;
        for (FVideo* v in videoArray) {
            if ([v.itemID isEqualToString:video.itemID]) {
                contains = true;
                indexArray = [videoArray indexOfObject:v];
                break;
            }
        }
        
        
        if (contains)
        {
            [[APP_DELEGATE bookmarkingVideos] removeObject:video.itemID];
            NSArray* tempArray = [NSArray arrayWithObjects: [NSIndexPath indexPathForRow:indexArray inSection:0], nil];
            if ([contentsVideoModeCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexArray inSection:0]]!=nil) {
                [contentsVideoModeCollectionView reloadItemsAtIndexPaths:tempArray];
                video.bookmark = @"0";
            }
        }
    }
}

- (void) refreshVideoCells{
    videoArray = [item getVideos];
    for (int i=0; i<videoArray.count; i++) {
        FVideo * vid = videoArray[i];
        [self refreshCellUnbookmark:[vid.itemID intValue]];
    }
}




-(void)preloadMoviesImage:(NSMutableArray *)videosArray videoGalleryId:(NSString *)galleryId
{
    
    NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"thubnailsLastUpdate"];
    
    NSMutableDictionary *temp;
    if ([APP_DELEGATE videoImages]==nil) {
        temp =  [[NSMutableDictionary alloc] init];
    } else{
        temp =  [APP_DELEGATE videoImages];
    }
    //default video image
    for (int i=0;i<[videosArray count];i++)
    {
        NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:currentVideoGalleryId videoId:[[videosArray objectAtIndex:i] itemID]];
        
        if (![preloadGalleryMoviesImages objectForKey:videoKey]) {
            if ([temp objectForKey:videoKey] ) {
                [preloadGalleryMoviesImages setValue:[temp objectForKey:videoKey] forKey:videoKey];
            } else{
                [preloadGalleryMoviesImages setValue:[self defaultVideoImage] forKey:videoKey];
            }
            
        }
    }
    
    //queue
    NSArray *activeQueues = @[
                              dispatch_queue_create("videoTumbnailsLoadingQueue1",NULL),
                              //sdispatch_queue_create("videoTumbnailsLoadingQueue2",NULL),
                              //dispatch_queue_create("videoTumbnailsLoadingQueue3",NULL),
                              ];
    
    //dispatch_queue_t videoTumbnailsLoadingQueue = dispatch_queue_create("videoTumbnailsLoadingQueue",NULL);
    
    for (int i=0;i<[videosArray count];i++)
    {
        int activeQueueIndex = i%[activeQueues count];
        dispatch_async([activeQueues objectAtIndex:activeQueueIndex], ^{
            FVideo *vid=[videosArray objectAtIndex:i];
            //id of image inside preloadGalleryMoviesImages
            NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:currentVideoGalleryId videoId:[[videosArray objectAtIndex:i] itemID]];
            
            //image is not default
            if ([preloadGalleryMoviesImages objectForKey:videoKey] != self.defaultVideoImage) {
                if([APP_DELEGATE connectedToInternet]){
                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid videoImage]];
                    UIImage *imgNew = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                    if (imgNew!=nil) {
                        NSData *data1 = UIImagePNGRepresentation(imgNew);
                        NSData *data2 = UIImagePNGRepresentation([preloadGalleryMoviesImages objectForKey:videoKey]);
                        if (![data1 isEqual:data2]) {
                            [preloadGalleryMoviesImages setValue:imgNew forKey:videoKey];
                        }
                    }
                }
                return;
            }
            
            //we are not loading current gallery
            if (galleryId != currentVideoGalleryId) {
                return;
            }
            
            
            
            if ([preloadGalleryMoviesImages count] <= i) {
                return;
            }
            
            
            
            UIImage *img;
            NSArray *pathComp=[[vid videoImage] pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[vid videoImage] lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                NSData *data=[NSData dataWithContentsOfFile:pathTmp];
                img = [UIImage imageWithData:data];
            } else{
                NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid videoImage]];
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
            }
            
            
            if (img!=nil) {
                CGSize size = CGSizeMake(300, 167);
                UIGraphicsBeginImageContext(size);
                
                CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
                [img drawInRect:imgBorder];
                
                img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                NSIndexPath *collectionIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    GEMainMenuCell *cell = [contentsVideoModeCollectionView cellForItemAtIndexPath:collectionIndexPath];
                    
                    [preloadGalleryMoviesImages setValue:img forKey:videoKey];
                    NSMutableDictionary *temp;
                    if ([APP_DELEGATE videoImages]==nil) {
                        temp =  [[NSMutableDictionary alloc] init];
                    } else{
                        temp =  [APP_DELEGATE videoImages];
                    }
                    [temp setValue:img forKey:videoKey];
                    [APP_DELEGATE setVideoImages:temp];
                    if (cell)
                    {
                        [[cell image] setImage:img];//iconImage];
                    }
                });
            }
        });
        
    }
    
    NSString *today=[self currentTimeInLjubljana];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"thubnailsLastUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [bubbleCFotona removeFromSuperview];
    bubbleCFotona = nil;
    [self showBubbles];
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
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
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
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
}

- (IBAction)closeSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckLeftSide;
    for (UIView *v in containerView.subviews) {
        [v setHidden:NO];
    }
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

-(NSString *)currentTimeInLjubljana
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd-MM-yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

#pragma mark - BUBBLES :D

-(void)showBubbles
{
    NSString *usr = [FCommon getUser];
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaHelper"]];
    if(![usersarray containsObject:usr]){
        [self.viewDeckController.leftController.view setUserInteractionEnabled:NO];
        NSLog(@"Hidden: %d",(settingsView.isHidden || settingsView==nil));
        // You should check before this, if any of bubbles needs to be displayed
        if(bubbleCFotona == nil && (settingsView.isHidden || settingsView==nil))
        {
            bubbleCFotona =[[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            //[bubbleC setBlockUserInteraction:NO];
            //[bubbleCFotona setBackgroundTint:[UIColor clearColor]];
            b3 = [[Bubble alloc] init];
            
            // Calculate point of caret
            CGPoint loc = CGPointZero;
            if (stateHelper<1) {
                loc.x = 323; // Center
                loc.y = 140; // Bottom
                // Set if highlight is desired
                CGRect newFrame =self.view.frame;
                newFrame.size.width = 320;
                
                [b3 setHighlight:newFrame];
                [b3 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b3 setFontColor:[UIColor whiteColor]];
                // Set buble size and position (first size, then position!!)
                [b3 setSize:CGSizeMake(200, 120)];
                [b3 setCornerRadius:5];
                [b3 setPositionOfCaret:loc withCaretFrom:LEFT_TOP];
                [b3 setCaretSize:15]; // Because tablet, we want a bigger bubble caret
                // Set font, paddings and text
                [b3 setTextContentInset: UIEdgeInsetsMake(16,16,16,16)]; // Set paddings
                [b3 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLEFOTONA1", nil)]];
                [b3 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]]; // Default font is helvetica-neue, size 12
                
                // Add bubble to controler
                [bubbleCFotona addBubble:b3];
                [b3 setDelegate:self];
            }
            
            if (stateHelper<2) {
                b4 = [[Bubble alloc] init];
                
                loc =[[[[self tabBarController] tabBar] subviews] objectAtIndex:4].frame.origin;//[[[[[APP_DELEGATE tabBar] tabBar] subviews] objectAtIndex:4] frame].origin;
                loc.x =[[APP_DELEGATE tabBar] tabBar].frame.size.width/2 + 182 + [[[[[APP_DELEGATE tabBar] tabBar] subviews] objectAtIndex:4]frame].size.width/2; // Center
                loc.y = self.view.frame.size.height - 50;//+= [[[self tabBarController] tabBar] frame].origin.y-3; // Bottom
                
                
                //                    for (int xt = 0; xt<temp; xt++) {
                //                        NSLog(@"%F, %f,%F, %f, %@",[[[[self tabBarController] tabBar] subviews] objectAtIndex:xt].frame.origin.x,[[[[self tabBarController] tabBar] subviews] objectAtIndex:xt].frame.origin.y,[[[[self tabBarController] tabBar] subviews] objectAtIndex:xt].frame.size.width,[[[[self tabBarController] tabBar] subviews] objectAtIndex:xt].frame.size.height,[[[[[APP_DELEGATE tabBar] tabBar]items] objectAtIndex:xt] title]);
                //                    }
                [b4 setCornerRadius:10];
                [b4 setSize:CGSizeMake(200, 130)];
                CGRect newFrame =[[[[[APP_DELEGATE tabBar] tabBar] subviews] objectAtIndex:4]frame];
                newFrame.origin.y += self.view.frame.size.height-newFrame.size.height-2;
                newFrame.origin.x = [[APP_DELEGATE tabBar] tabBar].frame.size.width/2 + 182;
                newFrame.size.height += 1;
                [b4 setHighlight:newFrame];
                
                [b4 setPositionOfCaret:loc withCaretFrom:BOTTOM_RIGHT];
                [b4 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLEFOTONA2", nil)]];
                [b4 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b4 setFontColor:[UIColor whiteColor]];
                [b4 setTextContentInset: UIEdgeInsetsMake(16,16,16,16)]; // Set paddings
                [b4 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
                
                [bubbleCFotona addBubble:b4];
                [b4 setDelegate:self];
            }
            
            //[containerView addSubview:bubbleCFotona];
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window addSubview:bubbleCFotona];
        }
    }
}

- (void)bubbleRequestedExit:(Bubble*)bubbleObject
{
    
    stateHelper++;
    [bubbleCFotona displayNextBubble];
    [bubbleObject removeFromSuperview];
    [self.viewDeckController.leftController.view setUserInteractionEnabled:YES];
    if (stateHelper>1) {
        NSMutableArray *helperArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaHelper"]];
        NSString *usr = [FCommon getUser];
        [helperArray addObject:usr];
        [[NSUserDefaults standardUserDefaults] setObject:helperArray forKey:@"fotonaHelper"];
        stateHelper = 0;
    }
    
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
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (stateHelper<2) {
            [bubbleCFotona removeFromSuperview];
            bubbleCFotona = nil;
            [self showBubbles];
        }
    }
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

-(void)refreshMenu:(NSString *)link{
    link=[link stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    if ([self.bookmarkMenu objectForKey:link]) {
        FFotonaMenuViewController *menu = [self.bookmarkMenu objectForKey:link];
        [menu refreshPDF:link];
    }
    
}

- (void) setOpenGal: (BOOL) og
{
    self.openVideoGal = og;
}

-(void) setPDF:(FFotonaMenu *)PDF{
    openPDF = true;
    self.PDFToOpen = PDF;
}

-(void) openPDFFromSearch{
    openPDF = false;
    [self  downloadFileFromSearch:[NSString stringWithFormat:@"%@",[PDFToOpen pdfSrc]] inFolder:@".PDF" type:6 withCategoryID:[PDFToOpen categoryID]];
}

@end

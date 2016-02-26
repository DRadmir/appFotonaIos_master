//
//  FIBookmarkViewController.m
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIBookmarkViewController.h"
#import "FIFlowController.h"
#import "FIContentViewController.h"
#import "FAppDelegate.h"
#import "FDownloadManager.h"
#import "FCase.h"
#import "FNews.h"
#import "FEvent.h"
#import "FFotonaMenu.h"
#import "FIVideoGalleryViewController.h"
#import "FICaseViewController.h"
#import "FINewsViewController.h"
#import "FIEventSingleViewController.h"

@interface FIBookmarkViewController ()
{
    UINavigationController *menu;
    FIBookmarkMenuViewController *subm;
    UIStoryboard *sb;
    UIViewController *openedView;
    FIContentViewController *contentView;
    FICaseViewController *caseView;
    FINewsViewController *newsView;
    FIEventSingleViewController *eventView;
    FIVideoGalleryViewController *videoView;
    int lastDocument;
    FCase *lastCase;
    FNews *lastNews;
    FEvent *lastEvent;
    NSString *pdfFolder;
    NSString *pathToPdf;
}
@end

@implementation FIBookmarkViewController

@synthesize contentViewBookmark;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(showMenu:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    //menu = [sb instantiateViewControllerWithIdentifier:@"bookmarkMenuNavigation"];
    subm = [sb instantiateViewControllerWithIdentifier:@"bookmarkMenu"];

    pdfFolder = @".PDF";
    pathToPdf = @"";
}

-(void)viewDidAppear:(BOOL)animated
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.bookmarkTab = self;
    if (flow.showMenu)
    {
        flow.showMenu = false;
        [self showMenu:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showMenu:(id)sender
{
    //[self  presentViewController:menu animated:true completion:nil];
    FIFlowController *flow = [FIFlowController sharedInstance];
    
    if (flow.bookmarkMenuArray.count > 0) {
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        for (FIBookmarkMenuViewController *m in flow.bookmarkMenuArray) {
            [controllers addObject:m];
        }
        [self.navigationController setViewControllers:controllers animated:YES];
    } else
    {
        [flow.bookmarkMenuArray addObject:subm];
        [self.navigationController pushViewController:subm animated:true];
    }

}

#pragma mark - Opening Views

-(void)openData:(NSMutableArray *)data
{
    BOOL replace = false;
    NSString *tempDocument = data[0];
    int document = tempDocument.intValue;
    if (lastDocument != document) {
        if (openedView != nil) {
            [openedView willMoveToParentViewController:nil];
            [openedView.view removeFromSuperview];
            [openedView removeFromParentViewController];
        }
        replace = true;
        lastDocument = document;
        lastCase = nil;
    }
    
    switch (lastDocument) {
        case 1:
        {
            FNews *news = data[2];
            [APP_DELEGATE setNewsTemp:news];
            [self openNews:news andReplace:replace];
        }
            break;
        case 2:
        {
            FEvent *event = data[2];
            [self openEvent:event andReplace:replace];
        }
            break;
        case 3:
        {
            NSString *subDocument = data[1];
            int tempSub = subDocument.intValue;
            switch (tempSub) {
                case 1:
                {
                    NSString *category = data[2];
                    [self openGallery:category andReplace:replace];
                }
                    break;
                case 2:
                {
                    FFotonaMenu *category = data[2];
                    [self openPDFCategory:category andReplace:replace];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 4:
            [self openCase:data[2] andReplace:replace];
            break;
        default:
        {
            NSString *titleHelp = data[2];
            NSString *contentHelp = data[3];
            [self openContent:titleHelp withDescription:contentHelp andReplace:replace];
        }
            break;
    }
}



- (void)openViewInContainer: (UIViewController *) viewToOpen
{
    openedView = viewToOpen;
    [viewToOpen.view setFrame:contentViewBookmark.bounds];
    [contentViewBookmark addSubview:viewToOpen.view];
    [self addChildViewController:viewToOpen];
    [viewToOpen didMoveToParentViewController:self];
}



#pragma mark - Open Content

- (void) openContent:(NSString *) title withDescription:(NSString *)description andReplace:(BOOL) replace
{
    if (contentView == nil) {
        contentView = [sb instantiateViewControllerWithIdentifier:@"contentViewController"];
        replace = true;
    }
    
    contentView.titleContent = title;
    contentView.descriptionContent = description;
    
    if (replace)
    {
        [self openViewInContainer:contentView];
    } else
    {
        [contentView reloadView];
    }
}

#pragma mark - Open Case

- (void) openCase:(FCase *) caseToShow andReplace:(BOOL) replace
{
    if (lastCase.caseID != caseToShow.caseID)
    {
        if (caseView == nil) {
            caseView = [sb instantiateViewControllerWithIdentifier:@"caseView"];
            replace = true;
        }
        caseView.caseToOpen = caseToShow;
        caseView.parentBookmarks = self;
        caseView.canBookmark = false; //true if opened in casebooktab
        openedView = caseView;
        lastCase = caseToShow;
        [caseView willMoveToParentViewController:nil];
        [caseView.view removeFromSuperview];
        [caseView removeFromParentViewController];
        [self openViewInContainer:caseView];
        
        
    }
}

#pragma mark - Open News

- (void) openNews:(FNews *) newsToShow andReplace:(BOOL) replace
{
    if (lastNews.newsID != newsToShow.newsID)
    {
        if (newsView == nil) {
            newsView = [sb instantiateViewControllerWithIdentifier:@"newsViewController"];
            replace = true;
        }
        openedView = caseView;
        lastNews = newsToShow;
        [newsView willMoveToParentViewController:nil];
        [newsView.view removeFromSuperview];
        [newsView removeFromParentViewController];
        [self openViewInContainer:newsView];
        
        
    }
}

#pragma mark - Open Event

- (void) openEvent:(FEvent *) eventToShow andReplace:(BOOL) replace
{
    if (lastEvent.eventID != eventToShow.eventID)
    {
        if (eventView == nil) {
            eventView = [sb instantiateViewControllerWithIdentifier:@"eventViewController"];
            replace = true;
        }
        eventView.eventToOpen = eventToShow;
        openedView = eventView;
        lastEvent = eventToShow;
        [eventView willMoveToParentViewController:nil];
        [eventView.view removeFromSuperview];
        [eventView removeFromParentViewController];
        [self openViewInContainer:eventView];
        
        
    }
}


#pragma mark - Open Disclaimer

- (void) openDisclaimer
{
    if (contentView == nil) {
        contentView = [sb instantiateViewControllerWithIdentifier:@"contentViewController"];
    }
    
    contentView.titleContent = @"Disclaimer";
    contentView.descriptionContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"];
    
    if (openedView != contentView)
    {
        if (openedView != nil) {
            [openedView willMoveToParentViewController:nil];
            [openedView.view removeFromSuperview];
            [openedView removeFromParentViewController];
            
        }
        [self openViewInContainer:contentView];
        openedView = contentView;
        lastCase = nil;
    }
    
}



#pragma mark - Open PDF

-(void) openPDFCategory:(FFotonaMenu *)category andReplace:(BOOL) replace
{
    NSString *fileURL = [category pdfSrc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,pdfFolder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,pdfFolder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,pdfFolder]]];
    }
    NSString *localPdf=[NSString stringWithFormat:@"%@%@/%@",docDir,pdfFolder,[fileURL lastPathComponent]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:localPdf];
    }
    
    if (([[NSFileManager defaultManager] fileExistsAtPath:localPdf]) && (downloaded)) {
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,pdfFolder] stringByAppendingPathComponent:[fileURL lastPathComponent]];
        [self openPDF:path];
    }else
    {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"FILEDOWNLOAD", nil)]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

-(void) openPDF:(NSString *)fileURL
{
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
    }
    pathToPdf = fileURL;
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    [[previewController.navigationController navigationBar] setHidden:YES];
    previewController.currentPreviewItemIndex = 0;
    
    [self presentViewController:previewController animated:YES completion:nil];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1; //assuming your code displays a single file
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:pathToPdf]; //path of the file to be displayed
}

-(void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    [self showMenu:self];
}

#pragma mark - Clear All
-(void)clearViews
{
    
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
        
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.bookmarkMenu != nil)
        {
            [[[flow bookmarkMenu] navigationController] popToRootViewControllerAnimated:false];
        }
        [flow.bookmarkMenuArray removeAllObjects];
    
    lastCase = nil;
    lastNews = nil;
    lastEvent = nil;
    lastDocument = -1;
    openedView = nil;
    [self showMenu:self];
}

#pragma mark - Open Video Gallery

- (void) openGallery:(NSString *) category andReplace:(BOOL) replace
{
    if (videoView == nil) {
        videoView = [sb instantiateViewControllerWithIdentifier:@"videoGalleryView"];
    }
    
    videoView.category = category;
     videoView.galleryID = @"-1";
    if (replace)
    {
        [self openViewInContainer:videoView];
    }
}



@end

//
//  FIFotonaViewController.m
//  fotona
//
//  Created by Janos on 18/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIFotonaViewController.h"
#import "FIFotonaMenuViewController.h"
#import "FFotonaMenuViewController.h"
#import "FIExternalLinkViewController.h"
#import "FIFlowController.h"
#import "FIVideoGalleryViewController.h"
#import "FIContentViewController.h"
#import "FAppDelegate.h"
#import "FDownloadManager.h"
#import "FDB.h"
#import "BubbleControler.h"


@interface FIFotonaViewController ()
{
//    UINavigationController *menu;
    NSString *lastCategory;
    FIFotonaMenuViewController *subMenu;
    
    UIViewController *openedView;
    UIStoryboard *sb;
    FIExternalLinkViewController *externalView;
    FIVideoGalleryViewController *videoGalleryView;
    FIContentViewController *contentView;
    NSString *pdfFolder;
    NSString *pathToPdf;
    BubbleControler *bubbleCFotona;
    Bubble *b3;
    Bubble *b4;
    int stateHelper;
    BOOL menuShown;
}

@end

@implementation FIFotonaViewController

@synthesize continerViewFotona;
@synthesize bookmarkMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    stateHelper = 0;
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showMenu:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
//    menu = [sb instantiateViewControllerWithIdentifier:@"menuNavigation"];
    subMenu = [sb instantiateViewControllerWithIdentifier:@"fotonaMenu"];
    lastCategory = @"";
    pdfFolder = @".PDF";
    pathToPdf = @"";
    
    if (self.bookmarkMenu == nil) {
        self.bookmarkMenu = [NSMutableDictionary new];
    }
    
}


-(void)viewDidAppear:(BOOL)animated
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.fotonaTab = self;
    menuShown = false;
    if (flow.showMenu)
    {
        flow.showMenu = false;
        [self showMenu:self];
        menuShown = true;
    }
    if (flow.fromSearch) {
        [self openGalleryFromSearch:flow.videoGal andReplace:false];
    }
    [self showBubbles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)openCategory:(FFotonaMenu *)fotonaCategory
{
    BOOL replace = false;
    if (![lastCategory isEqualToString:[fotonaCategory fotonaCategoryType]]) {
        if (openedView != nil) {
            [openedView willMoveToParentViewController:nil];
            [openedView.view removeFromSuperview];
            [openedView removeFromParentViewController];
           
        }
         replace = true;
        lastCategory = [fotonaCategory fotonaCategoryType];
    }
    
    if ([lastCategory isEqual:@"2"]) {
        [self openExternalLink:[fotonaCategory externalLink] andReplace:replace];
    } else{
        if ([lastCategory isEqual:@"3"]) {
            FIFlowController *flow = [FIFlowController sharedInstance];
            
            flow.caseFlow = [FDB getCaseWithID:[fotonaCategory categoryID]];
            if (flow.caseMenu != nil)
            {
                [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
            }
            [self.tabBarController setSelectedIndex:3];
        } else{
            if ([lastCategory isEqual:@"4"]) {
                [self openGallery:[fotonaCategory videoGalleryID] andReplace:replace];
            } else{
                if ([lastCategory isEqual:@"5"]) {
                    [self openContent:[fotonaCategory title] withDescription:[fotonaCategory text] andReplace:replace];
                } else{
                    if ([lastCategory isEqual:@"6"]) {
                        [self openPDFCategory:fotonaCategory andReplace:replace];
                    } else{
                    }
                }
            }
        }
    }
}

- (void)openViewInContainer: (UIViewController *) viewToOpen
{
    openedView = viewToOpen;
    [viewToOpen.view setFrame:continerViewFotona.bounds];
    [continerViewFotona addSubview:viewToOpen.view];
    [self addChildViewController:viewToOpen];
    [viewToOpen didMoveToParentViewController:self];
}


#pragma mark - Open Link

- (void) openExternalLink:(NSString *) url andReplace:(BOOL) replace
{
    if (externalView == nil) {
        externalView = [sb instantiateViewControllerWithIdentifier:@"webViewController"];
        replace = true;
    }
    externalView.urlString = url;
    if (replace)
    {
        [self openViewInContainer:externalView];
    } else
    {
        [externalView reloadView];
    }
}

#pragma mark - Open Video Gallery

- (void) openGallery:(NSString *) galleryID andReplace:(BOOL) replace
{
    if (videoGalleryView == nil) {
        videoGalleryView = [sb instantiateViewControllerWithIdentifier:@"videoGalleryView"];
        replace = true;
    }
    
    videoGalleryView.galleryID = galleryID;
     videoGalleryView.category = @"0";
    if (replace)
    {
        [self openViewInContainer:videoGalleryView];
    }

}

- (void) openGalleryFromSearch:(NSString *) galleryID andReplace:(BOOL) replace
{
    
    if (videoGalleryView == nil) {
        videoGalleryView = [sb instantiateViewControllerWithIdentifier:@"videoGalleryView"];
        replace = true;
    }
    
    videoGalleryView.galleryID = galleryID;
    videoGalleryView.category = @"0";
    
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
    }
    [self openViewInContainer:videoGalleryView];
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
        replace = true;
    } else
    {
        [contentView reloadView];
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
    
    if (([[NSFileManager defaultManager] fileExistsAtPath:localPdf]) && (downloaded) && [FDB checkIfBookmarkedForDocumentID:category.categoryID andType:BOOKMARKPDF]) {
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,pdfFolder] stringByAppendingPathComponent:[fileURL lastPathComponent]];
        [self openPDF:path];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            [self openExternalLink:fileURL andReplace:replace];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
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


#pragma mark - Open menu

- (IBAction)showMenu:(id)sender
{
     FIFlowController *flow = [FIFlowController sharedInstance];

    if (flow.fotonaMenuArray.count > 0) {
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        for (FIFotonaMenuViewController *m in flow.fotonaMenuArray) {
            [controllers addObject:m];
        }
        [self.navigationController setViewControllers:controllers animated:YES];
    } else
    {
        [flow.fotonaMenuArray addObject:subMenu];
        [self.navigationController pushViewController:subMenu animated:true];
    }
    
}

-(void)refreshMenu:(NSString *)link{
    link=[link stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    if ([self.bookmarkMenu objectForKey:link]) {
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.fotonaMenu != nil)
        {
           [[flow fotonaMenu] refreshPDF:link];
        }
        
    }
    
}

-(void)clearViews
{
    
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
    }
     FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.fotonaMenu != nil )
    {
        [[[flow fotonaMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    openedView = nil;
    lastCategory = @"";
    [flow.fotonaMenuArray removeAllObjects];

}

#pragma mark - BUBBLES :D

-(void)showBubbles
{
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaHelper"]];
    if(![usersarray containsObject:usr]){
        [self.viewDeckController.leftController.view setUserInteractionEnabled:NO];
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.fotonaHelperState > 1) {
            flow.fotonaHelperState = 0;
        }
        
        stateHelper = flow.fotonaHelperState;
        // You should check before this, if any of bubbles needs to be displayed
        if(bubbleCFotona == nil)
        {
            bubbleCFotona =[[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, [flow tabControler].view.frame.size.width, [flow tabControler].view.frame.size.height)];
            //[bubbleC setBlockUserInteraction:NO];
            //[bubbleCFotona setBackgroundTint:[UIColor clearColor]];
            
            // Calculate point of caret
            b3 = [[Bubble alloc] init];
            
            int orientation = 0;
            if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
                orientation = -1;
            }
            // Calculate point of caret
            CGPoint loc = contentView.view.frame.origin;
            CGRect newFrame = contentView.view.frame;
            if (stateHelper<1) {
                loc.x = [[flow tabControler] tabBar].frame.size.width/2; // Center
                loc.y = 155; // Bottom
                
                // Set if highlight is desired
                
                [b3 setCornerRadius:10];
                [b3 setSize:CGSizeMake(200, 130)];
                newFrame = flow.fotonaTab.view.frame;
                
                [b3 setHighlight:newFrame];
                
                [b3 setHighlight:newFrame];
                [b3 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b3 setFontColor:[UIColor whiteColor]];
                // Set buble size and position (first size, then position!!)
                [b3 setSize:CGSizeMake(200, 130)];
                [b3 setCornerRadius:5];
                [b3 setPositionOfCaret:loc withCaretFrom:TOP_CENTER];
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
                FIFlowController *flow = [FIFlowController sharedInstance];
                loc =[[[[[flow tabControler] tabBar] subviews] objectAtIndex:4] frame].origin;
                loc.x =[flow tabControler].view.frame.size.width -  [[[[[flow tabControler] tabBar] subviews] objectAtIndex:4]frame].size.width/2;
                loc.y = [flow tabControler].view.frame.size.height - [[flow tabControler] tabBar].frame.size.height;
                [b4 setCornerRadius:10];
                [b4 setSize:CGSizeMake(200, 130)];
                CGRect newFrame =[ [[[[flow tabControler] tabBar] subviews] objectAtIndex:4] frame];
                newFrame.origin.y = [flow tabControler].view.frame.size.height - [[flow tabControler] tabBar].frame.size.height;
                newFrame.origin.x =  [flow tabControler].view.frame.size.width -  [[[[[flow tabControler] tabBar] subviews] objectAtIndex:4]frame].size.width;
                newFrame.size.height += 1;
                [b4 setHighlight:newFrame];
                
                [b4 setPositionOfCaret:loc withCaretFrom:BOTTOM_RIGHT];
                [b4 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLECASE2", nil)]];
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
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.fotonaHelperState++;
    stateHelper = flow.fotonaHelperState;
    [bubbleCFotona displayNextBubble];
    [bubbleObject removeFromSuperview];
    [self.viewDeckController.leftController.view setUserInteractionEnabled:YES];
    if (stateHelper>1) {
        NSMutableArray *helperArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaHelper"]];
        NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
        if (usr == nil) {
            usr =@"guest";
        }
        [helperArray addObject:usr];
        [[NSUserDefaults standardUserDefaults] setObject:helperArray forKey:@"fotonaHelper"];
        stateHelper = 0;
        [bubbleCFotona removeFromSuperview];
        bubbleCFotona = nil;
        [self showMenu:self];
    } else if (stateHelper > 0)
    {
        [flow.fotonaMenuArray removeAllObjects];
        [flow.fotonaMenu closeMenu:flow.fotonaMenu];
    }
    
}
@end

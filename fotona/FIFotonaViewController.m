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
#import "FIGalleryViewController.h"
#import "FIContentViewController.h"
#import "FDownloadManager.h"
#import "FDB.h"
#import "FGoogleAnalytics.h"


@interface FIFotonaViewController ()
{
    //    UINavigationController *menu;
    NSString *lastCategory;
    FIFotonaMenuViewController *subMenu;
    
    UIViewController *openedView;
    UIStoryboard *sb;
    FIExternalLinkViewController *externalView;
    FIGalleryViewController *galleryView;
    FIContentViewController *contentView;
    NSString *pathToPdf;
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
    if (flow.showMenu && !flow.fromSearch)
    {
        flow.showMenu = false;
        [self showMenu:self];
        menuShown = true;
    }
    
    if (flow.fromSearch) {
        [self openGalleryFromSearch:flow.galToOpen andReplace:false andType:[[flow mediaToOpen] mediaType]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)openCategory:(FFotonaMenu *)fotonaCategory
{
    BOOL replace = false;
    if ([lastCategory intValue] != [[fotonaCategory fotonaCategoryType] intValue]) {
        if (openedView != nil) {
            [openedView willMoveToParentViewController:nil];
            [openedView.view removeFromSuperview];
            [openedView removeFromParentViewController];
            
        }
        replace = true;
        lastCategory = [fotonaCategory fotonaCategoryType];
    }
    switch ([[fotonaCategory fotonaCategoryType] intValue]) {
        case 2:{
            [FGoogleAnalytics writeGAForItem:[fotonaCategory title] andType:GAFOTONAWEBPAGEINT];
            [self openExternalLink:[fotonaCategory externalLink] andReplace:replace];
        }
            break;
        case 3:{
            FIFlowController *flow = [FIFlowController sharedInstance];
            
            flow.caseFlow = [FDB getCaseWithID:[fotonaCategory categoryID]];
            if (flow.caseMenu != nil)
            {
                [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
            }
            [self.tabBarController setSelectedIndex:3];
        }
            break;
        case 4:{
            [self openGallery:[fotonaCategory galleryItemIDs] andReplace:replace andType:MEDIAVIDEO];
        }
             break;
        case 5:{
            [self openContent:[fotonaCategory title] withDescription:[fotonaCategory text] andReplace:replace];
        }
            break;
        case 6:{
           [self openGallery:[fotonaCategory galleryItemIDs] andReplace:replace andType:MEDIAPDF];
        }
            break;
        default:
            break;
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

#pragma mark - Open Gallery

- (void) openGallery:(NSString *) galleryItems andReplace:(BOOL) replace andType:(NSString *)mediaType
{
    if (galleryView == nil) {
        galleryView = [sb instantiateViewControllerWithIdentifier:@"galleryView"];
        replace = true;
    }
    
    galleryView.galleryItems = galleryItems;
    galleryView.galleryType = mediaType;
    galleryView.category = @"0";
    if (replace)
    {
        [self openViewInContainer:galleryView];
    }
    
}

- (void) openGalleryFromSearch:(NSString *) galleryItems andReplace:(BOOL) replace andType:(NSString *)mediaType
{
    
    if (galleryView == nil) {
        galleryView = [sb instantiateViewControllerWithIdentifier:@"galleryView"];
        replace = true;
    }
    galleryView.galleryItems = galleryItems;
    galleryView.galleryType = mediaType;
    galleryView.category = @"0";
    
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
    }
    [self openViewInContainer:galleryView];
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

-(void)clearViews
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (openedView != nil) {
        [openedView willMoveToParentViewController:nil];
        [openedView.view removeFromSuperview];
        [openedView removeFromParentViewController];
        openedView = nil;
        if (flow.fotonaMenu != nil )
        {
            [[[flow fotonaMenu] navigationController] popToRootViewControllerAnimated:false];
            [flow.fotonaMenuArray removeAllObjects];
        }
    }
    
    openedView = nil;
    lastCategory = @"";
    if (flow.fotonaMenuArray.count > 1) {
        [flow.fotonaMenuArray removeAllObjects];
    }
    
    if (![self.navigationController.visibleViewController isKindOfClass:[FIFotonaMenuViewController class]]) {
        [self showMenu:self];
    }
}

@end

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
#import "BubbleControler.h"
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
    [self showBubbles];
    
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



#pragma mark - BUBBLES :D

-(void)showBubbles
{
    NSString *usr = [FCommon getUser];
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
        NSString *usr = [FCommon getUser];
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

//
//  FIVideoGalleryViewController.m
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIGalleryViewController.h"
#import "FDB.h"
#import "MBProgressHUD.h"
#import "FDownloadManager.h"
#import "FIFlowController.h"
#import "FGoogleAnalytics.h"
#import "FIGalleryTableViewCell.h"
#import "FHelperThumbnailImg.h"
#import "FIExternalLinkViewController.h"
#import "FIPDFViewController.h"


@interface FIGalleryViewController ()
{
    NSMutableArray *mediaArray;
    NSUInteger numberOfImages;
    NSString *lastGalleryItems;
    FIPDFViewController *pdfViewController;
}

@property (nonatomic, strong)UIImage *defaultVideoImage;

@end

@implementation FIGalleryViewController

@synthesize galleryItems;
@synthesize galleryType;
@synthesize videoGalleryTableView;
@synthesize category;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    mediaArray = NSMutableArray.new;
    lastGalleryItems = @"";
    
    [self.videoGalleryTableView setNeedsLayout];
    [self.videoGalleryTableView layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    FIFlowController *flow = [FIFlowController sharedInstance];
    
    if (flow.lastIndex == 2) {
        flow.videoView = self;
    }
    [self loadGallery];
    [videoGalleryTableView reloadData];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)viewDidAppear:(BOOL)animated
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.fromSearch) {
        if ([flow.mediaToOpen.mediaType  intValue] == [MEDIAVIDEO intValue]) {
            [self openVideo:flow.mediaToOpen];
        } else {
            [self openPdf:flow.mediaToOpen];
        }
        flow.fromSearch = false;
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Open Galery

-(void)loadGallery
{
        if ([galleryItems isEqualToString:@"-1"]) {
            
            mediaArray = [FDB getVideoswithCategory:category];
        } else
        {
            mediaArray = [FDB getMediaForGallery:galleryItems withMediType:galleryType];
        }

    numberOfImages = [mediaArray count];
    if (![lastGalleryItems isEqualToString:galleryItems]) {
        [videoGalleryTableView setContentOffset:CGPointZero animated:YES];
    }
    
    if (mediaArray.count > 0) {
        [FHelperThumbnailImg preloadImage:mediaArray mediaType:galleryType  forTableView:videoGalleryTableView orCollectionView:nil onIndex:nil];
    }
    
}

-(void) openVideo:(FMedia *) video
{
    [FCommon playVideoOnIphone:video onViewController:self];
}


#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastGalleryItems = galleryItems;
    
    if ([galleryItems isEqualToString:@"-1"]) {
        
        mediaArray = [FDB getVideoswithCategory:category];
    } else
    {
        mediaArray = [FDB getMediaForGallery:galleryItems withMediType:galleryType];
    }
    FMedia *media=[mediaArray objectAtIndex:[indexPath row]];
    if ([[media mediaType] intValue] == [MEDIAVIDEO intValue]) {
        [self openVideo:media];
    } else {
        if ([[media mediaType] intValue] == [MEDIAPDF intValue]) {
            [self openPdf:media];
        }
    }
          
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIGalleryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FITableGalleryCells" owner:self options:nil] objectAtIndex:0];
    [cell setContentForMedia:mediaArray[indexPath.row] forTableView:tableView onIndex:indexPath];
    cell.userInteractionEnabled = cell.enabled;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mediaArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 182;
}

#pragma mark - Getting Images

-(void)reloadCells:(NSString *)videoToReload
{
    for (FMedia *vid in mediaArray) {
        if ([videoToReload isEqualToString:vid.itemID]) {
            [self loadGallery];
            [self.videoGalleryTableView reloadData];
            break;
        }
    }
}

#pragma mark - Open PDF

-(void) openPdf:(FMedia *) pdf{
    if (pdfViewController == nil) {
        pdfViewController = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"pdfViewController"];
    }
    pdfViewController.pdfMedia = pdf;
    [[self navigationController] pushViewController:pdfViewController animated:YES];
}

#pragma mark - Refresh

-(void) refreshCellWithItemID:(NSString *)itemID andItemType:(NSString *) itemType{
    if ([galleryType intValue] == [itemType intValue]) {
        for (int i = 0; i<[mediaArray count]; i++){
            FMedia *item = mediaArray[i];
            if ([[item itemID] intValue]== [itemID intValue]) {
                NSIndexPath *index = [NSIndexPath  indexPathForItem:i inSection:0];
                [videoGalleryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

@end

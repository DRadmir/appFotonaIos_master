//
//  FIVideoGalleryViewController.m
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIGalleryViewController.h"
#import "FIVideoGalleryTableViewCell.h"
#import "FDB.h"
#import "MBProgressHUD.h"
#import "FDownloadManager.h"
#import "FIFlowController.h"
#import "FGoogleAnalytics.h"
#import "FIGalleryTableViewCell.h"
#import "FHelperThumbnailImg.h"
#import "FIExternalLinkViewController.h"


@interface FIGalleryViewController ()
{
    NSMutableArray *mediaArray;
    NSUInteger numberOfImages;
    NSString *lastGalleryItems;
    NSString *pathOnline;
    FIExternalLinkViewController *externalView;

   
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
        [FHelperThumbnailImg preloadImage:mediaArray mediaType:galleryType  forTableView:videoGalleryTableView onIndex:nil];
    }
    
}

-(void) openVideo:(FMedia *) video
{
    [FGoogleAnalytics writeGAForItem:[video title] andType:GAFOTONAVIDEOINT];
    BOOL downloaded = YES;
    NSString *local= [FMedia  createLocalPathForLink:[video path] andMediaType:MEDIAVIDEO];

    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:local];
    }
    
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:local] && downloaded && flag) {
          [FCommon playVideoFromURL:local onViewController:self localSaved:YES];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            
            [FCommon playVideoFromURL:video.path onViewController:self localSaved:NO];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
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
    [cell setContentForMedia:mediaArray[indexPath.row]];
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
    [FGoogleAnalytics writeGAForItem:[pdf title] andType:GAFOTONAPDFINT];
    pathOnline = [pdf path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,FOLDERPDF]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,FOLDERPDF] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",docDir,FOLDERPDF]]];
    }
    NSString *local= [FMedia createLocalPathForLink:[pdf path] andMediaType:MEDIAPDF];

    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:local];
    }
    if (([[NSFileManager defaultManager] fileExistsAtPath:local]) && (downloaded) && [FDB checkIfBookmarkedForDocumentID:[pdf itemID] andType:BOOKMARKPDF]) {
        [self openPDFFromUrl:local];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            [self openExternalLink:pathOnline];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}


-(void) openPDFFromUrl:(NSString *)fileURL
{
    pathOnline = fileURL;
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
    return [NSURL fileURLWithPath:pathOnline]; //path of the file to be displayed
}

#pragma mark - Open Link

- (void) openExternalLink:(NSString *) url
{
    if (externalView == nil) {
        externalView = [[UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"webViewController"];
    }
    externalView.urlString = url;
    [[self navigationController] pushViewController:externalView animated:YES];
}






@end

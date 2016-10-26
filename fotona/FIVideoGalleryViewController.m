//
//  FIVideoGalleryViewController.m
//  fotona
//
//  Created by Janos on 21/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIVideoGalleryViewController.h"
#import "FIVideoGalleryTableViewCell.h"
#import "FDB.h"
#import "MBProgressHUD.h"
#import "FDownloadManager.h"
#import "FIFlowController.h"
#import "FGoogleAnalytics.h"
#import "FIGalleryTableViewCell.h"


@interface FIVideoGalleryViewController ()
{
    NSMutableArray *videoArray;
    int numberOfImages;
    NSString *lastGallery;
   
}

@property (nonatomic, strong)UIImage *defaultVideoImage;

@end

@implementation FIVideoGalleryViewController

NSMutableDictionary *preloadGalleryMoviesImages;

@synthesize galleryID;
@synthesize defaultVideoImage = _defaultVideoImage;
@synthesize videoGalleryTableView;
@synthesize category;


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



- (void)viewDidLoad {
    [super viewDidLoad];
    
    videoArray = NSMutableArray.new;
    preloadGalleryMoviesImages = [[NSMutableDictionary alloc] init];
    lastGallery = @"";
    

    
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
        if (!flow.openPDF) {
            [self openVideo:flow.vidToOpen];
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
    if ([galleryID isEqualToString:@"-1"]) {
        
        videoArray = [FDB getVideoswithCategory:category];
    } else
    {
        videoArray = [FDB getVideosWithGallery:galleryID];
    }
    
    numberOfImages = [videoArray count];
    if (![lastGallery isEqualToString:galleryID]) {
        [videoGalleryTableView setContentOffset:CGPointZero animated:YES];
    }
    
    if (videoArray.count > 0 && ![lastGallery isEqualToString:galleryID]) {
        [self preloadMoviesImageFI:videoArray videoGalleryId:galleryID];
    }
    
}

-(void) openVideo:(FMedia *) video
{
    [FGoogleAnalytics writeGAForItem:[video title] andType:GAFOTONAVIDEOINT];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:video.localPath];
    }
    
    
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:video.localPath] && downloaded && flag) {
          [FCommon playVideoFromURL:video.localPath onViewController:self];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            FMedia *vid=[videoArray objectAtIndex:1];
            [FCommon playVideoFromURL:vid.path onViewController:self];
        } else {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}


#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastGallery = galleryID;
    
    if ([galleryID isEqualToString:@"-1"]) {
        
        videoArray = [FDB getVideoswithCategory:category];
    } else
    {
        videoArray = [FDB getVideosWithGallery:galleryID];
    }
    FMedia *vid=[videoArray objectAtIndex:[indexPath row]];
    [self openVideo:vid];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FIGalleryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FITableGalleryCells" owner:self options:nil] objectAtIndex:0];
    [cell setContentForVideo:videoArray[indexPath.row]];
  
//    FIVideoGalleryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoGalleryTableViewCell"];
//    cell.video = videoArray[indexPath.row];
//    [cell fillCell];
//    cell.parent = self;
//    
//    [[cell imgVideoThumbnail] setClipsToBounds:YES];
//    //[[cell imgVideoThumbnail] setContentMode:UIViewContentModeCenter];
//    
//    FVideo *vid= [videoArray objectAtIndex:indexPath.row];
//    
//    [cell setVideo:vid];
//    NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:vid.itemID];
//    UIImage *img = [preloadGalleryMoviesImages objectForKey:videoKey];
//    [[cell imgVideoThumbnail] setImage:img];
    
   // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSLog(@"%f", cell.frame.size.width);
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoArray.count;
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

-(void)preloadMoviesImageFI:(NSMutableArray *)videosArray videoGalleryId:(NSString *)galleryId//TODO: preselt to v svoj fail, pa tm nrdit de dobi not UITABLEVIEWcell in pol poklicat nazaj na celico eno metodo nekak
{
    NSMutableDictionary *temp;
    if ([APP_DELEGATE videoImages]==nil) {
        temp =  [[NSMutableDictionary alloc] init];
    } else{
        temp =  [APP_DELEGATE videoImages];
    }
    //default video image
    for (int i=0;i<[videosArray count];i++)
    {
        NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:[[videosArray objectAtIndex:i] itemID]];
        
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
            FMedia *vid=[videosArray objectAtIndex:i];
            //id of image inside preloadGalleryMoviesImages
            NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:[[videosArray objectAtIndex:i] itemID]];
            
            //image is not default
            if ([preloadGalleryMoviesImages objectForKey:videoKey] != self.defaultVideoImage) {
                if([APP_DELEGATE connectedToInternet]){
                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid mediaImage]];
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
            if (galleryId != galleryID) {
                return;
            }
            
            
            
            if ([preloadGalleryMoviesImages count] <= i) {
                return;
            }
            
            UIImage *img;
            NSArray *pathComp=[[vid mediaImage] pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[vid mediaImage] lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                NSData *data=[NSData dataWithContentsOfFile:pathTmp];
                img = [UIImage imageWithData:data];
            } else{
                NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid mediaImage]];
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
            }
            
            
            if (img!=nil) {
                
                UIGraphicsEndImageContext();
                NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                
                
                
                [preloadGalleryMoviesImages setValue:img forKey:videoKey];
                NSMutableDictionary *temp;
                if ([APP_DELEGATE videoImages]==nil) {
                    temp =  [[NSMutableDictionary alloc] init];
                } else{
                    temp =  [APP_DELEGATE videoImages];
                }
                [temp setValue:img forKey:videoKey];
                [APP_DELEGATE setVideoImages:temp];
                dispatch_async(dispatch_get_main_queue(), ^{
                FIGalleryTableViewCell *cell = (FIGalleryTableViewCell *)[videoGalleryTableView cellForRowAtIndexPath:tableIndexPath];
//                FIVideoGalleryTableViewCell *cell = (FIVideoGalleryTableViewCell *)[videoGalleryTableView cellForRowAtIndexPath:tableIndexPath];
                if (cell)
                {
//                    [[cell imgVideoThumbnail] setImage:img];
                    [cell refreshVideoThumbnail:img];
                }
                NSMutableArray* indexArray = [NSMutableArray array];
                [indexArray addObject:tableIndexPath];
                
                   // [videoGalleryTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
                });
            }
        });
    }
    
    NSString *today=[FCommon currentTimeInLjubljana];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"thubnailsLastUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(NSString *)getpreloadGalleryMoviesImagesKeyWithGalleryId:(NSString *)galleryId videoId:(NSString *)videoId
{
    return [NSString stringWithFormat:@"%@_%@", galleryId, videoId];
}

-(void)reloadCells:(NSString *)videoToReload
{
    for (FMedia *vid in videoArray) {
        if ([videoToReload isEqualToString:vid.itemID]) {
            [self loadGallery];
            [self.videoGalleryTableView reloadData];
            break;
        }
    }
}

@end

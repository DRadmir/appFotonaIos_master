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


@interface FIVideoGalleryViewController ()
{
    NSMutableArray *videoArray;
    int numberOfImages;
    NSString *lastGallery;
    AVQueuePlayer *player;
    AVPlayerViewController *controller;
}

@property (nonatomic, strong)UIImage *defaultVideoImage;

@end

@implementation FIVideoGalleryViewController

NSMutableDictionary *preloadGalleryMoviesImages;

@synthesize galleryID;
@synthesize defaultVideoImage = _defaultVideoImage;
@synthesize videoGalleryTableView;
@synthesize moviePlayer;
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
    
    self.videoGalleryTableView.estimatedRowHeight = 360;
    self.videoGalleryTableView.rowHeight = UITableViewAutomaticDimension;
    
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

-(void) openVideo:(FVideo *) video
{
    [FGoogleAnalytics writeGAForItem:[video title] andType:FOTONAVIDEOINT];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:video.localPath];
    }
    
    
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:video.localPath] && downloaded && flag) {
        NSString* strurl =video.localPath;
        NSURL *videoURL=[NSURL fileURLWithPath:strurl];
        moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        [moviePlayer.moviePlayer play];
    }else
    {
        if([APP_DELEGATE connectedToInternet]){
            NSString* strurl =video.path;
            NSURL *videoURL=[NSURL URLWithString:strurl];
            
            FVideo *vid=[videoArray objectAtIndex:1];
            NSString* strurl2 =vid.path;
            NSURL *videoURL2=[NSURL URLWithString:strurl2];

            AVPlayer *avplayer = [AVPlayer playerWithURL:videoURL];
       
//            AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:avplayer];
//            avplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//            
//            layer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//            [self.view.layer addSublayer: layer];
//            [avplayer play];
            
//            AVPlayerItem *item1 = [AVPlayerItem playerItemWithURL:videoURL];
//            AVPlayerItem *item2 = [AVPlayerItem playerItemWithURL:videoURL2];
//            player = [[AVQueuePlayer alloc] initWithItems:@[item1, item2]];
//
//            // create a player view controller
            
            player = [[AVQueuePlayer alloc] initWithURL:videoURL];
            controller = [[AVPlayerViewController alloc] init];
            controller.player = player;
            [self presentViewController:controller animated:YES completion:nil];
            [player play];
           
            
            
//            moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//            moviePlayer.moviePlayer.shouldAutoplay = false;
//            moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
//            [moviePlayer.moviePlayer play];
//            
//
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
    FVideo *vid=[videoArray objectAtIndex:[indexPath row]];
    [self openVideo:vid];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIVideoGalleryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoGalleryTableViewCell"];
    cell.video = videoArray[indexPath.row];
    [cell fillCell];
    cell.parent = self;
    
    [[cell imgVideoThumbnail] setClipsToBounds:YES];
    //[[cell imgVideoThumbnail] setContentMode:UIViewContentModeCenter];
    
    FVideo *vid= [videoArray objectAtIndex:indexPath.row];
    
    [cell setVideo:vid];
    NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:vid.itemID];
    UIImage *img = [preloadGalleryMoviesImages objectForKey:videoKey];
    [[cell imgVideoThumbnail] setImage:img];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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

#pragma mark - Getting Images

-(void)preloadMoviesImageFI:(NSMutableArray *)videosArray videoGalleryId:(NSString *)galleryId
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
            FVideo *vid=[videosArray objectAtIndex:i];
            //id of image inside preloadGalleryMoviesImages
            NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:[[videosArray objectAtIndex:i] itemID]];
            
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
            if (galleryId != galleryID) {
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
                FIVideoGalleryTableViewCell *cell = (FIVideoGalleryTableViewCell *)[videoGalleryTableView cellForRowAtIndexPath:tableIndexPath];
                if (cell)
                {
                    [[cell imgVideoThumbnail] setImage:img];//iconImage];
                }
                NSMutableArray* indexArray = [NSMutableArray array];
                [indexArray addObject:tableIndexPath];
                
                    [videoGalleryTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
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
    for (FVideo *vid in videoArray) {
        if ([videoToReload isEqualToString:vid.itemID]) {
            [self loadGallery];
            [self.videoGalleryTableView reloadData];
            break;
        }
    }
}

@end

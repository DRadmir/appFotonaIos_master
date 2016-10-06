//
//  FGalleryViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 6/6/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FGalleryViewController.h"
#import "FImage.h"
#import "FMDatabase.h"

@interface FGalleryViewController ()

@end

@implementation FGalleryViewController
@synthesize images;
@synthesize index;
@synthesize allowDelete;
@synthesize session;
@synthesize isShowroom;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithImages:(NSMutableArray *)imgs index:(int)i allowDelete:(BOOL)del
{
    self=[super init];
    if (self) {
        [self setImages:imgs];
        [self setIndex:i];
        [self setAllowDelete:del];
        if (allowDelete) {
            isShowroom=YES;
        }else
        {
            isShowroom=NO;
        }
    }
    
    return self;
}

-(id)initWithSession:(FSession *)s allowDelete:(BOOL)del
{
    self=[super init];
    if (self) {
        [self setSession:s];
        [self setAllowDelete:del];
        [self setImages:[[session.images componentsSeparatedByString:@"::"] mutableCopy]];
        [self setIndex:0];
        isShowroom=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    imageViews=[[NSMutableArray alloc] init];
    titleViews=[[NSMutableArray alloc] init];
    descriptionViews=[[NSMutableArray alloc] init];
    pinchRecognizers=[[NSMutableArray alloc] init];
    tmpViewsArray=[[NSMutableArray alloc] init];
    
    if (allowDelete) {
        [deleteBtn setHidden:NO];
        [self setOutlets1:NO];
        
    }else{
        [self setOutlets:NO];
    }

}


-(void)setOutlets:(BOOL)orient
{
    
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    float width=768;
    float height=1024;
    if (orientation!=UIInterfaceOrientationPortrait) {
        width=1024;
        height=768;
    }
    
    [imageScroll setContentSize:CGSizeMake(width*[images count],height-87)];
    [imageScroll setContentOffset:CGPointMake(width*index, 0)];
    
    int x=0;
    for (FImage *img in images) {
        UIView *tmpView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, width, height-87)];
        [tmpView setBackgroundColor:[UIColor clearColor]];
        [tmpView setClipsToBounds:YES];
        [imageScroll addSubview:tmpView];
        [tmpViewsArray addObject:tmpView];
        UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(100, 0, width-200, 50)];
        [title setNumberOfLines:1];
        [title setText:img.title];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"Helevetica-Neue" size:22.0]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [tmpView addSubview:title];
        [titleViews addObject:title];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, width, 550)];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                           initWithTarget:self action:@selector(imagePinched:)];
        [imgView setUserInteractionEnabled:YES];
        [imgView addGestureRecognizer:pinchRecognizer];
        
        [pinchRecognizers addObject:pinchRecognizer];
        
        [imgView setClipsToBounds:YES];
        [imageViews addObject:imgView];
        UILabel *desc=[[UILabel alloc] initWithFrame:CGRectMake(100, 620, width-200, 0)];
        [desc setNumberOfLines:0];
        [desc setText:img.description];
        [desc setTextColor:[UIColor whiteColor]];
        [desc setFont:[UIFont fontWithName:@"Helevetica-Neue" size:15.0]];
        [desc sizeToFit];
        [tmpView addSubview:desc];
        [descriptionViews addObject:desc];
        
        x+=width;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            NSString *pathTmp = [NSString stringWithFormat:@"%@%@",docDir,img.localPath];
            if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                
            }else{
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL URLWithString:pathTmp]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [imgView setImage:image];
                [tmpView addSubview:imgView];
            });
        });
    }
}

-(void)setOutlets1:(BOOL)orient
{
    
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    float width=768;
    float height=1024;
    if (orientation!=UIInterfaceOrientationPortrait) {
        width=1024;
        height=768;
    }
    
    [imageScroll setContentSize:CGSizeMake(width*[images count],height-87)];
    [imageScroll setContentOffset:CGPointMake(width*index, 0)];
    
    int x=0;
    for (NSString *img in images) {
        UIView *tmpView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, width, height-87)];
        [tmpView setBackgroundColor:[UIColor clearColor]];
        [tmpView setClipsToBounds:YES];
        UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(100, 0, width-200, 50)];
        [title setNumberOfLines:1];
        [title setText:[img lastPathComponent]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"Helevetica-Neue" size:22.0]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [tmpView addSubview:title];
        [titleViews addObject:title];
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, width, 550)];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(imagePinched:)];
        [imgView setUserInteractionEnabled:YES];
        [imgView addGestureRecognizer:pinchRecognizer];
        [imgView setClipsToBounds:YES];
        [pinchRecognizers addObject:pinchRecognizer];
        [imageViews addObject:imgView];
//        UILabel *desc=[[UILabel alloc] initWithFrame:CGRectMake(x+100, 620, width-200, 0)];
//        [desc setNumberOfLines:0];
//        [desc setText:img.description];
//        [desc setTextColor:[UIColor whiteColor]];
//        [desc setFont:[UIFont fontWithName:@"Helevetica-Neue" size:15.0]];
//        [desc sizeToFit];
//        [imageScroll addSubview:desc];
        
        x+=width;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:img]]];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [imgView setImage:image];
                [tmpView addSubview:imgView];
            });
        });
        
        [imageScroll addSubview:tmpView];
        [tmpViewsArray addObject:tmpView];
        
    }
}


-(IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)deletePhotoAlert:(id)sender
{
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure that you want to delete this photo?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [av setTag:1];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        if (buttonIndex==1) {
            [self deletePhoto];
        }
    }
}

-(void)deletePhoto
{
    
    if (isShowroom) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[images objectAtIndex:index]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[images objectAtIndex:index] error:nil];
        }
        [images removeObjectAtIndex:index];
    }else{
        [images removeObjectAtIndex:index];
        NSString *imgs=[images componentsJoinedByString:@"::"];
        if ([imgs isEqualToString:@"::"]) {
            imgs=@"";
        }
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        [database executeUpdate:@"UPDATE Session set images=? where id=?",imgs,session.sessionID];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
        [database close];
    }
    if (images.count>0) {
        for (UIView *v in imageScroll.subviews) {
            [v removeFromSuperview];
        }
        [self setOutlets1:NO];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    NSLog(@"page %lu",page);
    index=(int)page;
}

//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return [imageViews objectAtIndex:index];
//}
//
//-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
//{
//    
//}

- (IBAction)imagePinched:(id)sender {
    
    UIPinchGestureRecognizer *pinchRecognizer=[pinchRecognizers objectAtIndex:index];
    
    if (pinchRecognizer.state == UIGestureRecognizerStateEnded || pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        
        NSLog(@"gesture.scale = %f", pinchRecognizer.scale);
        UIImageView *tmpImg=(UIImageView *)[imageViews objectAtIndex:index];
        CGFloat currentScale = tmpImg.frame.size.width / tmpImg.bounds.size.width;
        CGFloat newScale = currentScale * pinchRecognizer.scale;
        
        if (newScale < 1) {
            newScale = 1;
        }
        if (newScale > 1.5) {
            newScale = 1.5;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        tmpImg.transform = transform;
        pinchRecognizer.scale = 1;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [imageScroll setDelegate:nil];
//    for (UIView *v in imageScroll.subviews) {
//        [v removeFromSuperview];
//    }
//    for (int i=0; i<imageViews.count; i++) {
//        if (i!=index) {
//            [[imageViews objectAtIndex:i] setHidden:YES];
//        }
//    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
    [self rotateViews];
//    for (int i=0; i<imageViews.count; i++) {
//        if (i!=index) {
//            [[imageViews objectAtIndex:i] setHidden:NO];
//        }
//    }
}

-(void)rotateViews
{
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    float width=768;
    float height=1024;
    if (orientation!=UIInterfaceOrientationPortrait) {
        width=1024;
        height=768;
    }
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    int x=0;
    for (int i=0; i<[tmpViewsArray count]; i++) {
        
        [[tmpViewsArray objectAtIndex:i] setFrame:CGRectMake(x, 0, width, height-87)];
        
        [[imageViews objectAtIndex:i] setFrame:CGRectMake(0, 50, width, 550)];
        
        [[titleViews objectAtIndex:i] setFrame:CGRectMake(100, 0, width-200, 50)];
        
        if (descriptionViews.count>0) {
            [[descriptionViews objectAtIndex:i] setFrame:CGRectMake(100, 620, width-200,0)];
        }
        
        x+=width;
    }
    [imageScroll setContentSize:CGSizeMake(width*[images count],height-87)];
    [imageScroll setContentOffset:CGPointMake(width*index, 0)];
    [UIView commitAnimations];
    [imageScroll setDelegate:self];
    
//    [imageScroll setFrame:CGRectMake(imageScroll.frame.origin.x, imageScroll.frame.origin.y, width, height-87)];
    
}

@end

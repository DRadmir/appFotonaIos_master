//
//  FIGalleryController.m
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIGalleryController.h"
#import "FMedia.h"
#import "FImage.h"
#import <AVFoundation/AVFoundation.h>
#import "FNews.h"
#import "FEvent.h"

@implementation FIGalleryController

@synthesize parent;
@synthesize scrollViewGallery;
@synthesize imagesArray;
@synthesize videosArray;
@synthesize type;
@synthesize caseWithGallery;

-(void)createGalleryWithImages:(NSArray *)images andVideos:(NSArray *)videos forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height  fromCase:(FCase *)caseContainingGallery
{
    caseWithGallery = caseContainingGallery;
    for (UIImageView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    int x = 0;
    int imgSize = 200;
    imagesArray = [[NSMutableArray alloc] init];
    
    for (FImage *image in images) {
        if ([image.deleted intValue] == 0) {
            [imagesArray addObject:image];
        }
    }

    videosArray =  [[NSMutableArray alloc] init];
    for (FMedia *video in videos) {
        if ([video.deleted intValue] == 0) {
            [videosArray addObject:video];
        }
    }
    
    
    for (int i=0;i<[videos count];i++) {
        FMedia *vid=[videos objectAtIndex:i];
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(x, 0, imgSize-30, imgSize-30)];
        [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [tmpImg setClipsToBounds:NO];
        x=x+(imgSize-20);
        
        dispatch_queue_t queue = dispatch_queue_create("Video queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            NSURL *videoURL;
            NSString *localPath = [FMedia createLocalPathForLink:vid.path andMediaType:MEDIAVIDEO];
            if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                videoURL= [NSURL URLWithString:vid.path] ;
            }else{
                videoURL=[NSURL fileURLWithPath:localPath];
            }
            
            AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            generate1.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMakeWithSeconds([vid.time integerValue], 1);
            CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
            UIImage *image=one;
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:image forState:UIControlStateNormal];
                [tmpImg addTarget:self action:@selector(openVideo:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:tmpImg];
                UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(x-(imgSize-20), imgSize-30, imgSize-40, 20)];
                [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
                [videoName setText:vid.title];
                [videoName setTextAlignment:NSTextAlignmentCenter];
                [scrollView addSubview:videoName];
            });
        });
    }
    
    int xS=210*(int)[videos count];
    
    
    for (int i=0;i<images.count;i++){
        FImage *img=[images objectAtIndex:i];
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(xS, 0, imgSize-30, imgSize-30)];
        [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [tmpImg setClipsToBounds:YES];
        xS=xS+(imgSize-20);
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            NSString *pathTmp = [FMedia createLocalPathForLink:img.path andMediaType:MEDIAIMAGE];
            if (pathTmp == nil || ![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            }else{
                
                image =[UIImage imageWithContentsOfFile:pathTmp];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:image forState:UIControlStateNormal];
                [tmpImg setTag:i];
                [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:tmpImg];
                UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(xS-(imgSize-20), imgSize-30, imgSize-40, 20)];
                [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
                [videoName setText:img.title];
                [videoName setTextAlignment:NSTextAlignmentCenter];
                [scrollView addSubview:videoName];
            });
            
        });
    }
    if ((images.count>0) || ([videos count]>0)) {
        [scrollView setHidden:NO];
        [scrollView setContentSize:CGSizeMake((imgSize+10)*(images.count+videos.count)-10, imgSize)];
        [scrollView setContentOffset:CGPointZero animated:YES];
        height.constant = imgSize;
        //[galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 230)];
        
    } else{
        //[galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 0)];
        [scrollView setHidden:YES];
        [scrollView setContentSize:CGSizeMake(0, 0)];
        height.constant = 0;
    }
}

-(void)createGalleryWithImagesForNews:(FNews *)newsGallery forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height andBottomHeight:(NSLayoutConstraint *)bottomHeight
{
    NSMutableArray *imgsClass = [NSMutableArray new];
    
    for (UIImageView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    int x = 0;
    int imgSize = 150;

    for (UIView *v in scrollView.subviews) {
        [v removeFromSuperview];
    }
    NSMutableArray *imgs;
    if ([newsGallery.rest isEqualToString:@"0"] || [newsGallery.bookmark isEqualToString:@"1"]) {
        imgs =[newsGallery images];
    }  else {
        imgs =[newsGallery imagesLinks];
    }
    UIImage *img;
    for (int i=0;i<imgs.count;i++){
        if ([newsGallery.rest isEqualToString:@"1"] && [newsGallery.bookmark isEqualToString:@"0"]) {
            if  ([ConnectionHelper connectedToInternet] &&  ![[imgs objectAtIndex:i] isEqualToString:@""]) {
                NSString *url_Img_FULL = [imgs objectAtIndex:i];
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                [imgs replaceObjectAtIndex:i withObject:img];
            } else {
                [imgs removeAllObjects];
                break;
            }
        } else{
            img =[imgs objectAtIndex:i];
        }
        [imgsClass addObject:img];
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(x, 0, imgSize, imgSize)]; //size of images in menu--------
        [tmpImg setClipsToBounds:YES];
        x=x+imgSize+10;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:img forState:UIControlStateNormal];
                [tmpImg setTag:i];
                [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
                [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:tmpImg];
            });
            
        });
    }
    imagesArray = imgsClass;
    if (imgs.count>0) {
        [scrollView setHidden:NO];
        [scrollView setContentSize:CGSizeMake((imgSize+10)*(imgs.count)-10, imgSize)];
        [scrollView setContentOffset:CGPointZero animated:YES];
        [newsGallery setImages:imgs];
        [newsGallery setRest:@"0"];
        height.constant=imgSize;
        bottomHeight.constant=32;
        
    } else{
        height.constant=0;
        bottomHeight.constant=0;
        [scrollView setHidden:YES];
        [scrollView setContentSize:CGSizeMake(0, 0)];
    }
}
-(void)createGalleryWithImagesForEvent:(FEvent *)eventGallery forScrollView:(UIScrollView *)scrollView andScrollHeight:(NSLayoutConstraint *)height andBottomHeight:(NSLayoutConstraint *)bottomHeight
{
    NSMutableArray *imgsClass = [NSMutableArray new];
    int imgSize = 150;
    int x=0;
    for (UIView *v in scrollView.subviews) {
        [v removeFromSuperview];
    }
    NSMutableArray *imgs=[eventGallery eventImages];
    
    for (int i=0;i<imgs.count;i++){
        
        NSLog(@"imgs");
        UIImage *img=[UIImage imageWithContentsOfFile: [imgs objectAtIndex:i]];
        [imgsClass addObject:img];
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(x, 0, imgSize, imgSize)]; //size of images in menu--------
        [tmpImg setClipsToBounds:YES];
        x=x+imgSize+10;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:img forState:UIControlStateNormal];
                [tmpImg setTag:i];
                [tmpImg.imageView setContentMode:UIViewContentModeScaleToFill];
                [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:tmpImg];
            });
            
        });
    }
    imagesArray = imgsClass;
    if (imgs.count>0) {
        [scrollView setContentSize:CGSizeMake(160*(imgs.count)-10, imgSize)];
        [scrollView setContentOffset:CGPointZero animated:YES];
        height.constant=imgSize;
        bottomHeight.constant=15;
        [scrollView setHidden:NO];
    } else{
        height.constant=0;
       bottomHeight.constant=0;
        [scrollView setHidden:YES];
        [scrollView setContentSize:CGSizeMake(0, 0)];
    }
}

-(IBAction)openVideo:(id)sender
{
    FMedia *vid=[videosArray objectAtIndex:[sender tag]];
    BOOL coverflow = [[caseWithGallery coverflow] isEqualToString:@"1"] ? YES : NO;
    [FCommon playVideo:vid onViewController:parent isFromCoverflow:coverflow];
}

-(IBAction)openGallery:(id)sender
{
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self photoAtIndex:[sender tag]];
    [parent presentViewController:photoPagesController animated:YES completion:nil];
    
}

#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < imagesArray.count){//[currentCase getImages].count){
        return YES;
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        FImage *img =imagesArray[index]; //[currentCase getImages][index];
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            if (type == 1) {
                NSString *pathTmp = [FMedia createLocalPathForLink:img.path andMediaType:MEDIAIMAGE];
                if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                    
                }else{
                    image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL fileURLWithPath:pathTmp]]];
                }
            } else{
                if (type == 2) {
                    image =imagesArray[index];
                } else{
                    if (type == 3) {
                         image = [UIImage imageWithContentsOfFile:imagesArray[index]];
                    }

                }

            }
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                handler(image);
            });
        });
        
        
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
attributedCaptionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSAttributedString *))handler{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        FImage *photo =imagesArray[index]; //[currentCase getImages][index];
        
        if (![photo.description isEqualToString:@""]) {
            if (type == 1) {
                NSMutableAttributedString *mutString=[[NSMutableAttributedString alloc] initWithData:[[NSString stringWithFormat:@"%@<br/>%@",photo.title,photo.description] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                handler([mutString string]);
            }
        }else{
            handler(photo.title);
        }
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
       
        
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index{}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index{}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index{}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index{}


#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
 shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return NO;
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    [parent.view setUserInteractionEnabled:true];
    NSLog(@"Finished using %@", photoPagesController);
    
}


@end

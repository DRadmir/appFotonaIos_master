//
//  FHelperThumbnailImg.m
//  fotona
//
//  Created by Janos on 19/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FHelperThumbnailImg.h"

@implementation FHelperThumbnailImg

//static NSMutableDictionary *preloadGalleryMoviesImages;
//
//-(UIImage *)defaultVideoImage
//{
//    if (!_defaultVideoImage) {
//        
//        _defaultVideoImage = [UIImage imageNamed:@"no_thunbail"];
//        
//        CGSize size = CGSizeMake( 300, 167);
//        UIGraphicsBeginImageContext(size);
//        
//        CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
//        [_defaultVideoImage drawInRect:imgBorder];
//        
//        _defaultVideoImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//    }
//    return _defaultVideoImage;
//}
//
//
//-(void)preloadMoviesImageFI:(NSMutableArray *)videosArray videoGalleryId:(NSString *)galleryId//TODO: preselt to v svoj fail, pa tm nrdit de dobi not UITABLEVIEWcell in pol poklicat nazaj na celico eno metodo nekak
//{
//    NSMutableDictionary *temp;
//    if ([APP_DELEGATE videoImages]==nil) {
//        temp =  [[NSMutableDictionary alloc] init];
//    } else{
//        temp =  [APP_DELEGATE videoImages];
//    }
//    //default video image
//    for (int i=0;i<[videosArray count];i++)
//    {
//        NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:[[videosArray objectAtIndex:i] itemID]];
//        
//        if (![preloadGalleryMoviesImages objectForKey:videoKey]) {
//            if ([temp objectForKey:videoKey] ) {
//                [preloadGalleryMoviesImages setValue:[temp objectForKey:videoKey] forKey:videoKey];
//            } else{
//                [preloadGalleryMoviesImages setValue:[self defaultVideoImage] forKey:videoKey];
//            }
//        }
//    }
//    
//    //queue
//    NSArray *activeQueues = @[
//                              dispatch_queue_create("videoTumbnailsLoadingQueue1",NULL),
//                              ];
//    
//    
//    for (int i=0;i<[videosArray count];i++)
//    {
//        int activeQueueIndex = i%[activeQueues count];
//        dispatch_async([activeQueues objectAtIndex:activeQueueIndex], ^{
//            FVideo *vid=[videosArray objectAtIndex:i];
//            //id of image inside preloadGalleryMoviesImages
//            NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:galleryID videoId:[[videosArray objectAtIndex:i] itemID]];
//            
//            //image is not default
//            if ([preloadGalleryMoviesImages objectForKey:videoKey] != self.defaultVideoImage) {
//                if([APP_DELEGATE connectedToInternet]){
//                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid videoImage]];
//                    UIImage *imgNew = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
//                    if (imgNew!=nil) {
//                        NSData *data1 = UIImagePNGRepresentation(imgNew);
//                        NSData *data2 = UIImagePNGRepresentation([preloadGalleryMoviesImages objectForKey:videoKey]);
//                        if (![data1 isEqual:data2]) {
//                            [preloadGalleryMoviesImages setValue:imgNew forKey:videoKey];
//                        }
//                    }
//                }
//                
//                return;
//            }
//            
//            //we are not loading current gallery
//            if (galleryId != galleryID) {
//                return;
//            }
//            
//            
//            
//            if ([preloadGalleryMoviesImages count] <= i) {
//                return;
//            }
//            
//            UIImage *img;
//            NSArray *pathComp=[[vid videoImage] pathComponents];
//            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[vid videoImage] lastPathComponent]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
//                NSData *data=[NSData dataWithContentsOfFile:pathTmp];
//                img = [UIImage imageWithData:data];
//            } else{
//                NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid videoImage]];
//                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
//            }
//            
//            
//            if (img!=nil) {
//                
//                UIGraphicsEndImageContext();
//                NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                
//                
//                
//                [preloadGalleryMoviesImages setValue:img forKey:videoKey];
//                NSMutableDictionary *temp;
//                if ([APP_DELEGATE videoImages]==nil) {
//                    temp =  [[NSMutableDictionary alloc] init];
//                } else{
//                    temp =  [APP_DELEGATE videoImages];
//                }
//                [temp setValue:img forKey:videoKey];
//                [APP_DELEGATE setVideoImages:temp];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    FIGalleryTableViewCell *cell = (FIGalleryTableViewCell *)[videoGalleryTableView cellForRowAtIndexPath:tableIndexPath];
//                    if (cell)
//                    {
//                        [cell refreshVideoThumbnail:img];
//                    }
//                    NSMutableArray* indexArray = [NSMutableArray array];
//                    [indexArray addObject:tableIndexPath];
//                });
//            }
//        });
//    }
//    
//    NSString *today=[FCommon currentTimeInLjubljana];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"thubnailsLastUpdate"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//}
//
//-(NSString *)getpreloadGalleryMoviesImagesKeyWithGalleryId:(NSString *)galleryId videoId:(NSString *)videoId
//{
//    return [NSString stringWithFormat:@"%@_%@", galleryId, videoId];
//}

@end

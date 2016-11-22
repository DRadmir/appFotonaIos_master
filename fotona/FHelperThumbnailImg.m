//
//  FHelperThumbnailImg.m
//  fotona
//
//  Created by Janos on 19/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FHelperThumbnailImg.h"
#import "FIGalleryTableViewCell.h"

@implementation FHelperThumbnailImg

static NSMutableDictionary *preloadGalleryMoviesImages;
static UIImage *defaultVideoImage;


+(UIImage *)defaultVideoImage
{
    if (!defaultVideoImage) {
        
        defaultVideoImage = [UIImage imageNamed:@"no_thunbail"];
        
        CGSize size = CGSizeMake( 300, 167);
        UIGraphicsBeginImageContext(size);
        
        CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
        [defaultVideoImage drawInRect:imgBorder];
        
        defaultVideoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return defaultVideoImage;
}


+(void)preloadImage:(NSMutableArray *)mediaArray mediaType:(NSString *)mediaType forTableView:(UITableView *)tableView orCollectionView:(UICollectionView *) collectionView onIndex:(NSIndexPath *) indexPath
{
    NSMutableDictionary *temp;
    if ([APP_DELEGATE videoImages]==nil) {
        temp =  [[NSMutableDictionary alloc] init];
    } else{
        temp =  [APP_DELEGATE videoImages];
    }
    //default video image
    for (int i=0;i<[mediaArray count];i++)
    {
        NSString *videoKey =[self getpreloadGalleryMoviesImagesKeyWithMediaId:[[mediaArray objectAtIndex:i] itemID] mediaType:mediaType];
        
        if (preloadGalleryMoviesImages == nil) {
            preloadGalleryMoviesImages = [[NSMutableDictionary alloc] init];
        }
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
                              dispatch_queue_create("videoTumbnailsLoadingQueue1",NULL)
                              ];
    
    
    for (int i=0;i<[mediaArray count];i++)
    {
        
        
        int activeQueueIndex = i%[activeQueues count];
        dispatch_async([activeQueues objectAtIndex:activeQueueIndex], ^{
            BOOL done = NO;
            UIImage * imageToLoad = defaultVideoImage;
            FMedia *media=[mediaArray objectAtIndex:i];
            //id of image inside preloadGalleryMoviesImages
            NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithMediaId:[[mediaArray objectAtIndex:i] itemID] mediaType:mediaType];
            
            //image is not default
            if ([preloadGalleryMoviesImages objectForKey:videoKey] != self.defaultVideoImage) {
                imageToLoad = [preloadGalleryMoviesImages objectForKey:videoKey];
                if([APP_DELEGATE connectedToInternet]){
                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[media mediaImage]];
                    UIImage *imgNew = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                    if (imgNew!=nil) {
                        NSData *data1 = UIImagePNGRepresentation(imgNew);
                        NSData *data2 = UIImagePNGRepresentation([preloadGalleryMoviesImages objectForKey:videoKey]);
                        if (![data1 isEqual:data2]) {
                            [preloadGalleryMoviesImages setValue:imgNew forKey:videoKey];
                            imageToLoad = imgNew;
                            
                        }
                    }
                }
                [self setImage:imageToLoad onIndex:indexPath forTableView:tableView orCollectionView:collectionView andPosition:i];
                
                done = YES;
            }
            
            //we are not loading current gallery
            if (!done && [[media mediaType] intValue] != [mediaType intValue]) {
                done = YES;
            }
            
            if (!done && [preloadGalleryMoviesImages count] <= i) {
                done = YES;
            }
            
            UIImage *img;
            NSArray *pathComp=[[media mediaImage] pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[media mediaImage] lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                NSData *data=[NSData dataWithContentsOfFile:pathTmp];
                img = [UIImage imageWithData:data];
            } else{
                NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[media mediaImage]];
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
            }
            
            if (img!=nil) {
                UIGraphicsEndImageContext();
                [preloadGalleryMoviesImages setValue:img forKey:videoKey];
                NSMutableDictionary *temp;
                if ([APP_DELEGATE videoImages]==nil) {
                    temp =  [[NSMutableDictionary alloc] init];
                } else{
                    temp =  [APP_DELEGATE videoImages];
                }
                [temp setValue:img forKey:videoKey];
                [APP_DELEGATE setVideoImages:temp];
                imageToLoad = img;
            }
            
            
            
            [self setImage:imageToLoad onIndex:indexPath forTableView:tableView orCollectionView:collectionView andPosition:i];
            
        });
    }
    
    NSString *today=[FCommon currentTimeInLjubljana];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"thubnailsLastUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(void)setImage:(UIImage *) image onIndex:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView orCollectionView:(UICollectionView *)collectionView andPosition:(int)i{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *tableIndexPath;
        if (indexPath == nil) {
            tableIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        } else {
            tableIndexPath = indexPath;
        }
        if (tableView != nil) {
            if ([[tableView cellForRowAtIndexPath:tableIndexPath] isKindOfClass:[FIGalleryTableViewCell class]]) {
                FIGalleryTableViewCell *cell = (FIGalleryTableViewCell *)[tableView cellForRowAtIndexPath:tableIndexPath];
                if (cell)
                {
                    [cell refreshMediaThumbnail:image];
                }
            }
        } else {
            if (collectionView != nil) {
                FIGalleryTableViewCell *cell = (FIGalleryTableViewCell *)[collectionView cellForItemAtIndexPath:tableIndexPath];
                if (cell)
                {
                    [cell refreshMediaThumbnail:image];
                }
                
            }
        }
    });
}

+(NSString *)getpreloadGalleryMoviesImagesKeyWithMediaId:(NSString *)mediaId mediaType:(NSString *)medaiType
{
    return [NSString stringWithFormat:@"%@_%@", mediaId, medaiType];
}

+(void)getThumbnailForMedia:(FMedia *)media onTableView:(UITableView *)tableView orCollectionView:(UICollectionView *)collectionView withIndex:(NSIndexPath *)indexPath{
    [self preloadImage:[NSMutableArray arrayWithObjects:media, nil] mediaType:[media mediaType] forTableView:tableView orCollectionView:collectionView onIndex:indexPath];
}

@end

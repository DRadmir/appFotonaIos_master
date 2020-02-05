//
//  FNewsView.m
//  fotona
//
//  Created by Janos on 12/08/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FNewsView.h"
#import "FNews.h"
#import "FImage.h"
#import "NSString+HTML.h"
#import "FMDatabase.h"
#import "HelperDate.h"
#import "HelperString.h"
#import "FDB.h"

@interface FNewsView ()

@end
NSMutableArray *relatedNews;
@implementation FNewsView

@synthesize newsView;
@synthesize newsScrollView;
@synthesize newsRelatedView;
@synthesize newsRelatedImage;
@synthesize newsRelatedTitle;
@synthesize newsRelatedDate;
@synthesize newsImageScroll;
@synthesize newsText;
@synthesize newsTitle;
@synthesize newsDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    [self openNews:[self news] andNewsArray:[self newsArray]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)openNews:(FNews *) news andNewsArray:(NSMutableArray *)newsArray{
    [newsScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    relatedNews = [[NSMutableArray alloc] init];
    for (FNews *n in newsArray) {
        if (n.newsID==news.newsID) {
            news=n;
            break;
        }
    }
    if (news.isReaded == NO) {
        news.isReaded = YES;
    }
    
    [newsTitle setText:[[news title] stringByConvertingHTMLToPlainText]];
    [newsTitle sizeToFit];
    [newsDate setText:[HelperDate formatedDate: [news nDate]]];
    newsText.attributedText = [HelperString toAttributedNews:[news text]];
    [self addImageScrollNews:[self news]];
    
    //filling related news
    int nc=0;
    
    for (FNews* n in newsArray) {
        if (nc<4 && [news newsID]!=[n newsID] ) {
            for (NSString *category in n.categories) {
                if ([[news categories] containsObject:category]) {
                    //todo dodat da odpira bookmark slike
                    UIImage *img;
                    if ([n headerImage] == nil ) {
                        NSString * header =n.headerImageLink;
                        if (header == nil || [header isEqualToString:@""]|| (![ConnectionHelper connectedToInternet])) {
                            img = [UIImage imageNamed:@"related_news"];
                        } else {
                            NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",  header];
                            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                            [n setHeaderImage:img];
                        }
                        
                    } else {
                        img = n.headerImage;
                    }
                    
                    [(UIImageView *)[newsRelatedImage objectAtIndex:nc] setImage:img];
                    [(UIImageView *)[newsRelatedImage objectAtIndex:nc] setClipsToBounds:YES];
                    [(UIImageView *)[newsRelatedImage objectAtIndex:nc] setContentMode:UIViewContentModeCenter];
                    
                    [(UILabel *)[newsRelatedTitle objectAtIndex:nc] setText:[n title]];
                    [(UILabel *)[newsRelatedDate objectAtIndex:nc] setText:[HelperDate formatedDate: [n nDate]]];
                    
                    [(UIView*)[newsRelatedView objectAtIndex:nc] setTag:nc];
                    
                    UITapGestureRecognizer *tapRelated = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(relatedClickNews:)];
                    [(UIView*)[newsRelatedView objectAtIndex:nc] addGestureRecognizer:tapRelated];
                    [(UIView *)[newsRelatedView objectAtIndex:nc] setHidden:NO];
                    
                    [relatedNews addObject:n];
                    
                    nc++;
                    break;
                }
            }
        }
        if (nc==4) {
            break;
        }
    }
    for (int t = nc; t<4; t++) {
        [(UIView *)[newsRelatedView objectAtIndex:t] setHidden:YES];
    }
    if ([FCommon isOrientationLandscape]){
        [newsView setFrame:CGRectMake(0,65, 1024, 655)];
    }
    else{
        [newsView setFrame:CGRectMake(0,65, 768, 909)];
    }
    
    [FDB setNewsRead:[self news]];
}

- (void) addImageScrollNews:(FNews *) currentNews{
    
    int x=0;
    for (UIView *v in newsImageScroll.subviews) {
        [v removeFromSuperview];
    }
    NSMutableArray *imgs;
    if ([currentNews.rest isEqualToString:@"0"] || [currentNews.bookmark isEqualToString:@"1"]) {
        imgs =[currentNews images];
    }  else {
        imgs =[currentNews imagesLinks];
    }
    UIImage *img;
    for (int i=0;i<imgs.count;i++){
        if ([currentNews.rest isEqualToString:@"1"] && [currentNews.bookmark isEqualToString:@"0"]) {
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
        
        UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
        [tmpImg setFrame:CGRectMake(x, 0, 150, 150)]; //size of images in menu--------
        [tmpImg setClipsToBounds:YES];
        x=x+160;
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                [tmpImg setImage:img forState:UIControlStateNormal];
                [tmpImg setTag:i];
                [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
                [tmpImg addTarget:self action:@selector(openGalleryNewsImages:) forControlEvents:UIControlEventTouchUpInside];
                [newsImageScroll addSubview:tmpImg];
            });
            
        });
    }
    
    if (imgs.count>0) {
        [newsImageScroll setHidden:NO];
        [newsImageScroll setContentSize:CGSizeMake(160*(imgs.count)-10, 180)];
        [newsImageScroll setContentOffset:CGPointZero animated:YES];
        [currentNews setImages:imgs];
        [currentNews setRest:@"0"];
        self.scrollImagesViewHeight.constant=180;
        self.scrollImagesViewBottom.constant=32;
        
    } else{
        self.scrollImagesViewHeight.constant=0;
        self.scrollImagesViewBottom.constant=0;
        [newsImageScroll setHidden:YES];
        [newsImageScroll setContentSize:CGSizeMake(0, 0)];
    }
    
}




#pragma mark - Related click

-(void)relatedClickNews:(UITapGestureRecognizer *)recognizer {
    NSUInteger viewIndex = recognizer.view.tag;
    FNews * tempNews = [relatedNews objectAtIndex:viewIndex];
    self.news = tempNews;
    [self openNews:[self news] andNewsArray:[self newsArray]];
}

#pragma mark - Opening images


-(IBAction)openGalleryNewsImages:(id)sender
{
    //    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    //    previewController.dataSource = self;
    //    previewController.delegate = self;
    //
    //    [[previewController.navigationController navigationBar] setHidden:YES];
    //    // start previewing the document at the current section index
    //    previewController.currentPreviewItemIndex = [sender tag];
    
    //    FGalleryViewController *previewController=[[FGalleryViewController alloc] initWithImages:[currentCase getImages] index:(int)[sender tag] allowDelete:NO];
    //    [self  presentViewController:previewController animated:YES completion:nil];
    
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self photoAtIndex:[sender tag]];
    [self presentViewController:photoPagesController animated:YES completion:nil];
    
}
#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < [[self news] images].count){
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
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            image = [[self news] images][index];
            
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
           completionHandler:(void (^)(NSString *))handler{}


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
//        FImage *photo = [[self news] images][index];
        
        
        //        handler(@[photo.description]);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler{}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
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
    [newsView setFrame:CGRectMake(newsView.frame.origin.x,65, newsView.frame.size.width, newsView.frame.size.height-115)];
    NSLog(@"Finished using %@", photoPagesController);
    if (beforeOrient!=[APP_DELEGATE currentOrientation]) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    }
    
}





@end

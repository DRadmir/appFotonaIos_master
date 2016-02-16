//
//  FIEventSingleViewController.m
//  fotona
//
//  Created by Janos on 29/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIEventSingleViewController.h"
#import "HelperDate.h"
#import "HelperString.h"
#import "FAppDelegate.h"

@interface FIEventSingleViewController ()

@end

@implementation FIEventSingleViewController

@synthesize eventToOpen;
@synthesize lblDate;
@synthesize lblTitle;
@synthesize imagesScrollView;
@synthesize imagesScrollViewHeight;
@synthesize textWebView;
@synthesize textWebViewHeight;
@synthesize imagesScrollBottomSpace;
@synthesize gallery;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textWebView.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
  if([APP_DELEGATE eventTemp] != nil )
  {
      eventToOpen = [APP_DELEGATE eventTemp];
      [APP_DELEGATE setEventTemp:nil];
  }
    if (eventToOpen != nil) {
        [self fillView];
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillView
{
    self.lblTitle.text = eventToOpen.title;
    self.lblDate.text = [[HelperDate formatedDate:[eventToOpen eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[eventToOpen eventdateTo] ]]];
    NSString *htmlString= [HelperString toHtmlEventIPhone:[eventToOpen text]];
    [self createGallery];
    [self.textWebView loadHTMLString:htmlString baseURL:nil];
    
}


#pragma mark webView

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {


}

#pragma  mark - Images gallery
-(void) createGallery
{
    gallery = [[FIGalleryController alloc] init];
    gallery.parent = self;
    gallery.type = 3;
    [gallery createGalleryWithImagesForEvent:eventToOpen forScrollView:imagesScrollView andScrollHeight:imagesScrollViewHeight andBottomHeight:imagesScrollBottomSpace];
}



@end

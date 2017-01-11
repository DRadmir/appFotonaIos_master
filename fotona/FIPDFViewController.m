//
//  FIPDFViewController.m
//  fotona
//
//  Created by Janos on 10/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIPDFViewController.h"
#import "FGoogleAnalytics.h"
#import "FDownloadManager.h"
#import "FIExternalLinkViewController.h"
#import "FDB.h"
#import "MBProgressHUD.h"


@implementation BasicPreviewItem

@synthesize previewItemURL, previewItemTitle;

-(void)dealloc
{
    self.previewItemURL = nil;
    self.previewItemTitle = nil;
}

@end


@interface FIPDFViewController (){
    NSString *pathOnline;
    FIExternalLinkViewController *externalView;
    BOOL reopen;
}

@end

@implementation FIPDFViewController

@synthesize pdfWebView;
@synthesize pdfMedia;
@synthesize ipadFotonaParent;
@synthesize ipadFavoriteParent;

- (void)viewDidLoad {
    [super viewDidLoad];
    reopen = YES;
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self clearWebView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (reopen) {
        [self openPdf:pdfMedia];
    } else {
       reopen = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if([ConnectionHelper connectedToInternet]){
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
    reopen = NO;
    [self presentViewController:previewController animated:YES completion:nil];
    
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1; //assuming your code displays a single file
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    BasicPreviewItem *previewItem =[BasicPreviewItem new];
    previewItem.previewItemURL = [NSURL fileURLWithPath:pathOnline];
    previewItem.previewItemTitle = pdfMedia.title;
    return previewItem; //path of the file to be displayed
}

-(void)previewControllerDidDismiss:(QLPreviewController *)controller {
    if (ipadFotonaParent!= nil) {
        [ipadFotonaParent closeSettings:nil];
    } else {
        if (ipadFavoriteParent!= nil) {
            [ipadFavoriteParent closeSettings:nil];
        } else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Open Link

- (void) openExternalLink:(NSString *) url
{
    [pdfWebView setDelegate:self];
    if([ConnectionHelper connectedToInternet]){
        NSURL *urlToOpen=[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlToOpen];
        [pdfWebView loadRequest:requestObj];
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
}

#pragma mark WebView

-(void)webViewDidStartLoad:(UIWebView *)webView{
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
    [webView addSubview:hud];
    hud.labelText = NSLocalizedString(@"LOADINGWEBPAGE", nil);
    [hud show:YES];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error: %@ %@", error, [error userInfo]);
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
//    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"LOADINGWEBPAGEERROR", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [av show];
}

-(void)clearWebView{
    [pdfWebView loadHTMLString:@"" baseURL:nil];
}



@end

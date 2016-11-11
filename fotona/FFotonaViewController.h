//
//  FFotonaViewController.h
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFotonaMenu.h"
#import <QuickLook/QuickLook.h>
#import "FDLabelView.h"
#import "Bubble.h"
#import "FMedia.h"

@interface FFotonaViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UISearchBarDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, BubbleDelegate>
{
    
    IBOutlet UIWebView *webView;
    
    IBOutlet UITableView *table;
    IBOutlet UILabel *menuTitle;
    IBOutlet UIView *menuHeader;
    IBOutlet UIButton *back;
    
    NSString *pathToPDF;
    IBOutlet UIButton *feedbackBtn;
    IBOutlet UIButton *menuBtn;
    
    IBOutlet UIView *contentModeView;
    IBOutlet FDLabelView *cTitleLbl;
    IBOutlet UIScrollView *contentModeScrollView;
    IBOutlet UIWebView *cDescription;
    
    IBOutlet UIView *contentVideoModeView;
    IBOutlet FDLabelView *cvTitleLbl;
    IBOutlet FDLabelView *cvDescriptionLbl;
    IBOutlet UICollectionView *contentsVideoModeCollectionView;
    IBOutlet UIScrollView *contentVideModeScrollView;
    NSMutableArray *videoBtns;
    
    IBOutlet UIView *webContentView;
    
    UIImage *imageToSave;
    NSString *imageName;
    
    IBOutlet UIView *customToolbar;
    
    IBOutlet UIToolbar *webViewToolbar;
    
    UIView *settingsView;
    
    
    
}
@property (nonatomic)BOOL openPDF;
@property (nonatomic, retain) FFotonaMenu *PDFToOpen;

@property (strong, nonatomic) IBOutlet UIWebView *cDescription;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *popupCloseBtn;

@property (nonatomic, retain) FFotonaMenu *item;

@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UIImageView *fotonaImg;
@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic,retain) NSMutableArray *menuItems;
@property (nonatomic,retain) NSMutableArray *menuTitles;

@property(nonatomic, retain) NSMutableDictionary *bookmarkMenu;

@property (nonatomic) BOOL openVideoGal;

-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t;
-(void)downloadFileFromSearch:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t withCategoryID:(NSString*)cID;
-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t withCategoryID:(NSString *)cID;
-(void)externalLink:(NSString *)link;
-(void)openContentWithTitle:(NSString *)title description:(NSString *)description;
-(void)openContentWithTitle:(NSString *)title description:(NSString *)description videoGallery:(NSString *)galleryID videos:(NSMutableArray *)videosArray;
-(void)openPreloaded;

-(IBAction)openMenu:(id)sender;
-(void) closeMenu;

- (IBAction)openSettings:(id)sender;
- (IBAction)closeSettings:(id)sender;

-(void) refreshCell:(int) index;
-(void) refreshCellUnbookmark:(int) index;
-(void) refreshVideoCells;

-(void) refreshMenu:(NSString *)link;

-(void)openVideoFromSearch:(FMedia *)video;

-(void) setOpenGal: (BOOL) og;
-(void) setPDF:(FFotonaMenu *)PDF;
-(void) openPDFFromSearch;
@end

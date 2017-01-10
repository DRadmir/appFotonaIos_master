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
#import "FMedia.h"

@interface FFotonaViewController : UIViewController <UIWebViewDelegate,UISearchBarDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    IBOutlet UIWebView *webView;
    
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
    NSString *imageName;
    
    IBOutlet UIView *customToolbar;
    IBOutlet UIToolbar *webViewToolbar;
    
    UIView *settingsView;
    BOOL isExpanded;
}
@property (strong, nonatomic) IBOutlet UIWebView *cDescription;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *popupCloseBtn;

@property (nonatomic, retain) FFotonaMenu *item;

@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UIImageView *fotonaImg;

@property(nonatomic, retain) NSMutableDictionary *bookmarkMenu;

@property (nonatomic) BOOL openVideoGal;


-(void)externalLink:(NSString *)link;
-(void)openContentWithTitle:(NSString *)title description:(NSString *)description;
-(void)openContentWithTitle:(NSString *)title description:(NSString *)description media:(NSMutableArray *)menuMediaArray andMediaType:(NSString *)mediaType;
-(void)openPreloaded;

-(IBAction)openMenu:(id)sender;
-(void) closeMenu;

- (IBAction)openSettings:(id)sender;
- (IBAction)closeSettings:(id)sender;

- (void) refreshCellForMedia:(NSString *)mediaID andMediaType:(NSString *)mediaType;

-(void) setOpenGal: (BOOL) og forMedia:(FMedia *)media;
-(void) openMediaFromSearch:(FMedia *)media;
@end

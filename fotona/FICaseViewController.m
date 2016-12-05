//
//  FICaseViewController.m
//  fotona
//
//  Created by Janos on 27/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FICaseViewController.h"
#import "FAuthor.h"
#import "FDB.h"

#import "FAppDelegate.h"
#import "FIGalleryController.h"
#import "FImage.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "FIFlowController.h"
#import "FITabbarController.h"

@interface FICaseViewController ()
{
    NSArray *videoArray;
    NSArray *imagesArry;

    
}
@end

@implementation FICaseViewController

@synthesize lblAuthor;
@synthesize lblDate;
@synthesize btnBookmark;
@synthesize btnRemoveBookmark;
@synthesize btnAddFavorite;
@synthesize btnRemoveFavorite;
@synthesize imgAuthor;
@synthesize lblTitle;
@synthesize scrollViewImages;
@synthesize scrollViewImagesHeight;
@synthesize viewIntroduction;
@synthesize lblIntroduction;
@synthesize btnReadMore;
@synthesize caseToOpen;
@synthesize parent;

@synthesize parametersContainer;
@synthesize tableParameters;
@synthesize headerTableParameters;
@synthesize parametersScrollView;

@synthesize parametersHeight;
@synthesize headerHeight;
@synthesize canBookmark;
@synthesize favoriteParent;

@synthesize gallery;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    BOOL bookmarked = [FDB checkIfBookmarkedForDocumentID:[caseToOpen caseID] andType:BOOKMARKCASE];
    if (bookmarked){//[currentCase.bookmark boolValue]) {
        [btnBookmark setHidden:YES];
        [btnRemoveBookmark setHidden:NO];
    } else {
        [btnBookmark setHidden:NO];
        [btnRemoveBookmark setHidden:YES];
    }
    
    [self loadCase];
    [self createGallery];
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.caseOpened = caseToOpen;
    if(flow.lastIndex == 3)
    {
        flow.caseView = self;
    }
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setPatameters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadCase
{
    
    int lineSpace =7;
    int fontSizeText = 15;
    FAuthor* author = [FDB getAuthorWithID:[caseToOpen authorID]];
    
    [lblAuthor setText:[author name]];

    [lblDate setText:[APP_DELEGATE timestampToDateString:[caseToOpen date]]];
    [lblTitle setText:caseToOpen.title];
    
    NSString * title = @"";
    NSMutableAttributedString *allAdditionalInfo=[[NSMutableAttributedString alloc] init];
    NSString *check=[[caseToOpen introduction] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([caseToOpen introduction] && ![check isEqualToString:@""]) {
        [lblIntroduction setHidden:NO];
        
        
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<p>Introduction</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        [lblIntroduction setFrame:CGRectMake(38, 15, self.view.frame.size.width-76, 0)];
        [lblIntroduction setNumberOfLines:0];
        [lblIntroduction setTextAlignment:NSTextAlignmentLeft];
        
        NSString *htmlString=[caseToOpen introduction];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSizeText] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:lineSpace];
        [style setAlignment:NSTextAlignmentLeft];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        title = @"<br/><br/>";
    }
    
    
    
    check=[[caseToOpen procedure] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([caseToOpen procedure] && ![check isEqualToString:@""]) {
        
        
        title =[title stringByAppendingString:@"<br/><p>Procedure</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        NSString *htmlString=[caseToOpen procedure];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSizeText] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:lineSpace];
        [style setAlignment:NSTextAlignmentLeft];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
    }
    
    
    
    check=[[caseToOpen results] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([caseToOpen results] && ![check isEqualToString:@""]) {
        title =[title stringByAppendingString:@"<br/><p>Results</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[caseToOpen results];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSizeText] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:lineSpace];
        [style setAlignment:NSTextAlignmentLeft];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
        
    }
    
    check=[[caseToOpen references] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([caseToOpen references] && ![check isEqualToString:@""]) {
        
        title =[title stringByAppendingString:@"<br/><p>References</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[caseToOpen references];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSizeText] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:lineSpace];
        [style setAlignment:NSTextAlignmentLeft];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        title = @"<br/><br/>";
        
    }
    
    //DISCLAMER
    title =[title stringByAppendingString:@"<br/><p>Disclamer</p><br/>"];
    NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
    [allAdditionalInfo appendAttributedString:titleAttrStr];
    
    //[self getDisclamer:true]
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerShort"]  dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSizeText] range: NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpace];
    [style setAlignment:NSTextAlignmentLeft];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, attrStr.length)];
    [allAdditionalInfo appendAttributedString:attrStr];
    
    btnReadMore.layer.cornerRadius = 3;
    btnReadMore.layer.borderWidth = 1;
    btnReadMore.layer.borderColor = btnReadMore.tintColor.CGColor;
    
    
    lblIntroduction.attributedText=allAdditionalInfo;
    [lblIntroduction sizeToFit];
    
    
}



-(void)setPatameters
{
    imgAuthor.layer.cornerRadius = imgAuthor.frame.size.height /2;
    imgAuthor.layer.masksToBounds = YES;
    imgAuthor.layer.borderWidth = 0;
    [imgAuthor setContentMode:UIViewContentModeScaleAspectFill];
    [imgAuthor setImage:[FDB getAuthorImage:[caseToOpen authorID]]];
    
    for (UIView *v in parametersScrollView.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }        }
    for (UIView *v in tableParameters.subviews) {
        if ([v isKindOfClass:[UILabel class]] || v.tag==100) {
            [v removeFromSuperview];
        }
        
    }
    
    
    int allDataCount=0;
    int allDataObjectAtIndex0Count=0;
    int columnWidth = 150;
    
    int y=0;
    if (caseToOpen.parameters && caseToOpen.parameters  != (id)[NSNull null] && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=0 && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=3) {
        NSArray*allData=[NSJSONSerialization JSONObjectWithData:[caseToOpen.parameters dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        
        NSMutableArray *allDataM=[allData mutableCopy];
        
        
        int j=0;
        //        int tableheight=0;
        for (NSArray *arr in allDataM){
            int x=0;
            int rowHeight=0;
            //            int rowWidth=200;
            for (int i=0; i<arr.count; i++) {
                NSString *htmlString=[arr objectAtIndex:i];
                NSString *s=htmlString;
                if ([htmlString rangeOfString:@"cm&sup2;"].location!=NSNotFound) {
                    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                    s=[attrStr string];
                }
                
                if (i==0) {
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(10, y, columnWidth, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
                    [lbl setTextColor:[UIColor colorWithRed:73.0/255.0 green:73.0/255 blue:73.0/255.0 alpha:1.0]];
                    [lbl setText:s];
                    lbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
                    [lbl setNumberOfLines:0];
                    
                    lbl.fdTextAlignment=FDTextAlignmentLeft;
                    lbl.fdLabelFitAlignment = FDLabelFitAlignmentTop;
                    lbl.lineHeightScale = 1.00;
                    
                    lbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
                    lbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
                    [lbl setLineBreakMode:NSLineBreakByTruncatingTail];
                    
                    if(j==0)
                    {
                        [lbl setTextColor:[UIColor whiteColor]];
                    }
                    if (rowHeight<lbl.frame.size.height) {
                        rowHeight=lbl.frame.size.height;
                    }
                    [tableParameters addSubview:lbl];
                    
                }else{
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(x, y, columnWidth, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
                    [lbl setText:s];
                    
                    lbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
                    [lbl setNumberOfLines:0];
                    
                    lbl.fdTextAlignment=FDTextAlignmentLeft;
                    lbl.fdLabelFitAlignment = FDLabelFitAlignmentTop;
                    lbl.lineHeightScale = 1.00;
                    [lbl setLineBreakMode:NSLineBreakByTruncatingTail];
                    
                    lbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
                    lbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
                    
                    if(j==0)
                    {
                        lbl.contentInset = UIEdgeInsetsMake(10.0, 0.0, 6.0, 0.0);
                        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
                        [lbl setTextColor:[UIColor whiteColor]];
                    }
                    if (rowHeight<lbl.frame.size.height) {
                        rowHeight=lbl.frame.size.height;
                    }
                    [UIView beginAnimations:@"expand" context:nil];
                    [UIView setAnimationDuration:0.4];
                    [UIView setAnimationDelegate:self];
                    [parametersScrollView addSubview:lbl];
                    [UIView commitAnimations];
                    x+=columnWidth;
                }
                
            }
            y+=rowHeight;
            if (j>0) {
                UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 0.5)];
                [line setBackgroundColor:[UIColor lightGrayColor]];
                [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [line setTag:100];
                [tableParameters addSubview:line];
            }else
            {
                [headerTableParameters setFrame:CGRectMake(0, 0, self.view.frame.size.width, rowHeight)];
                headerHeight.constant= rowHeight-10;
            }
            j++;
        }
        
        allDataCount=(int)[allData count];
        allDataObjectAtIndex0Count=(int)[[allData objectAtIndex:0] count];
    }
    
    [tableParameters setHidden:NO];
    
    if (allDataCount>0) {
        [tableParameters setFrame:CGRectMake(tableParameters.frame.origin.x, tableParameters.frame.origin.y, tableParameters.frame.size.width, y+40)];
    }
    else
    {
        [tableParameters setFrame:CGRectMake(tableParameters.frame.origin.x, tableParameters.frame.origin.y, tableParameters.frame.size.width, 0)];
        
    }
    [parametersScrollView setFrame:CGRectMake(parametersScrollView.frame.origin.x, parametersScrollView.frame.origin.y, parametersScrollView.frame.size.width, y)];
    
    if (allDataCount>0) {
        [parametersContainer setFrame:CGRectMake(parametersContainer.frame.origin.x, lblTitle.frame.origin.y+lblTitle.frame.size.height+40, parametersContainer.frame.size.width, tableParameters.frame.size.height)];
    }else
    {
        [parametersContainer setFrame:CGRectMake(parametersContainer.frame.origin.x, lblTitle.frame.origin.y+lblTitle.frame.size.height, parametersContainer.frame.size.width, 0)];
    }
    
    
    [parametersScrollView setContentSize:CGSizeMake(167*(allDataObjectAtIndex0Count-1), tableParameters.frame.size.height-40)];
    parametersHeight.constant = tableParameters.frame.size.height;
}

-(void) createGallery
{
    NSMutableArray *vidArr= [[NSMutableArray alloc] init];
    if ([[caseToOpen bookmark] boolValue] || [[caseToOpen coverflow] boolValue]) {
        vidArr = [caseToOpen getVideos];
    } else{
        vidArr = [caseToOpen video];
    }
    videoArray = vidArr;
    
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    if ([[caseToOpen bookmark] boolValue] || [[caseToOpen coverflow] boolValue]) {
        imgs = [caseToOpen getImages];
    } else{
        imgs = [caseToOpen images];
    }
    imagesArry = imgs;
    
    gallery = [[FIGalleryController alloc] init];
    gallery.parent = self;
    gallery.type = 1;
    [gallery createGalleryWithImages:imgs andVideos:vidArr forScrollView:scrollViewImages andScrollHeight:scrollViewImagesHeight  fromCase:caseToOpen];
    
}

- (IBAction)readMore:(id)sender {
    if(parent != nil)
    {
        [parent openDisclaimer];
    } else
    {
        [favoriteParent openDisclaimer];
    }
}

- (IBAction)removeBookmark:(id)sender {
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.lastIndex == 3)
    {
        if ([ConnectionHelper connectedToInternet]) {
            [btnBookmark setHidden:NO];
        } else {
            [btnBookmark setHidden:YES];
        }
    }
    [btnRemoveBookmark setHidden:YES];
    
    [HelperBookmark removeBookmarkedCase:caseToOpen];
}

- (IBAction)addBookmark:(id)sender {
    if ([ConnectionHelper getWifiOnlyConnection]) {
        [self bookmarkCase];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:self.view];
    }
}


- (void) refreshBookmarkBtn  {
    BOOL bookmarked = [FDB checkIfBookmarkedForDocumentID:[caseToOpen caseID] andType:BOOKMARKCASE];
    if (bookmarked){
        [btnBookmark setHidden:YES];
        [btnRemoveBookmark setHidden:NO];
    } else {
        if ([ConnectionHelper connectedToInternet]) {
            [btnBookmark setHidden:NO];
        } else {
            [btnBookmark setHidden:YES];
        }
        [btnRemoveBookmark setHidden:YES];
    }
}

- (IBAction)addToFavorite:(id)sender {
    [FDB addTooFavoritesItem:[[caseToOpen caseID] intValue] ofType:BOOKMARKCASE];
    [btnRemoveFavorite setHidden:NO];
    [btnAddFavorite setHidden:YES];
}

- (IBAction)removeFavorite:(id)sender {
    [FDB removeFromFavoritesItem:[[caseToOpen caseID] intValue] ofType:BOOKMARKCASE];
    [btnRemoveFavorite setHidden:YES];
    [btnAddFavorite setHidden:NO];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex > -1) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"OK"]) {
            [self bookmarkCase];
        }
        if ([buttonTitle isEqualToString:NSLocalizedString(@"CHECKWIFIONLYBTN", nil)]) {
            [ConnectionHelper setWifiOnlyConnection:TRUE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
            [self bookmarkCase];
        }
    }
}

-(void) bookmarkCase{
    if([ConnectionHelper connectedToInternet] || [[caseToOpen coverflow] boolValue]){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"BOOKMARKING", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"BOOKMARKING", nil)]) {
        [HelperBookmark bookmarkCase:caseToOpen];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    }
}



@end

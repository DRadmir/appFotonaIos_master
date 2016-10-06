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
#import "Bubble.h"
#import "BubbleControler.h"
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
    BubbleControler *bubbleC;
    Bubble *b1;
    Bubble *b2;
    int state;
    
}
@end

@implementation FICaseViewController

@synthesize lblAuthor;
@synthesize lblDate;
@synthesize btnBookmark;
@synthesize btnRemoveBookmark;
@synthesize imgAuthor;
@synthesize lblTitle;
@synthesize viewParametrs;
@synthesize scrollViewImages;
@synthesize scrollViewImagesHeight;
@synthesize viewIntroduction;
@synthesize lblIntroduction;
@synthesize btnReadMore;
@synthesize caseToOpen;
@synthesize parent;
@synthesize scrollViewMain;

@synthesize parametersContainer;
@synthesize tableParameters;
@synthesize headerTableParameters;
@synthesize parametersScrollView;

@synthesize parametersHeight;
@synthesize headerHeight;
@synthesize canBookmark;
@synthesize parentBookmarks;

@synthesize gallery;

- (void)viewDidLoad {
    [super viewDidLoad];
    state = 0;
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
    
    NSString *usr = [FCommon getUser];
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"casebookHelper"]];
    if(![usersarray containsObject:usr]){
        [bubbleC removeFromSuperview];
        bubbleC = nil;
        [scrollViewMain setScrollEnabled:NO];
        
        [self showBubbles];
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
    [scrollViewMain setContentOffset:CGPointMake(0, 0) animated:YES];
   
    int lineSpace =7;
    int fontSizeText = 15;
    FAuthor* author = [FDB getAuthorWithID:[caseToOpen authorID]];
    
    [lblAuthor setText:[author name]];
    imgAuthor.layer.cornerRadius = imgAuthor.frame.size.height /2;
    imgAuthor.layer.masksToBounds = YES;
    imgAuthor.layer.borderWidth = 0;
    dispatch_queue_t queue = dispatch_queue_create("com.4egenus.fotona", NULL);
    dispatch_async(queue, ^{
        //code to be executed in the background
        NSData *imgData=[FDB getAuthorImage:[caseToOpen authorID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            [imgAuthor setImage:[FDB getAuthorImage:[caseToOpen authorID]]];//[UIImage imageWithData:imgData]];
        });
    });
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
    if (caseToOpen.parametars && caseToOpen.parametars != (id)[NSNull null] && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=0 && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=3) {
        NSArray*allData=[NSJSONSerialization JSONObjectWithData:[caseToOpen.parametars dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        
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
    [gallery createGalleryWithImages:imgs andVideos:vidArr forScrollView:scrollViewImages andScrollHeight:scrollViewImagesHeight];
    
}

- (IBAction)readMore:(id)sender {
    if(parent != nil)
    {
        [parent openDisclaimer];
    } else
    {
        [parentBookmarks openDisclaimer];
    }
}

- (IBAction)removeBookmark:(id)sender {
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.lastIndex == 3)
    {
        [btnBookmark setHidden:NO];
    }
    [btnRemoveBookmark setHidden:YES];
    
    [FDB removeBookmarkedCase:caseToOpen];
}

- (IBAction)addBookmark:(id)sender {
    if ([APP_DELEGATE wifiOnlyConnection]) {
        [self bookmarkCase];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:self.view];
    }
}

- (void) refreshBookmarkBtn  {
    [btnBookmark setHidden:YES];
    [btnRemoveBookmark setHidden:NO];
    
}

- (IBAction)addToFavorite:(id)sender {
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex > -1) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"OK"]) {
            [self bookmarkCase];
        }
        if ([buttonTitle isEqualToString:NSLocalizedString(@"CHECKWIFIONLYBTN", nil)]) {
            [APP_DELEGATE setWifiOnlyConnection:TRUE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
            [self bookmarkCase];
        }
    }
}

-(void) bookmarkCase{
    
    if([APP_DELEGATE connectedToInternet] || [[caseToOpen coverflow] boolValue]){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Item bookmarking" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"Item bookmarking"]) {
        [HelperBookmark bookmarkCase:caseToOpen forCategory:0];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    }
}

#pragma mark - BUBBLES :D

-(void)showBubbles
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    // You should check before this, if any of bubbles needs to be displayed
    NSString *usr = [FCommon getUser];
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"casebookHelper"]];
    if(![usersarray containsObject:usr]){
        
        if(bubbleC == nil)
        {
            bubbleC = [[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, flow.tabControler.view.frame.size.width, flow.tabControler.view.frame.size.height)];
            
            // [bubbleC setBlockUserInteraction:NO];
            //[bubbleC setBackgroundTint:[UIColor clearColor]];
            b1 = [[Bubble alloc] init];
        
            int orientation = 0;
            if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
                orientation = -1;
            }
            // Calculate point of caret
            CGPoint loc = btnBookmark.frame.origin;
            CGRect newFrame = btnBookmark.frame;
            if (state<1) {
                if (!btnRemoveBookmark.isHidden) {
                    newFrame= btnRemoveBookmark.frame;
                    loc = btnRemoveBookmark.frame.origin;
                    loc.x =  [flow tabControler].view.frame.size.width - btnRemoveBookmark.frame.size.width + 25 ; // Center
                    loc.y += 65 +  btnRemoveBookmark.frame.size.height + (orientation * 32); // Bottom
                } else{
                    loc.x =  [flow tabControler].view.frame.size.width - btnBookmark.frame.size.width + 25; // Center
                    loc.y += 65 +  btnBookmark.frame.size.height + (orientation * 32); // Bottom
                }
                
                
                // Set if highlight is desired
                
                newFrame.origin.y += 65;

                [b1 setCornerRadius:10];
                [b1 setSize:CGSizeMake(200, 130)];
                newFrame =btnBookmark.frame;
                if (!btnRemoveBookmark.isHidden) {
                    newFrame= btnRemoveBookmark.frame;
                    newFrame.origin.y = 62 + btnRemoveBookmark.frame.origin.y + (orientation * 32);
                    newFrame.origin.x =  [flow tabControler].view.frame.size.width - btnRemoveBookmark.frame.size.width - 25;
                } else{
                    newFrame.origin.y = 62 + btnBookmark.frame.origin.y + (orientation * 32);
                    newFrame.origin.x =  [flow tabControler].view.frame.size.width - btnBookmark.frame.size.width - 25;
                }
                
                newFrame.size.height += 1;
                [b1 setHighlight:newFrame];

                [b1 setHighlight:newFrame];
                [b1 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b1 setFontColor:[UIColor whiteColor]];
                // Set buble size and position (first size, then position!!)
                [b1 setSize:CGSizeMake(200, 130)];
                [b1 setCornerRadius:5];
                [b1 setPositionOfCaret:loc withCaretFrom:TOP_RIGHT];
                [b1 setCaretSize:15]; // Because tablet, we want a bigger bubble caret
                // Set font, paddings and text
                [b1 setTextContentInset: UIEdgeInsetsMake(16,16,16,16)]; // Set paddings
                [b1 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLECASE1", nil)]];
                [b1 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]]; // Default font is helvetica-neue, size 12
                
                // Add bubble to controler
                [bubbleC addBubble:b1];
                [b1 setDelegate:self];
            }
            if (state<2) {
                b2 = [[Bubble alloc] init];
                FIFlowController *flow = [FIFlowController sharedInstance];
                loc =[[[[[flow tabControler] tabBar] subviews] objectAtIndex:4] frame].origin;
                loc.x =[flow tabControler].view.frame.size.width -  [[[[[flow tabControler] tabBar] subviews] objectAtIndex:4]frame].size.width/2;
                loc.y = [flow tabControler].view.frame.size.height - [[flow tabControler] tabBar].frame.size.height;
                [b2 setCornerRadius:10];
                [b2 setSize:CGSizeMake(200, 130)];
                CGRect newFrame =[ [[[[flow tabControler] tabBar] subviews] objectAtIndex:4] frame];
                newFrame.origin.y = [flow tabControler].view.frame.size.height - [[flow tabControler] tabBar].frame.size.height;
                newFrame.origin.x =  [flow tabControler].view.frame.size.width -  [[[[[flow tabControler] tabBar] subviews] objectAtIndex:4]frame].size.width;
                newFrame.size.height += 1;
                [b2 setHighlight:newFrame];
                
                [b2 setPositionOfCaret:loc withCaretFrom:BOTTOM_RIGHT];
                [b2 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLECASE2", nil)]];
                [b2 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b2 setFontColor:[UIColor whiteColor]];
                [b2 setTextContentInset: UIEdgeInsetsMake(16,16,16,16)]; // Set paddings
                [b2 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
                
                [bubbleC addBubble:b2];
                [b2 setDelegate:self];
            }
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window addSubview:bubbleC];
        }
    }
    
}

- (void)bubbleRequestedExit:(Bubble*)bubbleObject
{
    state++;
    [bubbleC displayNextBubble];
    [bubbleObject removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    [scrollViewMain setScrollEnabled:YES];
    if (state>1) {
        NSMutableArray *helperArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"casebookHelper"]];
        NSString *usr = [FCommon getUser];
        [helperArray addObject:usr];
        [[NSUserDefaults standardUserDefaults] setObject:helperArray forKey:@"casebookHelper"];
        state = 0;
        [bubbleC removeFromSuperview];
        bubbleC = nil;

    }
    
    
}

-(void) reloadBubbles
{
    if(bubbleC != nil)
    {
        [bubbleC removeFromSuperview];
        bubbleC = nil;
         [self showBubbles];
    }
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self reloadBubbles];
}


@end

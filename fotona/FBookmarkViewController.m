

#import "FBookmarkViewController.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "FCaseCategory.h"
#import "NSString+HTML.h"
#import "FUpdateContent.h"
#import "FImage.h"
#import "FMedia.h"
#import "FAuthor.h"
#import "FGalleryViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "FBookmarkMenuViewController.h"
#import "FMainViewController.h"
#import "FSettingsViewController.h"
#import "GEMainMenuCell.h"
#import "FDownloadManager.h"
#import "FFeaturedViewController_iPad.h"
#import "FNewsView.h"
#import "HelperString.h"
#import "FDB.h"

@interface FBookmarkViewController ()
{
    int numberOfSpaces;//between texts introduction, procedure ...
    int success;
    int numberOfImages;
    int rotate;
    BOOL direction;
    FSettingsViewController *settingsController;
    UIPanGestureRecognizer *swipeRecognizerB;
    NSMutableArray *imagesList;
    FNewsView *newsViewController;
    NSString *categ;
    
}
@property (nonatomic, strong)UIImage *defaultVideoImage;
@end

@implementation FBookmarkViewController
@synthesize menuItems;
@synthesize allItems;
@synthesize menuTitles;
@synthesize menuIcons;
@synthesize selectedIcon;
@synthesize currentCase;
@synthesize prevCase;
@synthesize flagCarousel;
@synthesize casesInMenu;
@synthesize allCasesInMenu;
@synthesize popover;
@synthesize popupCloseBtn;
@synthesize caseView;
@synthesize defaultVideoImage = _defaultVideoImage;
@synthesize  videoArray;
@synthesize showView;
@synthesize helpContent;
@synthesize helpScrollView;
@synthesize helpTitle;
@synthesize helpView;

@synthesize eventView;
@synthesize eventTitleLbl;
@synthesize eventDate;
@synthesize eventImagesScroll;
@synthesize eventImg;
@synthesize eventText;


static NSString * const reuseIdentifier = @"Cell";
NSMutableDictionary *preloadMoviesImages2;

#define OPENVIEW 1000
#define CLOSEVIEW 0

-(UIImage *)defaultVideoImage
{
    if (!_defaultVideoImage) {
        _defaultVideoImage = [UIImage imageNamed:@"no_thunbail"];
        
        CGSize size = CGSizeMake(300, 167);
        UIGraphicsBeginImageContext(size);
        
        CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
        [_defaultVideoImage drawInRect:imgBorder];
        
        _defaultVideoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return _defaultVideoImage;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setTitle:@"Bookmarks"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"bookmarks.png"]];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    //feedback
    [feedbackBtn addTarget:APP_DELEGATE action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    //search
    FSearchViewController *searchVC=[[FSearchViewController alloc] init];
    [searchVC setParent:self];
    popover=[[UIPopoverController alloc] initWithContentViewController:searchVC];
    
    
    categ = @"";
    isExpanded=NO;
    
    //video collection view
    [self.contentsVideoModeCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.contentsVideoModeCollectionView registerClass:[GEMainMenuCell class] forCellWithReuseIdentifier:reuseIdentifier];
    preloadMoviesImages2 = [[NSMutableDictionary alloc] init];
    [self.viewDeckController openLeftView];
    [caseView setTag:OPENVIEW];
    
    CGRect newFrame = fotonaImg.frame;
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
        newFrame.origin.x -= 105;
    
    else
        newFrame.origin.x -=  160;
    rotate = 1;
    fotonaImg.frame = newFrame;
    direction = TRUE;
    
    //swipe closing menu
    
    swipeRecognizerB = [[UIPanGestureRecognizer alloc]
                        initWithTarget:self action:@selector(swipeMenuBookmark:)];
    
    
    [caseScroll addGestureRecognizer:swipeRecognizerB];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabBookmarks:)
                                                 name:@"CloseOnTabBookmarks"
                                               object:nil];
    
    settingsController = [APP_DELEGATE settingsController];
    
    imagesList = [[NSMutableArray alloc] init];
    newsViewController = [[FNewsView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    CGRect newFrame = fotonaImg.frame;
    newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2;
    if (!self.viewDeckController.leftController.view.isHidden) {
        newFrame.origin.x -= 162;
    }
    newFrame.origin.y = self.view.frame.size.height/2-fotonaImg.frame.size.height/1.41;
    fotonaImg.frame = newFrame;
    [newsViewController.view setFrame:CGRectMake(0,65, self.view.frame.size.width, self.view.frame.size.height-114)];
    [self.tabBarItem setImage:[UIImage imageNamed:@"bookmarks_red.png"]];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    if (!exCaseView.isHidden) {
        //[self openCase];
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@",[currentCase caseID] ]];
        while([results next]) {
            currentCase.bookmark = [results stringForColumn:@"isBookmark"];
        }
        if ([currentCase.bookmark boolValue]) {
            [removeBookmarks setHidden:NO];
        } else {
            [removeBookmarks setHidden:YES];
        }
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    
    BOOL fimg =self.viewDeckController.leftController.view.isHidden;
    
    [self.viewDeckController openLeftView];
    
    
    [self.viewDeckController setLeftSize:self.view.frame.size.width-320];
    
    if  ([categ isEqualToString:@""])
    {
    videoArray = [self getVideos];
    } else
    {
        videoArray = [self getVideoswithCategory:categ];
    }
    [self.contentsVideoModeCollectionView reloadData];
    
    if(flagCarousel){ //when clicked on Carousel ----------------------------------------------------------------------------
        
        
        [[APP_DELEGATE main_ipad].caseMenu resetViewAnime:YES];
        //[(FCasesMenuViewController *) popover.contentViewController resetViewAnime:YES];
        [self openCase];
        
    }else
    {
        
        if (currentCase && beforeOrient!=[APP_DELEGATE currentOrientation]) {
            [self openCase];
        }
        
    }
    beforeOrient=[APP_DELEGATE currentOrientation];
    if (self.viewDeckController.leftController.view.isHidden != fimg) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x -=  162;
        rotate = 1;
        fotonaImg.frame = newFrame;
        direction = TRUE;
    }
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    flagCarousel=NO;
    [self.tabBarItem setImage:[UIImage imageNamed:@"bookmarks.png"]];
}


#pragma mark Search

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Text: %@",searchText);
    if ([searchText isEqualToString:@""]) {
        [popover dismissPopoverAnimated:YES];
    }else
    {
        [(FSearchViewController *)popover.contentViewController setSearchTxt:searchText];
        [(FSearchViewController *)popover.contentViewController search];
        [[(FSearchViewController *)popover.contentViewController tableSearch] reloadData];
        if (![popover isPopoverVisible]) {
            [popover presentPopoverFromRect:searchBar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
}


#pragma mark TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (allItems.count>1) {
        if (casesInMenu.count>0) {
            return 2;
        }
        return 1;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        if (allItems.count==1) {
            return 70;
        }
        return 100;
    }
    if ([[menuItems lastObject] isKindOfClass:[FCase class]]) {
        return 100;
    }
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [menuItems count];
    }else if(casesInMenu.count>0)
    {
        return casesInMenu.count;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    if (indexPath.section==1) {
        if (casesInMenu.count>0) {
            NSString *imageName=@"";
            if (allItems.count==1) {
                imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
            }
            else{
                imageName=selectedIcon;
            }
            
            
            if ([[casesInMenu objectAtIndex:indexPath.row] isKindOfClass:[FCase class]])
            {
                UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
                [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",imageName]]];
                [cell addSubview:img];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 220, 15)];
                [name setText:[(FCase *)[casesInMenu objectAtIndex:indexPath.row] name]];
                [cell addSubview:name];
                UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(300, 13.5, 8, 12.5)];
                [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
                [cell addSubview:indicator];
                UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, 280, 1)];
                [line setBackgroundColor:[UIColor lightGrayColor]];
                [cell addSubview:line];
                UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 40, 260, 60)];
                [caseLbl setText:[(FCase *)[casesInMenu objectAtIndex:indexPath.row] title]];
                [caseLbl setTextColor:[UIColor grayColor]];
                [caseLbl setNumberOfLines:3];
                [cell addSubview:caseLbl];
            }
            
        }
    }else{
        NSString *imageName=@"";
        if (allItems.count==1) {
            imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
        }
        else{
            imageName=selectedIcon;
        }
        
        
        if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FCase class]])
        {
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
            [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",imageName]]];
            [cell addSubview:img];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 220, 15)];
            [name setText:[(FCase *)[menuItems objectAtIndex:indexPath.row] name]];
            [cell addSubview:name];
            UILabel *indicator=[[UILabel alloc] initWithFrame:CGRectMake(300, 10, 20, 15)];
            [indicator setText:@">"];
            [cell addSubview:indicator];
            UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, 280, 1)];
            [line setBackgroundColor:[UIColor lightGrayColor]];
            [cell addSubview:line];
            UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 40, 260, 60)];
            [caseLbl setText:[(FCase *)[menuItems objectAtIndex:indexPath.row] title]];
            [caseLbl setTextColor:[UIColor grayColor]];
            [caseLbl setNumberOfLines:3];
            [cell addSubview:caseLbl];
            
            
        }else
        {
            if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FAuthor class]])
            {
                [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] name]];
            }else{
                [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] title]];
            }
            
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",imageName]]];
            
            UIView *bck=[[UIView alloc] initWithFrame:cell.frame];
            
            [bck setBackgroundColor:[UIColor redColor]];
            [cell setSelectedBackgroundView:bck];
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            cell.imageView.highlightedImage =[UIImage imageNamed:[NSString stringWithFormat:@"%@white",imageName]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        if (casesInMenu.count>0) {
            [self setCurrentCase:[casesInMenu objectAtIndex:indexPath.row]];
            [self openCase];
        }
    }else{
        if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FCase class]]) {
            [self setCurrentCase:[menuItems objectAtIndex:indexPath.row]];
            [self openCase];
        }else
            if ([[[menuItems objectAtIndex:indexPath.row] categoryID] isEqualToString:@""]) {
                //list by author or alphabetical
                if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Cases list"]) {
                    NSMutableArray *newItems=[self getAlphabeticalCases];
                    if (newItems.count==0) {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                        //                        [self backBtn:nil];
                    }
                    else {
                        selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                        [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] title]];
                        [menuTitle setText:[menuTitles lastObject]];
                        [allItems addObject:newItems];
                        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
                        [menuTable reloadData];
                    }
                }
                
            }
    }
}

-(void)openCase
{
    imagesList = [[NSMutableArray alloc] init];
    [caseScroll removeGestureRecognizer:swipeRecognizerB];
    if (![currentCase isEqual:prevCase]) {
        //        currentCase.bookmark = 0;
        FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
        [database open];
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where caseID=%@",[currentCase caseID] ]];
        while([results next]) {
            //currentCase.bookmark = [results stringForColumn:@"bookmark"];
            currentCase.coverflow = [results stringForColumn:@"alloweInCoverFlow"];
        }
        
        
        [tableParameters setHidden:YES];
        [fotonaImg setHidden:YES];
        [exCaseView setHidden:NO];
        [caseScroll addSubview:exCaseView];
        [self.view bringSubviewToFront:header];
        [images setImage:nil forState:UIControlStateNormal];
        [videos setImage:nil forState:UIControlStateNormal];
        for (UIView *v in imagesScroll.subviews) {
            [v removeFromSuperview];
        }
        
        
        for (UIView *v in additionalInfo.subviews) {
            [v setFrame:CGRectMake(38, 0, v.frame.size.width, 0)];
            if ([v isKindOfClass:[FDLabelView class]]) {
                [(FDLabelView *)v setText:@""];
            }
        }
    }
    
    flagParameters=NO;
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [additionalInfo setFrame:CGRectMake(0, additionalInfo.frame.origin.y, self.view.frame.size.width, 231)];
    if (![currentCase isEqual:prevCase]) {
        [caseScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    numberOfSpaces=0;
    [self setCaseOutlets];
    [self setPatameters];
    [self setPrevCase:currentCase];
    
    
   NSString *usr = [FCommon getUser];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, [currentCase caseID]]];
    //        FMResultSet *resultsBookmarked = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ and typeID=0 and", [results stringForColumn:@"caseID"]]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        
        //            if ([[resultsBookmarked stringForColumn:@"username"] isEqualToString:usr]) {
        flag=YES;
        //            }
        
        
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if (flag){//[[currentCase bookmark] isEqualToString:@"1"]) {
        [removeBookmarks setHidden:NO];
    } else{
        [removeBookmarks setHidden:YES];
    }
    [contentVideoModeView setHidden:YES];
    [contentVideoModeView setTag:CLOSEVIEW];
    [caseView setTag:OPENVIEW];
    [caseView setHidden:NO];
    [helpView setTag:CLOSEVIEW];
    [helpView setHidden:YES];
    [eventView setTag:CLOSEVIEW];
    [eventView setHidden:YES];
    [newsViewController.newsView setTag:CLOSEVIEW];
    [newsViewController.newsView setHidden:YES];
}

-(void)setCaseOutlets
{
    if (![currentCase isEqual:prevCase]) {
        for (UIView *v in additionalInfo.subviews) {
            if ([v isKindOfClass:[FDLabelView class]]) {
                [v removeFromSuperview];
            }
        }
    }
    
    authorImg.layer.cornerRadius = authorImg.frame.size.height /2;
    authorImg.layer.masksToBounds = YES;
    authorImg.layer.borderWidth = 0;
    dispatch_queue_t queue = dispatch_queue_create("com.4egenus.fotona", NULL);
    dispatch_async(queue, ^{
        //code to be executed in the background
        NSData *imgData=[self getAuthorImage:[currentCase authorID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            [authorImg setImage: [FDB getAuthorImage:[currentCase authorID]]];//[authorImg setImage:[UIImage imageWithData:imgData]];
        });
    });
    
    [authorNameLbl setText:[currentCase name]];
    [dateLbl setText:[APP_DELEGATE timestampToDateString:[currentCase date]]];
    [titleLbl setText:[currentCase title]];
    [titleLbl setNumberOfLines:0];
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        if(caseTittleFlag==0)
        {
            caseTittleFlag=1;
            
        }
    }
    
    NSMutableAttributedString *allAdditionalInfo=[[NSMutableAttributedString alloc] init];
    NSString *check=[[currentCase introduction] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    if ([currentCase introduction] && ![check isEqualToString:@""]) {
        [introductionTitle setHidden:NO];
        
        
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<p>Introduction</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        numberOfSpaces++;
        
        [introductionTitle setFrame:CGRectMake(38, 15, self.view.frame.size.width-76, 0)];
        [introductionTitle setNumberOfLines:0];
        [introductionTitle setTextAlignment:NSTextAlignmentJustified];
        
        NSString *htmlString=[currentCase introduction];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        
        //    }else
        //    {
        //        [introductionTitle setHidden:YES];
        //        [introductionLbl setHidden:YES];
    }
    
    
    
    check=[[currentCase procedure] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    if ([currentCase procedure] && ![check isEqualToString:@""]) {
        
        numberOfSpaces++;
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<br/><br/><br/><p>Procedure</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[currentCase procedure];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        //    }else
        //    {
        //        [procedureTitle setHidden:YES];
        //        [procedureLbl setHidden:YES];
    }
    
    
    
    check=[[currentCase results] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    if ([currentCase results] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<br/><br/><br/><p>Results</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[currentCase results];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        //    }else
        //    {
        //        [resultsTitle setHidden:YES];
        //        [resultsLbl setHidden:YES];
    }
    
    check=[[currentCase references] stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase references] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<br/><br/><br/><p>References</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
        [allAdditionalInfo appendAttributedString:titleAttrStr];
        
        
        
        
        NSString *htmlString=[currentCase references];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:10];
        [style setAlignment:NSTextAlignmentJustified];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, attrStr.length)];
        [allAdditionalInfo appendAttributedString:attrStr];
        
        //        if (![currentCase isEqual:prevCase]) {
        //            [additionalInfo insertSubview:referencesLbl belowSubview:referencesTitle];
        //        }
        //    }
        //    else
        //    {
        //        [referencesTitle setHidden:YES];
        //        [referencesLbl setHidden:YES];
    }
    
    //DISCLAMER
    numberOfSpaces++;
    NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[@"<br/><br/><br/><p>Disclamer</p><br/>" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
    [allAdditionalInfo appendAttributedString:titleAttrStr];
    //[self getDisclamer]
     NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerShort"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:10];
    [style setAlignment:NSTextAlignmentJustified];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, attrStr.length)];
    [allAdditionalInfo appendAttributedString:attrStr];
    
    numberOfSpaces++;
    
    
    introductionTitle.attributedText=allAdditionalInfo;
    [introductionTitle sizeToFit];
    
    //[additionalInfo setFrame:CGRectMake(introductionTitle.frame.origin.x,introductionTitle.frame.origin.y, introductionTitle.frame.size.width,introductionTitle.frame.size.height+125)];
    
    if ([additionalInfo isHidden]) {
        [additionalInfo setHidden:NO];
    }
    
    
    int x=0;
    if (![currentCase isEqual:prevCase]) {
        NSMutableArray *vidArr= [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            vidArr=[currentCase getVideos];
        } else{
            vidArr = [currentCase video];
        }
        for (int i=0;i<[vidArr count];i++) {
            FMedia *vid=[vidArr objectAtIndex:i];
            UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
            [tmpImg setFrame:CGRectMake(x, 0, 200, 200)];
            [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:NO];
            x=x+210;
            
            dispatch_queue_t queue = dispatch_queue_create("Video queue", NULL);
            dispatch_async(queue, ^{
                //code to be executed in the background
                NSURL *videoURL;
                if (![[NSFileManager defaultManager] fileExistsAtPath:vid.localPath]) {
                    videoURL= [NSURL URLWithString:vid.path] ;
                }else{
                    videoURL=[NSURL fileURLWithPath:vid.localPath];
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
                    //                    UIImageView *expandImg=[[UIImageView alloc] initWithFrame:CGRectMake(tmpImg.frame.size.width-25, tmpImg.frame.size.height-25, 60, 60)];
                    //                    expandImg.center = CGPointMake(tmpImg.frame.size.width / 2, tmpImg.frame.size.height / 2);
                    //
                    //                    [expandImg setImage:[UIImage imageNamed:@"playVideo"]];
                    //                    [tmpImg addSubview:expandImg];
                    [tmpImg setTag:i];
                    [tmpImg addTarget:self action:@selector(openVideo:) forControlEvents:UIControlEventTouchUpInside];
                    [imagesScroll addSubview:tmpImg];
                    UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(x-210, 200, 190, 20)];
                    [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                    [videoName setText:vid.title];
                    [videoName setTextAlignment:NSTextAlignmentCenter];
                    [imagesScroll addSubview:videoName];
                });
            });
        }
        
        int xS=210*(int)[vidArr count];
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            imgs=[currentCase getImages];
        } else{
            imgs = [currentCase images];
        }
        
        
        for (int i=0;i<imgs.count;i++){
            FImage *img=[imgs objectAtIndex:i];
            UIButton *tmpImg=[UIButton buttonWithType:UIButtonTypeCustom];
            [tmpImg setFrame:CGRectMake(xS, 0, 200, 200)];
            [tmpImg.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:YES];
            xS=xS+210;
            dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
            dispatch_async(queue, ^{
                //code to be executed in the background
                UIImage *image;
                 NSString *pathTmp = [NSString stringWithFormat:@"%@%@",docDir,img.localPath];
                if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                    
                }else{
                    image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL URLWithString:pathTmp]]];
                }
                [imagesList addObject:img];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //code to be executed on the main thread when background task is finished
                    [tmpImg setImage:image forState:UIControlStateNormal];
                    [tmpImg setTag:i];
                    [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                    [imagesScroll addSubview:tmpImg];
                    UILabel *videoName=[[UILabel alloc] initWithFrame:CGRectMake(xS-210, 200, 190, 20)];
                    [videoName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                    [videoName setText:img.title];
                    [videoName setTextAlignment:NSTextAlignmentCenter];
                    [imagesScroll addSubview:videoName];
                });
                
            });
        }
        if ((imgs.count>0) || ([vidArr count]>0)) {
            [imagesScroll setHidden:NO];
            [imagesScroll setContentSize:CGSizeMake(210*(imgs.count+vidArr.count)-10, 230)];
            [imagesScroll setContentOffset:CGPointZero animated:YES];
            [galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 230)];
            
        } else{
            [galleryView setFrame:CGRectMake(galleryView.frame.origin.x, galleryView.frame.origin.y, galleryView.frame.size.width, 0)];
            [imagesScroll setHidden:YES];
            [imagesScroll setContentSize:CGSizeMake(0, 0)];
        }
        
        
    }
}

-(void)setPatameters
{
    if (![currentCase isEqual:prevCase]) {
        for (UIView *v in parametersScrollView.subviews) {
            if ([v isKindOfClass:[UILabel class]]) {
                [v removeFromSuperview];
            }        }
        for (UIView *v in tableParameters.subviews) {
            if ([v isKindOfClass:[UILabel class]] || v.tag==100) {
                [v removeFromSuperview];
            }
            
        }
    }
    
    int allDataCount=0;
    int allDataObjectAtIndex0Count=0;
    
    int y=0;
    if (currentCase.parameters && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=0 && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=3) {
        NSArray*allData=[NSJSONSerialization JSONObjectWithData:[currentCase.parameters dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        
        NSMutableArray *allDataM=[allData mutableCopy];
        //        if (allDataM.count<5) {
        [expandBtn setHidden:YES];
        //        }
        
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
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(38, y, 200, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
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
                    FDLabelView *lbl=[[FDLabelView alloc] initWithFrame:CGRectMake(x, y, 160, 0)];
                    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
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
                        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
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
                    x+=167;
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
        [parametersConteiner setFrame:CGRectMake(parametersConteiner.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height+40, parametersConteiner.frame.size.width, tableParameters.frame.size.height)];
    }else
    {
        [parametersConteiner setFrame:CGRectMake(parametersConteiner.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height, parametersConteiner.frame.size.width, 0)];
    }
    
    
    [parametersScrollView setContentSize:CGSizeMake(167*(allDataObjectAtIndex0Count-1), tableParameters.frame.size.height-40)];
    
    //setting the size of image gallery
    if (galleryView.frame.size.height>0) {
        [galleryView setFrame:CGRectMake(0, parametersConteiner.frame.origin.y+parametersConteiner.frame.size.height+20, self.view.frame.size.width, 230)];
    } else {
        [galleryView setFrame:CGRectMake(0, parametersConteiner.frame.origin.y+parametersConteiner.frame.size.height, self.view.frame.size.width, 0)];
    }
    
    
    [self setContentSize];
    
}

-(void)setContentSize
{
    [imagesScroll setFrame:CGRectMake(imagesScroll.frame.origin.x, imagesScroll.frame.origin.y, self.view.frame.size.width-76, imagesScroll.frame.size.height)];
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
    [additionalInfo setFrame:CGRectMake(0, 658, self.view.frame.size.width, 231)];
    [introductionTitle sizeToFit];
    float additionalInfoH=introductionTitle.frame.size.height+100;
    [additionalInfo setFrame:CGRectMake(additionalInfo.frame.origin.x, galleryView.frame.origin.y+galleryView.frame.size.height+20, additionalInfo.frame.size.width,additionalInfoH)];
    [disclaimerBtn setHidden:NO];
    [disclaimerBtn setFrame:CGRectMake(38, introductionTitle.frame.size.height+30, 99, 40)];
    disclaimerBtn.layer.cornerRadius = 3;
    disclaimerBtn.layer.borderWidth = 1;
    disclaimerBtn.layer.borderColor = disclaimerBtn.tintColor.CGColor;
    [additionalInfo addSubview:disclaimerBtn ];
    [exCaseView setFrame:CGRectMake(0, 0, self.view.frame.size.width, additionalInfo.frame.origin.y+additionalInfo.frame.size.height)];
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
}

-(void)menu:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x += rotate * 180;
        rotate = -rotate;
        fotonaImg.frame = newFrame;
        [self.viewDeckController toggleLeftViewAnimated:YES];
        direction = !direction;
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}

- (IBAction)removeFromBookmarks:(id)sender {
    
    [removeBookmarks setHidden:YES];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=0",currentCase.caseID,usr,nil];
    BOOL bookmarked = NO;
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where typeID=0 and documentID=?" withArgumentsInArray:[NSArray arrayWithObjects:currentCase.caseID, nil]];
    while([resultsBookmarked next]) {
        bookmarked = YES;
    }
    
    if (!bookmarked) {
        if ([[currentCase coverflow] boolValue]) {
            [database executeUpdate:@"UPDATE Cases set isBookmark=? where caseID=?",@"0",currentCase.caseID];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            
        }
        else{
            [database executeUpdate:@"DELETE FROM Cases WHERE caseID=?",currentCase.caseID];
            [database executeUpdate:@"INSERT INTO Cases (caseID,title,name,active,authorID,isBookmark,alloweInCoverFlow) VALUES (?,?,?,?,?,?,?)",currentCase.caseID,currentCase.title,currentCase.name,currentCase.active,currentCase.authorID,@"0",currentCase.coverflow];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            [self deleteMediaForCaseGalleryID:currentCase.galleryID withArray:currentCase.images andType:0];
            [self deleteMediaForCaseGalleryID:currentCase.videoGalleryID withArray:currentCase.video andType:1];
        }
        
    }
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
}

-(void)deleteMediaForCaseGalleryID:(NSString *)gID withArray:(NSMutableArray *)array andType:(int)t
{
    if (t==0) {
        for (FImage *img in array) {
            NSArray *pathComp=[img.path pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    } else if (t==1){
        for (FMedia *vid in array) {
            NSArray *pathComp=[vid.path pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:pathTmp error:&error];
        }
    }
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"delete from Media where galleryID=?",gID];
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}


- (IBAction)openSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    [self.settingsBtn setEnabled:NO];
    [popupCloseBtn setHidden:NO];
    [menuBtn setHidden:YES];
    [settingsView addSubview:settingsController.view];
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 654)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
    }else
    {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 910)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
    }
    settingsController.contentWidth.constant = self.view.frame.size.width;
    
    [settingsView addSubview:settingsController.view];
    [caseView setHidden:YES];
    [contentVideoModeView setHidden:YES];
    [helpView setHidden:YES];
    [self.view addSubview:settingsView];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
    [settingsView setHidden:NO];
}

- (IBAction)closeSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckLeftSide;
    [UIView animateWithDuration:0.3 animations:^{
        if (caseView.tag==OPENVIEW) {
            caseView.hidden=NO;
        } else{
            if (contentVideoModeView.tag==OPENVIEW) {
                contentVideoModeView.hidden=NO;
            } else{
                helpView.hidden=NO;
            }
            
        }        [popupCloseBtn setHidden:YES];
        CGRect newFrame = settingsView.frame;
        newFrame.origin.x += self.view.frame.size.width;
        settingsView.frame = newFrame;
    } completion:^(BOOL finished) {
        [menuBtn setHidden:NO];
        [settingsView removeFromSuperview];
        [self.settingsBtn setEnabled:YES];
        [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
        [settingsView setHidden:YES];
    }];
    
    
    
}

-(void)expand:(id)sender
{
    flagParameters=!flagParameters;
    [self setPatameters];
}

-(void)backBtn:(id)sender
{
    if (allItems.count==1) {
        [menuTitle setHidden:YES];
        [menuTable setHidden:YES];
        [back setHidden:YES];
        [menuHeader setHidden:YES];
    }
    else
    {
        [allItems removeLastObject];
        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
        [allCasesInMenu removeLastObject];
        casesInMenu=[allCasesInMenu lastObject];
        [menuTable reloadData];
        [menuTitles removeLastObject];
        [menuTitle setText:[menuTitles lastObject]];
        
        
    }
}

-(IBAction)openVideo:(id)sender
{
    FMedia *vid=[[currentCase getVideos] objectAtIndex:[sender tag]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:vid.localPath];
    }
    if (![vid.localPath isEqualToString:@""] && downloaded) {
        [FCommon playVideoFromURL:vid.localPath onViewController:self];
    }else
    {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"FILEDOWNLOAD", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
}
-(IBAction)openGallery:(id)sender
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

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    if (showView==1) {
        return [imagesList count];
    }
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller

{
    if (showView==0) {
        [self.viewDeckController toggleLeftViewAnimated:YES];
    }
    [self.viewDeckController openLeftView];
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    if (showView==1) {
        NSURL *fileURL = nil;
        FImage *img=[imagesList objectAtIndex:idx];
        NSString *pathTmp = [NSString stringWithFormat:@"%@%@",docDir,img.localPath];

        if ([[img localPath] isEqualToString:@""]) {
            //        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Image is not downloaded. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //        [av show];
        }
        if (![[img localPath] isEqualToString:@""]) {
            fileURL = [NSURL fileURLWithPath:pathTmp];
            NSLog(@"FF%@",fileURL);
        }
        return fileURL;
    } else{
        return [NSURL fileURLWithPath:pathToPDF];
    }
}


//-(void)updateImage:(FImage *)img
//{
//    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
//    [database open];
//    [database executeUpdate:@"UPDATE Media set localPath=? where path=?",img.localPath,img.path];
//    [database close];
//}


-(IBAction)logout:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark DB

-(NSMutableArray *)getAlphabeticalCases
{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and bookmark=1 order by title"]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionary:[results resultDictionary]];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

-(NSData *)getAuthorImage:(NSString *)authID
{
    NSData *data=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author where authorID=%@",authID]];
    while([results next]) {
        NSLog(@"image link %@",[results stringForColumn:@"image"]);
        NSString *localImg=[results stringForColumn:@"imageLocal"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localImg]) {
            data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[results stringForColumn:@"image"]]];
        }else{
            data=[NSData dataWithContentsOfFile:[results stringForColumn:@"imageLocal"]];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return data;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation!=UIInterfaceOrientationPortrait) {
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 654)];
        [newsViewController.view setFrame:CGRectMake(0,65, self.view.frame.size.height, 654)];
    }else{
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 910)];
        [newsViewController.view setFrame:CGRectMake(0,65, self.view.frame.size.height, 910)];
    }
    [settingsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!self.viewDeckController.leftController.view.isHidden) {
        CGRect newFrame = fotonaImg.frame;
        newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
        fotonaImg.frame = newFrame;
    }
    
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else{
        [APP_DELEGATE setCurrentOrientation:0];
    }
    
    
    beforeOrient=[APP_DELEGATE currentOrientation];
    [APP_DELEGATE rotatePopupSearchedNewsInView:self.view];
    
    [self.viewDeckController setLeftSize:self.view.frame.size.width-320];
    if (currentCase) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [self setContentSize];
        [UIView commitAnimations];
        
    }
    [self.view bringSubviewToFront:[self.view viewWithTag:1000]];
}


#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index <imagesList.count){ //[currentCase getImages].count){//TODO P
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
        FImage *img =[imagesList objectAtIndex:index];
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            NSString *pathTmp = [NSString stringWithFormat:@"%@%@",docDir,img.localPath];
            if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                
            }else{
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL fileURLWithPath:pathTmp]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                handler(image);
            });
        });
        
        
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
attributedCaptionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSAttributedString *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        DEMOPhoto *photo = self.photos[index];
    //        if(self.simulateLatency){
    //            sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //        }
    //
    //        handler(photo.attributedCaption);
    //    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        FImage *photo = [imagesList objectAtIndex:index];
        
        if (![photo.description isEqualToString:@""]) {
            NSMutableAttributedString *mutString=[[NSMutableAttributedString alloc] initWithData:[[NSString stringWithFormat:@"%@<br/>%@",photo.title,photo.description] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            handler([mutString string]);
        }else{
            handler(photo.title);
        }
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        FImage *photo = [currentCase getImages][index];
    //
    ////        handler(photo.description);
    //    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    //        DEMOPhoto *photo = self.photos[index];
    //        if(self.simulateLatency){
    //            sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //        }
    //
    //        handler(photo.tags);
    //    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        FImage *photo = [imagesList objectAtIndex:index];
        
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler
{
    //    DEMOPhoto *photo = self.photos[index];
    //    if(self.simulateLatency){
    //        sleep(arc4random_uniform(2)+arc4random_uniform(2));
    //    }
    //
    //    handler(photo.comments.count);
}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index
{
    //    DEMOPhoto *photo = self.photos[index];
    //    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    //    [remainingComments removeObject:deletedComment];
    //    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    DEMOPhoto *photo = self.photos[index];
    //    NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:photo.tags];
    //    id<EBPhotoTagProtocol> tagData = [tagPopover dataSource];
    //    [remainingTags removeObject:tagData];
    //    [photo setTags:[NSArray arrayWithArray:remainingTags]];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    //    NSLog(@"Delete photo at index %li", (long)index);
    //    DEMOPhoto *deletedPhoto = self.photos[index];
    //    NSMutableArray *remainingPhotos = [NSMutableArray arrayWithArray:self.photos];
    //    [remainingPhotos removeObject:deletedPhoto];
    //    [self setPhotos:remainingPhotos];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo
{
    //    NSLog(@"add new tag %@", tagText);
    //
    //    DEMOPhoto *photo = self.photos[index];
    //
    //    DEMOTag *newTag = [DEMOTag tagWithProperties:@{
    //                                                   @"tagPosition" : [NSValue valueWithCGPoint:tagLocation],
    //                                                   @"tagText" : tagText}];
    //
    //    NSMutableArray *mutableTags = [NSMutableArray arrayWithArray:photo.tags];
    //    [mutableTags addObject:newTag];
    //
    //    [photo setTags:[NSArray arrayWithArray:mutableTags]];
    
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index
{
    //    DEMOComment *newComment = [DEMOComment
    //                               commentWithProperties:@{@"commentText": comment,
    //                                                       @"commentDate": [NSDate date],
    //                                                       @"authorImage": [UIImage imageNamed:@"guestAv.png"],
    //                                                       @"authorName" : @"Guest User"}];
    //    [newComment setUserCreated:YES];
    //
    //    DEMOPhoto *photo = self.photos[index];
    //    [photo addComment:newComment];
    //
    //    [controller setComments:photo.comments forPhotoAtIndex:index];
}





#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
    if (beforeOrient!=[APP_DELEGATE currentOrientation]) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [self setContentSize];
        [UIView commitAnimations];
    }
}


#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    //        return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledTagging){
    //        return NO;
    //    }
    
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
 shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    //We assume all comment objects used in the demo are of type DEMOComment
    //    DEMOComment *demoComment = (DEMOComment *)comment;
    //
    //    if(demoComment.isUserCreated){
    //        //Demo user can only delete his or her own comments.
    //        return YES;
    //    }
    //
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    //        return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledCommenting){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledActivities){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledMiscActions){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledDelete){
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    //    if(photo.disabledDeleteForTags){
    //        return NO;
    //    }
    //
    //    return YES;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    //    if(!self.photos.count){
    return NO;
    //    }
    //
    //    if(index > 0){
    //        return YES;
    //    }
    //
    //    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

#pragma mark UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}



//fill the cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView2 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *identifier = @"FCollectionViewCell";
    BOOL bookmarked =NO;
    GEMainMenuCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [[cell image] setClipsToBounds:YES];
    [[cell image] setContentMode:UIViewContentModeCenter];
    
    FMedia *vid= [videoArray objectAtIndex:indexPath.row];
    [[cell titleLbl] setText:vid.title]; //text under video
    [cell.titleLbl setNumberOfLines:2];
    //[cell.titleLbl sizeToFit];
    [cell setVideo:vid];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKVIDEO, vid.itemID]];
    while([results next]) {
        bookmarked=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    if (bookmarked) {
        [cell.bookmarkBtn setHidden: YES];
        [cell.bookmarkRemoveBtn setHidden: NO];
    } else {
        [cell.bookmarkBtn setHidden: NO];
        [cell.bookmarkRemoveBtn setHidden: YES];
    }
    
    
    
    NSString *videoKey = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:[[videoArray objectAtIndex:indexPath.row] videoGalleryID] videoId:[[videoArray objectAtIndex:indexPath.row] itemID]];//[self getPreloadMoviesImagesKeyWithVideoId:indexPath.row];
    [[cell image] setImage:[preloadMoviesImages2 objectForKey:videoKey]];
    
    [ cell setParent:self];
    return cell;
    
}




-(void)collectionView:(UICollectionView *)collectionView2 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMedia *vid=[videoArray objectAtIndex:[indexPath row]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:vid.localPath];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:vid.localPath] && downloaded) {
        [FCommon playVideoFromURL:vid.localPath onViewController:self];
    }else
    {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"FILEDOWNLOAD", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 320);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([videoArray count]>0) {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:contentVideoModeView];
        [contentVideoModeView addSubview:hud];
        hud.labelText = @"Updating video images";
        [hud show:YES];
        
        numberOfImages = [videoArray count];
        success = 0;
        [self preloadMoviesImage2:videoArray];
    }
    
    return [videoArray count];
}


-(NSMutableArray *)getVideos
{
    categ = @"";
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? " withArgumentsInArray:@[usr, BOOKMARKVIDEO]];
    while([results next]) {
        
        int videoId = [results intForColumn:@"documentID"];
        
        FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%d order by sort",videoId]];
        
        while([results2 next]) {
            FMedia *f=[[FMedia alloc] initWithDictionary:[results2 resultDictionary]];
            [videosTmp addObject:f];
        }
        
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    videosTmp=[videosTmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    videoArray = videosTmp;
    return videosTmp;
}

-(NSMutableArray *)getVideoswithCategory:(NSString *)videoCategory
{
    categ = videoCategory;
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    NSMutableArray *videosSelected=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? " withArgumentsInArray:@[usr, BOOKMARKVIDEO]];
    while([resultsBookmarked next]) {
        [videosSelected addObject:[resultsBookmarked objectForColumnName:@"documentID"]];
    }
    for (NSString *vidID in videosSelected) {
        FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ order by sort",vidID]];
        
        while([results2 next]) {
            FMedia *f=[[FMedia alloc] initWithDictionary:[results2 resultDictionary]];
            
            if ([f checkVideoForCategory:videoCategory]) {
                [videosTmp addObject:f];
            }
            
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    videosTmp=[videosTmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    videoArray = videosTmp;
    return videosTmp;
}

-(BOOL)checkFotona:(NSString *)f andCategory:(NSString *)category
{
    //TODO predelava za pravice
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",f,category]];
    while([results next]) {
        NSLog(@"%@, %@",[results stringForColumn:@"fotonaID"],[results stringForColumn:@"userSubType"]);
        check=YES;
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
}


-(void)setVideos{
    
  
    
    NSMutableArray *videosTmp=[[NSMutableArray alloc] init];
    NSMutableArray *videosSelected=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
   NSString *usr = [FCommon getUser];
    
    FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? " withArgumentsInArray:@[usr, BOOKMARKVIDEO]];
    while([resultsBookmarked next]) {
        [videosSelected addObject:[resultsBookmarked objectForColumnName:@"documentID"]];
    }
    for (NSString *vidID in videosSelected) {
        FMResultSet *results2 = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Media where mediaID=%@ order by sort",vidID]];
        
        while([results2 next]) {
            FMedia *f=[[FMedia alloc] initWithDictionary:[results2 resultDictionary]];
            
            if ([f checkVideoForCategory:categ]) {
                [videosTmp addObject:f];
            }
            
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    videosTmp=[videosTmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    videoArray = videosTmp;

}


//-(NSString *)getPreloadMoviesImagesKeyWithVideoId:(NSInteger *)videoId
//{
//    return [NSString stringWithFormat:@"%d", (int)videoId];
//}
-(NSString *)getpreloadGalleryMoviesImagesKeyWithGalleryId:(NSString *)galleryId videoId:(NSString *)videoId
{
    return [NSString stringWithFormat:@"%@_%@", galleryId, videoId];
}

-(void)preloadMoviesImage2:(NSMutableArray *)videosArray2
{
    NSMutableDictionary *temp;
    if ([APP_DELEGATE videoImages]==nil) {
        temp =  [[NSMutableDictionary alloc] init];
    } else{
        temp =  [APP_DELEGATE videoImages];
    }
    //default video image
    for (int i=0;i<[videosArray2 count];i++)
    {
        NSString *videoKey2 =[self getpreloadGalleryMoviesImagesKeyWithGalleryId:[[videosArray2 objectAtIndex:i] videoGalleryID]videoId:[[videosArray2 objectAtIndex:i] itemID]]; //[self getPreloadMoviesImagesKeyWithVideoId:(NSInteger)i];
        if (![preloadMoviesImages2 objectForKey:videoKey2]) {
            if (![temp objectForKey:videoKey2]) {
                [preloadMoviesImages2 setValue:[self defaultVideoImage] forKey:videoKey2];
            } else{
                [preloadMoviesImages2 setValue:[temp objectForKey:videoKey2] forKey:videoKey2];
            }
            
        }
    }
    
    //queue
    NSArray *activeQueues2 = @[
                               dispatch_queue_create("videoTumbnailsLoadingQueue1",NULL),
                               //sdispatch_queue_create("videoTumbnailsLoadingQueue2",NULL),
                               //dispatch_queue_create("videoTumbnailsLoadingQueue3",NULL),
                               ];
    
    NSString *lastUpdate=[[NSUserDefaults standardUserDefaults] objectForKey:@"thubnailsLastUpdate"];
    for (int i=0;i<[videosArray2 count];i++)
    {
        FMedia *vid=[videosArray2 objectAtIndex:i];
        int activeQueueIndex = i%[activeQueues2 count];
        dispatch_async([activeQueues2 objectAtIndex:activeQueueIndex], ^{
            
            //id of image inside preloadGalleryMoviesImages
            NSString *videoKey2 = [self getpreloadGalleryMoviesImagesKeyWithGalleryId:[[videosArray2 objectAtIndex:i] videoGalleryID] videoId:[[videosArray2 objectAtIndex:i] itemID]];
            //image is not default
            if ([preloadMoviesImages2 objectForKey:videoKey2] != self.defaultVideoImage) {
                if (![lastUpdate isEqualToString:[self currentTimeInLjubljana]]) {
                    if ([APP_DELEGATE connectedToInternet]) {
                        
                        
                        NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid mediaImage]];
                        UIImage *imgNew = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                        CGSize size = CGSizeMake(300, 167);
                        UIGraphicsBeginImageContext(size);
                        
                        CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
                        [imgNew drawInRect:imgBorder];
                        
                        imgNew = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        if (imgNew!=nil) {
                            NSData *data1 = UIImagePNGRepresentation(imgNew);
                            NSData *data2 = UIImagePNGRepresentation([preloadMoviesImages2 objectForKey:videoKey2]);
                            if (![data1 isEqual:data2]) {
                                [preloadMoviesImages2 setValue:imgNew forKey:videoKey2];
                            }
                        }
                    }
                    
                    success++;
                    if (success == numberOfImages) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideAllHUDsForView:contentVideoModeView animated:YES];
                        });
                    }
                    
                    return;
                }
            }
            
            FMedia *vid=[videosArray2 objectAtIndex:i];
            
            if ([preloadMoviesImages2 count] <= i) {
                success++;
                if (success == numberOfImages) {
                    [MBProgressHUD hideAllHUDsForView:contentVideoModeView animated:YES];
                }
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img;
                NSArray *pathComp=[[vid mediaImage] pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[vid mediaImage] lastPathComponent]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                    NSData *data=[NSData dataWithContentsOfFile:pathTmp];
                    img = [UIImage imageWithData:data];
                } else{
                    NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",[vid mediaImage]];
                    img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                }
                if (img!=nil) {
                    CGSize size = CGSizeMake(300, 167);
                    UIGraphicsBeginImageContext(size);
                    
                    CGRect imgBorder = CGRectMake(0, 0, size.width, size.height);
                    [img drawInRect:imgBorder];
                    
                    img = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    NSIndexPath *collectionIndexPath2 = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    GEMainMenuCell *cell2 = [self.contentsVideoModeCollectionView cellForItemAtIndexPath:collectionIndexPath2];
                    
                    [preloadMoviesImages2 setValue:img forKey:videoKey2];
                    NSMutableDictionary *temp;
                    if ([APP_DELEGATE videoImages]==nil) {
                        temp =  [[NSMutableDictionary alloc] init];
                    } else{
                        temp =  [APP_DELEGATE videoImages];
                    }
                    [temp setValue:img forKey:videoKey2];
                    [APP_DELEGATE setVideoImages:temp];
                    if (cell2)
                    {
                        [[cell2 image] setImage:img];//iconImage];
                    }
                    
                }
                success++;
                if (success == numberOfImages) {
                    [MBProgressHUD hideAllHUDsForView:contentVideoModeView animated:YES];
                }
            });
            
        });
    }
    
}

-(void)openContentWithTitle:(NSString *)title
{
    [cvTitleLbl setText:title];
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
        [contentVideoModeView setFrame:CGRectMake(0,65, 1024, 650)];
    
    else
        [contentVideoModeView setFrame:CGRectMake(0,65, 768, 909)];
    [popupCloseBtn setHidden:YES];
    [menuBtn setHidden:NO];
    [contentVideoModeView setTag:OPENVIEW];
    [caseView setTag:CLOSEVIEW];
    [helpView setTag:CLOSEVIEW];
    [self.contentsVideoModeCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view addSubview:contentVideoModeView];
    [self.contentsVideoModeCollectionView reloadData];
    [caseView setHidden:YES];
    [helpView setHidden:YES];
    [eventView setTag:CLOSEVIEW];
    [eventView setHidden:YES];
    [contentVideoModeView setHidden:NO];
    [newsViewController.view setTag:CLOSEVIEW];
    [newsViewController.view  setHidden:YES];
}


-(void)downloadFile:(NSString *)fileUrl inFolder:(NSString *)folder type:(int)t
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",docDir,folder] withIntermediateDirectories:YES attributes:nil error:nil];
        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:folder]];
    }
    
    
    NSString *localPdf=[NSString stringWithFormat:@"%@%@/%@",docDir,folder,[fileUrl lastPathComponent]];
    BOOL downloaded = YES;
    for (FDownloadManager * download in [APP_DELEGATE downloadManagerArray]) {
        downloaded = [download checkDownload:localPdf];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPdf] && downloaded) {
        NSString *path = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[fileUrl lastPathComponent]];
        if (t==6) {
            [self openPDF:path];
        }
    }else
    {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"FILEDOWNLOAD", nil)]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    }
    
}

-(void)openPDF:(NSString *)path
{
    pathToPDF=path;
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    [[previewController.navigationController navigationBar] setHidden:YES];
    // start previewing the document at the current section index
    previewController.currentPreviewItemIndex = 0;
    
    [self  presentViewController:previewController animated:YES completion:nil];
}

-(NSString *)currentTimeInLjubljana
{
    NSDateFormatter *dateFormater=[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd.MM.yyyy"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Ljubljana"]];
    
    return [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

#pragma mark swipeMenu

-(IBAction)swipeMenuBookmark:(UIPanGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint vel = [recognizer velocityInView:caseScroll];
        if (self.viewDeckController.leftController.view.isHidden) {
            if (vel.x > 0 && !direction)
            {
                // user dragged towards the right
                CGRect newFrame = fotonaImg.frame;
                newFrame.origin.x += rotate * 180;
                rotate = -rotate;
                fotonaImg.frame = newFrame;
                [self.viewDeckController toggleLeftViewAnimated:YES];
                direction = TRUE;
            }
            
        } else{
            if (vel.x < 0  && direction)
            {
                // user dragged towards the left
                CGRect newFrame = fotonaImg.frame;
                newFrame.origin.x += rotate * 180;
                rotate = -rotate;
                fotonaImg.frame = newFrame;
                [self.viewDeckController toggleLeftViewAnimated:YES];
                direction = FALSE;
            }
        }
        
    } completion:^(BOOL finished) {
    }];
    
}

-(void)openHelp{
    [helpTitle setText:@"How to use bookmarks"];
    
    NSString *htmlString=[NSString stringWithFormat:NSLocalizedString(@"HOWTOUSE", nil)];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [helpContent setText:attrStr.string];
    helpContent.shadowColor = nil; // fill your color here
    helpContent.shadowOffset = CGSizeMake(0.0, -1.0);
    helpContent.lineHeightScale = 1.00;
    helpContent.fixedLineHeight = 24.00;
    helpContent.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
    helpContent.fdAutoFitMode=FDAutoFitModeAutoHeight;
    helpContent.fdTextAlignment=FDTextAlignmentJustify;
    helpContent.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    helpContent.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait)
        [helpView setFrame:CGRectMake(0,65, 1024, 650)];
    else
        [helpView setFrame:CGRectMake(0,65, 768, 909)];
    [popupCloseBtn setHidden:YES];
    [menuBtn setHidden:NO];
    [helpView setTag:OPENVIEW];
    [caseView setTag:CLOSEVIEW];
    [contentVideoModeView setTag:CLOSEVIEW];
    [self.view addSubview:helpView];
    [caseView setHidden:YES];
    [helpView setHidden:NO];
    [eventView setTag:CLOSEVIEW];
    [eventView setHidden:YES];
    [contentVideoModeView setHidden:YES];
    [newsViewController.newsView setTag:CLOSEVIEW];
    [newsViewController.newsView setHidden:YES];
}

- (IBAction)showDisclaimer:(id)sender {
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [helpView setFrame:CGRectMake(0, 65, 1024, 650)];
        [helpScrollView setFrame:CGRectMake(0, 0, 1024, 650)];
    }else
    {
        [helpView setFrame:CGRectMake(0, 65, 768, 909)];
        [helpScrollView setFrame:CGRectMake(0, 0, 768, 909)];
    }
    [helpView setTag:OPENVIEW];
    [caseView setTag:CLOSEVIEW];
    [contentVideoModeView setTag:CLOSEVIEW];
    [self.view  addSubview:helpView];
    [caseView setHidden:YES];
    [helpView setHidden:NO];
    [eventView setTag:CLOSEVIEW];
    [eventView setHidden:YES];
    [newsViewController.newsView setTag:CLOSEVIEW];
    [newsViewController.newsView setHidden:YES];
    [contentVideoModeView setHidden:YES];
    [helpTitle setText:@"Disclaimer"];
    
    
    //    cDescriptionLbl=[[FDLabelView alloc] initWithFrame:CGRectMake(38, 209, 710, 211)];
    helpContent.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.00];
    helpContent.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    helpContent.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    helpContent.minimumScaleFactor = 0.50;
    helpContent.numberOfLines = 0;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    //[self getDisclamer]
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [helpContent setText:attrStr.string];
    helpContent.shadowColor = nil; // fill your color here
    helpContent.shadowOffset = CGSizeMake(0.0, -1.0);
    helpContent.lineHeightScale = 1.00;
    helpContent.fixedLineHeight = 24.00;
    helpContent.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
    helpContent.fdAutoFitMode=FDAutoFitModeAutoHeight;
    helpContent.fdTextAlignment=FDTextAlignmentJustify;
    helpContent.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    helpContent.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    [helpScrollView setContentSize:CGSizeMake(768, helpContent.frame.origin.y+helpContent.frame.size.height+20)];
    
}

-(void) openEvent:(FEvent*) event fromCategory:(int) category{
    [eventTitleLbl setText:[[event title] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    
    NSString *htmlString=[HelperString toHtmlEvent:[event text]];
    
    [eventText loadHTMLString:htmlString baseURL:nil];
    eventDate.text = [[event eventdate] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [event eventdateTo]]];
    NSString * img =@"";
    if (category==0) {
        img = [event getDot];
    } else{
        img = [event getDot:category];
    }
    [self addImageScrollToEvent:event];
    [eventImg setImage:[UIImage imageNamed:img]];
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [eventView setFrame:CGRectMake(0,65, 1024, 654)];
    }else
    {
        [eventView setFrame:CGRectMake(0,65, 768, 910)];
    }
    

    [eventView setContentOffset:CGPointMake(0, -eventView.contentInset.top) animated:YES];
    
    [contentVideoModeView setTag:CLOSEVIEW];
    [caseView setTag:CLOSEVIEW];
    [helpView setTag:CLOSEVIEW];
    [self.view addSubview:eventView];
    [caseView setHidden:YES];
    [helpView setHidden:YES];
    [contentVideoModeView setHidden:YES];
    [eventView setTag:OPENVIEW];
    [eventView setHidden:NO];
    [newsViewController.newsView setTag:CLOSEVIEW];
    [newsViewController.newsView setHidden:YES];
    
}

- (void) addImageScrollToEvent:(FEvent *) showEvent{
    FEvent *openEvent = showEvent;
    int x=0;
    for (UIView *v in eventImagesScroll.subviews) {
        [v removeFromSuperview];
    }
    NSMutableArray *imgs=[openEvent eventImages];
    
    for (int i=0;i<imgs.count;i++){
        //todo dodat da odpira bookmark slike oz slike shranjene na napravi ne iz baze
        NSLog(@"imgs");
        UIImage *img=[UIImage imageWithContentsOfFile:[imgs objectAtIndex:i]];//[imgs objectAtIndex:i];
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
                [tmpImg.imageView setContentMode:UIViewContentModeScaleToFill];
                [tmpImg addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
                [eventImagesScroll addSubview:tmpImg];
            });
            
        });
        FImage *f=[[FImage alloc] init];
        [f setLocalPath:[imgs objectAtIndex:i]];
        [imagesList addObject:f];
    }
    
   
    if (imgs.count>0) {
        [eventImagesScroll setContentSize:CGSizeMake(160*(imgs.count)-10, 180)];
        [eventImagesScroll setContentOffset:CGPointZero animated:YES];
        [eventImagesScroll setFrame:CGRectMake(eventImagesScroll.frame.origin.x, eventImagesScroll.frame.origin.y, self.view.frame.size.width, 180)];
        [eventText setFrame:CGRectMake(eventImagesScroll.frame.origin.x, eventImagesScroll.frame.origin.y+180, self.view.frame.size.width, self.view.frame.size.height-180-eventImagesScroll.frame.origin.y)];
        [eventImagesScroll setHidden:NO];
    } else{
       // self.scrollViewHeight.constant=0;
        //self.scrollViewBottomSpace.constant=0;
        [eventImagesScroll setHidden:YES];
        [eventImagesScroll setContentSize:CGSizeMake(0, 0)];
        [eventImagesScroll setFrame:CGRectMake(eventImagesScroll.frame.origin.x, eventImagesScroll.frame.origin.y, 0, 0)];
        [eventText setFrame:CGRectMake(eventImagesScroll.frame.origin.x, eventImagesScroll.frame.origin.y, eventText.frame.size.width, eventText.frame.size.height+180)];

    }
}

-(void) openNews:(FNews*) news{
    [newsViewController.newsView removeFromSuperview];
    if (news.isReaded == NO) {
        news.isReaded = YES;
    }

    NSMutableArray *newsArray = [self getNewsFromDB];
    
    newsViewController.newsArray = newsArray;
    newsViewController.news = news;

    [self.view addSubview:newsViewController.view];

    if (![news isReaded]){
        NSString *t = [NSString stringWithFormat:@"%ld",[news newsID]];
        [[[FFeaturedViewController_iPad alloc] init] setNewsReaded:t];

        news.isReaded = YES;
    }
    [APP_DELEGATE setNewsTemp:nil];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr = [FCommon getUser];
    
    NSString * newsIDtemp=[NSString stringWithFormat:@"%ld",[news newsID]];
    [database executeUpdate:@"INSERT INTO NewsRead (newsID, userName) VALUES (?,?)",newsIDtemp,usr];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];

    [contentVideoModeView setTag:CLOSEVIEW];
    [caseView setTag:CLOSEVIEW];
    [helpView setTag:CLOSEVIEW];
    
    [caseView setHidden:YES];
    [helpView setHidden:YES];
    [contentVideoModeView setHidden:YES];
    [eventView setTag:CLOSEVIEW];
    [eventView setHidden:YES];
    [newsViewController.newsView setTag:OPENVIEW];
    [newsViewController.newsView setHidden:NO];
    [self.view addSubview:newsViewController.newsView];
}


-(NSMutableArray *)getNewsFromDB
{
    NSMutableArray *news=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=%hhd ORDER BY title DESC",YES]];
    while([results next]) {
        FNews *f;
        f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
        [news addObject:f];
        
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    news = [NSMutableArray arrayWithArray:[news sortedArrayUsingFunction:dateSortNews context:nil] ];
    
    
    //The date sort function
    return news;
}

NSComparisonResult dateSortNews(FNews *n1, FNews *n2, void *context) {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSDate *d1 = [formatter dateFromString:n1.nDate];
    NSDate *d2 = [formatter dateFromString:n2.nDate];
    
    //return [d1 compare:d2]; // ascending order
    return [d2 compare:d1]; // descending order
}


- (void)closeOnTabBookmarks:(NSNotification *)n {
    [caseScroll addGestureRecognizer:swipeRecognizerB];
    exCaseView.hidden=YES;
    contentVideoModeView.hidden=YES;
    helpView.hidden = YES;
    caseView.hidden=NO;
    [fotonaImg setHidden:NO];
    [caseView addSubview:fotonaImg];
    CGRect newFrame = fotonaImg.frame;
    newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
    fotonaImg.frame = newFrame;
    rotate = 1;
    [[APP_DELEGATE main_ipad].bookMenu resetViewAnime:YES];
    [self.viewDeckController openLeftView];
    direction = TRUE;
    [contentVideoModeView removeFromSuperview];
    [eventView removeFromSuperview];
    [newsViewController.newsView removeFromSuperview];
}

//-(NSString *) getDisclamer{
//    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
//    NSString *htmlString = @"";
//    [database open];
//    FMResultSet *results = [database executeQuery:@"SELECT * FROM Disclaimer"];
//    while([results next]) {
//        htmlString = [results stringForColumn:@"disclaimer"];
//    }
//    [database close];
//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
//    return htmlString;
//}
@end

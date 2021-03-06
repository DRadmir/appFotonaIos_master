//
//  FCasebookViewController.m
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FCasebookViewController.h"
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
#import "FCaseMenuViewController.h"
#import "FMainViewController_iPad.h"
#import "FSettingsViewController.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "FDB.h"
#import "FGoogleAnalytics.h"
#import "FMediaManager.h"

@interface FCasebookViewController ()
{
    int numberOfSpaces;//between texts introduction, procedure ...
    int state;
    BOOL openGal;
    FSettingsViewController *settingsController;
    int rotate;
    BOOL direction;
    UIPanGestureRecognizer *swipeRecognizerB;
}
@end

@implementation FCasebookViewController
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
        [self setTitle:NSLocalizedString(@"CASEBOOOKTABTITLE", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"casebook_grey.png"]];
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
    
    
    isExpanded=NO;
    
    openGal = NO;
    state = 0;
    
    CGRect newFrame = fotonaImg.frame;
    
    if ([FCommon isOrientationLandscape])
        newFrame.origin.x -= 105;
    
    else
        newFrame.origin.x -=  160;
    rotate = 1;
    fotonaImg.frame = newFrame;
    direction = TRUE;
    
    //swipe closing menu
    
    swipeRecognizerB = [[UIPanGestureRecognizer alloc]
                        initWithTarget:self action:@selector(swipeMenuCaseBook:)];
    
    
    [caseScroll addGestureRecognizer:swipeRecognizerB];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabCasebook:)
                                                 name:@"CloseOnTabCasebook"
                                               object:nil];
    
    settingsController = [APP_DELEGATE settingsController];
    
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait) {
        [exCaseView setFrame:CGRectMake(0,65, 1024, 655)];
    }
    else
    {
        [exCaseView setFrame:CGRectMake(0,65, 768, 909)];
    }

    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    [self.tabBarItem setImage:[UIImage imageNamed:@"casebook_red.png"]];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    
    if (!exCaseView.isHidden) {
        if (currentCase!=nil) {
            BOOL bookmarked = NO;
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            NSString *usr = [FCommon getUser];
            
            FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, currentCase.caseID]];
            while([resultsBookmarked next]) {
                bookmarked = YES;
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            if (bookmarked || [currentCase.coverflow intValue] == 1){//[currentCase.bookmark boolValue]) {
                [addBookmarks setHidden:YES];
                [removeBookmarks setHidden:NO];
            } else {
                if ([ConnectionHelper connectedToInternet]) {
                    [addBookmarks setHidden:NO];
                } else {
                    [addBookmarks setHidden:YES];
                }
                [removeBookmarks setHidden:YES];
            }
            
        }
    }

    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL fimg =self.viewDeckController.leftController.view.isHidden;
    CGRect newFrame = fotonaImg.frame;
    newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2;
    if (!self.viewDeckController.leftController.view.isHidden) {
        newFrame.origin.x -= 162;
        
    }

    fotonaImg.frame = newFrame;
    if ([FCommon getCase] != nil) {
        flagCarousel = YES;
        currentCase = [FCommon getCase];
        [FCommon setCase:nil];
    }
    if(flagCarousel){ //when clicked on Carousel ---------------------------------------------------------------------------
        [self.viewDeckController closeLeftView];
        [[APP_DELEGATE main_ipad].caseMenu resetViewAnime:YES];
        [self openCase];
        [[APP_DELEGATE tabBar] setLast:3];
        
        
        if (direction) {
            CGRect newFrame = fotonaImg.frame;
            
            newFrame.origin.x +=  180;
            rotate = -1;
            fotonaImg.frame = newFrame;
            direction = FALSE;
        }
        
    }else
    {
        [self.viewDeckController closeLeftView];
       
        if (currentCase && beforeOrient!=[APP_DELEGATE currentOrientation]) {
                  [self openCase];
        }
        if(!openGal){
            [self.viewDeckController openLeftView];
        }
        
        if (self.viewDeckController.leftController.view.isHidden != fimg) {
            CGRect newFrame = fotonaImg.frame;
            
            newFrame.origin.x -=  180;
            rotate = 1;
            fotonaImg.frame = newFrame;
            direction = TRUE;
            
        }
    }
    beforeOrient=[APP_DELEGATE currentOrientation];
    openGal = NO;
    [self.viewDeckController setLeftSize:self.view.frame.size.width-320];
        
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    flagCarousel=NO;
    [self.tabBarItem setImage:[UIImage imageNamed:@"casebook_grey.png"]];
    if (!settingsView.isHidden && settingsView != nil) {
        [self closeSettings:nil];
    }
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
            if (indexPath.row<menuIcons.count) {
                imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
            } else {
                imageName=[NSString stringWithFormat:@""];
            }
            
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
        }else if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FAuthor class]]) {
            NSMutableArray *newItems=[self getCasesWithAuthorID:[[menuItems objectAtIndex:indexPath.row] authorID]];
            NSLog(@"case author");
            if (newItems.count>0) {
                selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] name]];
                [menuTitle setText:[menuTitles lastObject]];
                [allItems addObject:newItems];
                menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
                [menuTable reloadData];
            }
            else
            {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
            
            
        }else{
            if ([[[menuItems objectAtIndex:indexPath.row] categoryID] isEqualToString:@""]) {
                //list by author or alphabetical
                if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Case Author"]) {
                    NSMutableArray *newItems=[self getAuthors];
                    selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                    [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] title]];
                    [menuTitle setText:[menuTitles lastObject]];
                    [allItems addObject:newItems];
                    menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
                    [menuTable reloadData];
                    
                }else if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Alphabetical List"]) {
                    NSMutableArray *newItems=[self getAlphabeticalCases];
                    selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                    [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] title]];
                    [menuTitle setText:[menuTitles lastObject]];
                    [allItems addObject:newItems];
                    menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
                    [menuTable reloadData];
                }
            }else{
                NSMutableArray *newItems=[self getFromDB:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                if (newItems.count==0) {
                    newItems=[self getCases:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                    if (newItems.count==0) {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                        //                        [self backBtn:nil];
                    }
                    else {
                        casesInMenu=[[NSMutableArray alloc] init];
                        [allCasesInMenu addObject:casesInMenu];
                        selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                        [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] title]];
                        [menuTitle setText:[menuTitles lastObject]];
                        
                        [allItems addObject:newItems];
                        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
                        [menuTable reloadData];
                    }
                }else{
                    selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                    [menuTitles addObject:[[menuItems objectAtIndex:indexPath.row] title]];
                    [menuTitle setText:[menuTitles lastObject]];
                    casesInMenu=[self getCases:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                    [allCasesInMenu addObject:casesInMenu];
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
    [contentModeView removeFromSuperview];
//    NSString *usr = [FCommon getUser];
    
    [caseScroll removeGestureRecognizer:swipeRecognizerB];
    
    BOOL bookmarked = [FDB checkIfBookmarkedForDocumentID:[currentCase caseID] andType:BOOKMARKCASE];
    [caseScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    if ([FDB checkIfFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE]) {
        [removeFavorite setHidden:NO];
        [addToFavorite setHidden:YES];
    } else {
        [removeFavorite setHidden:YES];
        [addToFavorite setHidden:NO];
    }

    if (![currentCase isEqual:prevCase]) {
        NSLog(@"%@",currentCase.coverTypeID);
        [tableParameters setHidden:YES];
        [fotonaImg setHidden:YES];
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
    [caseScroll setContentSize:CGSizeMake(self.view.frame.size.width, exCaseView.frame.size.height)];
    [additionalInfo setFrame:CGRectMake(0, additionalInfo.frame.origin.y, self.view.frame.size.width, 231)];
    if (![currentCase isEqual:prevCase]) {
        [caseScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    numberOfSpaces=0;
    [self setCaseOutlets];
    [self setPatameters];
    [self setPrevCase:currentCase];
    [exCaseView setHidden:NO];
    
    
    if (bookmarked || [currentCase.coverflow intValue] == 1){//[[currentCase bookmark] boolValue]) {
        [addBookmarks setHidden:YES];
        [removeBookmarks setHidden:NO];
    } else{
        if ([ConnectionHelper connectedToInternet]) {
            [addBookmarks setHidden:NO];
        } else {
            [addBookmarks setHidden:YES];
        }
        [removeBookmarks setHidden:YES];
    }
}

-(void)setCaseOutlets
{
    [FGoogleAnalytics writeGAForItem:[currentCase title] andType:GACASEINT];
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
   
    [authorImg setImage: [FDB getAuthorImage:[currentCase authorID]]];
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
    
    NSString * title = @"";
    NSMutableAttributedString *allAdditionalInfo=[[NSMutableAttributedString alloc] init];
    NSString *check=[[currentCase introduction] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
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
        
        title = @"<br/><br/>";
        
    }
    
    
    
    check=[[currentCase procedure] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase procedure] && ![check isEqualToString:@""]) {
        
        numberOfSpaces++;
        
        title =[title stringByAppendingString:@"<br/><p>Procedure</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
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
        title = @"<br/><br/>";
    }
    
    
    
    check=[[currentCase results] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase results] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        title =[title stringByAppendingString:@"<br/><p>Results</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
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
        title = @"<br/><br/>";
    }
    
    check=[[currentCase references] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    check=[check stringByReplacingOccurrencesOfString:@"<br type=\"_moz\" />" withString:@""];
    if ([currentCase references] && ![check isEqualToString:@""]) {
        numberOfSpaces++;
        title =[title stringByAppendingString:@"<br/><p>References</p><br/>"];
        NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
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
        title = @"<br/><br/>";
        
    }
    
    //DISCLAMER
    numberOfSpaces++;
    title =[title stringByAppendingString:@"<br/><p>Disclamer</p><br/>"];
    NSMutableAttributedString * titleAttrStr = [[NSMutableAttributedString alloc] initWithData:[title dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [titleAttrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue" size:17] range: NSMakeRange(0, titleAttrStr.length)];
    [allAdditionalInfo appendAttributedString:titleAttrStr];
    
    //[self getDisclamer:true]
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerShort"]  dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
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
        
        NSMutableArray *caseVideos= [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            caseVideos=[currentCase getVideos];
        } else{
            caseVideos = [currentCase video];
        }
        NSMutableArray *vidArr = [[NSMutableArray alloc] init];
        for (FMedia *video in caseVideos) {
            if ([video.deleted intValue] == 0) {
                [vidArr addObject:video];
            }
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
                NSString *localPath = [FMedia createLocalPathForLink:vid.path andMediaType:MEDIAVIDEO];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                    videoURL= [NSURL URLWithString:vid.path] ;
                }else{
                    videoURL=[NSURL fileURLWithPath:localPath];
                }
                
                AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
                AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                generate1.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                
                //on cases video thumbnail is the same of CMS
                UIImage *image;
                
                if ([ConnectionHelper connectedToInternet])
                    {
                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: vid.mediaImage]];
                        image = [UIImage imageWithData: imageData];
                        
                        }
                else
                {
                    CMTime time = CMTimeMakeWithSeconds([vid.time integerValue], 1);
                    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
                    image=one;
                }
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    //code to be executed on the main thread when background task is finished
                    [tmpImg setImage:image forState:UIControlStateNormal];
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
        NSMutableArray *caseImages = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            caseImages=[currentCase getImages];
        } else{
            caseImages = [currentCase images];
        }
        
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        for (FImage *image in caseImages) {
            if ([image.deleted intValue] == 0) {
                [imgs addObject:image];
            }
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
                NSString *pathTmp = [FMedia createLocalPathForLink:img.path andMediaType:MEDIAIMAGE];
                if (![[NSFileManager defaultManager] fileExistsAtPath:pathTmp]) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
                    
                }else{
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pathTmp]]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //code to be executed on the main thread when background task is finished
                    [tmpImg setImage:image forState:UIControlStateNormal];
                    [tmpImg setTag:i];
                    [tmpImg addTarget:self action:@selector(openGalleryCase:) forControlEvents:UIControlEventTouchUpInside];
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
    if (currentCase.parameters && currentCase.parameters != (id)[NSNull null] && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=0 && [[[APP_DELEGATE currentLogedInUser] userType] intValue]!=3 && [FCommon userPermission:currentCase.userPermissions]) {
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
    if ([FCommon isOrientationLandscape]) {
        [disclaimerBtn setFrame:CGRectMake(225, introductionTitle.frame.size.height-15, 99, 40)];
    }else
    {
        [disclaimerBtn setFrame:CGRectMake(480, introductionTitle.frame.size.height-15, 99, 40)];
    }
    
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

#pragma mark Bookmarks

- (IBAction)addToFavorite:(id)sender {    
    [FDB addTooFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE];
    [removeFavorite setHidden:NO];
    [addToFavorite setHidden:YES];
}

- (IBAction)removeFavorite:(id)sender {
    [FDB removeFromFavoritesItem:[[currentCase caseID] intValue] ofType:BOOKMARKCASE];
    [removeFavorite setHidden:YES];
    [addToFavorite setHidden:NO];
}

- (IBAction)removeFromBookmarks:(id)sender {
    [HelperBookmark removeBookmarkedCase:currentCase];
}

- (IBAction)addToBookmarks:(id)sender {
    if ([ConnectionHelper getWifiOnlyConnection]) {
        [self bookmarkCase];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:self.view];
    }
    
}

- (void) refreshBookmarkBtn  {
    if ([addBookmarks isHidden]) {
        if ([ConnectionHelper connectedToInternet] || [currentCase.coverflow intValue] == 1) {
            [addBookmarks setHidden:NO];
        } else {
            [addBookmarks setHidden:YES];
        }
    } else {
        [addBookmarks setHidden:YES];
    }
    [removeBookmarks setHidden:![removeBookmarks isHidden]];
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
            //            [ wifiSwitch setOn:YES animated:YES];
            [self bookmarkCase];
        }
    }
    
}

-(void) bookmarkCase{
    
    if([ConnectionHelper connectedToInternet] || [currentCase.coverflow intValue] == 1){
        //[addBookmarks setHidden:YES];
        //[removeBookmarks setHidden:NO];
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"BOOKMARKING", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

-(void)addMedia:(NSMutableArray *)m withType:(int)type{
    if (m.count>0) {
        NSMutableArray *links =[[NSMutableArray alloc] init];
        if (type==0) {
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FImage *img in m) {
                NSArray *pathComp=[img.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@/%@",@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[img.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,sort, deleted, fileSize) VALUES (?,?,?,?,?,?,?,?,?,?)",img.itemID,img.title,img.path,pathTmp,img.description,@"0",@"0",img.sort, img.deleted, img.fileSize];
                //                [img downloadFile:img.path inFolder:@"/.Cases"];
                [links addObject:img.path];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            [APP_DELEGATE setBookmarkAll:YES];
            [[FDownloadManager shared] downloadImages:links];
        }else if(type==1){
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            for (FMedia *vid in m) {
                NSArray *pathComp=[vid.path pathComponents];
                NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[vid.path lastPathComponent]];
                [database executeUpdate:@"INSERT INTO Media (mediaID,title,path,localPath,description,mediaType,isBookmark,time,mediaImage,sort, active, deleted, download, fileSize, userPermissions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",vid.itemID,vid.title,vid.path,pathTmp,vid.description,@"1",@"0",vid.time,vid.mediaImage,vid.sort, vid.active, vid.deleted, vid.download, vid.filesize, vid.userPermissions];
                //                [vid downloadFile:vid.path inFolder:@"/.Cases"];
                [links addObject:vid.path];
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            [APP_DELEGATE setBookmarkAll:YES];
            [[FDownloadManager shared] downloadVideos:links];
        }
        
    }
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

- (IBAction)openSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    [self.settingsBtn setEnabled:NO];
    if ([FCommon isOrientationLandscape]) {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 654)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 654)];
    }else
    {
        settingsView=[[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, 910)];
        [settingsController.view setFrame:CGRectMake(0,0, self.view.frame.size.width, 910)];
    }
    settingsController.contentWidth.constant = self.view.frame.size.width;
    
    [settingsView addSubview:settingsController.view];
    
    [popupCloseBtn setHidden:NO];
    [menuBtn setHidden:YES];
    
    [caseView setHidden:YES];
    [self.view addSubview:settingsView];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
    [settingsView setHidden:NO];
    
}

- (IBAction)closeSettings:(id)sender {
    self.viewDeckController.panningMode = IIViewDeckLeftSide;
    [UIView animateWithDuration:0.3 animations:^{
        [caseView setHidden:NO];
        [popupCloseBtn setHidden:YES];
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

- (IBAction)showDisclaimer:(id)sender {
    
    [self openDisclaimer];
    
}

-(void) openDisclaimer{
    [exCaseView setHidden:YES];
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait){
        [contentModeView setFrame:CGRectMake(0, 0, 1024, 653)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 1024, 653)];
    }else
    {
        [contentModeView setFrame:CGRectMake(0, 0, 768, 909)];
        [contentModeScrollView setFrame:CGRectMake(0, 0, 768, 909)];
    }
    
    [fotonaImg setHidden:YES];
    [caseView addSubview:contentModeView];
    [cTitleLbl setText:@"Disclaimer"];
    
    cDescriptionLbl.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.00];
    cDescriptionLbl.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    cDescriptionLbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    cDescriptionLbl.minimumScaleFactor = 0.50;
    cDescriptionLbl.numberOfLines = 0;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[[[NSUserDefaults standardUserDefaults] stringForKey:@"disclaimerLong"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [cDescriptionLbl setText:attrStr.string];
    cDescriptionLbl.shadowColor = nil; // fill your color here
    cDescriptionLbl.shadowOffset = CGSizeMake(0.0, -1.0);
    cDescriptionLbl.lineHeightScale = 1.00;
    cDescriptionLbl.fixedLineHeight = 24.00;
    cDescriptionLbl.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
    cDescriptionLbl.fdAutoFitMode=FDAutoFitModeAutoHeight;
    cDescriptionLbl.fdTextAlignment=FDTextAlignmentJustify;
    cDescriptionLbl.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    cDescriptionLbl.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    [contentModeScrollView setContentSize:CGSizeMake(768, cDescriptionLbl.frame.origin.y+cDescriptionLbl.frame.size.height+20)];
    
}

-(IBAction)openVideo:(id)sender
{
    FMedia *vid=[[currentCase getVideos] objectAtIndex:[sender tag]];
    BOOL coverflow = [[currentCase coverflow] isEqualToString:@"1"] ? YES : NO;
    [FCommon playVideo:vid onViewController:self isFromCoverflow:coverflow];
    
}
-(IBAction)openGalleryCase:(id)sender
{
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self photoAtIndex:[sender tag]];
    photoPagesController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoPagesController animated:YES completion:nil];
    openGal=YES;
    
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
        imgs=[currentCase getImages];
    } else{
        imgs = [currentCase images];
    }
    
    return imgs.count;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
        imgs=[currentCase getImages];
    } else{
        imgs = [currentCase images];
    }
    
    FImage *img=[imgs objectAtIndex:idx];//[[currentCase getImages] objectAtIndex:idx];
    if ([[img localPath] isEqualToString:@""]) {
        //        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Image is not downloaded. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [av show];
    }
    if (![[img localPath] isEqualToString:@""]) {
        fileURL = [NSURL fileURLWithPath:[img localPath]];
        NSLog(@"FF%@",fileURL);
    }
    return fileURL;
}



-(IBAction)logout:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark DB
-(NSMutableArray *)getMenu
{
    NSMutableArray *m=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM CaseCategories where categorieIDPrev is null"]];
    while([results next]) {
        FCaseCategory *cc=[[FCaseCategory alloc] init];
        [cc setCategoryID:[results stringForColumn:@"categorieID"]];
        [cc setCategoryIDPrev:[results stringForColumn:@"categorieIDPrev"]];
        [cc setTitle:[results stringForColumn:@"title"]];
        [cc setActive:[results stringForColumn:@"active"]];
        [m addObject:cc];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return m;
}
-(NSMutableArray *)getFromDB:(NSString *)prev
{
    NSMutableArray *m=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM CaseCategories where categorieIDPrev=%@",prev]];
    while([results next]) {
        FCaseCategory *cc=[[FCaseCategory alloc] init];
        [cc setCategoryID:[results stringForColumn:@"categorieID"]];
        [cc setCategoryIDPrev:[results stringForColumn:@"categorieIDPrev"]];
        [cc setTitle:[results stringForColumn:@"title"]];
        [cc setActive:[results stringForColumn:@"active"]];
        [m addObject:cc];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return m;
}

-(NSMutableArray *)getCases:(NSString *)catID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT c.* FROM Cases as c,CasesInCategories as cic where cic.categorieID=%@ and cic.caseID=c.caseID",catID]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        if ([FCommon isGuest] && ([FCommon userPermission:[f userPermissions]] || [[currentCase coverflow] boolValue])) {
            [cases addObject:f];
        }else if(![FCommon isGuest]){
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

-(NSMutableArray *)getAuthors{
    NSMutableArray *authors=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Author"]];
    while([results next]) {
        FAuthor *f=[[FAuthor alloc] init];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setImageLocal:[results stringForColumn:@"imageLocal"]];
        [f setCv:[results stringForColumn:@"cv"]];
        [f setActive:[results stringForColumn:@"active"]];
        [authors addObject:f];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return authors;
}

-(NSMutableArray *)getCasesWithAuthorID:(NSString *)authorID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where authorID=%@",authorID]];
    while([results next]) {
        FCase *f=[[FCase alloc] initWithDictionaryFromDB:[results resultDictionary]];
        if ([FCommon isGuest] && ([FCommon userPermission:[f userPermissions]] || [[currentCase coverflow] boolValue])) {
            [cases addObject:f];
        }else if(![FCommon isGuest]){
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

-(NSMutableArray *)getAlphabeticalCases
{
    NSMutableArray *cases=[APP_DELEGATE caseArray];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [cases sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
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
        
    }else{
        [settingsView setFrame:CGRectMake(0,0, self.view.frame.size.height, 910)];
        
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
        [disclaimerBtn setFrame:CGRectMake(225, introductionTitle.frame.size.height-15, 99, 40)];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
        [disclaimerBtn setFrame:CGRectMake(480, introductionTitle.frame.size.height-15, 99, 40)];
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
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
        imgs=[currentCase getImages];
    } else{
        imgs = [currentCase images];
    }
    if(index < imgs.count){//[currentCase getImages].count){
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
        NSMutableArray *caseImages = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            caseImages=[currentCase getImages];
        } else{
            caseImages = [currentCase images];
        }
        
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        for (FImage *image in caseImages) {
            if ([image.deleted intValue] == 0) {
                [imgs addObject:image];
            }
        }

        FImage *img =imgs[index]; //[currentCase getImages][index];
        
        dispatch_queue_t queue = dispatch_queue_create("Image queue", NULL);
        dispatch_async(queue, ^{
            //code to be executed in the background
            UIImage *image;
            //            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img.path]]];
            NSString *pathTmp = [FMedia createLocalPathForLink:img.path andMediaType:MEDIAIMAGE];
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
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            imgs=[currentCase getImages];
        } else{
            imgs = [currentCase images];
        }
        
        FImage *photo =imgs[index]; //[currentCase getImages][index];
        
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
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        if ([[currentCase bookmark] boolValue] || [[currentCase coverflow] boolValue]) {
            imgs=[currentCase getImages];
        } else{
            imgs = [currentCase images];
        }
//        FImage *photo = imgs[index];
        //[currentCase getImages][index];
        
        
        //        handler(@[photo.description]);
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


#pragma mark swipeMenu

-(IBAction)swipeMenuCaseBook:(UIPanGestureRecognizer *)recognizer {
    
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint vel = [recognizer velocityInView:caseScroll];
        
        if (vel.y == 0  && vel.x > 1 && !direction)
        {
            if (self.viewDeckController.leftController.view.isHidden) {
                // user dragged towards the right
                CGRect newFrame = fotonaImg.frame;
                newFrame.origin.x += rotate * 180;
                rotate = -rotate;
                fotonaImg.frame = newFrame;
                [self.viewDeckController toggleLeftViewAnimated:YES];
                direction = TRUE;
            }
            
        } else{
            if (vel.y == 0  && vel.x < -1  && direction)
            {
                if (!self.viewDeckController.leftController.view.isHidden) {
                    // user dragged towards the left
                    CGRect newFrame = fotonaImg.frame;
                    newFrame.origin.x += rotate * 180;
                    rotate = -rotate;
                    fotonaImg.frame = newFrame;
                    [self.viewDeckController toggleLeftViewAnimated:YES];
                    direction = FALSE;
                }
            }
        }
        
    } completion:^(BOOL finished) {
    }];
    
    
}

- (void)closeOnTabCasebook:(NSNotification *)n {
    [caseScroll addGestureRecognizer:swipeRecognizerB];
    [contentModeView removeFromSuperview];
    [caseView setHidden:NO];
    [exCaseView setHidden:YES];
    [fotonaImg setHidden:NO];
    CGRect newFrame = fotonaImg.frame;
    newFrame.origin.x = self.view.frame.size.width/2-fotonaImg.frame.size.width/2-162;
    fotonaImg.frame = newFrame;
    rotate = 1;
    [[APP_DELEGATE main_ipad].caseMenu resetViewAnime:YES];
    [self.viewDeckController openLeftView];
    direction = TRUE;
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"BOOKMARKING", nil)]) {
        [HelperBookmark bookmarkCase:currentCase];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    }
}



@end

//
//  FFeaturedViewController.m
//  Fotona
//
//  Created by Dejan Krstevski on 3/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FFeaturedViewController_iPad.h"
#import "FMDatabase.h"
#import "FNews.h"
#import "FEvent.h"
#import "NSString+HTML.h"
#import "FDLabelView.h"
#import "FCase.h"
#import "FCasebookViewController.h"
#import "FCaseMenuViewController.h"
#import "FSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FCollectionViewCell.h"
#import "UIView+Border.h"
#import "FSettingsViewController.h"
#import "FGalleryViewController.h"
#import "FImage.h"
#import "NewsViewCell.h"
#import "FCarousel.h"
#import "FNewsView.h"
#import "HelperBookmark.h"
#import "HelperDate.h"
#import "FDB.h"



@interface FFeaturedViewController_iPad ()
{
    BOOL wrap;
    int status;
    FSettingsViewController *settingsController;
    UILabel *disclaimerLbl;
    
    long selectedCowerflowIndexIpad;
    NSTimer *animationRotationTimerIpad;
}

@end

@implementation FFeaturedViewController_iPad
@synthesize carousel;
@synthesize items;
@synthesize newsArray;
@synthesize popover;
@synthesize eventsArray;
@synthesize collectionView;
@synthesize openNews;
@synthesize aboutDescription;
@synthesize aboutScrollView;
@synthesize aboutTitle;
@synthesize aboutView;


#define OPENVIEW 1000
#define CLOSEVIEW 0
#define SETTINGSVIEW 2000;

int cellNumber =5;
int e=0;

int disclamerRotation = 1;

FNewsView *newsViewController;

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
        [self setTitle:@"Featured"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"homepage_red.png"]];
        status = 0;
        
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    newsViewController = [[FNewsView alloc] init];
    [APP_DELEGATE setClosedNews:NO];
    // Do any additional setup after loading the view from its nib.
    
    firstRun=YES;
    beforeOrient=[APP_DELEGATE currentOrientation];
    
    //feedback
    [feedbackBtn addTarget:APP_DELEGATE action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    //feedback
    // [settingsBtn addTarget:APP_DELEGATE action:@selector(:) forControlEvents:UIControlEventTouchUpInside];
    
    //search
    FSearchViewController *searchVC=[[FSearchViewController alloc] init];
    [searchVC setParent:self];
    popover=[[UIPopoverController alloc] initWithContentViewController:searchVC];
    
    
    cellNumber =5;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"NewsViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NewsViewCell"];
    
    if([[FCommon getUser] isEqualToString:@"guest"]){
        cellNumber = 4;
    }
    else{
        cellNumber = 5;
    }
    

    //swipe closing news
    
    UISwipeGestureRecognizer *swipeRecognizerAbout = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(closeNews:)];
    [aboutView addGestureRecognizer:swipeRecognizerAbout];
    
    settingsController = [APP_DELEGATE settingsController];
    
    UISwipeGestureRecognizer *swipeRecognizerAboutS = [[UISwipeGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(closeNews:)];
    [settingsView addGestureRecognizer:swipeRecognizerAboutS];
    //tab closing news
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeOnTabNews:)
                                                 name:@"CloseOnTabNews"
                                               object:nil];
    //disclaimerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height - 63)];
    // disclaimerLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, disclaimerScrollView.frame.size.width-40, 460.0f)];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUp];
    carousel.type = iCarouselTypeLinear;
    [carousel reloadData];
    
    if ([APP_DELEGATE closedNews]) {
        //[self getNewsFromDB];
        newsArray = [FDB getNewsSortedDateFromDB];
        cellNumber = 12;
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        if ([APP_DELEGATE closedEvents]) {
            self.eventsArray = [FDB getEventsFromDB];//[[self getEventsFromDB];
            [APP_DELEGATE setClosedEvents:NO];
        }
        
    }
    [APP_DELEGATE setClosedNews:NO];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"homepage_red.png"]];
    [self.view addSubview:mainScroll];
    if (firstRun || [APP_DELEGATE newNews]) {
        [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText = @"Opening news";
        [hud show:YES];
        [newsScroll setHidden:YES];
    }
    
    if (firstRun || beforeOrient!=[APP_DELEGATE currentOrientation]) {
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
        if (orientation!=UIInterfaceOrientationPortrait) {
            // Do something when in landscape
            screenWidth=768.f;
            [mainScroll setFrame:CGRectMake(0,65, 1024, 655)];
            [newsViewController.view setFrame:CGRectMake(0,65, 1024, 655)];
            
        }
        else
        {
            // Do something when in portrait
            screenWidth=1024.f;
            [mainScroll setFrame:CGRectMake(0,65, 768, 909)];
            [newsViewController.view setFrame:CGRectMake(0,65, 768, 909)];
        }
        
    }
    if (!firstRun) {
        FNews *newsTemp = [APP_DELEGATE newsTemp];
        if(newsTemp != nil){
            [self openNews:newsTemp];
        } else{
            [collectionView reloadData];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (firstRun || [APP_DELEGATE newNews]){
        self.eventsArray = [FDB getEventsFromDB];//[self getEventsFromDB];
        //[self getNewsFromDB];
        newsArray = [FDB getNewsSortedDateFromDB];
        if (newsArray.count>=1) {
            [collectionView reloadData];
            [newsScroll setHidden:NO];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
        }
        
        
        if (firstRun) {
            firstRun=NO;
        }
    }
    beforeOrient=[APP_DELEGATE currentOrientation];
    if ([APP_DELEGATE currentOrientation] != disclamerRotation) {
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopRotationAnimationIpad];
    [self.tabBarItem setImage:[UIImage imageNamed:@"homepage_grey.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    e = newsArray.count;
    if (cellNumber>newsArray.count && e>0) {
        cellNumber = newsArray.count;
    }
    if (newsArray !=nil){
        if ([[[APP_DELEGATE currentLogedInUser] userType] intValue] == 0 || [[[APP_DELEGATE currentLogedInUser] userType] intValue] == 3)
            e++;
    }
    if(eventsArray !=nil)
        e++;
    return e;
}
#define ABOUT_CELL_VIEW_START_TAG 600
#define EVENT_CELL_VIEW_START_TAG 500
#define NEWS_CELL_VIEW_START_TAG 400

//fill the cell
- (FCollectionViewCell *)collectionView:(UICollectionView *)collectionView2 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"FCollectionViewCell";
    static NSString *identifier2 = @"NewsViewCell";
    if ([[[APP_DELEGATE currentLogedInUser] userType]intValue] == 0 || [[[APP_DELEGATE currentLogedInUser] userType] intValue] == 3){
        if (indexPath.row == 0) {
            FCollectionViewCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
            [cell setTag:ABOUT_CELL_VIEW_START_TAG];
            [cell.eventCell setHidden:YES];
            [cell.aboutCell setHidden:NO];
            //cell.aboutDesc.text =
            NSString *htmlString = [NSString stringWithFormat:NSLocalizedString(@"ABOUTSHORT", nil)];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5;
            paragraphStyle.paragraphSpacing=24;
            paragraphStyle.lineBreakMode= NSLineBreakByTruncatingTail;
            
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
            NSDictionary *attrsDictionary = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
            //popupEventText.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:17];
            cell.aboutDesc.attributedText = [[NSAttributedString alloc] initWithString:attrStr.string attributes:attrsDictionary];
            return cell;
        } else {
            
            if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
                status = 1; //guest landscape
                if (indexPath.row==2) {
                    FCollectionViewCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
                    [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
                    [cell.eventCell setHidden:NO];
                    [cell.aboutCell setHidden:YES];
                    [cell setTag:EVENT_CELL_VIEW_START_TAG];
                    cell.events = eventsArray;
                    [cell fillData];
                    return cell;
                    
                    
                } else {
                    NewsViewCell *cell2 = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier2 forIndexPath:indexPath];
                    if (indexPath.row==1) {
                        cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row-1];
                    } else {
                        cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row-2];
                    }
                    return cell2;
                }
                
            }
            else{
                status = 2; //guest portrait
                if (indexPath.row==1) {
                    FCollectionViewCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
                    [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
                    [cell.aboutCell setHidden:YES];
                    [cell.eventCell setHidden:NO];
                    cell.events = eventsArray;
                    [cell setTag:EVENT_CELL_VIEW_START_TAG];
                    [cell fillData];
                    return cell;
                } else {
                    NewsViewCell *cell2 = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier2 forIndexPath:indexPath];
                    cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row-2];
                    return cell2;
                }
            }
        }
    }else {
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            status = 3; //usr landscape
            if (indexPath.row==2) {
                FCollectionViewCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
                [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
                [cell.aboutCell setHidden:YES];
                [cell.eventCell setHidden:NO];
                cell.events = eventsArray;
                [cell setTag:EVENT_CELL_VIEW_START_TAG];
                [cell fillData];
                return cell;
            } else {
                NewsViewCell *cell2 = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier2 forIndexPath:indexPath];;
                if (indexPath.row<2) {
                    cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row];
                } else {
                    cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row-1];
                }
                return cell2;
            }
        }
        else{
            status = 4; //usr portrait
            if (indexPath.row==1) {
                FCollectionViewCell *cell = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
                [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
                [cell.aboutCell setHidden:YES];
                [cell.eventCell setHidden:NO];
                cell.events = eventsArray;
                [cell setTag:EVENT_CELL_VIEW_START_TAG];
                [cell fillData];
                return cell;
            } else {
                NewsViewCell *cell2 = [collectionView2 dequeueReusableCellWithReuseIdentifier:identifier2 forIndexPath:indexPath];
                if (indexPath.row==0) {
                    cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row];
                } else {
                    cell2 = [self fillNewsCell:cell2 withIndex:indexPath.row-1];
                }
                return cell2;
            }
        }
    }
}

- (NewsViewCell *) fillNewsCell:(NewsViewCell *) cell2 withIndex:(int) index{
    NewsViewCell *tempCell = cell2;
    [tempCell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    tempCell.newsNew.hidden = YES;
    [tempCell setTag:NEWS_CELL_VIEW_START_TAG];
    tempCell.newsTitle.text = [[newsArray objectAtIndex:index] title];
    tempCell.newsDate.text = [HelperDate formatedDate: [[newsArray objectAtIndex:index] nDate]];
    if (index>=cellNumber) {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:mainScroll];
        [mainScroll addSubview:hud];
        hud.labelText = @"Loading...";
        //        [[MBProgressHUD showHUDAddedTo:self.view animated:YES]  setLabelText:@"Loading"];
        [hud show:YES];
        CGPoint offset = collectionView.contentOffset;
        offset.y-=30;
        collectionView.scrollEnabled =NO;
        [collectionView setContentOffset:offset animated:NO];
        int l = 4;
        cellNumber+=l;
        if (cellNumber>newsArray.count) {
            l =newsArray.count+l-cellNumber;
            cellNumber = newsArray.count;
        }
        dispatch_queue_t queue = dispatch_queue_create("com.4egenus.fotona", NULL);
        dispatch_async(queue, ^{
            newsArray = [FNews getImages:newsArray fromStart:index forNumber:l];
            dispatch_async(dispatch_get_main_queue(), ^{
                collectionView.scrollEnabled = YES;
                [collectionView reloadData ];
                [MBProgressHUD hideAllHUDsForView:mainScroll animated:YES];
                
            });
        });
        
    }
    
    tempCell.newsImage.image =[[[newsArray objectAtIndex:index] images] objectAtIndex:0];
    [tempCell.newsImage setContentMode:UIViewContentModeScaleAspectFill];
    [tempCell.newsImage setClipsToBounds:YES];
    
    if (![[newsArray objectAtIndex:index] isReaded] && index<8) {
        tempCell.newsNew.hidden = NO;
    }
    return tempCell;
}


//click on news cell
-(void)collectionView:(UICollectionView *)collectionView2 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int index = 0;
    //setting index for reading news
    switch (status) {
        case 1:
            if (indexPath.row == 1) {
                index = 0;
            } else {
                index = indexPath.row - 2;
            }
            break;
        case 2:
            index = indexPath.row -2;
            break;
        case 3:
            if (indexPath.row < 2) {
                index = indexPath.row;
            } else {
                index = indexPath.row-1;
            }
            break;
            
        default:
            if (indexPath.row == 0) {
                index = indexPath.row;
            } else {
                index = indexPath.row-1;
            }
            break;
    }
    FCollectionViewCell *cell = (FCollectionViewCell*)[collectionView2 cellForItemAtIndexPath:indexPath];
    if (cell.tag !=EVENT_CELL_VIEW_START_TAG && cell.tag !=ABOUT_CELL_VIEW_START_TAG) {
        NewsViewCell* cell = (NewsViewCell*)[collectionView2 cellForItemAtIndexPath:indexPath];
        [popupCloseBtn setHidden:NO];
        cell.newsNew.hidden  = YES;
        openNews = [newsArray objectAtIndex:index];
        
        
        
        newsViewController.newsArray = newsArray;
        newsViewController.news = [newsArray objectAtIndex:index];
        //tempView.parent = self;
        [self.view addSubview:newsViewController.view];
        [mainScroll setHidden:YES];
        [aboutView setHidden:YES];
        [newsViewController.view setHidden:NO];
        if (![[newsArray objectAtIndex:index] isReaded]){
            NSString *t = [NSString stringWithFormat:@"%ld",[[newsArray objectAtIndex:index] newsID]];
            [self setNewsReaded:t];
            FNews * temp = [newsArray objectAtIndex:index];
            temp.isReaded = YES;
        }
        
        newsViewController.view.tag = OPENVIEW;
        mainScroll.tag=CLOSEVIEW;
        aboutView.tag = CLOSEVIEW;
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(closeNews:)];
        [newsViewController.view addGestureRecognizer:swipeRecognizer];
    }
    else if(cell.tag ==ABOUT_CELL_VIEW_START_TAG){
        [self openAbout];
    }
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
        return CGSizeMake(312, 321);
    }
    else
        return CGSizeMake(346, 321);
}

-(void)openNews:(FNews *) news {
    openNews = news;
    [newsViewController.view removeFromSuperview];
    for (FNews *n in newsArray) {
        if (n.newsID==news.newsID) {
            news=n;
            break;
        }
    }
    if (news.isReaded == NO) {
        news.isReaded = YES;
    }
    [popupCloseBtn setHidden:NO];
    newsViewController.newsArray = newsArray;
    newsViewController.news = news;
    [mainScroll setHidden:YES];
    [aboutView setHidden:YES];
    
    [self.view addSubview:newsViewController.view];
    if (![news isReaded]){
        NSString *t = [NSString stringWithFormat:@"%ld",[news newsID]];
        [self setNewsReaded:t];
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
    
    newsViewController.view.tag = OPENVIEW;
    mainScroll.tag=CLOSEVIEW;
    aboutView.tag = CLOSEVIEW;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(closeNews:)];
    [newsViewController.view addGestureRecognizer:swipeRecognizer];
    
}


-(IBAction)closePopupNewsView:(id)sender
{
    
    [self closeViewsAnimated];
}

-(void)openSettings:(id)sender
{
    [settingsBtn setEnabled:NO];
    
    [popupCloseBtn setHidden:NO];
    
    
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
    if (mainScroll.isHidden) {
        if (newsViewController.view.isHidden) {
            aboutView.hidden=YES;
            aboutView.tag=OPENVIEW;
        } else {
            newsViewController.view.hidden=YES;
            newsViewController.view.tag=OPENVIEW;
            
        }
    }
    else{
        [mainScroll setHidden:YES];
        mainScroll.tag=OPENVIEW;
    }
    settingsView.tag = OPENVIEW;
    [self.view addSubview:settingsView];
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:NO];
    [settingsView setHidden:NO];
}


-(IBAction)showButton:(id)sender
{
    [sender setHidden:NO];
}

-(void)setNewsReaded:(NSString *)nID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    [database executeUpdate:@"UPDATE News set isReaded='YES' where newsID=?",nID];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
}


#pragma mark iCarousel methods

- (void)setUp
{
    //set up data
    wrap = YES;
    
    self.items = [FDB getCasesForCarouselFromDB];//self.getCasesForCarouselFromDB;
    //random mixing carousel
    for (int x = 0; x < [items count]; x++) {
        int randInt = (arc4random() % ([items count] - x)) + x;
        [items exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    
}
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    FCarousel * card = [[FCarousel alloc] initWithNibName:@"FCarousel" bundle:nil];
    card.type = [[[items objectAtIndex:index] coverTypeID] intValue];
    card.background = [UIImage imageNamed:[NSString stringWithFormat:@"card%@.png",[[items objectAtIndex:index] coverTypeID]]];
    card.caseTitle = [(FCase *)items[index] title];
    card.date = [APP_DELEGATE timestampToDateString:[(FCase *)items[index] date]];
    card.name = [NSString stringWithFormat:@"%@",[(FCase *)items[index] name]];
    
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2), ^{
        //code to be executed in the background
        NSLog(@"author id %@",[(FCase *)items[index] authorID]);
        // NSData *imgData=[FDB getAuthorImage:[(FCase *)items[index] authorID]];//[self getAuthorImage:[(FCase *)items[index] authorID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            //[imageView setImage:[UIImage imageWithData:imgData]];
            card.carouselDoctorImage.layer.cornerRadius = card.carouselDoctorImage.frame.size.height /2;
            card.carouselDoctorImage.layer.masksToBounds = YES;
            card.carouselDoctorImage.layer.borderWidth = 0;
            [card.carouselDoctorImage setContentMode:UIViewContentModeScaleAspectFill];
            card.carouselDoctorImage.image = [FDB getAuthorImage:[(FCase *)items[index] authorID]];//[UIImage imageWithData:imgData];
        });
    });
    view = card.view;
     [self resetRotationAnimationIpad];
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 440.0, 193.0)];
        ((UIImageView *)view).image = [UIImage imageNamed:[NSString stringWithFormat:@"card%lu.png",index%3+1]];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 210, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50.0f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = (index == 0)? @"[": @"]";
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return 1.035f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}


#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    FCase *item = (self.items)[index];
    NSLog(@"Tapped view number: %@", item);
    UINavigationController *tempC = [(IIViewDeckController *)[[self.tabBarController viewControllers] objectAtIndex:3] centerController];
    [(FCasebookViewController *)[tempC visibleViewController] setCurrentCase:item];
    [(FCasebookViewController *)[tempC visibleViewController] setFlagCarousel:YES];
    [self.tabBarController setSelectedIndex:3];
    
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


-(FNews *)getNewsByID:(NSString *)newsID
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FNews *f=[[FNews alloc] init];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM News where active=1 and newsID=%@",newsID]];
    while([results next]) {
        f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return f;
}



-(FCase *)getCase:(NSString *)caseID
{
    FCase *f=[[FCase alloc] init];
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and caseID=%@ limit 1",caseID]];
    while([results next]) {
        [f setCaseID:[results stringForColumn:@"caseID"]];
        [f setTitle:[results stringForColumn:@"title"]];
        [f setCoverTypeID:[results stringForColumn:@"coverTypeID"]];
        [f setName:[results stringForColumn:@"name"]];
        [f setImage:[results stringForColumn:@"image"]];
        [f setIntroduction:[results stringForColumn:@"introduction"]];
        [f setProcedure:[results stringForColumn:@"procedure"]];
        [f setResults:[results stringForColumn:@"results"]];
        [f setReferences:[results stringForColumn:@"references"]];
        [f setParametars:[results stringForColumn:@"parameters"]];
        [f setDate:[results stringForColumn:@"date"]];
        [f setGalleryID:[results stringForColumn:@"galleryID"]];
        [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
        [f setActive:[results stringForColumn:@"active"]];
        [f setAllowedForGuests:[results stringForColumn:@"allowedForGuests"]];
        [f setAuthorID:[results stringForColumn:@"authorID"]];
        [f setBookmark:[results stringForColumn:@"isBookmark"]];
        [f setCoverflow:[results stringForColumn:@"alloweInCoverFlow"]];
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    if ([APP_DELEGATE checkGuest]) {
        if ([f.allowedForGuests isEqualToString:@"1"]) {
            return f;
        }
    } else {
        return f;
    }
    return nil;
}


//changing the screen orientation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        [mainScroll setFrame:CGRectMake(0,65, 1024, 655)];
        [newsViewController.view setFrame:CGRectMake(0,65, 1024, 655)];
        [carousel setFrame:CGRectMake(0, 0, 1024, 338)];
        
        screenWidth=768;
        [APP_DELEGATE setCurrentOrientation:1];
        beforeOrient=[APP_DELEGATE currentOrientation];
        [collectionView reloadData];
        [settingsView setFrame:CGRectMake(0,65, self.view.frame.size.height, 654)];
        
    }else
    {
        [mainScroll setFrame:CGRectMake(0,65, 768, 909)];
        [newsViewController.view setFrame:CGRectMake(0,65, 768, 909)];
        [carousel setFrame:CGRectMake(0, 0, 768, 338)];
        
        screenWidth=1024;
        [APP_DELEGATE setCurrentOrientation:0];
        beforeOrient=[APP_DELEGATE currentOrientation];
        [collectionView reloadData];
        [settingsView setFrame:CGRectMake(0,65, self.view.frame.size.height, 909)];
    }
    [settingsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [disclaimerView  setFrame:CGRectMake(0.0f, 0.0f, self.parentViewController.view.frame.size.height, self.parentViewController.view.frame.size.width)];
    [disclaimerScrollView  setFrame:CGRectMake(0.0f, 0.0f, self.parentViewController.view.frame.size.height, self.parentViewController.view.frame.size.width - 63)];
    [disclaimerLbl  setFrame :CGRectMake(40.0f, 40.0f, disclaimerScrollView.frame.size.width-80, 460.0f)];
    [disclaimerLbl sizeToFit];
    disclaimerScrollView.contentSize = CGSizeMake(disclaimerScrollView.contentSize.width, disclaimerLbl.frame.size.height+15);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [APP_DELEGATE rotatePopupSearchedNewsInView:self.view];
}

#pragma mark closeviews

-(IBAction)closeNews:(UISwipeGestureRecognizer *)recognizer {
    
    [self closeViewsAnimated];
}

- (void)closeOnTabNews:(NSNotification *)n {
    [self closeViewsAnimated];
}

-(void) closeViewsAnimated{
    
    
    if (settingsView.tag==OPENVIEW) {
        [UIView animateWithDuration:0.3 animations:^{
            
            if (newsViewController.view.tag==OPENVIEW) {
                newsViewController.view.hidden=NO;
            } else{
                if (aboutView.tag==OPENVIEW) {
                    aboutView.hidden=NO;
                } else{
                    [popupCloseBtn setHidden:YES];
                    [mainScroll setHidden:NO];
                    
                }
            }
            
            CGRect newFrame = settingsView.frame;
            newFrame.origin.x += self.view.frame.size.width;
            settingsView.frame = newFrame;
        } completion:^(BOOL finished) {
            if (newsViewController.view.tag==OPENVIEW) {
                newsViewController.view.tag=CLOSEVIEW;
            } else{
                if (aboutView.tag==OPENVIEW) {
                    aboutView.tag=CLOSEVIEW;
                } else{
                    [newsViewController.view removeFromSuperview];
                    [aboutView removeFromSuperview];
                    [collectionView reloadData];
                    
                }
                
            }
            settingsView.tag=CLOSEVIEW;
            [settingsView removeFromSuperview];
            CGRect newFrame = settingsView.frame;
            newFrame.origin.x -= self.view.frame.size.width;
            settingsView.frame = newFrame;
            [settingsView setHidden:YES];
            
        }];
        
        
        
    } else{
        if (!newsViewController.view.isHidden) {
            [UIView animateWithDuration:0.3 animations:^{
                [mainScroll setHidden:NO];
                CGRect newFrame = newsViewController.view.frame;
                newFrame.origin.x += self.view.frame.size.width;
                newsViewController.view.frame = newFrame;
                [popupCloseBtn setHidden:YES];
            } completion:^(BOOL finished) {
                
                [newsViewController.view removeFromSuperview];
                [mainScroll setHidden:NO];
                [collectionView reloadData];
                newsViewController.view.tag=CLOSEVIEW;
            }];
            
        } else if (!aboutView.isHidden) {
            [UIView animateWithDuration:0.3 animations:^{
                [mainScroll setHidden:NO];
                CGRect newFrame = aboutView.frame;
                newFrame.origin.x += self.view.frame.size.width;
                aboutView.frame = newFrame;
                [popupCloseBtn setHidden:YES];
            } completion:^(BOOL finished) {
                [aboutView removeFromSuperview];
                [mainScroll setHidden:NO];
                [collectionView reloadData];
                aboutView.tag=CLOSEVIEW;
            }];
            
        }
        
        
    }
    
    [[[APP_DELEGATE tabBar] tabBar] setUserInteractionEnabled:YES];
    
    
    [settingsBtn setEnabled:YES];
    
}

#pragma mark openingAbout

-(void)openAbout{
    [aboutTitle setText:@"About fotona"];
    
    NSString *htmlString=[NSString stringWithFormat:NSLocalizedString(@"ABOUTLONG", nil)];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    paragraphStyle.paragraphSpacing=0.3;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    NSDictionary *attrsDictionary = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
    aboutDescription.attributedText = [[NSAttributedString alloc] initWithString:attrStr.string attributes:attrsDictionary];
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
        [aboutView setFrame:CGRectMake(0,65, 1024, 650)];
    else
        [aboutView setFrame:CGRectMake(0,65, 768, 909)];
    [popupCloseBtn setHidden:NO];
    [self.view addSubview:aboutView];
    [aboutView setTag:OPENVIEW];
    [newsViewController.view setTag:CLOSEVIEW];
    [mainScroll setTag:CLOSEVIEW];
    [mainScroll setHidden:YES];
    [newsViewController.view setHidden:YES];
    [aboutView setHidden:NO];
}





- (IBAction)btnAcceptClick:(id)sender {
    NSMutableArray *disclaimerArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"disclaimerShown"]];
    NSString *usr = [FCommon getUser];
    [disclaimerArray addObject:usr];
    [[NSUserDefaults standardUserDefaults] setObject:disclaimerArray forKey:@"disclaimerShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [disclaimerView removeFromSuperview];
}

- (IBAction)btnDeclineClick:(id)sender {
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"STARTDISCLAIMERCLOSE", nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        exit(0);
    }
}

- (void) showDisclaimer
{
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation!=UIInterfaceOrientationPortrait) {
        [disclaimerView  setFrame:CGRectMake(0.0f, 0.0f, 1024, 768)];
        [disclaimerScrollView  setFrame:CGRectMake(0.0f, 0.0f, 1024, 768 - 63)];
        disclamerRotation = 0;
    }
    else
    {
        disclamerRotation  = 1;
        [disclaimerView  setFrame:CGRectMake(0.0f, 0.0f, 768, 1024)];
        [disclaimerScrollView  setFrame:CGRectMake(0.0f, 0.0f, 768, 1024 - 63)];
    }
    
    
    btnAccept.layer.cornerRadius = 3;
    btnAccept.layer.borderWidth = 1;
    btnAccept.layer.borderColor = btnAccept.tintColor.CGColor;
    btnDecline.layer.cornerRadius = 3;
    btnDecline.layer.borderWidth = 1;
    btnDecline.layer.borderColor = btnDecline.tintColor.CGColor;
    disclaimerLbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 40.0f, disclaimerScrollView.frame.size.width-80, 460.0f)];
    NSString *htmlString=[NSString stringWithFormat:@"<html><body><style>p{margin-top: 27px;margin-bottom: 27px; line-height:30px; font-size:1.3em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} p6{ line-height:30px; font-size:1.5em; font-family: 'HelveticaNeue-Medium', Helvetica, Serif;} h{ line-height:30px; font-size:2em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</body></html>", [NSString stringWithFormat:NSLocalizedString(@"STARTDISCLAIMER", nil)]];
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    //[attrStr addAttribute:NSFontAttributeName value: [UIFont fontWithName:@"HelveticaNeue-Light" size:17] range: NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:10];
    [style setAlignment:NSTextAlignmentJustified];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, attrStr.length)];
    
    disclaimerLbl.attributedText = attrStr;
    disclaimerLbl.numberOfLines = 0;
    [disclaimerLbl sizeToFit];
    [disclaimerScrollView addSubview:disclaimerLbl];
    disclaimerScrollView.contentSize = CGSizeMake(disclaimerScrollView.contentSize.width, disclaimerLbl.frame.size.height+15);
    [self.parentViewController.view addSubview:disclaimerView];
    disclamerRotation = [APP_DELEGATE currentOrientation];
    
}

#pragma mark: - Rotating cases

- (void) startRotationAnimationIpad {
    animationRotationTimerIpad = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(moveTo) userInfo:nil repeats:NO];
}

- (void) stopRotationAnimationIpad {
    [animationRotationTimerIpad invalidate];
    animationRotationTimerIpad = nil;
}

- (void) resetRotationAnimationIpad {
    [self stopRotationAnimationIpad];
    [self startRotationAnimationIpad];
}

- (void) moveTo
{
    [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         selectedCowerflowIndexIpad = [carousel currentItemIndex] + 1;
                         [carousel scrollToItemAtIndex:selectedCowerflowIndexIpad animated:true];
                     }
                     completion:nil];
}




@end

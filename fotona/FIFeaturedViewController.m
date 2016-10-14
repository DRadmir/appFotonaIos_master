//
//  FIFeaturedViewController.m
//  fotona
//
//  Created by Janos on 22/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIFeaturedViewController.h"
#import "FICarousel.h"
#import "FDB.h"
#import "FIFeaturedEventTableViewCell.h"
#import "FIFeaturedNewsTableViewCell.h"
#import "MBProgressHUD.h"
#import "FIFlowController.h"
#import "FINewsContainerViewController.h"
#import "UIWindow+Fotona.h"
#import "FINewsViewController.h"
#import "FGoogleAnalytics.h"


#define ABOUT_CELL_VIEW_START_TAG 600
#define EVENT_CELL_VIEW_START_TAG 500
#define NEWS_CELL_VIEW_START_TAG 400

@interface FIFeaturedViewController ()
{
    BOOL wrap;
    BOOL eventsBool;
    BOOL newsBool;
    BOOL guestBool;
    
    int newsCount;
    int extraNews;
    
    int newsSelected;
    
    FIFeaturedEventTableViewCell *eventCell;
    
    BOOL aboutClick;
    NSIndexPath *eventCellIndex;
    
    long selectedCowerflowIndexIphone;
    NSTimer *animationRotationTimerIphone;
}
@end

@implementation FIFeaturedViewController

@synthesize carousel;
@synthesize items;
@synthesize carouselHeight;

@synthesize newsArray;
@synthesize eventsArray;
@synthesize tableViewFeatured;


- (void)viewDidLoad {
    [super viewDidLoad];
    carouselHeight.constant = [[UIScreen mainScreen] bounds].size.width / 2.279;
    
    newsCount = 12;
    extraNews = 4;
    newsSelected = 0;
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.newsTab == nil)
    {
        flow.newsTab = self;
    }
    
    [self.tableViewFeatured setNeedsLayout];
    [self.tableViewFeatured layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    [self setUp];
    carousel.type = iCarouselTypeLinear;
    [carousel reloadData];
    eventsArray = [FDB getEventsFromDB];
    newsArray = [FDB getNewsSortedDateFromDB];
    eventsBool =  (eventsArray != nil);
    newsBool = (newsArray != nil);
    guestBool = ([[[APP_DELEGATE currentLogedInUser] userType] intValue] == 0 || [[[APP_DELEGATE currentLogedInUser] userType] intValue] == 3);
    if (eventsBool) {
        [self createEventCell];
    }
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.showMenu = true;
    
    }

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FGoogleAnalytics writeGAForItem:nil andType:GAFEATUREDTABINT];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopRotationAnimationIphone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Events

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    if (eventsBool) {
        count++;
    }
    if (newsBool) {
        count++;
    }
    if (guestBool) {
        count++;
    }
    return count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 103;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    aboutClick = false;
    if (guestBool && indexPath.section == 0) {
        aboutClick = true;
        [self performSegueWithIdentifier:@"showNews" sender:self];
    } else
    {
        if (newsBool) {
            NSInteger count = 0;
            if (eventsBool) {
                count++;
            }
            if (guestBool) {
                count++;
            }
            
            if (indexPath.section == count) {
                newsSelected = indexPath.row;
                FIFeaturedNewsTableViewCell *cell = [self.tableViewFeatured cellForRowAtIndexPath:indexPath];
                cell.signNewNewsCell.hidden = true;
                [APP_DELEGATE setNewsArray:newsArray];
                [self performSegueWithIdentifier:@"showNews" sender:self];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && guestBool) {
        
        return 1;
    } else if ((guestBool && eventsBool && section == 1) || (section == 0 && eventsBool))
    {
        return 1;
    }
    return newsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && guestBool) {
        
        FIFeaturedNewsTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedNewsTableViewCell" owner:self options:nil] objectAtIndex:2];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setTag:ABOUT_CELL_VIEW_START_TAG];
        [cell fillCell];
        return cell;
        
    } else if ((guestBool && eventsBool && indexPath.section == 1) || (indexPath.section == 0 && eventsBool))
    {
        eventCellIndex = indexPath;
        return eventCell;
    }
    
    FIFeaturedNewsTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedNewsTableViewCell" owner:self options:nil] objectAtIndex:0];
    if (indexPath.row == 0) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedNewsTableViewCell" owner:self options:nil] objectAtIndex:1];
    }
    if (indexPath.row > newsCount - 1) {
        
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText = @"Loading...";
        //        [[MBProgressHUD showHUDAddedTo:self.view animated:YES]  setLabelText:@"Loading"];
        [hud show:YES];
        CGPoint offset = self.tableViewFeatured.contentOffset;
        offset.y-=10;
        self.tableViewFeatured.scrollEnabled =NO;
        [self.tableViewFeatured setContentOffset:offset animated:NO];
        int l = 4;
        if (newsCount + l > newsArray.count) {
            l = newsArray.count - newsCount;
        }
        newsCount+=l;
        dispatch_queue_t queue = dispatch_queue_create("com.4egenus.fotona", NULL);
        dispatch_async(queue, ^{
            newsArray = [FNews getImages:newsArray fromStart:indexPath.row forNumber:l];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableViewFeatured.scrollEnabled  = YES;
                [self.tableViewFeatured reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        });
        
    }
    cell.news = newsArray[indexPath.row];
    [cell fillCell];
    if (indexPath.row>= 8)
    {
        cell.signNewNewsCell.hidden = true;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:NEWS_CELL_VIEW_START_TAG];
    return cell;
}


#pragma mark - iCarousel methods

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
    FICarousel * card = [[FICarousel alloc] initWithNibName:@"FICarousel" bundle:nil];
    card.caseCard = [items objectAtIndex:index];
    card.view.frame = CGRectMake(card.view.frame.origin.x, card.view.frame.origin.y,[[UIScreen mainScreen] bounds].size.width, carouselHeight.constant);
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2), ^{
        //code to be executed in the background
        //NSData *imgData=[FDB getAuthorImage:[(FCase *)items[index] authorID]];//[self getAuthorImage:[(FCase *)items[index] authorID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            card.carouselDoctorImage.layer.cornerRadius = card.carouselDoctorImage.frame.size.height /2;
            card.carouselDoctorImage.layer.masksToBounds = YES;
            card.carouselDoctorImage.layer.borderWidth = 0;
            [card.carouselDoctorImage setContentMode:UIViewContentModeScaleAspectFill];
            card.carouselDoctorImage.image = [FDB getAuthorImage:[(FCase *)items[index] authorID]];
        });
    });
    view = card.view;
    [self resetRotationAnimationIphone];
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
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, carouselHeight.constant)];
        ((UIImageView *)view).image = [UIImage imageNamed:[NSString stringWithFormat:@"card%lu.png",index%3+1]];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 210, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:10.0f];
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
            return 1.00f;
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


#pragma mark - iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.caseFlow = self.items[index];
    if (flow.caseMenu != nil)
    {
        [[[flow caseMenu] navigationController] popToRootViewControllerAnimated:false];
    }
    flow.lastIndex = 3;
    [self.tabBarController setSelectedIndex:3];
    
}

#pragma mark - Custom

-(void) createEventCell
{
    eventCell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedEventTableViewCell" owner:self options:nil] objectAtIndex:0];
    [eventCell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    eventCell.events = eventsArray;
    [eventCell setTag:EVENT_CELL_VIEW_START_TAG];
    [eventCell fillDataiPhone];
    eventCell.parent = self;
    [eventCell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showNews"])
    {
        if (aboutClick) {
            FINewsContainerViewController *openView = (FINewsContainerViewController *)segue.destinationViewController;
            openView.showAbout = true;
        } else{
            if ([APP_DELEGATE newsTemp] == nil) {
                [APP_DELEGATE setNewsTemp:newsArray[newsSelected]];
            }
        }
        
        
    }
}

#pragma mark - Opening News

-(void)openNews
{
    aboutClick = false;
    [APP_DELEGATE setNewsArray:newsArray];
    if ([[APP_DELEGATE window].visibleViewController isKindOfClass:[FINewsContainerViewController class]]) {
        for (UIView *object in [APP_DELEGATE window].visibleViewController.childViewControllers ) {
            if([object isKindOfClass:[FINewsViewController class]])
            {
                FINewsViewController *nview = (FINewsViewController *)object;
                [nview reloadView];
            }
        }
        
    } else
    {
        [self performSegueWithIdentifier:@"showNews" sender:self];
    }
}

#pragma mark: - Rotating cases

- (void) startRotationAnimationIphone {
    animationRotationTimerIphone = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(moveTo) userInfo:nil repeats:NO];
}

- (void) stopRotationAnimationIphone {
    [animationRotationTimerIphone invalidate];
    animationRotationTimerIphone = nil;
}

- (void) resetRotationAnimationIphone {
    [self stopRotationAnimationIphone];
    [self startRotationAnimationIphone];
}

- (void) moveTo
{
    [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         selectedCowerflowIndexIphone = [carousel currentItemIndex] + 1;
                         [carousel scrollToItemAtIndex:selectedCowerflowIndexIphone animated:true];
                     }
                     completion:nil];
}

@end

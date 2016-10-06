//
//  FNewsViewController.m
//  fotona
//
//  Created by Janos on 06/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FINewsViewController.h"
#import "HelperString.h"
#import "FIFeaturedNewsTableViewCell.h"
#import "FDB.h"
#import "FImage.h"
#import "FVideo.h"
#import "FIGalleryController.h"
#import "HelperDate.h"

@interface FINewsViewController ()

@end

NSMutableArray *newsArray;
NSMutableArray *relatedArray;
NSArray *videoArray;
NSArray *imagesArry;
int height;
int tableHeight;
int tableHeight;
int bottomHeight;


@implementation FINewsViewController

@synthesize news;
@synthesize gallery;
@synthesize scrollViewHeight;
@synthesize scroolViewImages;
@synthesize scrollViewBottom;
@synthesize bottomCostraint;
@synthesize viewMain;

- (void)viewDidLoad {
    [super viewDidLoad];
    height = self.relatedViewHeight.constant;
    tableHeight = self.relatedTableViewHeight.constant ;
    bottomHeight = bottomCostraint.constant;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([APP_DELEGATE newsTemp] != nil  ) {
        [self reloadView];
    }
}
    

-(void)reloadView
{
    if (relatedArray == nil)
    {
        relatedArray = [NSMutableArray new];
    } else{
        [relatedArray removeAllObjects];
    }
    
    if([APP_DELEGATE newsTemp] != nil )
    {
        news = [APP_DELEGATE newsTemp];
        [APP_DELEGATE setNewsTemp:nil];
    }
    if (news != nil) {
        [self fillNews];
    }
    
    [FDB setNewsRead:news];
    
    [self createGallery];
    
    bottomCostraint.constant = 10;
    [self.scrollViewMain setContentSize:CGSizeMake(self.scrollViewMain.contentSize.width, self.scrollViewMain.contentSize.width-bottomHeight+10)];
    [self.scrollViewMain setNeedsLayout];
    [self.scrollViewMain layoutIfNeeded];
    self.tabelViewRelated.scrollEnabled = false;
    [self.tabelViewRelated reloadData];
    [self.scrollViewMain setContentOffset:CGPointMake(0, 0) animated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillNews
{
    self.lblTitle.text = self.news.title;
    self.lblDate.text = [HelperDate formatedDate:self.news.nDate];
    self.textViewNews.attributedText = [HelperString toAttributedNews:self.news.text];
    
    int nc=0;
    
    newsArray = [APP_DELEGATE newsArray];
    
    for (FNews* n in newsArray) {
        if (nc<4 && [news newsID]!=[n newsID] ) {
            for (NSString *category in n.categories) {
                if ([[news categories] containsObject:category]) {
                    //todo dodat da odpira bookmark slike
                    UIImage *img;
                    if ([n headerImage] == nil ) {
                        NSString * header = n.headerImageLink;
                        if (header == nil || [header isEqualToString:@""]|| (![APP_DELEGATE connectedToInternet])) {
                            img = [UIImage imageNamed:@"related_news"];
                        } else {
                            NSString *url_Img_FULL = [NSString stringWithFormat:@"%@",  header];
                            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
                            
                        }
                        
                    } else {
                        img = n.headerImage;
                    }
                    [n setHeaderImage:img];
                    [relatedArray addObject:n];
                    nc++;
                    break;
                }
            }
        }
        if (nc==4) {
            break;
        }
        
    }
    if (relatedArray.count > 0) {
        FIFeaturedNewsTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedNewsTableViewCell" owner:self options:nil] objectAtIndex:0];
        self.relatedViewHeight.constant = height + relatedArray.count * cell.frame.size.height;
        self.relatedTableViewHeight.constant = tableHeight + relatedArray.count * cell.frame.size.height;
    }
}

#pragma mark - Related TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIFeaturedNewsTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FIFeaturedNewsTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.news = [relatedArray objectAtIndex:indexPath.row];
    cell.related = true;
    [cell fillCell];
    [self.tabelViewRelated deselectRowAtIndexPath:indexPath animated:false];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return relatedArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 360;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [APP_DELEGATE setNewsTemp:[relatedArray objectAtIndex:indexPath.row]];
    if (relatedArray.count > 0) {
        self.relatedViewHeight.constant = height;
        self.relatedTableViewHeight.constant = tableHeight;
    }
    
    [self reloadView];
}

-(void) createGallery
{
    gallery = [[FIGalleryController alloc] init];
    gallery.parent = self;
    gallery.type = 2;
    [gallery createGalleryWithImagesForNews:self.news forScrollView:scroolViewImages andScrollHeight:scrollViewHeight andBottomHeight:scrollViewBottom];
}



@end




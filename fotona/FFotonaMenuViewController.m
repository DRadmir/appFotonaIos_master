//
//  FFotonaMenuViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 4/17/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FFotonaMenuViewController.h"
#import "FMDatabase.h"
#import "FCase.h"
#import "FFotonaMenu.h"
#import "FCasebookViewController.h"
#import "FFotonaViewController.h"
#import "IIViewDeckController.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "FItemBookmark.h"
#import "FDB.h"
#import "UIColor+Hex.h"
#import "FGoogleAnalytics.h"

@interface FFotonaMenuViewController (){
    
    NSInteger index;
    NSArray *iconsInMenu;
}
@end

@implementation FFotonaMenuViewController
@synthesize allItems;
@synthesize menuItems;
@synthesize menuTitles;
@synthesize menuIcons;
@synthesize selectedIcon;
@synthesize parent;
@synthesize lastSelectedCategory;
BOOL enabled;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    table.contentInset = UIEdgeInsetsMake(-35, 0, -75, 0);
    
    index = -1;
    
    if (self.bookmarkPDF == nil) {
        self.bookmarkPDF = [NSMutableArray new];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    iconsInMenu=[NSArray arrayWithObjects:@"about_fotona",@"aesthetics_and_surgery_products",@"dental_products",@"gynecology_products",@"distributor_news",@"la&ha_publications",@"ifw_2015",@"disclaimer", nil];
    for (UIView *v in self.navigationController.navigationBar.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    [[self.navigationController navigationBar] addSubview:menuTitle];
    if (!lastSelectedCategory) {
        menuTitles=[NSMutableArray arrayWithObjects:@"Menu", nil];
        [menuTitle setText:[menuTitles lastObject]];
        allItems=[[NSMutableArray alloc] init];
        [allItems addObject:[FDB getFotonaMenu:lastSelectedCategory]];//[self getFotonaMenu:lastSelectedCategory]];
        [back setHidden:YES];
        
        menuIcons=[NSMutableArray arrayWithObjects:@"about_fotona",@"aesthetics_and_surgery_products",@"dental_products",@"gynecology_products",@"distributor_news",@"la&ha_publications",@"ifw_2015",@"disclaimer", nil];
        
        menuItems=[allItems lastObject];
    }else{
        [menuTitle setText:[menuTitles lastObject]];
        [allItems addObject:[FDB getFotonaMenu:lastSelectedCategory]];//[self getFotonaMenu:lastSelectedCategory]];
        menuItems=[allItems lastObject];
    }
    [table reloadData];
}

#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItems count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    NSString *iconaName=@"fotonamenu_icon9";
    
    int icon = [[[menuItems objectAtIndex:indexPath.row] iconName] intValue];
    if (icon < iconsInMenu.count) {
        iconaName = [iconsInMenu objectAtIndex:icon];
    } else{
        if (selectedIcon) {
            iconaName=selectedIcon;
        }else{
            NSString *tempTitle = [[menuItems objectAtIndex:indexPath.row] title];
            tempTitle = [tempTitle lowercaseString];
            tempTitle = [tempTitle stringByReplacingOccurrencesOfString: @" " withString: @"_"];
            
            if ([menuIcons containsObject:tempTitle]) {
                iconaName=tempTitle;
            } else
            {
                iconaName = @"fotonam";
            }
        }
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",iconaName]]];
    [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] title]];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    
    UIView *bck=[[UIView alloc] initWithFrame:cell.frame];
    
    [bck setBackgroundColor:[UIColor colorFromHex:FOTONARED]];
    [cell setSelectedBackgroundView:bck];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.imageView.highlightedImage =[UIImage imageNamed:[NSString stringWithFormat:@"%@",iconaName]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    //if webpage and no internet
    if ([[[menuItems objectAtIndex:indexPath.row] fotonaCategoryType] intValue] == [FOTONACATEGORYWEBPAGE intValue] && ![ConnectionHelper connectedToInternet]) {
        [cell setUserInteractionEnabled:NO];
        [[cell textLabel] setTextColor:[[UIColor blackColor] colorWithAlphaComponent:DISABLEDCOLORALPHA]];
        cell.imageView.alpha = DISABLEDCOLORALPHA;
    } else {
        [cell setUserInteractionEnabled:YES];
        [[cell textLabel] setTextColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
        cell.imageView.alpha = 1;
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 50;
    }else{
        return 100;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFotonaMenu *clicked=[menuItems objectAtIndex:indexPath.row];
    
    NSMutableArray *newItems= [FDB getFotonaMenu:clicked.categoryID];//[self getFotonaMenu:clicked.categoryID];
    if (newItems.count>0) {
        FFotonaMenuViewController *subMenu=[[FFotonaMenuViewController alloc] init];
        [subMenu setMenuTitles:[NSMutableArray arrayWithObject:[clicked title]]];
        [subMenu setAllItems:[NSMutableArray arrayWithObject:newItems]];
        [subMenu setLastSelectedCategory:clicked.categoryID];
        [subMenu setParent:parent];
        if (selectedIcon) {
            [subMenu setSelectedIcon:selectedIcon];
        }else{
            NSString *tempTitle = [clicked title];
            tempTitle = [tempTitle lowercaseString];
            tempTitle = [tempTitle stringByReplacingOccurrencesOfString: @" " withString: @"_"];
            
            if ([menuIcons containsObject:tempTitle]) {
                [subMenu setSelectedIcon:tempTitle];
            } else
            {
                [subMenu setSelectedIcon: @"fotonam"];
            }
        }
        
        [self.navigationController pushViewController:subMenu animated:YES];
    }else
    {
        if ([[clicked fotonaCategoryType] intValue] == 4 || [[clicked fotonaCategoryType] intValue] == 6) {
            //video + pdf gallery
            NSArray *media = [clicked getMedia];
            if (media.count >0) {
                [self.viewDeckController closeLeftViewAnimated:YES];
                [parent closeMenu];
                for (UIView *v in parent.containerView.subviews) {
                    [v removeFromSuperview];
                }
                
                [[parent fotonaImg] setHidden:YES];
                [parent setItem:clicked];
                [parent openContentWithTitle:[clicked title] description:[clicked text] media:[clicked getMedia] andMediaType:MEDIAVIDEO];
            } else
            {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        } else
        {
            
            [self.viewDeckController closeLeftViewAnimated:YES];
            [parent closeMenu];
            for (UIView *v in parent.containerView.subviews) {
                [v removeFromSuperview];
            }
            
            [[parent fotonaImg] setHidden:YES];
            //logic open screen
            if ([[clicked fotonaCategoryType] intValue] == 2) {
                //external link
                [FGoogleAnalytics writeGAForItem:[clicked title] andType:GAFOTONAWEBPAGEINT];
                [parent setItem:nil];
                [parent externalLink:[clicked externalLink]];
            }
            if ([[clicked fotonaCategoryType] intValue] == 3) {
                //case
                [parent setItem:nil];
                FCase *item = [FDB getCaseForFotona:[clicked caseID]];       //[self getCase:[clicked caseID]];
                [(FCasebookViewController *)[(IIViewDeckController *)[[self.tabBarController viewControllers] objectAtIndex:1] centerController] setCurrentCase:item];
                [(FCasebookViewController *)[(IIViewDeckController *)[[self.tabBarController viewControllers] objectAtIndex:1] centerController] setFlagCarousel:YES];
                [self.tabBarController setSelectedIndex:3];
            }
            
            if ([[clicked fotonaCategoryType] intValue] == 5) {
                //content
                [parent setItem:nil];
                [parent openContentWithTitle:[clicked title] description:[clicked text]];
            }
            if ([[clicked fotonaCategoryType] intValue] == 7) {
                //preloaded
                [parent setItem:nil];
                [parent openPreloaded];
            }
        }
    }
}

-(IBAction)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetViewAnime:(BOOL) anime{
    [self.navigationController popToRootViewControllerAnimated:anime];
}

@end

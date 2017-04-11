//
//  FIFotonaMenuViewController.m
//  fotona
//
//  Created by Janos on 18/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIFotonaMenuViewController.h"
#import "FDB.h"
#import "FIFlowController.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "UIColor+Hex.h"
#import "BubbleControler.h"

@interface FIFotonaMenuViewController ()
{
    NSArray *iconsInMenu;
    int index;
    BubbleControler *bubbleCFotona;
    Bubble *b3;
    int stateHelper;
    FIFotonaMenuViewController *sub;
}


@end

@implementation FIFotonaMenuViewController

@synthesize menuIcons;
@synthesize previousCategory;
@synthesize previousCategoryID;
@synthesize previousIcon;
@synthesize allItems;
@synthesize parent;
@synthesize bookmarkPDF;
@synthesize menuTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    iconsInMenu=[NSArray arrayWithObjects:@"about_fotona",@"aesthetics_and_surgery_products",@"dental_products",@"gynecology_products",@"distributor_news",@"la&ha_publications",@"ifw_2015",@"disclaimer", nil];
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(closeMenu:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    index = -1;
    
    
    if (self.bookmarkPDF == nil) {
        self.bookmarkPDF = [NSMutableArray new];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    if (!previousCategory) {
        [self setTitle:@"Menu"];
    } else
    {
        [self setTitle:previousCategory];
    }
    allItems = [FDB getFotonaMenu:previousCategoryID];
    FIFlowController *flow = [FIFlowController sharedInstance];
    stateHelper = flow.fotonaHelperState;
    flow.fotonaMenu = self;
    while ([flow.fotonaMenuArray lastObject] != self)
    {
        [flow.fotonaMenuArray removeLastObject];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self showBubbles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeMenu:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:true];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.showMenu = false;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allItems.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFotonaMenu *clicked = [allItems objectAtIndex:indexPath.row];
    if ([[clicked fotonaCategoryType] intValue] == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FIFotonaMenuViewController *subMenu = [sb instantiateViewControllerWithIdentifier:@"fotonaMenu"];
        subMenu.previousCategory = clicked.title;
        subMenu.previousCategoryID = clicked.categoryID;
        subMenu.parent = self.parent;
        FIFlowController *flow = [FIFlowController sharedInstance];
        [flow.fotonaMenuArray addObject:subMenu];
        [self.navigationController pushViewController:subMenu animated:YES];
    } else{
        [self.navigationController popToRootViewControllerAnimated:true];
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.fotonaTab != nil)
        {
            [[flow fotonaTab] openCategory:clicked];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"fotonaMenuTabelViewCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.textLabel.text = [[allItems objectAtIndex:indexPath.row] title];
    NSString *iconaName=@"fotonamenu_icon9";
    
    int icon = [[[allItems objectAtIndex:indexPath.row] iconName] intValue];
    if (icon < iconsInMenu.count) {
        iconaName = [iconsInMenu objectAtIndex:icon];
    } else{
        if (previousIcon) {
            iconaName=previousIcon;
        }else{
            NSString *tempTitle = [[allItems objectAtIndex:indexPath.row] title];
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

    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",iconaName]]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //if webpage and no internet
    if ([[[allItems objectAtIndex:indexPath.row] fotonaCategoryType] intValue] == [FOTONACATEGORYWEBPAGE intValue] && ![ConnectionHelper connectedToInternet]) {
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

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorFromHex:FOTONARED] ForCell:cell];  //highlight colour
    NSString *iconaName=@"fotonamenu_icon9";

    int icon = [[[allItems objectAtIndex:indexPath.row] iconName] intValue];
    if (icon < iconsInMenu.count) {
        iconaName = [iconsInMenu objectAtIndex:icon];
    } else{
        if (previousIcon) {
            iconaName=previousIcon;
        }else{
            NSString *tempTitle = [[allItems objectAtIndex:indexPath.row] title];
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
     [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",iconaName]]];
    cell.textLabel.textColor = [UIColor whiteColor];
}
- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor whiteColor] ForCell:cell];  //highlight colour
    NSString *iconaName=@"fotonamenu_icon9";
    
    int icon = [[[allItems objectAtIndex:indexPath.row] iconName] intValue];
    if (icon < iconsInMenu.count) {
        iconaName = [iconsInMenu objectAtIndex:icon];
    } else{
        if (previousIcon) {
            iconaName=previousIcon;
        }else{
            NSString *tempTitle = [[allItems objectAtIndex:indexPath.row] title];
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
    
    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",iconaName]]];
    cell.textLabel.textColor = [UIColor blackColor];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}




@end

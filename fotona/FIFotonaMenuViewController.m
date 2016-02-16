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
#import "FAppDelegate.h"
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showBubbles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeMenu:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
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
    if ([[clicked fotonaCategoryType] isEqualToString:@"1"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FIFotonaMenuViewController *subMenu = [sb instantiateViewControllerWithIdentifier:@"fotonaMenu"];
        subMenu.previousCategory = clicked.title;
        subMenu.previousCategoryID = clicked.categoryID;
        subMenu.parent = self.parent;
        [self.navigationController pushViewController:subMenu animated:YES];
    } else{
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
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
        iconaName = [iconsInMenu objectAtIndex:icon-1];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorFromHex:@"ED1C24"] ForCell:cell];  //highlight colour
    NSString *iconaName=@"fotonamenu_icon9";

    int icon = [[[allItems objectAtIndex:indexPath.row] iconName] intValue];
    if (icon < iconsInMenu.count) {
        iconaName = [iconsInMenu objectAtIndex:icon-1];
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
    UIImage *temp = [UIImage imageNamed:[NSString stringWithFormat:@"%@",iconaName]];
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
        iconaName = [iconsInMenu objectAtIndex:icon-1];
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[allItems objectAtIndex:indexPath.row] fotonaCategoryType] isEqualToString:@"6"]) {
        return YES;
    }
    return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[allItems objectAtIndex:indexPath.row] fotonaCategoryType] isEqualToString:@"6"]) {
        if (![[[allItems objectAtIndex:indexPath.row] bookmark] boolValue]) {
            UITableViewRowAction *bookmarkAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Add to Bookmarks"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
              
                index = indexPath.row;
                if ([APP_DELEGATE wifiOnlyConnection]) {
                    [self bookmarkPdf];
                    [[self menuTableView] reloadData];
                    
                } else {
                    UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
                    [av showInView:self.view];
                }
                
                
            }];
             bookmarkAction.backgroundColor = [UIColor colorFromHex:@"ED1C24"];
            return @[bookmarkAction];
            
        } else{
            UITableViewRowAction *unbookmarkAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove from Bookmarks"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                
                [[allItems objectAtIndex:indexPath.row] setBookmark:@"0"];
                [FDB removeFromBookmarkForDocumentID:[[allItems objectAtIndex:indexPath.row] categoryID]];
                
                [tableView reloadData];
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }];
            unbookmarkAction.backgroundColor = [UIColor colorFromHex:@"ED1C24"];
            return @[unbookmarkAction];
        }
    }
    return nil;
}

-(void) bookmarkPdf{
    if([APP_DELEGATE connectedToInternet]){
        [self.bookmarkPDF addObject:[allItems objectAtIndex:index]];
        FIFlowController *flow = [FIFlowController sharedInstance];
        if (flow.fotonaTab != nil)
        {
            [[flow fotonaTab].bookmarkMenu setObject:self forKey:[[allItems objectAtIndex:index] pdfSrc]];
        }
        [HelperBookmark bookmarkPDF:[allItems objectAtIndex:index]];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void) refreshPDF:(NSString *)link{
    for (int i=0; i<[self.bookmarkPDF count]; i++) {
        if ([[[self.bookmarkPDF objectAtIndex:i] pdfSrc] isEqualToString:link]) {
            [[self.bookmarkPDF objectAtIndex:i] setBookmark:@"1"];
            [self.bookmarkPDF removeObjectAtIndex:i];
            [menuTableView reloadData];
        }
    }
}

#pragma mark - BUBBLES :D

-(void)showBubbles
{
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fotonaHelper"]];
    if(![usersarray containsObject:usr]){
        FIFlowController *flow = [FIFlowController sharedInstance];
        [self.viewDeckController.leftController.view setUserInteractionEnabled:NO];
        // You should check before this, if any of bubbles needs to be displayed
        if(bubbleCFotona == nil)
        {
            bubbleCFotona =[[BubbleControler alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            //[bubbleC setBlockUserInteraction:NO];
            //[bubbleCFotona setBackgroundTint:[UIColor clearColor]];
            b3 = [[Bubble alloc] init];
            
            // Calculate point of caret
            CGPoint loc = CGPointZero;
            if (stateHelper<1) {
                loc.x = [[flow tabControler] tabBar].frame.size.width/2; // Center
                loc.y = 155; // Bottom
                // Set if highlight is desired
                
                CGRect newFrame = flow.tabControler.view.frame;
                
                [b3 setHighlight:newFrame];
                [b3 setTint:[UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1]];
                [b3 setFontColor:[UIColor whiteColor]];
                // Set buble size and position (first size, then position!!)
                [b3 setSize:CGSizeMake(200, 120)];
                [b3 setCornerRadius:5];
                [b3 setPositionOfCaret:loc withCaretFrom:TOP_CENTER];
                [b3 setCaretSize:15]; // Because tablet, we want a bigger bubble caret
                // Set font, paddings and text
                [b3 setTextContentInset: UIEdgeInsetsMake(16,16,16,16)]; // Set paddings
                [b3 setText:[NSString stringWithFormat:NSLocalizedString(@"BUBBLEFOTONA1", nil)]];
                [b3 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]]; // Default font is helvetica-neue, size 12
                
                // Add bubble to controler
                [bubbleCFotona addBubble:b3];
                [b3 setDelegate:self];
            }
            
            
            //[containerView addSubview:bubbleCFotona];
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window addSubview:bubbleCFotona];
        }
    }
}
- (void)bubbleRequestedExit:(Bubble*)bubbleObject
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.fotonaHelperState++;
    stateHelper++;
    [bubbleCFotona displayNextBubble];
    [bubbleObject removeFromSuperview];
    [self closeMenu:self];

    
}





@end

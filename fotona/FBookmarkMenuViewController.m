//
//  FCasesMenuViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 4/18/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FBookmarkMenuViewController.h"
#import "FCaseCategory.h"
#import "FMDatabase.h"
#import "FCase.h"
#import "FAuthor.h"
#import "FAppDelegate.h"
#import "FBookmarkViewController.h"
#import "IIViewDeckController.h"
#import "MBProgressHUD.h"
#import "FFotonaMenuViewController.h"
#import "UIColor+Hex.h"

@interface FBookmarkMenuViewController ()

@end

@implementation FBookmarkMenuViewController
@synthesize allCasesInMenu;
@synthesize allItems;
@synthesize menuIcons;
@synthesize menuItems;
@synthesize menuTitles;
@synthesize casesInMenu;
@synthesize selectedIcon;
@synthesize parent;

NSMutableArray *newItems;
int removed = 0;
NSString *categoryMenu = @"";


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
    newItems=[[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    
    menuTable.contentInset = UIEdgeInsetsMake(-75, 0, -75, 0);
    if (!allItems) {
        [back setHidden:YES];
        NSMutableArray *mainMenu=[[NSMutableArray alloc] init];
        allCasesInMenu=[[NSMutableArray alloc] init];
        casesInMenu=[[NSMutableArray alloc] init];
        menuIcons=[[NSMutableArray alloc] init];
        //        FCaseCategory *alphaList=[[FCaseCategory alloc] init];
        //        [alphaList setTitle:@"Casebook"];
        //        [alphaList setCategoryID:@""];
        //        [mainMenu addObject:alphaList];
        //        allItems=[[NSMutableArray alloc] init];
        //        menuIcons = [[NSMutableArray alloc] initWithObjects:@"casebook", nil];
        //        FCaseCategory *fotonaList=[[FCaseCategory alloc] init];
        //        [fotonaList setTitle:@"Fotona"];
        //        [fotonaList setCategoryID:@""];
        //        [mainMenu addObject:fotonaList];
        //        allItems=[[NSMutableArray alloc] init];
        //        [allItems addObject:mainMenu];
        //        [menuIcons addObject:@"fotonam"];
        allItems=[[NSMutableArray alloc] init];
        
        NSArray *temp =[APP_DELEGATE currentLogedInUser].userTypeSubcategory;
        if ([[APP_DELEGATE currentLogedInUser].userType intValue] == 0 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 1 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3) {
            temp = @[@"1", @"2", @"3"];
        }
        NSString *name = @"";
        NSArray *tempArray = @[@"2",@"1", @"3"];
        for (int i = 0; i< tempArray.count; i++) {
            for (int j = 0; j< temp.count; j++) {
                NSString *t1 = tempArray[i];
                NSString *category = temp[j];
            if (t1.intValue == category.intValue) {
                switch (category.intValue) {
                    case 1:
                        name = @"Dentistry";
                        [menuIcons addObject:@"dental"];
                        break;
                    case 2:
                        name = @"Aesthetics";
                        [menuIcons addObject:@"aesthetics_and_surgery_products"];
                        break;
                    case 3:
                        name = @"Gynecology";
                        [menuIcons addObject:@"gynecology_products"];
                        break;
                    default:
                        break;
                }
                FCaseCategory *fotonaList=[[FCaseCategory alloc] init];
                [fotonaList setTitle:name];
                [fotonaList setCategoryID:@""];
                [mainMenu addObject:fotonaList];
                [allItems addObject:mainMenu];
            }
           
            }
        }
        
        
        FCaseCategory *allBookmarks=[[FCaseCategory alloc] init];
        [allBookmarks setTitle:@"Other"];
        [allBookmarks setCategoryID:@""];
        [mainMenu addObject:allBookmarks];
        [menuIcons addObject:@"bookmark"];
        [allItems addObject:mainMenu];

        FCaseCategory *instructions=[[FCaseCategory alloc] init];
        [instructions setTitle:@"How to use bookmarks"];
        [instructions setCategoryID:@""];
        [mainMenu addObject:instructions];
        [menuIcons addObject:@"fotonamenu_icon8"];
        [allItems addObject:mainMenu];
        menuTitles =[[NSMutableArray alloc] initWithObjects:@"Menu", nil];
        [menuTitle setText:[menuTitles lastObject]];
        
        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
    }else{
        [back setHidden:NO];
        [menuTitle setText:[menuTitles lastObject]];
        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
    }
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    for (UIView *v in self.navigationController.navigationBar.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    [[self.navigationController navigationBar] addSubview:menuTitle];
    if([[menuTitles objectAtIndex:0] isEqualToString:@"Casebook"]){
        menuItems =[self getAlphabeticalCases];
        [menuTable reloadData];
    }
    
    
}

-(void)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (casesInMenu.count>0) {
        return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if ([[menuItems lastObject] isKindOfClass:[FCase class]]){
            return 100;
        }
        return 50;
    }else{
        return 100;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (removed==1) {
            removed =0;
            menuItems = newItems;
            return [newItems count];
        }
        return [menuItems count];
    }else if(casesInMenu.count>0)
    {
        return casesInMenu.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    if (indexPath.section==1) {
        if (casesInMenu.count>0) {
            NSString *imageName=@"";
            if (!selectedIcon) {
                imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
            }
            else{
                imageName=selectedIcon;
            }
            
            
            if ([[casesInMenu objectAtIndex:indexPath.row] isKindOfClass:[FCase class]])
            {
                UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
                [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",imageName]]];
                [cell addSubview:img];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 220, 20)];
                [name setText:[(FCase *)[casesInMenu objectAtIndex:indexPath.row] name]];
                [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
                [name setClipsToBounds:NO];
                [cell addSubview:name];
                UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(300, 13.5, 8, 12.5)];
                [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
                [cell addSubview:indicator];
                UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, 280, 1)];
                [line setBackgroundColor:[UIColor lightGrayColor]];
                [cell addSubview:line];
                UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, 260, 40)];
                [caseLbl setText:[(FCase *)[casesInMenu objectAtIndex:indexPath.row] title]];
                [caseLbl setTextColor:[UIColor grayColor]];
                [caseLbl setClipsToBounds:NO];
                [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                [caseLbl setNumberOfLines:2];
                [cell addSubview:caseLbl];
            }
            
            
        }
    }else{
        NSString *imageName=@"";
        if (!selectedIcon) {
            imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
        }
        else{
            imageName=selectedIcon;
        }
        
        
        if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FCase class]])
        {
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
            [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",imageName]]];
            [cell addSubview:img];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 220, 20)];
            [name setText:[(FCase *)[menuItems objectAtIndex:indexPath.row] name]];
            [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
            [name setClipsToBounds:NO];
            [cell addSubview:name];
            UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(300, 13.5, 8, 12.5)];
            [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
            [cell addSubview:indicator];
            UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, 280, 1)];
            [line setBackgroundColor:[UIColor lightGrayColor]];
            [cell addSubview:line];
            UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, 260, 40)];
            [caseLbl setText:[(FCase *)[menuItems objectAtIndex:indexPath.row] title]];
            [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
            [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
            [caseLbl setClipsToBounds:NO];
            [caseLbl setTextColor:[UIColor grayColor]];
            [caseLbl setNumberOfLines:2];
            [cell addSubview:caseLbl];
            
            
        }else
        {
            if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FAuthor class]])
            {
                [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] name]];
            }else{
                [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] title]];
            }
            
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",imageName]]];
            
            UIView *bck=[[UIView alloc] initWithFrame:cell.frame];
            
            [bck setBackgroundColor:[UIColor colorFromHex:@"ED1C24"]];
            [cell setSelectedBackgroundView:bck];
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            cell.imageView.highlightedImage =[UIImage imageNamed:[NSString stringWithFormat:@"%@_white",imageName]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        if (casesInMenu.count>0) {
            [self.viewDeckController toggleLeftViewAnimated:YES];
            [(FBookmarkViewController*)self.viewDeckController.centerController setPrevCase:[(FBookmarkViewController*)self.viewDeckController.centerController currentCase]];
            [(FBookmarkViewController*)self.viewDeckController.centerController setCurrentCase:[casesInMenu objectAtIndex:indexPath.row]];
            [(FBookmarkViewController*)self.viewDeckController.centerController openCase];
        }
    }else{
        if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FNews class]]) {
            [self.viewDeckController toggleLeftViewAnimated:YES];
            [(FBookmarkViewController*)self.viewDeckController.centerController openNews:[menuItems objectAtIndex:indexPath.row]];
            
        } else {
            if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FEvent class]]) {
                [self.viewDeckController toggleLeftViewAnimated:YES];
                [(FBookmarkViewController*)self.viewDeckController.centerController openEvent:[menuItems objectAtIndex:indexPath.row] fromCategory:[categoryMenu intValue]];
            } else {
                if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FCase class]]) {
                    [self.viewDeckController toggleLeftViewAnimated:YES];
                    [(FBookmarkViewController*)self.viewDeckController.centerController setPrevCase:[(FBookmarkViewController*)self.viewDeckController.centerController currentCase]];
                    [(FBookmarkViewController*)self.viewDeckController.centerController setCurrentCase:[menuItems objectAtIndex:indexPath.row]];
                    [(FBookmarkViewController*)self.viewDeckController.centerController openCase];
                }else{
                    
                    if ([[[menuItems objectAtIndex:indexPath.row] categoryID] isEqualToString:@""]) {
                        if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"How to use bookmarks"]) {
                            [self.viewDeckController closeLeftViewAnimated:YES];
                            [parent openHelp];
                        }
                        else{
                            if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Casebook"]) {
                                newItems=[self getAlphabeticalCases];
                                if (newItems.count>0){
                                    FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                    if (selectedIcon) {
                                        subMenu.selectedIcon=selectedIcon;
                                    }else{
                                       
                                        subMenu.selectedIcon=@"casebook";
                                    }
                                    [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                    [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                    [self.navigationController pushViewController:subMenu animated:YES];
                                } else
                                {
                                    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [av show];
                                }
                                
                                
                            } else {
                                if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Fotona"]) {
                                    newItems=[[NSMutableArray alloc] init];
                                    allCasesInMenu=[[NSMutableArray alloc] init];
                                    casesInMenu=[[NSMutableArray alloc] init];
                                    
                                    FCaseCategory *alphaList=[[FCaseCategory alloc] init];
                                    [alphaList setTitle:@"Videos"];
                                    [alphaList setCategoryID:@""];
                                    [newItems addObject:alphaList];
                                    
                                    FCaseCategory *fotonaList=[[FCaseCategory alloc] init];
                                    [fotonaList setTitle:@"Documents"];
                                    [fotonaList setCategoryID:@""];
                                    [newItems addObject:fotonaList];
                                    
                                    menuIcons = [[NSMutableArray alloc] initWithObjects:@"video", @"documents", nil];
                                    
                                    //predelat v bookmarksmenu
                                    FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                    
                                    [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                    [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                    [subMenu setMenuIcons:menuIcons];
                                    [subMenu setParent:parent];
                                    [self.navigationController pushViewController:subMenu animated:YES];
                                    
                                    
                                } else {
                                    
                                    if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Videos"]) {
                                        [parent getVideoswithCategory:categoryMenu];
                                        if (parent.videoArray.count>0) {
                                            [self.viewDeckController toggleLeftViewAnimated:YES];
                                            [[parent caseView] setHidden:YES];
                                            [parent openContentWithTitle:@"Videos" ];
                                        } else {
                                            [parent.contentsVideoModeCollectionView reloadData];
                                            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [av show];
                                        }
                                    } else if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Documents"]) {
                                        
                                        [self getFotonaMenu];
                                        if (newItems.count>0) {
                                            [[parent caseView] setHidden:YES];
                                            FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                            if (selectedIcon) {
                                                subMenu.selectedIcon=selectedIcon;
                                            }else{
                                                subMenu.selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                                            }
                                            [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                            [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                            [subMenu setParent:parent];
                                            [self.navigationController pushViewController:subMenu animated:YES];
                                        } else {
                                            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [av show];
                                        }
                                    } else {
                                        if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Dentistry"] ||
                                            [[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Aesthetics"] ||
                                            [[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Gynecology"] ||
                                            [[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Surgery"]||
                                            [[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Other"] ) {
                                            if (![[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Other"]) {
                                                
                                                
                                                
                                                switch (indexPath.row) {
                                                    case 0:
                                                        categoryMenu = @"2";//[NSString stringWithFormat:@"%ld", indexPath.row];
                                                        break;
                                                    case 1:
                                                        categoryMenu = @"1";//[NSString stringWithFormat:@"%ld", indexPath.row];
                                                        break;
                                                    case 2:
                                                        categoryMenu = @"3";//[NSString stringWithFormat:@"%ld", indexPath.row];
                                                        break;
                                                    default:
                                                        categoryMenu = @"0";
                                                        break;
                                                }
                                                
                                                
                                                
                                            } else {
                                                categoryMenu = @"0";
                                            }
                                            NSLog(@"%@",categoryMenu);
                                            newItems = [[NSMutableArray alloc] init];
                                            allCasesInMenu=[[NSMutableArray alloc] init];
                                            casesInMenu=[[NSMutableArray alloc] init];
                                            
                                            FCaseCategory *newsList=[[FCaseCategory alloc] init];
                                            [newsList setTitle:@"News"];
                                            [newsList setCategoryID:@""];
                                            [newItems addObject:newsList];
                                            menuIcons = [[NSMutableArray alloc] initWithObjects:@"news", nil];
                                            
                                            FCaseCategory *eventsList=[[FCaseCategory alloc] init];
                                            [eventsList setTitle:@"Events"];
                                            [eventsList setCategoryID:@""];
                                            [newItems addObject:eventsList];
                                            [menuIcons addObject:@"events"];
                                            
                                            FCaseCategory *fotonaList=[[FCaseCategory alloc] init];
                                            [fotonaList setTitle:@"Fotona"];
                                            [fotonaList setCategoryID:@""];
                                            [newItems addObject:fotonaList];
                                            [menuIcons addObject:@"fotonam"];
                                            
                                            FCaseCategory *alphaList=[[FCaseCategory alloc] init];
                                            [alphaList setTitle:@"Casebook"];
                                            [alphaList setCategoryID:@""];
                                            [newItems addObject:alphaList];
                                            [menuIcons addObject:@"casebook"];
                                            
                                            
                                            
                                            
                                            
                                            //predelat v bookmarksmenu
                                            FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                            
                                            [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                            [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                            [subMenu setMenuIcons:menuIcons];
                                            [subMenu setParent:parent];
                                            [self.navigationController pushViewController:subMenu animated:YES];
                                            
                                        } else {
                                            if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"News"]) {
                                                newItems = [self getNewsMenu];
                                                if (newItems.count>0){
                                                    FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                                    if (selectedIcon) {
                                                        subMenu.selectedIcon=selectedIcon;
                                                    }else{
                                                        subMenu.selectedIcon=@"news";
                                                    }
                                                    [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                                    [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                                    [self.navigationController pushViewController:subMenu animated:YES];
                                                } else
                                                {
                                                    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                    [av show];
                                                }
                                            } else{
                                                if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Events"]) {
                                                    [self getEventsMenu];
                                                    if (newItems.count>0) {
                                                        [[parent caseView] setHidden:YES];
                                                        FBookmarkMenuViewController *subMenu=[[FBookmarkMenuViewController alloc] init];
                                                        if (selectedIcon) {
                                                            subMenu.selectedIcon=selectedIcon;
                                                        }else{
                                                            subMenu.selectedIcon=@"events";
                                                        }
                                                        [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                                                        [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                                                        [subMenu setParent:parent];
                                                        [self.navigationController pushViewController:subMenu animated:YES];
                                                    } else {
                                                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                        [av show];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if ([[[menuItems objectAtIndex:indexPath.row] fotonaCategoryType] isEqualToString:@"6"]) {
                            //pdf
                            [self.viewDeckController closeLeftViewAnimated:YES];
                            [parent setShowView:0];
                            [parent downloadFile:[NSString stringWithFormat:@"%@",[[menuItems objectAtIndex:indexPath.row] pdfSrc]] inFolder:@".PDF" type:6];
                        }
                    }
                }
            }
        }
    }
    
    [tableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[menuItems objectAtIndex:indexPath.row] fotonaCategoryType] isEqualToString:@"6"]) {
        
        
        
        UITableViewRowAction *unbookmarkAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove from Bookmarks"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            //[table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[menuItems objectAtIndex:indexPath.row] setBookmark:@"0"];
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            NSString *usr = [APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
            if (usr == nil) {
                usr =@"guest";
            }
            [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",[[menuItems objectAtIndex:indexPath.row] categoryID],usr,BOOKMARKPDF];
            FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",[[menuItems objectAtIndex:indexPath.row] categoryID],BOOKMARKPDF]];
            BOOL flag=NO;
            while([resultsBookmarked next]) {
                flag=YES;
            }
            if (!flag) {
                [database executeUpdate:@"UPDATE FotonaMenu set isBookmark=? where categoryID=?",@"0",[[menuItems objectAtIndex:indexPath.row] categoryID]];
                
                NSString *folder=@".PDF";
                NSString *downloadFilename = [[NSString stringWithFormat:@"%@%@",docDir,folder] stringByAppendingPathComponent:[[[menuItems objectAtIndex:indexPath.row] pdfSrc] lastPathComponent]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                [fileManager removeItemAtPath:downloadFilename error:&error];
                
            }
            
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            
            [database close];
            [self getFotonaMenu];
            removed = 1;
            [menuTable reloadData];
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }];
         unbookmarkAction.backgroundColor = [UIColor colorFromHex:@"ED1C24"];
        return @[unbookmarkAction];
    }
    
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FFotonaMenu class]])
        if ([[[menuItems objectAtIndex:indexPath.row] fotonaCategoryType] isEqualToString:@"6"]) {
            return YES;
        }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark DB
-(NSMutableArray *)getAlphabeticalCases
{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and isBookmark=1 order by title"]];
    while([results next]) {
        NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
        if (usr == nil) {
            usr =@"guest";
        }
        FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, [results stringForColumn:@"caseID"]]];
        BOOL flag=NO;
        while([resultsBookmarked next]) {
            flag=YES;
        }
        
        if (flag) {
            FCase *f=[[FCase alloc] init];
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
            if (![categoryMenu isEqualToString:@"0"]) {
                if ([f.coverTypeID isEqualToString:categoryMenu])
                    [cases addObject:f];
                
            } else {
                [cases addObject:f];
            }
            
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

-(void)getFotonaMenu
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    NSMutableArray *documents=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;// [[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
    
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=2" withArgumentsInArray:[NSArray arrayWithObjects:usr, nil]];
    while([resultsBookmarked next]) {
            [documents addObject:[resultsBookmarked objectForColumnName:@"documentID"]];
    }
    for (NSString *docID in documents) {
        FMResultSet *results = [database executeQuery:@"SELECT * FROM FotonaMenu where categoryID=? and active=1" withArgumentsInArray:[NSArray arrayWithObjects:docID, nil]];
        
        while([results next]) {
            FFotonaMenu *f=[[FFotonaMenu alloc] init];
            [f setCategoryID:[results stringForColumn:@"categoryID"]];
            [f setCategoryIDPrev:[results stringForColumn:@"categoryIDPrev"]];
            [f setTitle:[results stringForColumn:@"title"]];
            [f setFotonaCategoryType:[results stringForColumn:@"fotonaCategoryType"]];
            [f setDescription:[results stringForColumn:@"description"]];
            [f setText:[results stringForColumn:@"text"]];
            [f setCaseID:[results stringForColumn:@"caseID"]];
            [f setPdfSrc:[results stringForColumn:@"pdfSrc"]];
            [f setExternalLink:[results stringForColumn:@"externalLink"]];
            [f setVideoGalleryID:[results stringForColumn:@"videoGalleryID"]];
            [f setActive:[results stringForColumn:@"active"]];
            [f setSort:[results stringForColumn:@"sort"]];
            [f setIconName:[results stringForColumn:@"icon"]];
            [f setBookmark:[results stringForColumn:@"isBookmark"]];
            
            if (![categoryMenu isEqualToString:@"0"]) {
                if ([self checkFotonaForUser:f andCategory:categoryMenu]) {
                    [menu addObject:f];
                }
            } else {
                [menu addObject:f];
            }
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    newItems = menu;
}

-(BOOL)checkFotonaForUser:(FFotonaMenu *)f andCategory:(NSString *)category
{
    BOOL check=NO;
    
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM FotonaMenuForUserSubType where fotonaID=%@ and userSubType=%@",f.categoryID,category]];
            while([results next]) {
                check=YES;
            }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return check;
}


-(NSMutableArray *)getNewsMenu
{
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    BOOL showNews = false;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;
    if (usr == nil) {
        usr =@"guest";
    }
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=?" withArgumentsInArray:[NSArray arrayWithObjects:usr,BOOKMARKNEWS, nil]];
    while([resultsBookmarked next]) {
        FNews *f=[[FNews alloc] init];
        FMResultSet *results = [database executeQuery:@"SELECT * FROM News where newsID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"], nil]];
        while([results next]) {
            f=[[FNews alloc] initWithDictionary:[results resultDictionary]];
            
            if (![categoryMenu isEqualToString:@"0"]) {
                
                if (([f.categories containsObject:categoryMenu])|| ([categoryMenu isEqualToString:@"4"] && [f.categories containsObject:@"2"] )){
                    [menu addObject:f];
                }
            } else {
                [menu addObject:f];
            }
            
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    return menu;
}

-(void)getEventsMenu
{
    
    NSMutableArray *menu=[[NSMutableArray alloc] init];
    BOOL showEvent = false;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;
    if (usr == nil) {
        usr =@"guest";
    }
    FMResultSet *resultsBookmarked =  [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=?" withArgumentsInArray:[NSArray arrayWithObjects:usr,BOOKMARKEVENTS, nil]];
    while([resultsBookmarked next]) {
        showEvent = false;
            FEvent *e=[[FEvent alloc] init];
            FMResultSet *results = [database executeQuery:@"SELECT * FROM Events where eventID=?" withArgumentsInArray:[NSArray arrayWithObjects:[resultsBookmarked stringForColumn:@"documentID"], nil]];
            while([results next]) {
                e=[[FEvent alloc] initWithDictionary:[results resultDictionary]];
                if (![categoryMenu isEqualToString:@"0"]) {
                    if (([e.eventcategories containsObject:categoryMenu])|| ([categoryMenu isEqualToString:@"4"] && [e.eventcategories containsObject:@"2"] )){
                        [menu addObject:e];
                    }
                } else {
                    [menu addObject:e];
                }

                
            }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    newItems = menu;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetViewAnime:(BOOL) anime{
    [self.navigationController popToRootViewControllerAnimated:anime];
}

-(NSString *) categoryTransform: (NSString *) c {
    if ([c isEqualToString:@"Dentistry"]) {
        c = @"1";
    } else {
        if ([c isEqualToString:@"Aesthetics"]) {
            c = @"2";
        } else {
            if ([c isEqualToString:@"Gynecology"]) {
                c = @"3";
            } else {
                c = @"4";
            }
        }
    }
    
    return c;
}


@end

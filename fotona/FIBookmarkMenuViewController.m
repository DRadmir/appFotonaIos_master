//
//  FIBookmarkMenuViewController.m
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIBookmarkMenuViewController.h"
#import "FIFlowController.h"
#import "FAppDelegate.h"
#import "UIColor+Hex.h"
#import "FDB.h"

@interface FIBookmarkMenuViewController ()
{
    NSArray *newItems;
}

@end

@implementation FIBookmarkMenuViewController

@synthesize titleMenu;
@synthesize category;
@synthesize documentType;
@synthesize subDocumentType;

@synthesize menuTitles;
@synthesize menuIcons;
@synthesize categories;
@synthesize parent;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(closeMenu:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
}


-(void)viewWillAppear:(BOOL)animated
{
    menuIcons = [NSMutableArray new];
    menuTitles = [NSMutableArray new];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.bookmarkMenu = self;
    if (titleMenu == nil) {
        [self setTitle:@"Menu"];
        self.parent = flow.bookmarkTab;
    } else
    {
        [self setTitle:titleMenu];
    }
    
    for (UIView *v in self.navigationController.navigationBar.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    
    if (category == 0) {
        categories = [NSMutableArray new];
        NSArray *temp =[APP_DELEGATE currentLogedInUser].userTypeSubcategory;
        if ([[APP_DELEGATE currentLogedInUser].userType intValue] == 0 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 1 || [[APP_DELEGATE currentLogedInUser].userType intValue] == 3) {
            temp = @[@"1", @"2", @"3"];
        }
        NSArray *tempArray = @[@"2",@"1", @"3"];
        for (int i = 0; i< tempArray.count; i++) {
            for (int j = 0; j< temp.count; j++) {
                NSString *t1 = tempArray[i];
                NSString *categoryString = temp[j];
                if (t1.intValue == categoryString.intValue) {
                    [categories addObject:[NSString stringWithFormat:@"%@", categoryString]];
                    switch (categoryString.intValue) {
                        case 1:
                            [menuIcons addObject:@"dental"];
                            [menuTitles addObject:@"Dentistry"];
                            break;
                        case 2:
                            [menuIcons addObject:@"aesthetics_and_surgery_products"];
                            [menuTitles addObject:@"Aesthetics"];
                            break;
                        case 3:
                            [menuIcons addObject:@"gynecology_products"];
                            [menuTitles addObject:@"Gynecology"];
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        [categories addObject:@"0"];
        [menuIcons addObject:@"bookmark"];
        [menuTitles addObject:@"Other"];
        [menuIcons addObject:@"fotonamenu_icon8"];
        [menuTitles addObject:@"How to use bookmarks"];
    } else
    {
        if (documentType == 0) {
            [menuIcons addObject:@"news"];
            [menuTitles addObject:@"News"];
            [menuIcons addObject:@"events"];
            [menuTitles addObject:@"Events"];
            [menuIcons addObject:@"fotonam"];
            [menuTitles addObject:@"Fotona"];
            [menuIcons addObject:@"casebook"];
            [menuTitles addObject:@"Casebook"];
        } else
        {
            switch (documentType) { //1 - news, 2-events,3-fotona, 4-cases
                case 1:
                {
                    newItems=[FDB getNewsForCategory:categories[category-1]];
                    [menuIcons addObject:@"news"];
                }
                    break;
                    
                case 2:
                    newItems=[FDB getEventsForCategory:categories[category-1]];
                    [menuIcons addObject:@"events"];
                    break;
                    
                case 3:
                    
                    if (subDocumentType == 0) {
                        [menuIcons addObject:@"video"];
                        [menuTitles addObject:@"Videos"];
                        [menuIcons addObject:@"documents"];
                        [menuTitles addObject:@"Documents"];
                    } else{
                        switch (subDocumentType) { //1 - video, 2-document
                            case 1:
                            {
                                newItems=[FDB  getVideoswithCategory:categories[category-1]];
                            }
                                break;
                                
                            case 2:
                                newItems=[FDB getPDFForCategory:categories[category-1]];
                                [menuIcons addObject:@"documents"];
                                break;
                            default:
                                break;
                        }
                        
                    }
                    break;
                    
                case 4:
                    [menuIcons addObject:@"casebook"];
                    newItems=[FDB getAlphabeticalCasesForBookmark:categories[category-1]];
                    break;
                    
                default:
                    break;
            }
        }
        
    }
    
    while ([flow.bookmarkMenuArray lastObject] != self)
    {
        [flow.bookmarkMenuArray removeLastObject];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"]; 
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeMenu:(id)sender
{
    //[self.navigationController dismissViewControllerAnimated:true completion:nil];
    [self.navigationController popToRootViewControllerAnimated:true];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.showMenu = false;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (documentType == 4) {
        return 100;
    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((documentType == 0) || ((documentType == 3) && (subDocumentType == 0))){
        return menuTitles.count;
    } else{
        return newItems.count;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *data = [NSMutableArray new];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    FIBookmarkMenuViewController *subMenu = [sb instantiateViewControllerWithIdentifier:@"bookmarkMenu"];
    FIFlowController *flow = [FIFlowController sharedInstance];
    subMenu.parent = self.parent;
    subMenu.titleMenu = cell.textLabel.text;
    subMenu.categories = self.categories;
    if (category == 0) {
        if (indexPath.row < 3) {
            subMenu.category = indexPath.row+1;
        } else
        {
            if (indexPath.row == 3) {
                subMenu.category = 4;
            } else
            {
                subMenu.category = -1;
                [data addObject:@"5"];
                [data addObject:@"0"];
                [data addObject:@"How to use bookmarks"];
                [data addObject:NSLocalizedString(@"HOWTOUSE", nil)];
                [parent openData:data];
                [self.navigationController popToRootViewControllerAnimated:true];
                //[self.navigationController dismissViewControllerAnimated:true completion:nil];
            }
        }
        if (subMenu.category != -1) {
            
            [flow.bookmarkMenuArray addObject:subMenu];
            [self.navigationController pushViewController:subMenu animated:YES];
        }
    } else{
        subMenu.category = category;
        if (documentType == 0) {
            subMenu.documentType = indexPath.row + 1;
            switch (indexPath.row+1) {
                case 1:
                {
                    newItems=[FDB getNewsForCategory:categories[category-1]];
                    if (newItems.count>0){
                        [flow.bookmarkMenuArray addObject:subMenu];
                        [self.navigationController pushViewController:subMenu animated:YES];
                    } else
                    {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                    }
                    
                }
                    break;
                case 2:
                {
                    newItems=[FDB getEventsForCategory:categories[category-1]];
                    if (newItems.count>0){
                        [flow.bookmarkMenuArray addObject:subMenu];
                        [self.navigationController pushViewController:subMenu animated:YES];
                    } else
                    {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                    }
                    
                }
                    break;
                case 4:
                {
                    newItems=[FDB getAlphabeticalCasesForBookmark:categories[category-1]];
                    if (newItems.count>0){
                        [flow.bookmarkMenuArray addObject:subMenu];
                        [self.navigationController pushViewController:subMenu animated:YES];
                    } else
                    {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                    }
                    
                }
                    break;
                    
                case 3:
                    [flow.bookmarkMenuArray addObject:subMenu];
                    [self.navigationController pushViewController:subMenu animated:YES];
                    break;
                    
                default:
                    break;
            }
            
        } else{
            subMenu.documentType = documentType;
            [data addObject:[NSString stringWithFormat:@"%d",documentType]];
            [data addObject:@"0"];
            switch (documentType) {
                case 1:
                {
                    
                    [data addObject:(FNews *)[newItems objectAtIndex:indexPath.row]];
                    [parent openData:data];
                    //[self.navigationController dismissViewControllerAnimated:true completion:nil];
                    [self.navigationController popToRootViewControllerAnimated:true];
                }
                    break;
                    
                case 2:
                    [data addObject:(FEvent *)[newItems objectAtIndex:indexPath.row]];
                    [parent openData:data];
                    [self.navigationController popToRootViewControllerAnimated:true];
                    //[self.navigationController dismissViewControllerAnimated:true completion:nil];
                    break;
                    
                case 3:
                {
                    
                    if (subDocumentType == 0) {
                        subMenu.subDocumentType = indexPath.row + 1;
                        if (subMenu.subDocumentType == 1) {
                            newItems=[FDB getVideoswithCategory:categories[category-1]];
                            if (newItems.count>0){
                                [data removeLastObject];//remove @"0"
                                [data addObject:@"1"];
                                [data addObject:categories[category-1]];
                                [parent openData:data];
                                [self.navigationController popToRootViewControllerAnimated:true];
                                //[self.navigationController dismissViewControllerAnimated:true completion:nil];
                            } else
                            {
                                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [av show];
                            }
                        } else
                        {
                            if (subMenu.subDocumentType ==2) {
                                newItems=[FDB getPDFForCategory:categories[category-1]];
                                if (newItems.count>0){
                                    [flow.bookmarkMenuArray addObject:subMenu];
                                    [self.navigationController pushViewController:subMenu animated:YES];
                                } else
                                {
                                    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [av show];
                                }
                                
                            }
                        }
                    } else if (subDocumentType == 2)
                    {
                        [data removeLastObject];//remove @"0"
                        [data addObject:@"2"];
                        [data addObject:(FFotonaMenu *)[newItems objectAtIndex:indexPath.row]];
                        [self.navigationController popToRootViewControllerAnimated:true];
                        //[self.navigationController dismissViewControllerAnimated:true completion:nil];
                        [parent openData:data];
                        
                    }
                    
                }
                    break;
                    
                case 4:
                {
                    [data addObject:(FCase *)[newItems objectAtIndex:indexPath.row]];
                    [parent openData:data];
                    [self.navigationController popToRootViewControllerAnimated:true];
                    //[self.navigationController dismissViewControllerAnimated:true completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"bookmarkCell"];
    
    
    switch (documentType) { //1 - news, 2-events,3-fotona, 4-cases
        case 1:
        case 2:
        {
            cell.textLabel.text = [newItems[indexPath.row] title];
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[0]]]];
            
        }
            break;
        case 3:
            
            if (subDocumentType == 0) {
                cell.textLabel.text = menuTitles[indexPath.row];
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[indexPath.row]]]];
            } else{
                switch (subDocumentType) {  //1 - video, 2-document
                    case 2:
                    {
                        cell.textLabel.text = [newItems[indexPath.row] title];
                        [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[0]]]];
                        
                    }
                        break;
                    default:
                        break;
                }
                
            }
            break;
            
        case 4:
        {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
            [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[0]]]];
            [cell addSubview:img];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, screenWidth-100, 20)];
            [name setText:[(FCase *)[newItems objectAtIndex:indexPath.row] name]];
            [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
            name.textColor = [UIColor blackColor];
            [name setClipsToBounds:NO];
            [cell addSubview:name];
            UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-20, 13.5, 8, 12.5)];
            [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
            [cell addSubview:indicator];
            UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, screenWidth-20, 1)];
            [line setBackgroundColor:[UIColor lightGrayColor]];
            [cell addSubview:line];
            UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, screenWidth-100, 40)];
            [caseLbl setText:[(FCase *)[newItems objectAtIndex:indexPath.row] title]];
            [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
            [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
            [caseLbl setClipsToBounds:NO];
            [caseLbl setTextColor:[UIColor grayColor]];
            [caseLbl setNumberOfLines:2];
            [cell addSubview:caseLbl];
        }
            break;
            
        default:
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = menuTitles[indexPath.row];
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[indexPath.row]]]];
            break;
    }
    
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    [self setCellColor:[UIColor colorFromHex:@"ED1C24"] ForCell:cell];  //highlight colour
    
    
    if (documentType == 4)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white",menuIcons[0]]]];
        [cell addSubview:img];
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, screenWidth-100, 20)];
        [name setText:[(FCase *)[newItems objectAtIndex:indexPath.row] name]];
        [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
        name.textColor = [UIColor whiteColor];
        [name setClipsToBounds:NO];
        [cell addSubview:name];
        UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-20, 13.5, 8, 12.5)];
        [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
        [cell addSubview:indicator];
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, screenWidth-20, 1)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [cell addSubview:line];
        UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, screenWidth-100, 40)];
        [caseLbl setText:[(FCase *)[newItems objectAtIndex:indexPath.row] title]];
        [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
        [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [caseLbl setClipsToBounds:NO];
        [caseLbl setTextColor:[UIColor grayColor]];
        [caseLbl setNumberOfLines:2];
        [cell addSubview:caseLbl];
        
        
    }else
    {
        if (menuIcons.count > 1) {
            UIImage *testImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_white",menuIcons[indexPath.row]]];
            if (testImage == nil) {
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",menuIcons[indexPath.row]]]];
            } else{
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white",menuIcons[indexPath.row]]]];
            }
        } else
        {
            UIImage *testImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_white",menuIcons[0]]];
            if (testImage == nil) {
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",menuIcons[0]]]];
            } else{
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white",menuIcons[0]]]];
            }
        }
        
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
}
- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor whiteColor] ForCell:cell];
    
    [self setCellColor:[UIColor whiteColor] ForCell:cell];  //highlight colour
    
    
    if (documentType == 4)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[0]]]];
        [cell addSubview:img];
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, screenWidth-100, 20)];
        [name setText:[(FCase *)[newItems objectAtIndex:indexPath.row] name]];
        [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
        name.textColor = [UIColor blackColor];
        [name setClipsToBounds:NO];
        [cell addSubview:name];
        UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-20, 13.5, 8, 12.5)];
        [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
        [cell addSubview:indicator];
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, screenWidth-20, 1)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [cell addSubview:line];
        UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, screenWidth-100, 40)];
        [caseLbl setText:[(FCase *)[newItems objectAtIndex:indexPath.row] title]];
        [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
        [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [caseLbl setClipsToBounds:NO];
        [caseLbl setTextColor:[UIColor grayColor]];
        [caseLbl setNumberOfLines:2];
        [cell addSubview:caseLbl];
        
        
    }else
    {
        if (menuIcons.count > 1) {
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[indexPath.row]]]];
        } else
        {
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",menuIcons[0]]]];
        }
        
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
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
    if (subDocumentType == 2) {
        return YES;
    }
    return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (subDocumentType == 2) {
            UITableViewRowAction *unbookmarkAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove from Bookmarks"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                [[newItems objectAtIndex:indexPath.row] setBookmark:@"0"];
                [FDB removeFromBookmarkForDocumentID:[[newItems objectAtIndex:indexPath.row] categoryID]];
                newItems=[FDB getPDFForCategory:categories[category-1]];
                [tableView reloadData];
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }];
         unbookmarkAction.backgroundColor = [UIColor colorFromHex:@"ED1C24"];
            return @[unbookmarkAction];
    }
    return nil;
}



@end

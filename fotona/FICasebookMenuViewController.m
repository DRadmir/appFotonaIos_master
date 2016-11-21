//
//  FICasebookMenuViewController.m
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FICasebookMenuViewController.h"
#import "FCaseCategory.h"
#import "FAuthor.h"
#import "FCase.h"
#import "FDB.h"
#import "FIFlowController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FImage.h"
#import "FMedia.h"
#import "UIColor+Hex.h"
#import "FHelperRequest.h"
#import "FGoogleAnalytics.h"

@interface FICasebookMenuViewController ()
{
    BOOL casesInMenu;
    NSArray *authors;
    int updateCounter;
    int success;
    FCase *caseToReturn;
    BOOL enabled;
}

@end

@implementation FICasebookMenuViewController

@synthesize menuIcons;
@synthesize allItems;
@synthesize previousIcon;
@synthesize previousCategory;
@synthesize previousCategoryID;
@synthesize parent;
@synthesize caseMenuTableView;
@synthesize type;

- (void)viewDidLoad {
    [super viewDidLoad];
    casesInMenu = false;
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(closeMenu:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.caseMenu = self;
    
    if (!previousCategory) {
        [self setTitle:@"Menu"];
        menuIcons = [[NSMutableArray alloc] initWithObjects:@"medical_",@"tissue_type_",@"laser_system_type_",@"laser_wavelenght_",@"case_author_",@"disclaimer_", nil];
        
        allItems = [FDB getCasebookMenu];//[self getMenu];
        
        FCaseCategory *caseAuthor=[[FCaseCategory alloc] init];
        [caseAuthor setTitle:@"Case Author"];
        [caseAuthor setCategoryID:@""];
        [allItems addObject:caseAuthor];
        
        FCaseCategory *disclaimer=[[FCaseCategory alloc] init];
        [disclaimer setTitle:@"Disclaimer"];
        [disclaimer setCategoryID:@""];
        [allItems addObject:disclaimer];
        self.parent = flow.caseTab;
    } else
    {
        [self setTitle:previousCategory];
        if (type == 0) {
            allItems = [FDB getCaseCategoryWithPrev:previousCategoryID];
        } else if (type == -1)
        {
            allItems = [NSMutableArray new];
            authors = [FDB getAuthors];
            for (FAuthor *a in authors) {
                FCaseCategory *disclaimer=[[FCaseCategory alloc] init];
                [disclaimer setTitle:[a name]];
                [disclaimer setCategoryID:[a authorID]];
                [allItems addObject:disclaimer];
            }
        } else
        {
            if (type == 1)
            {
                allItems = [FDB getCasesWithCategoryID:previousCategoryID];
            } else
            {
                allItems = [FDB getCasesWithAuthorID:previousCategoryID];
            }
        }
    }
    
    while ([flow.caseMenuArray lastObject] != self)
    {
        [flow.caseMenuArray removeLastObject];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    enabled = true;
    [FGoogleAnalytics writeGAForItem:[self title] andType:GACASEMENUINT];
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (type > 0) {
        return 100;
    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allItems.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (type > 0) {
        [self getCase:[[allItems objectAtIndex:indexPath.row] caseID]];
    } else
    {
        FCaseCategory *clicked = [allItems objectAtIndex:indexPath.row];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
        FICasebookMenuViewController *subMenu = [sb instantiateViewControllerWithIdentifier:@"caseMenuViewController"];
        subMenu.previousCategory = clicked.title;
        subMenu.previousCategoryID = [clicked categoryID];
        subMenu.parent = self.parent;
        if (!previousCategory) {
            subMenu.previousIcon = [menuIcons objectAtIndex:indexPath.row];
            if ([[clicked title] isEqualToString:@"Case Author"]) {
                subMenu.type = -1;
                [self.navigationController pushViewController:subMenu animated:YES];
                [flow.caseMenuArray addObject:subMenu];
            } else
            {
                if ([[clicked title] isEqualToString:@"Disclaimer"]) {
                    // [self.navigationController dismissViewControllerAnimated:true completion:nil];
                    [self.navigationController popToRootViewControllerAnimated:true];
                    [parent openDisclaimer];
                } else
                {
                    subMenu.type = 0;
                    [self.navigationController pushViewController:subMenu animated:YES];
                    [flow.caseMenuArray addObject:subMenu];
                }
            }
        } else {
            subMenu.previousIcon = previousIcon;
            if (type ==-1) {
                
                NSArray *menuArray = [FDB getCasesWithAuthorID:[clicked categoryID]];
                if (menuArray.count >0) {
                    subMenu.type = 2;
                    [self.navigationController pushViewController:subMenu animated:YES];
                    [flow.caseMenuArray addObject:subMenu];
                } else
                {
                    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                
            } else
            {
                
                NSArray *menuArray = [FDB getCaseCategoryWithPrev:[clicked categoryID]];
                
                if (menuArray.count >0) {
                    subMenu.type = 0;
                    [self.navigationController pushViewController:subMenu animated:YES];
                    [flow.caseMenuArray addObject:subMenu];
                } else
                {
                    menuArray = [FDB getCasesWithCategoryID:[clicked categoryID]];
                    if (menuArray.count >0) {
                        subMenu.type = 1;
                        [self.navigationController pushViewController:subMenu animated:YES];
                        [flow.caseMenuArray addObject:subMenu];
                    } else
                    {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                    }
                }
                
            }
            
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    enabled = true;
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"casebookMenuCell"];
    
    if (type > 0)
    {
        [self setUnhilightedCellStyle:cell withIndex:indexPath];
    }else
    {
        if (type == -1)
        {
            [cell.textLabel setText:[[allItems objectAtIndex:indexPath.row] title]];
            UIImage *image = [UIImage imageNamed:@"case_author_red"];
            [cell.imageView setImage:image];
            image = [UIImage imageWithContentsOfFile:[[authors objectAtIndex:indexPath.row] imageLocal]];
            UIImageView *img=[FCommon imageCutWithRect:CGRectMake(13, 5, 45, 45)];
            //img.backgroundColor = [UIColor whiteColor];
            img.image = image;
            [cell.contentView addSubview:img];
        }else{
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = [[allItems objectAtIndex:indexPath.row] title];
            if (!previousCategory) {
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",[menuIcons objectAtIndex:indexPath.row]]]];
            } else{
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",previousIcon]]];
            }
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //Disabeling cell for unbookmarked cases without connection
    cell.userInteractionEnabled = enabled;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorFromHex:FOTONARED] ForCell:cell];  //highlight colour
    
    
    if (type > 0)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@white",previousIcon]]];
        [cell addSubview:img];
        
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, screenWidth-100, 20)];
        [name setText:[(FCase *)[allItems objectAtIndex:indexPath.row] name]];
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
        [caseLbl setText:[(FCase *)[allItems objectAtIndex:indexPath.row] title]];
        [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
        [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [caseLbl setClipsToBounds:NO];
        [caseLbl setTextColor:[UIColor grayColor]];
        [caseLbl setNumberOfLines:2];
        [cell addSubview:caseLbl];
    }else
    {
        if (!previousCategory) {
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@white",[menuIcons objectAtIndex:indexPath.row]]]];
        } else{
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@white",previousIcon]]];
            
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
    [self setCellColor:[UIColor whiteColor] ForCell:cell];  //highlight colour
    
    if (type > 0)
    {
        [self setUnhilightedCellStyle:cell withIndex:indexPath];
    }else {
        if (!previousCategory) {
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",[menuIcons objectAtIndex:indexPath.row]]]];
        } else{
            [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",previousIcon]]];
            
        }
    }
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void) setUnhilightedCellStyle: (UITableViewCell *) cell withIndex:(NSIndexPath *) indexPath{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    
    UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, screenWidth-100, 20)];
    [name setText:[(FCase *)[allItems objectAtIndex:indexPath.row] name]];
    [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.5]];
    [name setClipsToBounds:NO];
    [name setTextColor:[UIColor blackColor]];
    [cell addSubview:name];
    UIImageView *indicator=[[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-20, 13.5, 8, 12.5)];
    [indicator setImage:[UIImage imageNamed:@"menu_arrow"]];
    [cell addSubview:indicator];
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(40, 37, screenWidth-20, 1)];
    [line setBackgroundColor:[UIColor colorFromHex:@"EEEEEE"]];
    [cell addSubview:line];
    UILabel *caseLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 49, screenWidth-100, 40)];
    [caseLbl setText:[(FCase *)[allItems objectAtIndex:indexPath.row] title]];
    [caseLbl setLineBreakMode:NSLineBreakByTruncatingTail];
    [caseLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    [caseLbl setClipsToBounds:NO];
    [caseLbl setTextColor:[UIColor grayColor]];
    [caseLbl setNumberOfLines:2];
    [cell addSubview:caseLbl];
    
    UIImageView *img = [FCommon imageCutWithRect:CGRectMake(5, 5, 30, 30)];
    
    UIImage *temp = [FDB getAuthorImage:[[allItems objectAtIndex:indexPath.row] authorID]];
    [img setImage:temp];

    
    if ([[(FCase *)[allItems objectAtIndex:indexPath.row] bookmark] isEqualToString:@"0"] && [[(FCase *)[allItems objectAtIndex:indexPath.row] coverflow] isEqualToString:@"0"] && ![APP_DELEGATE connectedToInternet]) {
        enabled = false;
        [caseLbl setTextColor:[[UIColor grayColor] colorWithAlphaComponent:DISABLEDCOLORALPHA]];
        [name setTextColor:[[UIColor blackColor] colorWithAlphaComponent:DISABLEDCOLORALPHA]];
        img.alpha = DISABLEDCOLORALPHA;
    }
    
    [cell addSubview:img];
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Get Case

-(void) getCase:(NSString *) caseID
{
    updateCounter=0;
    success=0;
    
    FCase *caseTemp = [FDB getCaseWithID:caseID];
    BOOL flag = [FDB checkIfBookmarkedForDocumentID:caseID andType:BOOKMARKCASE];
    
    if (( [[caseTemp bookmark] boolValue] && flag)|| [[caseTemp coverflow] boolValue]){
        caseToReturn = caseTemp;
        [self openCase];
    } else{
        if([APP_DELEGATE connectedToInternet]){

             NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:[caseTemp caseID] onView:self.view];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                NSArray *caseArray = [dic objectForKey:@"d"];
                FCase *caseObj=[[FCase alloc] initWithDictionaryFromServer:caseArray[0]];
                NSMutableArray *imgs = [[NSMutableArray alloc] init];
                for (NSDictionary *imgLink in [caseObj images]) {
                    FImage * img = [[FImage alloc] initWithDictionaryFromServer:imgLink];
                    
                    [imgs addObject:img];
                }
                [caseObj setImages:imgs];
                NSMutableArray *videos = [[NSMutableArray alloc] init];
                for (NSDictionary *videoLink in [caseObj video]) {
                    FMedia * videoTemp = [[FMedia alloc] initWithDictionaryFromServer:videoLink];
                    
                    [videos addObject:videoTemp];
                }
                [caseObj setVideo:videos];
                updateCounter++;
                success++;
                [self removeHud];
                caseToReturn = caseObj;
                [self openCase];
            }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Cases failed %@",error.localizedDescription);
                                                 updateCounter++;
                                                 
                                                 [self removeHud];
                                                 
                                             }];
            [operation start];
        } else {
            [self.viewDeckController toggleLeftViewAnimated:YES];
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (success<updateCounter) {
      
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:0];
        [av show];
    }
    success=0;
    updateCounter=0;
}

-(void) openCase
{
    FIFlowController *flow = [FIFlowController sharedInstance];
    flow.showMenu = false;
    [self.navigationController popToRootViewControllerAnimated:true];
    parent.caseToOpen = caseToReturn;
    [parent openCase];
}



@end

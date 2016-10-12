//
//  FCasesMenuViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 4/18/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FCaseMenuViewController.h"
#import "FCaseCategory.h"
#import "FMDatabase.h"
#import "FCase.h"
#import "FAuthor.h"
#import "FCasebookViewController.h"
#import "IIViewDeckController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FImage.h"
#import "FVideo.h"
#import "FDB.h"
#import "FHelperRequest.h"

@interface FCaseMenuViewController ()


@end

@implementation FCaseMenuViewController
@synthesize allCasesInMenu;
@synthesize allItems;
@synthesize menuIcons;
@synthesize menuItems;
@synthesize menuTitles;
@synthesize casesInMenu;
@synthesize selectedIcon;
@synthesize titleMenu;



NSString* category =@"";
int casesType=0; //forknowing if i have to refresh cases in menu
NSMutableArray *temp;
NSString *count = @"";



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
    
    menuTable.contentInset = UIEdgeInsetsMake(-75, 0, -75, 0);
    
    
    if (!allItems) {
        [back setHidden:YES];
        titleMenu = @"Menu";
        NSMutableArray *mainMenu=[FDB getCasebookMenu];//[self getMenu];
        allCasesInMenu=[[NSMutableArray alloc] init];
        casesInMenu=[[NSMutableArray alloc] init];
        FCaseCategory *caseAuthor=[[FCaseCategory alloc] init];
        [caseAuthor setTitle:@"Case Author"];
        [caseAuthor setCategoryID:@""];
        [mainMenu addObject:caseAuthor];
        
        FCaseCategory *disclaimer=[[FCaseCategory alloc] init];
        [disclaimer setTitle:@"Disclaimer"];
        [disclaimer setCategoryID:@""];
        [mainMenu addObject:disclaimer];
        allItems=[[NSMutableArray alloc] init];
        [allItems addObject:mainMenu];
        
        menuTitles =[[NSMutableArray alloc] initWithObjects:@"Menu", nil];
        [menuTitle setText:[menuTitles lastObject]];
        
        menuIcons = [[NSMutableArray alloc] initWithObjects:@"medical_",@"tissue_type_",@"laser_system_type_",@"laser_wavelenght_",@"case_author_",@"disclaimer_", nil];
        
        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
    }else{
        [back setHidden:NO];
        [menuTitle setText:[menuTitles lastObject]];
        menuItems=[[NSMutableArray alloc] initWithArray:[allItems lastObject]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    count=menuTitle.text;
    titleMenu = menuTitle.text;
    for (UIView *v in self.navigationController.navigationBar.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    [[self.navigationController navigationBar] addSubview:menuTitle];
    updateCounter=0;
    success=0;
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
            NSString *imageName=@"fotonam_";
            if (!selectedIcon) {
                if (indexPath.row < menuIcons.count) {
                    imageName=[NSString stringWithFormat:@"%@",[menuIcons objectAtIndex:indexPath.row]];
                }
                
            }
            else{
                imageName=selectedIcon;
            }
            
            
            if ([[casesInMenu objectAtIndex:indexPath.row] isKindOfClass:[FCase class]])
            {
                UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
                [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",imageName]]];
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
                UIImage *image = [UIImage imageNamed:@"related_news_clear"];

                [cell.imageView setImage:image];
                
                image = [UIImage imageWithContentsOfFile:[[menuItems objectAtIndex:indexPath.row] imageLocal]];
                NSLog(@"%@",[[menuItems objectAtIndex:indexPath.row] imageLocal]);
                UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
                img.layer.cornerRadius = img.frame.size.height /2;
                img.layer.masksToBounds = YES;
                img.layer.borderWidth = 0;
                [img setContentMode:UIViewContentModeScaleAspectFill];
                //img.backgroundColor = [UIColor whiteColor];
                img.image = image;
                
                [cell.contentView addSubview:img];

                
            }else{
                [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] title]];
                [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@red",imageName]]];
                
                UIView *bck=[[UIView alloc] initWithFrame:cell.frame];
                
                [bck setBackgroundColor:[UIColor redColor]];
                [cell setSelectedBackgroundView:bck];
                
                [cell setSelectedTextColor:[UIColor whiteColor]];
                [cell setSelectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@white",imageName]]];
                
            }
            
            
            
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
            if (casesType!=0) {
                temp = [[NSMutableArray alloc] init];
                switch (casesType) {
                    case -1:
                        temp=[self getCasesWithAuthorID:category];
                        break;
                    case 1:
                        temp=[self getCases:category];
                        break;
                        
                    default:
//                        temp=[self getAlphabeticalCases];
                        break;
                }
                casesInMenu = temp;
            }
            
            [self.viewDeckController toggleLeftViewAnimated:YES];
            UINavigationController *tempC = self.viewDeckController.centerController;

            [(FCasebookViewController *)[tempC visibleViewController]  setPrevCase:[(FCasebookViewController*)[tempC visibleViewController] currentCase]];
           // [(FCasebookViewController*)self.viewDeckController.centerController setPrevCase:[(FCasebookViewController*)self.viewDeckController.centerController currentCase]];
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            NSString *usr = [FCommon getUser];
            
            FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, [[casesInMenu objectAtIndex:indexPath.row] caseID]]];
            BOOL flag=NO;
            while([resultsBookmarked next]) {
                flag=YES;
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            
            if (( [[[casesInMenu objectAtIndex:indexPath.row] bookmark] boolValue] && flag)|| [[[casesInMenu objectAtIndex:indexPath.row] coverflow] boolValue]) {
                UINavigationController *tempC = self.viewDeckController.centerController;

                [(FCasebookViewController*)self.viewDeckController.centerController setCurrentCase:[casesInMenu objectAtIndex:indexPath.row]];
                [(FCasebookViewController*)self.viewDeckController.centerController openCase];
            } else{
                if([APP_DELEGATE connectedToInternet]){
                    
                     NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:[[menuItems objectAtIndex:indexPath.row] caseID] onView:[(FCasebookViewController*)self.viewDeckController.centerController view]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        // I get response as XML here and parse it in a function
                        
                        NSError *jsonError;
                        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                        NSString *c = [dic objectForKey:@"d"];
                        NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
                        FCase *caseObj=[[FCase alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&jsonError]];
                        NSLog(@"%@",[jsonError localizedDescription]);
                        
                        updateCounter++;
                        success++;
                        
                        [self removeHud];
                        UINavigationController *tempC = self.viewDeckController.centerController;
                        //                [(FCasebookViewController *)[tempC visibleViewController] setCurrentCase:item];
                        //                [(FCasebookViewController *)[tempC visibleViewController] setFlagCarousel:YES];
                        [(FCasebookViewController*)[tempC visibleViewController] setCurrentCase:caseObj];
                        [(FCasebookViewController*)[tempC visibleViewController]openCase];
                        
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
    }else{
        if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FCase class]]) {
            if (casesType!=0) {
                temp = [[NSMutableArray alloc] init];
                switch (casesType) {
                    case -1:
                        temp=[self getCasesWithAuthorID:category];
                        break;
                    case 1:
                        temp=[self getCases:category];
                        break;
                        
                    default:
                        //temp=[self getAlphabeticalCases];
                        break;
                }
                menuItems = temp;
            }
            
            
            [self.viewDeckController toggleLeftViewAnimated:YES];
            UINavigationController *tempC = self.viewDeckController.centerController;
            //                [(FCasebookViewController *)[tempC visibleViewController] setCurrentCase:item];
            //                [(FCasebookViewController *)[tempC visibleViewController] setFlagCarousel:YES];
            [(FCasebookViewController *)[tempC visibleViewController]  setPrevCase:[(FCasebookViewController*)[tempC visibleViewController] currentCase]];
            FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
            [database open];
            NSString *usr = [FCommon getUser];
            
            FMResultSet *resultsBookmarked = [database executeQuery:@"SELECT * FROM UserBookmark where username=? and typeID=? and documentID=?" withArgumentsInArray:@[usr, BOOKMARKCASE, [[menuItems objectAtIndex:indexPath.row] caseID]]];
            BOOL flag=NO;
            while([resultsBookmarked next]) {
                flag=YES;
            }
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
            [database close];
            
            if (( [[[menuItems objectAtIndex:indexPath.row] bookmark] boolValue] && flag)|| [[[menuItems objectAtIndex:indexPath.row] coverflow] boolValue]){
                UINavigationController *tempC = self.viewDeckController.centerController;
                [(FCasebookViewController*)[tempC visibleViewController] setCurrentCase:[menuItems objectAtIndex:indexPath.row]];
                [(FCasebookViewController*)[tempC visibleViewController]  openCase];
            } else{
                if([APP_DELEGATE connectedToInternet]){
                     NSMutableURLRequest *request = [FHelperRequest requestToGetCaseByID:[[menuItems objectAtIndex:indexPath.row] caseID] onView:[(FCasebookViewController*)self.viewDeckController.centerController view]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        // I get response as XML here and parse it in a function
                        
                        NSError *jsonError;
                        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
                        NSString *c = [dic objectForKey:@"d"];
                        NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
                        FCase *caseObj=[[FCase alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&jsonError]];
                        NSMutableArray *imgs = [[NSMutableArray alloc] init];
                        for (NSDictionary *imgLink in [caseObj images]) {
                            FImage * img = [[FImage alloc] initWithDictionary:imgLink];
                            
                            [imgs addObject:img];
                        }
                        [caseObj setImages:imgs];
                        NSMutableArray *videos = [[NSMutableArray alloc] init];
                        for (NSDictionary *videoLink in [caseObj video]) {
                            FVideo * videoTemp = [[FVideo alloc] initWithDictionary:videoLink];
                            
                            [videos addObject:videoTemp];
                        }
                        [caseObj setVideo:videos];
                        updateCounter++;
                        success++;
                        [self removeHud];
                        UINavigationController *tempC = self.viewDeckController.centerController;
                        [(FCasebookViewController*)[tempC visibleViewController] setCurrentCase:caseObj];
                        [(FCasebookViewController*)[tempC visibleViewController] openCase];
                        
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
            
            
        }else if ([[menuItems objectAtIndex:indexPath.row] isKindOfClass:[FAuthor class]]) {
            casesType = 0;
            NSMutableArray *newItems=[self getCasesWithAuthorID:[[menuItems objectAtIndex:indexPath.row] authorID]];
            NSLog(@"case author");
            if (newItems.count>0) {
                FCaseMenuViewController *subMenu=[[FCaseMenuViewController alloc] init];
                if (selectedIcon) {
                    subMenu.selectedIcon=selectedIcon;
                }else{
                    subMenu.selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                }
                [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] name]]];
                [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                [self.navigationController pushViewController:subMenu animated:YES];
            }
            else
            {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCASECATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
            
            
        }else{
            casesType = 0;
            if ([[[menuItems objectAtIndex:indexPath.row] categoryID] isEqualToString:@""]) {
                //list by author or alphabetical
                if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Case Author"]) {
                    NSArray *newItems=[FDB getAuthors];
                    FCaseMenuViewController *subMenu=[[FCaseMenuViewController alloc] init];
                    if (selectedIcon) {
                        subMenu.selectedIcon=selectedIcon;
                    }else{
                        subMenu.selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                    }
                    [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                    [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                    
                    [self.navigationController pushViewController:subMenu animated:YES];
                    
                }else {
                    if ([[[menuItems objectAtIndex:indexPath.row] title] isEqualToString:@"Disclaimer"])
                    {
                        [self.viewDeckController toggleLeftViewAnimated:YES];
                        UINavigationController *tempC = self.viewDeckController.centerController;
                        [(FCasebookViewController*)[tempC visibleViewController]  openDisclaimer];
                        
                        
                    }
                    
                }
            }else
            {
                NSMutableArray *newItems=[FDB getCaseCategoryWithPrev:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                if (newItems.count==0)
                {
                    newItems=[self getCases:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                    if (newItems.count==0)
                    {
                        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"EMPTYCASECATEGORY", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                    } else
                    {
                        FCaseMenuViewController *subMenu=[[FCaseMenuViewController alloc] init];
                        if (selectedIcon)
                        {
                            subMenu.selectedIcon=selectedIcon;
                        } else
                        {
                            subMenu.selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                        }
                        [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                        [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                        casesInMenu=[[NSMutableArray alloc] init];
                        [subMenu setCasesInMenu:casesInMenu];
                        [self.navigationController pushViewController:subMenu animated:YES];
                    }
                } else
                {
                    FCaseMenuViewController *subMenu=[[FCaseMenuViewController alloc] init];
                    if (selectedIcon)
                    {
                        subMenu.selectedIcon=selectedIcon;
                    } else
                    {
                        subMenu.selectedIcon=[menuIcons objectAtIndex:indexPath.row];
                    }                    [subMenu  setMenuTitles:[NSMutableArray arrayWithObject:[[menuItems objectAtIndex:indexPath.row] title]]];
                    [subMenu  setAllItems:[NSMutableArray arrayWithObject:newItems]];
                    casesInMenu=[self getCases:[[menuItems objectAtIndex:indexPath.row] categoryID]];
                    category =[[menuItems objectAtIndex:indexPath.row] categoryID];
                    [subMenu setCasesInMenu:casesInMenu];
                    [self.navigationController pushViewController:subMenu animated:YES];
                }
                
                
            }
        }
    }
    
    [tableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark DB


-(NSMutableArray *)getCasesWithAuthorID:(NSString *)authorID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Cases where active=1 and authorID=%@",authorID]];
    while([results next]) {
        casesType = -1;
        category = authorID;
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
        //[cases addObject:f];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}
-(NSMutableArray *)getCases:(NSString *)catID{
    NSMutableArray *cases=[[NSMutableArray alloc] init];
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT c.* FROM Cases as c,CasesInCategories as cic where cic.categorieID=%@ and cic.caseID=c.caseID and c.active=1",catID]];
    while([results next]) {
        casesType = 1;
        category = catID;
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
        //[cases addObject:f];
        if ([APP_DELEGATE checkGuest]) {
            if ([f.allowedForGuests isEqualToString:@"1"]) {
                [cases addObject:f];
            }
        } else {
            [cases addObject:f];
        }
    }
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    
    return cases;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) resetViewAnime:(BOOL) anime{
    
    [self.navigationController popToRootViewControllerAnimated:anime];
}


-(void)removeHud
{
    NSLog(@"remove");
    [APP_DELEGATE setUpdateInProgress:NO];
    [MBProgressHUD hideAllHUDsForView:[(FCasebookViewController*)self.viewDeckController.centerController view] animated:YES];
    if (success<updateCounter) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:(FCasebookViewController*)self.viewDeckController.centerController cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av setTag:0];
        [av show];
    }
    success=0;
    updateCounter=0;
}

-(NSData *)getAuthorImage:(NSString *)authID
{
    NSData *data=nil;
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT image,imageLocal FROM Author where authorID=%@",authID]];
    while([results next]) {
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


 @end

//
//  FIOptionsViewController.m
//  fotona
//
//  Created by Janos on 25/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIOptionsViewController.h"
#import "FAppDelegate.h"

@interface FIOptionsViewController ()  

@end

@implementation FIOptionsViewController

@synthesize menuIcons;
@synthesize menuTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(cancelMenu:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMenu, nil] animated:false];
    
    menuTitles = [NSArray arrayWithObjects:@"Settings",@"Feedback", nil];
    menuIcons = [NSMutableArray arrayWithObjects:@"settingsMenu",@"feedbackMenu", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Close Menu

- (IBAction)cancelMenu:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"showSettings" sender:self];
    } else if (indexPath.row == 1)
    {
        [self cancelMenu:self];
        [APP_DELEGATE sendFeedback:self];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"fotonaMenuTabelViewCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.textLabel.text = [menuTitles objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_red",[menuIcons objectAtIndex:indexPath.row]]]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
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

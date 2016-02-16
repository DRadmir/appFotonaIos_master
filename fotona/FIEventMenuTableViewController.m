//
//  FIEventMenuTableViewController.m
//  fotona
//
//  Created by Janos on 30/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIEventMenuTableViewController.h"

@interface FIEventMenuTableViewController ()

@end

NSArray *menu;
NSArray *categories;
NSIndexPath *selectedIndex;
@implementation FIEventMenuTableViewController

@synthesize eventMenuTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Event Categories"];
    
    menu= [NSArray arrayWithObjects: @"All", @"Aesthetics", @"Dentistry", @"Gynecology",nil];
    categories = [NSArray arrayWithObjects: @"0", @"2", @"1", @"3",nil];
    
    selectedIndex = [NSIndexPath indexPathForRow:[categories indexOfObject:[NSString stringWithFormat:@"%d",self.parent.ci]] inSection:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menu.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedcell = [tableView cellForRowAtIndexPath:selectedIndex];
    selectedcell.accessoryType = UITableViewCellAccessoryNone;
    selectedcell.textLabel.textColor = [UIColor colorWithRed:0.216 green:0.216 blue:0.216 alpha:1];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1];
    selectedIndex = indexPath;
    self.parent.ci = [[categories objectAtIndex:indexPath.row] intValue];
    [self.parent reloadData];
    [[self navigationController] popViewControllerAnimated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =[self.eventMenuTableView dequeueReusableCellWithIdentifier:@"eventsMenuTabelViewCell"]; //[self.tableView dequeueReusableCellWithIdentifier:@"eventsMenuTabelViewCell"];
    [cell.textLabel setText:menu[indexPath.row]];
    if (indexPath.row == selectedIndex.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:0.929 green:0.11 blue:0.141 alpha:1];
    }
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

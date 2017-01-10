//
//  FIEventViewController.m
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIEventViewController.h"
#import "FIEventTableViewCell.h"
#import "FEventViewCell.h"
#import "FDB.h"
#import "FEvent.h"
#import "FIEventSingleViewController.h"
#import "FIEventMenuTableViewController.h"
#import "FIFlowController.h"
#import "FIEventContainerViewController.h"
#import "FGoogleAnalytics.h"

@interface FIEventViewController ()
{
    NSArray *tableData;
    int ti;
    int selected;
    FEvent *eventToOpen;
}


@end


@implementation FIEventViewController


@synthesize ci;

- (void)viewDidLoad {
    [super viewDidLoad];
    ci = 0;
    UIBarButtonItem *categoryMenu = [[UIBarButtonItem alloc] initWithTitle:@"Categories"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showCategoryMenu:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:categoryMenu, nil] animated:false];
    tableData = [FDB fillEventsWithCategory:0 andType:0 andMobile:false];//[FDB fillArrayWithCategory:0 andType:0];
    
    self.eventsTableView.estimatedRowHeight = 360;
    self.eventsTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.eventsTableView setNeedsLayout];
    [self.eventsTableView layoutIfNeeded];
    
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.eventTab == nil)
    {
        flow.eventTab = self;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    if ([APP_DELEGATE eventTemp] != eventToOpen && [APP_DELEGATE eventTemp] != nil) {
        eventToOpen = [APP_DELEGATE eventTemp];
        [self openEvent];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [FGoogleAnalytics writeGAForItem:nil andType:GAEVENTTABINT];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIEventTableViewCell *cell =[FIEventTableViewCell fillCell:indexPath fromArray:tableData andCategory:ci andTableView:self.eventsTableView];//[self.eventsTableView dequeueReusableCellWithIdentifier:@"eventsTabelViewCell"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    eventToOpen = tableData[indexPath.row];
    [self openEvent];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openEvent"]) {
        
        FIEventContainerViewController *openView = (FIEventContainerViewController *)segue.destinationViewController;
        openView.eventToContain = eventToOpen;
    }
}


-(void)reloadData
{
    tableData = [FDB fillEventsWithCategory:ci andType:ti andMobile:false];//[FDB fillArrayWithCategory:ci andType:ti];
    [self.eventsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [_eventsTableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - SegmenControl

- (IBAction)typeSelected:(id)sender {
    ti = self.typeSelector.selectedSegmentIndex;
    [self reloadData];
    
}

#pragma mark - Open Event

-(void) openEvent
{
    if (eventToOpen != nil) {
         [APP_DELEGATE setEventTemp:nil];
        [self performSegueWithIdentifier:@"openEvent" sender:self];
    }
}

#pragma mark - Open menu

- (IBAction)showCategoryMenu:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    FIEventMenuTableViewController *menu = [sb instantiateViewControllerWithIdentifier:@"eventsMenu"];
    menu.parent = self;
    [self.navigationController pushViewController:menu animated:true];
}

@end

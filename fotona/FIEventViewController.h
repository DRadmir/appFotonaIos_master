//
//  FIEventViewController.h
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIBaseView.h"

@interface FIEventViewController : FIBaseView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeSelector;

@property (nonatomic) int ci;

-(void) reloadData;

- (IBAction)typeSelected:(id)sender;
-(void) openEvent;
@end

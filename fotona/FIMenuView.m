//
//  FIMenuView.m
//  fotona
//
//  Created by Janos on 30/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIMenuView.h"

@interface FIMenuView ()

@end

@implementation FIMenuView

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                              style:UIBarButtonSystemItemCancel
                                                             target:self
                                                             action:@selector(cancelPress:)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:item1, nil] animated:false];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}



@end




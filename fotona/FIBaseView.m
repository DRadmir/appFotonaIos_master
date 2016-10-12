//
//  FIBaseView.m
//  fotona
//
//  Created by Janos on 24/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIBaseView.h"
#import "FISearchViewController.h"
#import "FIFlowController.h"

@interface FIBaseView (){
    id<GAITracker> tracker;
}
@end

@implementation FIBaseView

@synthesize searchBar;


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *className = NSStringFromClass([self class]);
    if (tracker == nil){
        tracker = [[GAI sharedInstance] defaultTracker];
    }
    [tracker set:kGAIScreenName value:className];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithTitle:@""
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showSettingsFedback:)];
    [btnSettings setImage:[UIImage imageNamed:@"settingsMenu"]];
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnSearch, btnSettings, nil] animated:false];
    
    searchBar = [[FISearchViewController alloc]  init];//  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    searchBar.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    searchBar.view.hidden = true;
   // searchBar.delegate = self;
    [self.view addSubview:searchBar.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showSettingsFedback:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"IPhoneStoryboard" bundle:nil];
    UINavigationController *menu = [sb instantiateViewControllerWithIdentifier:@"optionsNavigation"];
    [self  presentViewController:menu animated:true completion:nil];
}

- (IBAction)search:(id)sender
{
    [self toggleSearchBar ];
}


-(void) toggleSearchBar
{
    if (searchBar.view.hidden) {
        FIFlowController *flow = [FIFlowController sharedInstance];
        flow.lastOpenedView = self;
        [UIView animateWithDuration:0.3 animations:^{
            self.searchBar.view.hidden = false;
            self.searchBar.searchBarIPhone.text = @"";
            [self.searchBar becomeFirstResponder];
        
        }
                         completion:nil];
    } else
    {
        
            self.searchBar.view.hidden = true;
            self.searchBar.searchBarIPhone.text = @"";
            [self.searchBar resignFirstResponder];
        
    }
}


@end

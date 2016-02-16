//
//  FIFeaturedSingleEventViewController.m
//  fotona
//
//  Created by Janos on 31/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIFeaturedSingleEventViewController.h"
#import "HelperDate.h"

@interface FIFeaturedSingleEventViewController ()

@end

@implementation FIFeaturedSingleEventViewController

@synthesize imageDot;
@synthesize event;
@synthesize lblTitle;
@synthesize lblDate;
@synthesize lblLocation;
@synthesize category;
@synthesize btnMoreEvents;
@synthesize parent;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,[[UIScreen mainScreen] bounds].size.width,self.view.frame.size.height);
    lblTitle.text = [event.title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    lblDate.text = [[HelperDate formatedDate:[event eventdate]] stringByAppendingString:[NSString stringWithFormat:@" - %@",  [HelperDate formatedDate:[event eventdateTo]]]];
    lblLocation.text = event.eventplace;
    if (category==0) {
        [imageDot setImage:[UIImage imageNamed:[event getDot]]];
    } else{
        [imageDot setImage:[UIImage imageNamed:[event getDot:category]]];
    }

    [btnMoreEvents addTarget:parent
               action:@selector(showMoreEvents:)
     forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end

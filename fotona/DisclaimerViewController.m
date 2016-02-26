//
//  DisclaimerViewController.m
//  fotona
//
//  Created by Janos on 18/11/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "FAppDelegate.h"

@interface DisclaimerViewController ()
{
     UILabel *disclaimerLbl;
}

@end

@implementation DisclaimerViewController

@synthesize parentiPad;
@synthesize parentiPhone;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
    NSMutableArray *usersarray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"disclaimerShown"]];
    if(![usersarray containsObject:usr]){
        [self showDisclaimer];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    disclaimerLbl.frame = CGRectMake(40.0f, 40.0f, disclaimerScrollView.frame.size.width-80, 460.0f);
    [disclaimerLbl sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showDisclaimer
{
    btnAccept.layer.cornerRadius = 3;
    btnAccept.layer.borderWidth = 1;
    btnAccept.layer.borderColor = btnAccept.tintColor.CGColor;
    btnDecline.layer.cornerRadius = 3;
    btnDecline.layer.borderWidth = 1;
    btnDecline.layer.borderColor = btnDecline.tintColor.CGColor;
    disclaimerLbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 40.0f, self.parentViewController.view.frame.size.width-80, 460.0f)];
    NSString *htmlString=[NSString stringWithFormat:@"<html><body><style>p{margin-top: 27px;margin-bottom: 27px; line-height:30px; font-size:1.3em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} p6{ line-height:30px; font-size:1.5em; font-family: 'HelveticaNeue-Medium', Helvetica, Serif;} h{ line-height:30px; font-size:2em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</body></html>", [NSString stringWithFormat:NSLocalizedString(@"STARTDISCLAIMER", nil)]];
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:10];
    [style setAlignment:NSTextAlignmentJustified];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, attrStr.length)];
    
    disclaimerLbl.attributedText = attrStr;
    disclaimerLbl.numberOfLines = 0;
    [disclaimerLbl sizeToFit];
     disclaimerScrollView.contentSize = CGSizeMake(disclaimerScrollView.contentSize.width, disclaimerLbl.frame.size.height+15) ;
    [disclaimerScrollView addSubview:disclaimerLbl];
}

- (IBAction)btnAcceptClick:(id)sender {
    NSMutableArray *disclaimerArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"disclaimerShown"]];
    NSString *usr =[APP_DELEGATE currentLogedInUser].username;//[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if (usr == nil) {
        usr =@"guest";
    }
    [disclaimerArray addObject:usr];
    [[NSUserDefaults standardUserDefaults] setObject:disclaimerArray forKey:@"disclaimerShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (parentiPad == nil)
    {
        
        [parentiPhone showFeatured];
        [self removeFromParentViewController];
    } else
    {
        [parentiPad showFeatured];
    }
}



- (IBAction)btnDeclineClick:(id)sender {
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"STARTDISCLAIMERCLOSE", nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the Ok button
    if (buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APP_DELEGATE setCurrentLogedInUser:nil];

        [self removeFromParentViewController];
        exit(0);
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [disclaimerScrollView  setFrame:CGRectMake(0.0f, 0.0f, self.parentViewController.view.frame.size.height, self.parentViewController.view.frame.size.width - 63)];
    [disclaimerLbl  setFrame :CGRectMake(40.0f, 40.0f, self.parentViewController.view.frame.size.width - 80, 460.0f)];
    [disclaimerLbl sizeToFit];
    disclaimerScrollView.contentSize = CGSizeMake(disclaimerScrollView.contentSize.width, disclaimerLbl.frame.size.height+15);
}


@end

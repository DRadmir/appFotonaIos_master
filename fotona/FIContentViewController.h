//
//  FIContentViewController.h
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIContentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblTitleContent;
@property (strong, nonatomic) IBOutlet UIWebView *webViewContent;

@property (strong, nonatomic) NSString* titleContent;
@property (strong, nonatomic) NSString* descriptionContent;

-(void) reloadView;

@end

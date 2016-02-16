//
//  FExternalLinkViewController.h
//  fotona
//
//  Created by Janos on 20/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIExternalLinkViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *externalWebView;

@property (strong, nonatomic) NSString* urlString;
@property (nonatomic) BOOL changePass;

-(void) reloadView;

@end

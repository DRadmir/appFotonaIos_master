//
//  FRegistrationViewController.h
//  fotona
//
//  Created by Janos on 15/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRegistrationViewController : UIViewController
{
    IBOutlet UIButton *btnClose;
    IBOutlet UIWebView *webView;
}
@property (strong, nonatomic) NSString* urlString;

@property (nonatomic) BOOL fromSettings;



@end

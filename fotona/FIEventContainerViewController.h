//
//  FIEventContainerViewController.h
//  fotona
//
//  Created by Janos on 29/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"
#import "FEvent.h"

@interface FIEventContainerViewController : FIBaseView

@property (nonatomic) FEvent *eventToContain;
@property (strong, nonatomic) IBOutlet UIView *eventContainerView;

@end

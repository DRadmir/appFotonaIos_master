//
//  FICasebookViewController.h
//  fotona
//
//  Created by Janos on 26/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"
#import "FCase.h"

@interface FICasebookContainerViewController : FIBaseView

@property (strong, nonatomic) FCase *caseToOpen;
@property (strong, nonatomic) IBOutlet UIView *caseContainer;

-(void) openCase;
-(void) openDisclaimer;

-(void)clearViews;
- (IBAction)showMenu:(id)sender;
@end

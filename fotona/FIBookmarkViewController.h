//
//  FIBookmarkViewController.h
//  fotona
//
//  Created by Janos on 28/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"
#import <QuickLook/QuickLook.h>

@interface FIBookmarkViewController : FIBaseView <QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIView *contentViewBookmark;


-(void)openData:(NSMutableArray *)data;
-(void) openContent:(NSString *) title withDescription:(NSString *)description andReplace:(BOOL) replace;
- (void) openDisclaimer;
-(void)clearViews;
- (IBAction)showMenu:(id)sender;
@end

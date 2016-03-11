//
//  FIFotonaViewController.h
//  fotona
//
//  Created by Janos on 18/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"
#import "FFotonaMenu.h"
#import <QuickLook/QuickLook.h>
#import "Bubble.h"

@interface FIFotonaViewController : FIBaseView <QLPreviewControllerDelegate,QLPreviewControllerDataSource, BubbleDelegate>

@property (strong, nonatomic) IBOutlet UIView *continerViewFotona;
@property(nonatomic) NSMutableDictionary *bookmarkMenu;



-(void) openGalleryFromSearch:(NSString *) galleryID andReplace:(BOOL) replace;
-(void) openCategory: (FFotonaMenu *) fotonaCategory;
-(void)refreshMenu:(NSString *)link;

-(void) clearViews;
- (IBAction)showMenu:(id)sender;


@end

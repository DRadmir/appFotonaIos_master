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


@interface FIFotonaViewController : FIBaseView

@property (strong, nonatomic) IBOutlet UIView *continerViewFotona;
@property(nonatomic) NSMutableDictionary *bookmarkMenu;


-(void) openGallery:(NSString *) galleryItems andReplace:(BOOL) replace andType:(NSString *)mediaType;
-(void) openGalleryFromSearch:(NSString *) galleryItems andReplace:(BOOL) replace andType:(NSString *)mediaType;
-(void) openCategory: (FFotonaMenu *) fotonaCategory;
-(void) clearViews;
- (IBAction)showMenu:(id)sender;


@end

//
//  FIFlowController.h
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIFotonaViewController.h"
#import <Foundation/Foundation.h>
#import "FIFotonaMenuViewController.h"
#import "FISettingsViewController.h"
#import "FICasebookMenuViewController.h"
#import "FICasebookContainerViewController.h"
#import "FIEventViewController.h"
#import "FIFeaturedViewController.h"
#import "FMainViewController.h"
#import "FIBookmarkMenuViewController.h"
#import "FIBookmarkViewController.h"
#import "FICaseViewController.h"
#import "FITabbarController.h"
#import "FIVideoGalleryViewController.h"
#import "FIBaseView.h"
#import "FCase.h"
#import "FVideo.h"


@interface FIFlowController : NSObject
{
}

+(FIFlowController *) sharedInstance;

@property (strong, nonatomic, readwrite) FIFotonaViewController *fotonaTab;
@property (strong, nonatomic, readwrite) FIFotonaMenuViewController *fotonaMenu;
@property (strong, nonatomic, readwrite) FICasebookContainerViewController *caseTab;
@property (strong, nonatomic, readwrite) FICasebookMenuViewController *caseMenu;
@property (strong, nonatomic, readwrite) FIEventViewController *eventTab;
@property (strong, nonatomic, readwrite) FIFeaturedViewController *newsTab;
@property (strong, nonatomic, readwrite) FISettingsViewController *fotonaSettings;
@property (strong, nonatomic, readwrite) FIBookmarkMenuViewController *bookmarkMenu;
@property (strong, nonatomic, readwrite) FIBookmarkViewController *bookmarkTab;

@property (strong, nonatomic, readwrite) FICaseViewController *caseView;
@property (strong, nonatomic, readwrite) FIVideoGalleryViewController *videoView;

@property (strong, nonatomic, readwrite) FCase *caseFlow;
@property (strong, nonatomic, readwrite) FCase *caseOpened;
@property (nonatomic, readwrite) int lastIndex;

@property (strong, nonatomic, readwrite) FMainViewController* mainControler;
@property (strong, nonatomic, readwrite) FITabbarController* tabControler;
@property (strong, nonatomic, readwrite) FIBaseView *lastOpenedView;

@property (nonatomic) BOOL showMenu;

@property (nonatomic) BOOL fromSearch;
@property(strong, nonatomic) NSString* videoGal;
@property(strong, nonatomic) FVideo* vidToOpen;

@property(nonatomic) int fotonaHelperState;

@end

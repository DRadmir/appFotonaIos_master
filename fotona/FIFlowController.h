//
//  FIFlowController.h
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIFotonaViewController.h"
#import "FIFotonaMenuViewController.h"
#import "FISettingsViewController.h"
#import "FICasebookMenuViewController.h"
#import "FICasebookContainerViewController.h"
#import "FIEventViewController.h"
#import "FIFeaturedViewController.h"
#import "FMainViewController.h"
#import "FIFavoriteViewController.h"
#import "FICaseViewController.h"
#import "FITabbarController.h"
#import "FIGalleryViewController.h"
#import "FIBaseView.h"
#import "FCase.h"
#import "FMedia.h"


@interface FIFlowController : NSObject
{
}

+(FIFlowController *) sharedInstance;

@property (strong, nonatomic, readwrite) FIFotonaViewController *fotonaTab;
@property (strong, nonatomic, readwrite) FIFotonaMenuViewController *fotonaMenu;
@property (strong, nonatomic, readwrite) NSMutableArray *fotonaMenuArray;
@property (strong, nonatomic, readwrite) FICasebookContainerViewController *caseTab;
@property (strong, nonatomic, readwrite) FICasebookMenuViewController *caseMenu;
@property (strong, nonatomic, readwrite) NSMutableArray *caseMenuArray;
@property (strong, nonatomic, readwrite) FIEventViewController *eventTab;
@property (strong, nonatomic, readwrite) FIFeaturedViewController *newsTab;
@property (strong, nonatomic, readwrite) FISettingsViewController *fotonaSettings;
@property (strong, nonatomic, readwrite) FIFavoriteViewController *favoriteTab;
@property (strong, nonatomic, readwrite) NSMutableArray *bookmarkMenuArray;

@property (strong, nonatomic, readwrite) FICaseViewController *caseView;
@property (strong, nonatomic, readwrite) FIGalleryViewController *videoView;

@property (strong, nonatomic, readwrite) FCase *caseFlow;
@property (strong, nonatomic, readwrite) FCase *caseOpened;
@property (nonatomic, readwrite) int lastIndex;

@property (strong, nonatomic, readwrite) FMainViewController* mainControler;
@property (strong, nonatomic, readwrite) FITabbarController* tabControler;
@property (strong, nonatomic, readwrite) FIBaseView *lastOpenedView;

@property (nonatomic) BOOL showMenu;

@property (nonatomic) BOOL fromSearch;
@property (nonatomic) BOOL fromSearchFotona;
@property(strong, nonatomic) FMedia* mediaToOpen;
@property (strong, nonatomic) NSString *mediaTypeToOpen;
@property (strong, nonatomic) NSString *galToOpen;

@property(nonatomic) int fotonaHelperState;

@end

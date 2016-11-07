//
//  FIFlowController.m
//  fotona
//
//  Created by Janos on 18/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "FIFlowController.h"
#import "FIFotonaViewController.h"


@interface FIFlowController ()
@end

@implementation FIFlowController

@synthesize fotonaTab;
@synthesize fotonaMenu;
@synthesize fotonaMenuArray;
@synthesize caseTab;
@synthesize caseMenu;
@synthesize caseMenuArray;
@synthesize fotonaSettings;
@synthesize eventTab;
@synthesize newsTab;
@synthesize lastIndex;
@synthesize mainControler;
@synthesize bookmarkMenuArray;

@synthesize caseFlow;
@synthesize caseOpened;
@synthesize caseView;
@synthesize tabControler;
@synthesize videoView;
@synthesize lastOpenedView;

@synthesize showMenu;

@synthesize fromSearch;
@synthesize mediaToOpen;
@synthesize galToOpen;

@synthesize fotonaHelperState;

+ (FIFlowController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static FIFlowController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[FIFlowController alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        fotonaTab = nil;
        fotonaMenu = nil;
        caseTab = nil;
        caseMenu = nil;
        fotonaSettings = nil;
        eventTab = nil;
        newsTab = nil;
        caseFlow = nil;
        caseOpened = nil;
        lastIndex = 0;
        mainControler = nil;
        caseView = nil;
        tabControler = nil;
        videoView = nil;
        showMenu = nil;
        lastOpenedView = nil;
        fromSearch = nil;
        galToOpen = nil;
        mediaToOpen = nil;
        fotonaHelperState = 0;
        fotonaMenuArray = [NSMutableArray new];
        caseMenuArray = [NSMutableArray new];
        bookmarkMenuArray = [NSMutableArray new];
    }
    return self;
}


@end

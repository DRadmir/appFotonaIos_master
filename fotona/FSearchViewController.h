//
//  FSearchViewController.h
//  fotona
//
//  Created by Dejan Krstevski on 4/16/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMedia.h"
#import "FFotonaViewController.h"

@interface FSearchViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UIView *tmpNews;
    int updateCounter;
    int success;
    
}

@property (nonatomic, retain) IBOutlet UIView *popupView;
@property (nonatomic, retain) IBOutlet UILabel *popupTitle;
@property (nonatomic, retain) IBOutlet UITextView *popupText;

@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, retain) NSString *searchTxt;
@property (nonatomic, retain) IBOutlet UITableView *tableSearch;
@property (nonatomic) BOOL characterLimit;


@property (nonatomic, retain) NSMutableArray *newsSearchRes;
@property (nonatomic, retain) NSMutableArray *casesSearchRes;
@property (nonatomic, retain) NSMutableArray *videosSearchRes;
@property (nonatomic, retain) NSMutableArray *pdfsSearchRes;
@property (nonatomic, retain) NSMutableArray *fotonaSearchRes;
@property (nonatomic, retain) NSMutableArray *eventsSearchRes;

-(void)search;

@end

//
//  FISearchViewViewController.h
//  fotona
//
//  Created by Janos on 31/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FISearchViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UIView *tmpNewsIPhone;
    
    int updateCounterIPhone;
    int successIPhone;
    
}

@property (nonatomic, retain) UIViewController *parentIPhone;
@property (nonatomic, retain) NSString *searchTxtIPhone;
@property (nonatomic, retain) IBOutlet UITableView *tableSearchIPhone;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarIPhone;
@property (nonatomic) BOOL characterLimit;


@property (nonatomic, retain) NSMutableArray *newsSearchResIPhone;
@property (nonatomic, retain) NSMutableArray *casesSearchResIPhone;
@property (nonatomic, retain) NSMutableArray *videosSearchResIPhone;
@property (nonatomic, retain) NSMutableArray *pdfsSearcResIPhone;
@property (nonatomic, retain) NSMutableArray *fotonaSearcResIPhone;
@property (nonatomic, retain) NSMutableArray *eventsSearcResIPhone;


-(void)searchIPhone;

@end

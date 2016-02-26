//
//  FNewsViewController.h
//  fotona
//
//  Created by Janos on 06/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIBaseView.h"
#import "FNews.h"
#import "FIGalleryController.h"

@interface FINewsViewController : FIBaseView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewMain;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIScrollView *scroolViewImages;
@property (strong, nonatomic) IBOutlet UIView *viewRelated;
@property (strong, nonatomic) IBOutlet UITextView *textViewNews;
@property (strong, nonatomic) IBOutlet UITableView *tabelViewRelated;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *relatedViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *relatedTableViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomCostraint;
@property (strong, nonatomic) IBOutlet UIView *viewMain;

@property (strong, nonatomic) FNews *news;
@property (strong, nonatomic)  FIGalleryController *gallery;


-(void)fillNews;
-(void)reloadView;


@end

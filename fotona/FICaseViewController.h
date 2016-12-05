//
//  FICaseViewController.h
//  fotona
//
//  Created by Janos on 27/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FCase.h"
#import "FICasebookContainerViewController.h"
#import "FIGalleryController.h"
#import "FIFavoriteViewController.h"


@interface FICaseViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblAuthor;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIButton *btnBookmark;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveBookmark;
@property (strong, nonatomic) IBOutlet UIImageView *imgAuthor;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewImagesHeight;
@property (strong, nonatomic) IBOutlet UIView *viewIntroduction;
@property (strong, nonatomic) IBOutlet UILabel *lblIntroduction;
@property (strong, nonatomic) IBOutlet UIButton *btnReadMore;


@property (strong, nonatomic) IBOutlet UIView *parametersContainer;
@property (strong, nonatomic) IBOutlet UIView *tableParameters;
@property (strong, nonatomic) IBOutlet UIView *headerTableParameters;
@property (strong, nonatomic) IBOutlet UIScrollView *parametersScrollView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *parametersHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;

@property (strong, nonatomic) IBOutlet UIButton *btnAddFavorite;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveFavorite;

@property (strong, nonatomic)  FIGalleryController *gallery;
@property (nonatomic) BOOL canBookmark;


@property (strong, nonatomic) FCase* caseToOpen;
@property (strong, nonatomic) FICasebookContainerViewController *parent;
@property (strong, nonatomic) FIFavoriteViewController *favoriteParent;

- (IBAction)readMore:(id)sender;
- (IBAction)removeBookmark:(id)sender;
- (IBAction)addBookmark:(id)sender;
- (void) refreshBookmarkBtn;
- (IBAction)addToFavorite:(id)sender;
- (IBAction)removeFavorite:(id)sender;
@end

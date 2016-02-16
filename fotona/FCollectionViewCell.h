//
//  FCollectionViewCell.h
//  fotona
//
//  Created by Janus! on 29/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCollectionViewCell : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *imgView;
//@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
//@property (weak, nonatomic) IBOutlet UIView *newsCell;
//@property (weak, nonatomic) IBOutlet UITextField *signNew;
//@property (weak, nonatomic) IBOutlet UITextView *titleFrame;



@property (weak, nonatomic) IBOutlet UIView *aboutCell;
@property (weak, nonatomic) IBOutlet UILabel *aboutDesc;
@property (weak, nonatomic) IBOutlet UIButton *readMore;
@property (weak, nonatomic) IBOutlet UIView *aboutDescView;

@property (weak, nonatomic) IBOutlet UIButton *greenBtn;
@property (weak, nonatomic) IBOutlet UIButton *blueBtn;
@property (weak, nonatomic) IBOutlet UIButton *orangeBtn;
@property (weak, nonatomic) IBOutlet UIButton *pinkBtn;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;



@property (weak, nonatomic) IBOutlet UIView *eventCell;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *eventTitle;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *eventDate;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *eventLocation;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *eventView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *eventCategoryImage;

@property (strong, nonatomic) NSArray *events;//of Event


- (IBAction)moreEvents:(id)sender;
- (IBAction)dotButtonAction:(id)sender;
- (void)fillData;


@end

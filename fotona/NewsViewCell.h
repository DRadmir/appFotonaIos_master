//
//  NewsViewCell.h
//  fotona
//
//  Created by Janus! on 25/02/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UIView *newsView;
@property (weak, nonatomic) IBOutlet UITextField *newsNew;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet UITextView *newsTitle;

@end

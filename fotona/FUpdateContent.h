//
//  FUpdateContent.h
//  Fotona
//
//  Created by Dejan Krstevski on 4/2/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "FMainViewController_iPad.h"
#import "UpdateDelegate.h"



@interface FUpdateContent : NSObject{
    int casesFlag;
    int updateCounter;
    int success;

}

@property (nonatomic, weak) id <UpdateDelegate> updateDelegate;


@property (nonatomic, retain) UIView *hudView;
@property (nonatomic,retain) UIViewController *parent;

+(FUpdateContent *)shared;
-(void)updateContent:(UIViewController *)viewForHud;
-(void)addMediaWhithout:(NSMutableArray *)m withType:(int)type;
@end

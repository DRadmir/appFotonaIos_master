//
//  FFolderViewController.h
//  fotona
//
//  Created by Dejan Krstevski on 4/7/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface FFolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UIAlertViewDelegate>
{
    IBOutlet UITableView *table;
    IBOutlet UILabel *folderTitle;
    BOOL hasNewFiles;
    NSInteger indexForFileToAdd;
}
@property (nonatomic, retain) NSMutableArray *folderContent;
@property (nonatomic, retain) NSString *subFolder;
@property (nonatomic, retain) NSMutableArray *filesToAdd;


@property (nonatomic, retain) NSMutableDictionary *iconsForDocs;

-(IBAction)goBack:(id)sender;

@end

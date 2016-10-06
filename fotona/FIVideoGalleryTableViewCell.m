//
//  FIVideoGalleryTableViewCell.m
//  fotona
//
//  Created by Janos on 22/01/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FIVideoGalleryTableViewCell.h"
#import "FDB.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "FIFlowController.h"

@implementation FIVideoGalleryTableViewCell

@synthesize video;
@synthesize btnBookmark;
@synthesize btnUnbookmark;
@synthesize parent;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillCell
{
    [btnBookmark setBackgroundColor:[UIColor whiteColor]];
    [btnBookmark setTitle:NSLocalizedString(@"BTNBOOKMARKADD", nil) forState:UIControlStateNormal];
    [btnBookmark setTitle:NSLocalizedString(@"BTNBOOKMARKPROCESSING", nil) forState:UIControlStateDisabled];
    [btnBookmark setTitleColor:[UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:1] forState:UIControlStateNormal];
    [btnBookmark.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    btnBookmark.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [btnUnbookmark setBackgroundColor:[UIColor whiteColor]];
    [btnUnbookmark setTitle:NSLocalizedString(@"BTNBOOKMARKREMOVE", nil) forState:UIControlStateNormal];
    [btnUnbookmark setTitleColor:[UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:1] forState:UIControlStateNormal];
    [btnUnbookmark.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    btnUnbookmark.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    [[self lblVideoTitle] setText: [[self video] title]];
    if ([FDB checkIfBookmarkedForDocumentID:[video itemID] andType:BOOKMARKVIDEO])
    {
        btnUnbookmark.hidden = false;
        btnBookmark.enabled = true;
        btnBookmark.hidden = true;
    } else
    {
        btnBookmark.hidden = false;
        btnUnbookmark.hidden = true;
    }
}

- (IBAction)addToBookmark:(id)sender {
    if ([APP_DELEGATE wifiOnlyConnection]) {
        [self bookmarkVideo];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:parent.view];
    }
}

- (IBAction)removeFromBookmark:(id)sender {
    [FDB removeBookmarkedVideo:video];
    video.bookmark = @"0";
    FIFlowController *flow = [FIFlowController sharedInstance];
    if (flow.lastIndex == 2)
    {
        [btnBookmark setHidden:NO];
    }
    [btnUnbookmark setHidden:YES];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [parent loadGallery];
    [parent.videoGalleryTableView reloadData];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > -1) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if  ([buttonTitle isEqualToString:@"OK"]) {
            [self bookmarkVideo];
        }
        
        if ([buttonTitle isEqualToString:NSLocalizedString(@"CHECKWIFIONLYBTN", nil)]) {
            [APP_DELEGATE setWifiOnlyConnection:TRUE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiOnly"];
            [self bookmarkVideo];
        }
    }
    
}

-(void) bookmarkVideo{
    if([APP_DELEGATE connectedToInternet]){
        if ([APP_DELEGATE bookmarkingVideos] == nil) {
            [APP_DELEGATE setBookmarkingVideos:[NSMutableArray new]];
        }
        [[APP_DELEGATE bookmarkingVideos] addObject:video.itemID];
        if ([HelperBookmark bookmarkVideo:video]) {
            [btnBookmark setEnabled:NO];
        } else{
            [btnBookmark setEnabled:YES];
            [btnBookmark setHidden:YES];
            [btnUnbookmark setHidden:NO];
        }
        
        [[FDownloadManager shared] prepareForDownloadingFiles];
        
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}




@end

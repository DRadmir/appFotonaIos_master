//
//  GEMainMenuCell.m
//  GibExplorer
//
//  Created by Dejan Krstevski on 2/26/14.
//  Copyright (c) 2014 Dejan Krstevski. All rights reserved.
//

#import "GEMainMenuCell.h"
#import "FMDatabase.h"
#import "FBookmarkViewController.h"
#import "FDownloadManager.h"
#import "HelperBookmark.h"
#import "FItemBookmark.h"
#import "UIView+Border.h"

@implementation GEMainMenuCell

@synthesize image;
@synthesize transparentView;
@synthesize titleLbl;
@synthesize bookmarkBtn;
@synthesize bookmarkRemoveBtn;

@synthesize parent;
@synthesize parentFotona;

@synthesize video;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //default size
        CGRect buttonFrame = CGRectMake(0, 270, 300, 30);
        CGRect buttonFrameRemove = CGRectMake(0, 270, 300, 30);
        CGRect imageFrame = CGRectMake(0, 90, 300, 167);
        CGRect textFrame = CGRectMake(0, 10, 300, 80);
        
        
        //size in video gallery. Image format 16:9
        if (frame.size.height == 320) {
            buttonFrame = CGRectMake(0, 270, 300, 30);
            buttonFrameRemove = CGRectMake(0, 270, 300, 30);
            imageFrame = CGRectMake(0, 90, 300, 167);
            textFrame = CGRectMake(0, 10, 300, 80);
        }
        
        self.bookmarkBtn=[[UIButton alloc] initWithFrame:buttonFrame];
        [self.bookmarkBtn setBackgroundColor:[UIColor whiteColor]];
        [self.bookmarkBtn setTitle:NSLocalizedString(@"BTNBOOKMARKADD", nil) forState:UIControlStateNormal];
        [self.bookmarkBtn setTitle:NSLocalizedString(@"BTNBOOKMARKPROCESSING", nil) forState:UIControlStateDisabled];
        [self.bookmarkBtn setTitleColor:[UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:1] forState:UIControlStateNormal];
        [self.bookmarkBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
        self.bookmarkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.bookmarkBtn addTarget:self
                             action:@selector(aMethod:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.bookmarkBtn];
        
        self.bookmarkRemoveBtn=[[UIButton alloc] initWithFrame:buttonFrame];
        [self.bookmarkRemoveBtn setBackgroundColor:[UIColor whiteColor]];
        [self.bookmarkRemoveBtn setTitle:NSLocalizedString(@"BTNBOOKMARKREMOVE", nil) forState:UIControlStateNormal];
        [self.bookmarkRemoveBtn setTitleColor:[UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:1] forState:UIControlStateNormal];
        [self.bookmarkRemoveBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
        self.bookmarkRemoveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.bookmarkRemoveBtn addTarget:self
                                   action:@selector(bMethod:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.bookmarkRemoveBtn];
        self.image=[[UIImageView alloc] initWithFrame:imageFrame];
        [self.image setContentMode:UIViewContentModeCenter];
        [self.contentView addSubview:self.image];
        
        self.titleLbl = [[UILabel alloc] initWithFrame:textFrame];
        [self.titleLbl setText:@"tmp"];
        
        
        [self.titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]];
        [self.titleLbl setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.titleLbl];
        
        
    }
    [self addBottomBorderWithColor:[UIColor lightGrayColor] andWidth:1];
    return self;
}

-(void)aMethod:(UIButton*)sender
{
    if ([APP_DELEGATE wifiOnlyConnection]) {
        [self bookmarkVideo];
    } else {
        UIActionSheet *av = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CHECKWIFIONLY", nil)] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", NSLocalizedString(@"CHECKWIFIONLYBTN", nil),nil];
        [av showInView:parentFotona.view];
    }
    
}

-(void)bMethod:(UIButton*)sender
{
    FMDatabase *database = [FMDatabase databaseWithPath:DB_PATH];
    [database open];
    NSString *usr = [FCommon getUser];
    [database executeUpdate:@"DELETE FROM UserBookmark WHERE documentID=? and username=? and typeID=?",video.itemID,usr,BOOKMARKVIDEO];
    
    FMResultSet *resultsBookmarked =  [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM UserBookmark where documentID=%@ AND typeID=%@",video.itemID,BOOKMARKVIDEO]];
    BOOL flag=NO;
    while([resultsBookmarked next]) {
        flag=YES;
    }
    if (!flag) {
        [database executeUpdate:@"UPDATE Media set isBookmark=? where mediaID=?",@"0",video.itemID];
        NSString *downloadFilename = [video path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:downloadFilename error:&error];
        
        NSArray *pathComp=[[video mediaImage] pathComponents];
        NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[[video mediaImage] lastPathComponent]];        [fileManager removeItemAtPath:pathTmp error:&error];
        
    }
    
    
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    [database close];
    video.bookmark = @"0";
    [self.bookmarkBtn setHidden:NO];
    [self.bookmarkRemoveBtn setHidden:YES];
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"REMOVEBOOKMARKS", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [parent setVideos];
    [parent.contentsVideoModeCollectionView reloadData];
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
        if ([HelperBookmark bookmarkMedia:video]) {
            [self.bookmarkBtn setEnabled:NO];
        } else{
            [self.bookmarkBtn setEnabled:YES];
            [self.bookmarkBtn setHidden:YES];
            [self.bookmarkRemoveBtn setHidden:NO];
        }
        
         [[FDownloadManager shared] prepareForDownloadingFiles];

    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTIONBOOKMARK", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

@end

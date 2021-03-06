//
//  FCaseGalleryView.m
//  fotona
//
//  Created by Janos on 14/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FCaseGalleryView.h"
#import "FDB.h"
#import "UIColor+Hex.h"
#import "HelperBookmark.h"
#import "FDownloadManager.h"

@implementation FCaseGalleryView

@synthesize imgAuthor;
@synthesize imgBackground;
@synthesize lblTitle;
@synthesize lblCaseType;
@synthesize lblAuthorName;
@synthesize lblDescription;

@synthesize btnDownloadAdd;
@synthesize btnFavoriteAdd;
@synthesize btnDownloadRemove;
@synthesize btnFavoriteRemove;

@synthesize containerView;

@synthesize caseToShow;
@synthesize item;
@synthesize parentIphone;
@synthesize parentIpad;
@synthesize index;
@synthesize enabled;

#pragma mark - Layout

-(void) setContentForCase:(FCase *)fcase{
    enabled = true;
    caseToShow = fcase;
    [lblTitle setText:[caseToShow title]];
    [lblAuthorName setText:[caseToShow name]];
    [lblDescription setText:[caseToShow introduction]];
    
    imgBackground.image = [UIImage imageNamed:[NSString stringWithFormat:@"fav_cell_bg%@.png",[caseToShow coverTypeID]]];
    
    switch ([[caseToShow coverTypeID] intValue]) {
        case 1:
            lblCaseType.text = @"   Dentistry";
            lblCaseType.backgroundColor = [UIColor colorWithRed:0.345 green:0.702 blue:0.824 alpha:1];
            break;
        case 2:
            lblCaseType.text = @"   Aesthetics";
            lblCaseType.backgroundColor = [UIColor colorWithRed:0.902 green:0.678 blue:0.424 alpha:1];
            break;
        case 3:
            lblCaseType.text = @"   Gynecology";
            lblCaseType.backgroundColor = [UIColor colorWithRed:0.875 green:0.325 blue:0.549 alpha:1];
            break;
        default:
            NSLog(@"Icarousel error, wrong type");
            break;
    }
    
    if(([FDB checkIfBookmarkedForDocumentID:[item itemID] andType:[item typeID]]) || ([fcase.coverflow intValue] == 1)){
        btnDownloadRemove.hidden = NO;
        btnDownloadAdd.hidden = YES;
    } else {
        btnDownloadRemove.hidden = YES;
        if ([ConnectionHelper connectedToInternet]) {
            [btnDownloadAdd setHidden:NO];
        } else {
            [btnDownloadAdd setHidden:YES];
        }
    }
    
    if([FDB checkIfFavoritesItem: [[item itemID] intValue] ofType:[item typeID]]){
        btnFavoriteRemove.hidden = NO;
        btnFavoriteAdd.hidden = YES;
    } else {
        btnFavoriteRemove.hidden = YES;
        btnFavoriteAdd.hidden = NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        imgAuthor.layer.cornerRadius = imgAuthor.frame.size.height /2;
        imgAuthor.layer.masksToBounds = YES;
        imgAuthor.layer.borderWidth = 0;
        [imgAuthor setContentMode:UIViewContentModeScaleAspectFill];
        imgAuthor.image = [FDB getAuthorImage:[caseToShow authorID]];
    });
    
    //if not accessible change alpha
    if ([[caseToShow bookmark] isEqualToString:@"0"] && [[caseToShow coverflow] isEqualToString:@"0"] && ![ConnectionHelper connectedToInternet]) {
        enabled = false;
        [imgAuthor setAlpha:DISABLEDCOLORALPHA];
        [imgBackground setAlpha:DISABLEDCOLORALPHA];
        [lblAuthorName setAlpha:DISABLEDCOLORALPHA];
        [lblTitle setAlpha:DISABLEDCOLORALPHA];
        [lblDescription setAlpha:DISABLEDCOLORALPHA];
        [lblCaseType setAlpha:DISABLEDCOLORALPHA];
    } else {
        enabled = true;
        [imgAuthor setAlpha:1];
        [imgBackground setAlpha:1];
        [lblAuthorName setAlpha:1];
        [lblTitle setAlpha:1];
        [lblDescription setAlpha:1];
        [lblCaseType setAlpha:1];
    }
    
    if ([FCommon isIpad]) {
         [containerView setBackgroundColor:[UIColor lightBackgroundColor]];
    } else {
        [containerView setBackgroundColor:[UIColor whiteColor]];
    }
}

#pragma mark - Buttons

- (IBAction)favoriteRemove:(id)sender {
    [FDB removeFromFavoritesItem:[[item itemID] intValue] ofType:[item typeID]];
    if (parentIphone != nil) {
        [parentIphone deleteRowAtIndex:index];
    } else {
        if (parentIpad != nil) {
            [parentIpad deleteRowAtIndex:index];
        }
    }
    btnFavoriteRemove.hidden = true;
    btnFavoriteAdd.hidden = false;
    
}

- (IBAction)favoriteAdd:(id)sender {
    [FDB addTooFavoritesItem:[[item itemID] intValue] ofType:[item typeID]];
    btnFavoriteRemove.hidden = false;
    btnFavoriteAdd.hidden = true;
}

- (IBAction)downloadRemove:(id)sender {
    [HelperBookmark removeBookmarkedCase:caseToShow];
    
    if ([ConnectionHelper connectedToInternet] && ([caseToShow.coverflow intValue] == 0)) {
        btnDownloadRemove.hidden = YES;
        [btnDownloadAdd setHidden:NO];
    } else {
        btnDownloadRemove.hidden = NO;
        [btnDownloadAdd setHidden:YES];
    }
}

- (IBAction)downloadAdd:(id)sender {
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"BOOKMARKING", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"BOOKMARKING", nil)]) {
        [HelperBookmark bookmarkCase:caseToShow];
        [APP_DELEGATE setBookmarkAll:YES];
        [[FDownloadManager shared] prepareForDownloadingFiles];
    }
}

@end

//
//  FCaseGalleryView.m
//  fotona
//
//  Created by Janos on 14/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FCaseGalleryView.h"
#import "FDB.h"

@implementation FCaseGalleryView

@synthesize imgAuthor;
@synthesize imgBackground;
@synthesize lblTitle;
@synthesize lblCaseType;
@synthesize lblAuthorName;
@synthesize lblDescription;

@synthesize btnDownloadAdd;
@synthesize btnFavoriteAdd;
@synthesize btnDownladRemove;
@synthesize btnFavoriteRemove;

@synthesize caseToShow;
@synthesize item;
@synthesize parentIphone;
@synthesize index;
@synthesize enabled;


-(void) setContentForCase:(FCase *)fcase{
    enabled = true;
    caseToShow = fcase;
    [lblTitle setText:[caseToShow title]];
    [lblAuthorName setText:[caseToShow name]];
    //todo dodat vse ostale podatke
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
    
    if([FDB checkIfBookmarkedForDocumentID:[item itemID] andType:[item typeID]]){
        btnDownladRemove.hidden = false;
        btnDownloadAdd.hidden = true;
    } else {
        btnDownladRemove.hidden = true;
        btnDownloadAdd.hidden = false;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        imgAuthor.layer.cornerRadius = imgAuthor.frame.size.height /2;
        imgAuthor.layer.masksToBounds = YES;
        imgAuthor.layer.borderWidth = 0;
        [imgAuthor setContentMode:UIViewContentModeScaleAspectFill];
        imgAuthor.image = [FDB getAuthorImage:[caseToShow authorID]];
    });
    
    //if not accessible change alpha
    if ([[caseToShow bookmark] isEqualToString:@"0"] && [[caseToShow coverflow] isEqualToString:@"0"] && ![APP_DELEGATE connectedToInternet]) {
        enabled = false;
        [imgAuthor setAlpha:DISABLEDCOLORALPHA];
        [imgBackground setAlpha:DISABLEDCOLORALPHA];
        [lblAuthorName setAlpha:DISABLEDCOLORALPHA];
        [lblTitle setAlpha:DISABLEDCOLORALPHA];
        [lblDescription setAlpha:DISABLEDCOLORALPHA];
        [lblCaseType setAlpha:DISABLEDCOLORALPHA];
        btnDownloadAdd.hidden = true;
    }
}

- (IBAction)favoriteRemove:(id)sender {
    [FDB removeFromFavoritesItem:[[item itemID] intValue] ofType:[item typeID]];
    if (parentIphone != nil) {
        [parentIphone deleteRowAtIndex:index];
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
    btnDownladRemove.hidden = true;
    btnDownloadAdd.hidden = false;
}

- (IBAction)downloadAdd:(id)sender {
    btnDownladRemove.hidden = false;
    btnDownloadAdd.hidden = true;
}

@end

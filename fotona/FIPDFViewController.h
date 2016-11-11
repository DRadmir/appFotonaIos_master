//
//  FIPDFViewController.h
//  fotona
//
//  Created by Janos on 10/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBaseView.h"

@interface FIPDFViewController : FIBaseView <QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIWebViewDelegate>

@property FMedia *pdfMedia;
@property (strong, nonatomic) IBOutlet UIWebView *pdfWebView;

-(void) openPdf:(FMedia *) pdf;

@end

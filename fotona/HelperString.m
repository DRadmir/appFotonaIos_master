//
//  HelperString.m
//  fotona
//
//  Created by Janos on 27/11/15.
//  Copyright © 2015 4egenus. All rights reserved.
//

#import "HelperString.h"

@implementation HelperString

+(NSString *)toHtmlEvent:(NSString *)text
{
    NSString *attributedText = [NSString stringWithFormat:@"<html><body><style>p{margin-top: 27px;margin-bottom: 27px; line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} td{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} li{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} ul{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} strong{ line-height:30px; font-weight:bold; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</body></html>", text];
    
    return attributedText;
}

+(NSString *)toHtmlEventIPhone:(NSString *)text
{
    NSString *attributedText = [NSString stringWithFormat:@"<html><body><style>p{margin-top: 27px;margin-bottom: 27px; line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} td{ line-height:25px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} li{ line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} ul{ line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} strong{ line-height:24px; font-weight:bold; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</body></html>", text];
    
    return attributedText;
}

+(NSString *)toHtml:(NSString *)text
{
    NSString *attributedText = [NSString stringWithFormat:@"<html><body><p><style>p{text-align: justify; margin-top: 27px;margin-bottom: 27px; line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} td{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} li{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} ul{ line-height:30px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} strong{ line-height:30px; font-weight:bold; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} em{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} u{ line-height:30px; font-size:1.05em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</p></body></html>", text];
    
    return attributedText;
}

+(NSString *)toHtmlIphone:(NSString *)text
{
    NSString *attributedText = [NSString stringWithFormat:@"<html><body><p><style>p{text-align: justify; margin-top: 27px;margin-bottom: 27px; line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} td{ line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} li{ line-height:24px; font-size:1.02em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} ul{ line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} strong{ line-height:24px; font-weight:bold; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} em{ line-height:24px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;} u{ line-height:30px; font-size:0.95em; font-family: 'HelveticaNeue-Light', Helvetica, Serif;}</style>%@</p></body></html>", text];
    
    return attributedText;
}

+(NSAttributedString *)toAttributedNews:(NSString *)text
{
    NSString * temp =@"<p>&nbsp;</p>";
    int startPosition = text.length;
    
    NSUInteger length = [text length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [text rangeOfString: temp options:0 range:range];
        if(range.location != NSNotFound)
        {
            startPosition = range.location;
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    if ((startPosition+temp.length)==text.length) {
        text = [text substringToIndex:startPosition];
    }
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat fontSize = 17;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        //if device is ipad
        paragraphStyle.lineSpacing = 10;
        paragraphStyle.paragraphSpacing=24;
        fontSize = 17;
        
    } else
    {
        //if device is iphone
        paragraphStyle.lineSpacing = 6;
        paragraphStyle.paragraphSpacing=20;
        fontSize = 15;
    }
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    
    NSDictionary *attrsDictionary = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
    return [[NSAttributedString alloc] initWithString:attrStr.string attributes:attrsDictionary];
}


+(NSAttributedString *)toAttributedCase:(NSString *)text
{
    NSString * temp =@"<p>&nbsp;</p>";
    int startPosition = text.length;
    
    NSUInteger length = [text length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [text rangeOfString: temp options:0 range:range];
        if(range.location != NSNotFound)
        {
            startPosition = range.location;
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    if ((startPosition+temp.length)==text.length) {
        text = [text substringToIndex:startPosition];
    }
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat fontSize = 17;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        //if device is ipad
        paragraphStyle.lineSpacing = 10;
        paragraphStyle.paragraphSpacing=24;
        fontSize = 17;
        
    } else
    {
        //if device is iphone
        paragraphStyle.lineSpacing = 10;
        paragraphStyle.paragraphSpacing=20;
        fontSize = 15;
    }
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    
    NSDictionary *attrsDictionary = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
    return [[NSAttributedString alloc] initWithString:attrStr.string attributes:attrsDictionary];
}


@end

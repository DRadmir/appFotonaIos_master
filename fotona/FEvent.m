//
//  FEvent.m
//  fotona
//
//  Created by Gost on 26/01/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#import "FEvent.h"
#import "FDownloadManager.h"

@implementation FEvent

@synthesize eventID;
@synthesize title;
@synthesize eventplace;
@synthesize text;
@synthesize eventdate;
@synthesize typeE;
@synthesize eventcategories;
@synthesize eventdateTo;
@synthesize eventImages;
@synthesize active;
@synthesize mobileFeatured;

//database
@synthesize eventcategoriesDB;
@synthesize eventImagesDB;
@synthesize activeDB;
@synthesize mobileFeaturedDB;

@synthesize bookmark;


-(id)init
{
    self=[super init];
    if (self) {
    }
    
    
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        
        [self setEventID:[[dic valueForKey:@"eventID"]  integerValue]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setEventplace:[dic valueForKey:@"description"]];
        [self setText:[dic valueForKey:@"text"]];
        [self setTypeE:[[dic valueForKey:@"type"] integerValue]];
        [self setEventdate:[dic valueForKey:@"date"]];
        [self setEventdateTo:[dic valueForKey:@"dateTo"]];
        
        NSString *temp = [dic valueForKey:@"images"];
        NSMutableArray *tempB = [temp componentsSeparatedByString:@","];
        NSMutableArray *tempA = [[NSMutableArray alloc]init];
//        if (![temp isEqualToString:@""]) {
//            for (int i=0; i<tempB.count; i++) {
//                //NSData *data = [[NSData alloc]initWithBase64EncodedString:[tempB objectAtIndex:i] options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                //UIImage *background = [UIImage imageWithData:data];
//                UIImage *img = [UIImage imageWithContentsOfFile: [tempB objectAtIndex:i]];
//                [tempA addObject:img];
//            }
//            
//        }
        if (![temp isEqualToString:@""])
            [self setEventImages:tempB];
        tempA = nil;
        temp = [dic valueForKey:@"categories"];
        tempA =  [[temp componentsSeparatedByString:@","] mutableCopy];
        [self setEventcategories:tempA];
        [self setActive:[[dic valueForKey:@"active"] boolValue]];
        [self setMobileFeatured:[[dic valueForKey:@"mobileFeatured"] boolValue]];
        [self setBookmark:[dic valueForKey:@"isBookmark"]];
    }
    
    
    return self;
}

-(id)initWithDictionaryDB:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        
        [self setEventID:[[dic valueForKey:@"eventID"]  integerValue]];
        [self setTitle:[dic valueForKey:@"title"]];
        [self setEventplace:[dic valueForKey:@"description"]];
        [self setText:[dic valueForKey:@"text"]];
        [self setEventdateTo:[dic valueForKey:@"dateTo"]];
        [self setTypeE:[[dic valueForKey:@"type"] integerValue]];
        [self setEventdate:[dic valueForKey:@"date"]];
        NSString *temp = @"";
        NSMutableArray * download = [NSMutableArray new];
        for (int i =0; i<[[dic valueForKey:@"images"] count]; i++) {
            if (i>0) {
                temp=[temp stringByAppendingString:@","];
            }
            
            //            NSString *url_Img_FULL = [NSString stringWithFormat:[[dic valueForKey:@"images"] objectAtIndex:i]];
            //            UIImage *background = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
            //            NSData *dataImage = [[NSData alloc] init];
            //            dataImage = UIImagePNGRepresentation(background);
            //            NSString *stringImage = [dataImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            //
            //            temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%@",stringImage]];
            
            NSString *url_Img_FULL = [[dic valueForKey:@"images"] objectAtIndex:i];
            NSArray *pathComp=[url_Img_FULL pathComponents];
            NSString *pathTmp = [[NSString stringWithFormat:@"%@%@/%@",docDir,@".Cases",[pathComp objectAtIndex:pathComp.count-2]] stringByAppendingPathComponent:[url_Img_FULL lastPathComponent]];
            
            temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%@",pathTmp]];
             [[APP_DELEGATE imagesToDownload] addObject:url_Img_FULL];
           // [download addObject:url_Img_FULL];
        }
        
        //[[FDownloadManager shared] downloadImages:download];
        
        [self setEventImagesDB:temp];
        NSString *temp2 = @"";
        for (int i =0; i<[[dic valueForKey:@"categories"] count]; i++) {
            if (i>0) {
                temp2 = [temp2 stringByAppendingString:@","];
            }
            temp2 =[temp2 stringByAppendingString:[[[dic valueForKey:@"categories"] objectAtIndex:i] stringValue]];
        }
        [self setEventcategoriesDB:temp2];
        [self setActiveDB:[NSString stringWithFormat:@"%hhd",[[dic valueForKey:@"active"] boolValue]]];
        [self setMobileFeaturedDB:[NSString stringWithFormat:@"%hhd",[[dic valueForKey:@"mobileFeatured"] boolValue]]];
        [self setBookmark:@"0"];
    }
    
    
    return self;
}

/*barve pik
 modra - dentestry
 orangna - aestewtichs
 roya - gyno
 yelena - surgery
 siva - all*/



- (NSString *)getDot{
    int c = [[[self eventcategories] objectAtIndex:0] integerValue];
    switch (c) {
        case 1:
            return @"event_dental_red.pdf";
            break;
            
        case 2:
            return @"event_aesthetics_red.pdf";
            break;
        case 3:
            return @"event_gyno_red.pdf";
            break;
        case 4:
            return @"event_surgery_red.pdf";
            break;
        default:
            return @"event_all_red.pdf";
            break;
    }
}

- (NSString *)getDot:(int) cat{
    switch (cat) {
        case 1:
            return @"blue.png";
            break;
            
        case 2:
            return @"orange.png";
            break;
        case 3:
            return @"pink.png";
            break;
        default:
            return @"green.png";
            break;
    }
}


@end

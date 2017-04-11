//
//  FNotificationManager.m
//  fotona
//
//  Created by Janos on 19/11/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import "FNotificationManager.h"
#import "AFNetworking.h"
#import "FHelperRequest.h"
#import "UIWindow+Fotona.h"
#import "FImage.h"
#import "MBProgressHUD.h"


@implementation FNotificationManager
//        if (notificationType == 1) {
//            [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openFotonaTab"];
//        } else {
//            [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openCaseTab"];
//        }
+(void) openNotification:(NSString *)url ofType:(int)type{
    switch (type) {
        case NOTIFICATIONMEDIA:
            [self openMediaTest:url];
            break;
        case NOTIFICATIONCASE:
            [self openCase:url];
            break;
        default:
            break;
    }
}


+(void) openCase:(NSString*) url
{
    if([ConnectionHelper connectedToInternet]){
        UIViewController *topController = [[APP_DELEGATE window] visibleViewController];
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:[topController view]];

        if ([topController view] != nil) {
            [[topController view] addSubview:hud];
            hud.labelText = @"Opening case";
            [hud show:YES];
        }

        NSMutableURLRequest *request = [FHelperRequest requestToGetCaseFromNotification:url ];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
            NSArray *c = [dic objectForKey:@"d"];
         
            FCase *caseObj=[[FCase alloc] initWithDictionaryFromServer:c[0]];
            NSMutableArray *imgs = [[NSMutableArray alloc] init];
            for (NSDictionary *imgLink in [caseObj images]) {
                FImage * img = [[FImage alloc] initWithDictionaryFromServer:imgLink];
                
                [imgs addObject:img];
            }
            [caseObj setImages:imgs];
            NSMutableArray *videos = [[NSMutableArray alloc] init];
            for (NSDictionary *videoLink in [caseObj video]) {
                FMedia * videoTemp = [[FMedia alloc] initWithDictionaryFromServer:videoLink];
                [videos addObject:videoTemp];
            }
            [caseObj setVideo:videos];
          
            [hud removeFromSuperview];
            
            if([FCommon isIpad]){
                UINavigationController *tempC = [[[topController.tabBarController viewControllers] objectAtIndex:3] centerController];
                if (tempC == nil) {
                    [FCommon setCase:caseObj];
                    [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openCaseTab"];
                } else {
                    [(FCasebookViewController *)[tempC topViewController] setCurrentCase:caseObj];
                    [(FCasebookViewController *)[tempC topViewController] setFlagCarousel:YES];
                    if ([topController isKindOfClass:[FCasebookViewController class]]) {
                        [(FCasebookViewController*)topController openCase];
                    }else{
                        [topController.tabBarController setSelectedIndex:3];
                    }
                }
                
                
            } else {
                [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openCaseTab"];
                [FCase openCase:caseObj];

            }
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Cases failed %@",error.localizedDescription);
                                            [hud removeFromSuperview];
                                         }];
        [operation start];
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}


+(void) openMediaTest:(NSString*) url
{
    
    if([ConnectionHelper connectedToInternet]){
        UIViewController *topController = [[APP_DELEGATE window] visibleViewController];
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:[topController view]];
        
        if ([topController view] != nil) {
            [[topController view] addSubview:hud];
            hud.labelText = @"Opening media";
            [hud show:YES];
        }
        
        NSMutableURLRequest *request = [FHelperRequest requestToGetCaseFromNotification:url ];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *c = [dic objectForKey:@"d"];
            
            FMedia *media=[[FMedia alloc] initWithDictionaryFromServer:c];
            
            [hud removeFromSuperview];
            
            if ([FCommon isIpad]) {

                
                UINavigationController *tempC = [[[topController.tabBarController viewControllers] objectAtIndex:2] centerController];
                if (tempC == nil) {
                    [FCommon setMedia:media];
                    [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openFotonaTab"];
                } else {
                [(FFotonaViewController *)[tempC topViewController] setOpenGal:YES forMedia:media];
                if (tempC.tabBarController.selectedIndex == 2) {
                   
                   [(FFotonaViewController *)[tempC topViewController] openMediaFromSearch:media];
                } else {
                    
                   [topController.tabBarController setSelectedIndex:2];
                }
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"openFotonaTab"];
                [FMedia openMedia:media];
            }
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Cases failed %@",error.localizedDescription);
                                             [hud removeFromSuperview];
                                         }];
        [operation start];
    } else {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"NOCONNECTION", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

}


+(void) setActiveNotificationa:(NSString *)active{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:active forKey:@"notificationEnabled"];
    [defaults synchronize];
}

+(NSString *)getActiveNotification{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *active = [defaults valueForKey:@"notificationEnabled"];
    return active;
}


@end

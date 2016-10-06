//
//  FLogin.m
//  fotona
//
//  Created by Janos on 16/12/15.
//  Copyright © 2015 4egenus. All rights reserved.
//


#import "FLogin.h"
#import "MBProgressHUD.h"
#import "FAppDelegate.h"
#import "ConnectionHelper.h"
#import "FDownloadManager.h"
#import "SFHFKeychainUtils.h"
#import "FMainViewController.h"
#import "FMainViewController_iPad.h"
#import "AFNetworking.h"
#import "Logger.h"

@implementation FLogin

@synthesize parentiPad;
@synthesize parentiPhone;
@synthesize parent;

@synthesize logintype;
@synthesize letToLogin;


UIButton *tmp;

-(void)setDefaultParent:(FMainViewController_iPad * )piPad andiPhone:(FMainViewController *)piPhone
{
    if(piPad != nil)
    {
        parentiPad = piPad;
        parent = piPad;
    } else
    {
        parentiPhone = piPhone;
        parent = piPhone;
    }
    
}

-(void)autoLogin
{
    logintype = 3;
    if([ConnectionHelper isConnected])
    {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:parent.view];
        [parent.view addSubview:hud];
        hud.labelText = @"Updating content";
        [hud show:YES];
        
        [self setDelegate];
    } else{
        logintype = 0;
        NSString *usrName=[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
        if(parentiPad != nil)
        {
            if ([usrName isEqualToString:@"guest"]) {
                [self guest:parentiPad.loginGuestBtn];
            }else{
                [parentiPad.username setText:usrName];
                [parentiPad.password setText:[SFHFKeychainUtils getPasswordForUsername:usrName andServiceName:@"fotona" error:nil]];
                [self login:parentiPad.loginBtn];
            }
        } else
        {
            if ([usrName isEqualToString:@"guest"]) {
                [self guest:parentiPhone.btnGuest];
            }else{
                [parentiPhone.textFieldUser setText:usrName];
                [parentiPhone.textFieldPass setText:[SFHFKeychainUtils getPasswordForUsername:usrName andServiceName:@"fotona" error:nil]];
                [self loginUpdated];
            }
            
        }
        
    }
    
}

-(void)guest:(id)sender
{
    logintype = 1;
    if([ConnectionHelper isConnected])
    {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:parent.view];
        [parent.view addSubview:hud];
        hud.labelText = @"Updating content";
        [hud show:YES];
        [self setDelegate];
        
    } else{
        logintype = 0;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"] isEqualToString:@"updated"]) {
            if (letToLogin==0) {
                FUser *guest=[[FUser alloc] init];
                [guest setUserType:@"0"];
                [guest setUsername:@"guest"];
                [APP_DELEGATE setCurrentLogedInUser:guest];
                [APP_DELEGATE setUserFolderPath:[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"guest"]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:[APP_DELEGATE userFolderPath]]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:[APP_DELEGATE userFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
                    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[APP_DELEGATE userFolderPath]]];
                }
                NSArray *arrDir=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
                for (NSString *s in arrDir) {
                    if (![[s substringToIndex:1] isEqualToString:@"."]) {
                        [self renameFolder:[NSString stringWithFormat:@"%@%@",docDir,s]];
                    }
                }
                [self showUserFolder:@".guest"];
            }else{
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Some data might missing" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login anyway", nil];
                [av setTag:1];
                [av show];
            }
        }else{
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"For first login you need to be connected to internet." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [av setTag:1];
            [av show];
        }
        
        
    }
    
}

-(void)login:(id)sender
{
    logintype = 2;
    tmp=(UIButton *)sender;
    if([ConnectionHelper isConnected])
    {
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:parent.view];
        [parent.view addSubview:hud];
        hud.labelText = @"Updating content";
        [hud show:YES];
        [self setDelegate];
        
    } else{
        logintype = 0;
        [tmp setEnabled:NO];
        if([ConnectionHelper isConnected])
        {
            [self loginOnFotona:tmp];
        }else{
            [self loginUserOffline];
            [tmp setEnabled:YES];
        }
        
    }
    
}


-(IBAction)loginOnFotona:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"Username"]) {
        
    } else {
        
    }

    NSString *usrName=@"";
    NSString *password=@"";
    if(parentiPad != nil)
    {
        usrName = parentiPad.username.text;
        password = parentiPad.password.text;
    } else
    {
        usrName = parentiPhone.textFieldUser.text;
        password = parentiPhone.textFieldPass.text;
    }
    
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fotona.com/inc/verzija2/ajax/"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *user=[usrName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *postString = [NSString stringWithFormat:@"cmd=login&u=%@&p=%@",user,password];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"]){
        [MBProgressHUD hideAllHUDsForView:parent.view animated:YES];
        MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:parent.view];
        [parent.view addSubview:hud];
        hud.labelText = @"Login user";
        [hud show:YES];
       
        
    }
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // I get response as XML here and parse it in a function
        //        NSLog(@"%@",[operation responseString]);
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableLeaves error:nil];
        if (![[dic valueForKey:@"msg"] isEqualToString:@"Success"]) {
            
            ////////////////////////////////////////////////////////
            
            FUser *usr=[[FUser alloc] init];
            [usr setUsername:usrName];
            [SFHFKeychainUtils storeUsername:usrName andPassword:@"" forServiceName:@"fotona" updateExisting:YES error:nil];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"autoLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //TODO: Brisanje uporabnika iz baze [FUser addUserInDB:usr];
            //TODO: Pogledat kako preprečt autologin - kaj je pogoj da izvede autologin
            [FUser deleteUserInDB:usr];
            [FUser checkIfUserExistsInDB:usr];
            //////////////////////////////////////////////////////
            
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Wrong username or password!" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
            [alertView show];
            if(parentiPad != nil)
            {
                [parentiPad showLoginForm];
            } else
            {
                [parentiPhone showLoginForm];
            }
            
        }
        else if([[dic valueForKey:@"msg"] isEqualToString:@"Success"]){
            
 
            
            FUser *usr=[[FUser alloc] initWithDictionary:[[dic objectForKey:@"values"] objectAtIndex:0]];
            [usr setUsername:@"test"];
            [SFHFKeychainUtils storeUsername:usr.username andPassword:password forServiceName:@"fotona" updateExisting:YES error:nil];
            [[NSUserDefaults standardUserDefaults] setValue:usr.username forKey:@"autoLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [usr setPassword:[NSString stringWithFormat:@"%lu",(unsigned long)password.hash]];
            [FUser addUserInDB:usr];
            [APP_DELEGATE setCurrentLogedInUser:usr];
            [APP_DELEGATE setUserFolderPath:[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),usr.username]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[APP_DELEGATE userFolderPath]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[APP_DELEGATE userFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
                [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[APP_DELEGATE userFolderPath]]];
            }
            NSArray *arrDir=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
            for (NSString *s in arrDir) {
                if (![[s substringToIndex:1] isEqualToString:@"."]) {
                    [self renameFolder:[NSString stringWithFormat:@"%@%@",docDir,s]];
                }
            }
            
            //set last online login
            NSDate *today=[NSDate dateWithTimeIntervalSinceNow:0];
            [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"lastOnlineLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setValue:usr.username forKey:@"autoLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showUserFolder:[NSString stringWithFormat:@".%@",usr.username]];
            if(parentiPad != nil)
            {
                [parentiPad showFeatured];
            } else
            {
                [parentiPhone showFeatured];
            }
        }
        
        
        
        [sender setEnabled:YES];
        //        [SVProgressHUD dismiss];
        [MBProgressHUD hideAllHUDsForView:parent.view animated:YES];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"failed %@",error.localizedDescription);
                                         UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Connection problem" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
                                         [alertView show];
                                         [sender setEnabled:YES];
                                         [MBProgressHUD hideAllHUDsForView:parent.view animated:YES];
                                         if(parentiPad != nil)
                                         {
                                             [parentiPad showLoginForm];
                                         } else
                                         {
                                             [parentiPhone showLoginForm];
                                         }
                                         
                                     }];
    
    [operation start];
}

-(void)loginUserOffline
{
    NSString *usrName=@"";
    NSString *password=@"";
    if(parentiPad != nil)
    {
        usrName = parentiPad.username.text;
        password = parentiPad.password.text;
    } else
    {
        usrName = parentiPhone.textFieldUser.text;
        password = parentiPhone.textFieldPass.text;
    }
    
    NSDate *lastOnlineLogin=[[NSUserDefaults standardUserDefaults] valueForKey:@"lastOnlineLogin"];
    if (lastOnlineLogin) {
        NSString *lastLoginString=[APP_DELEGATE differenceBetweenDate:[NSDate dateWithTimeIntervalSinceNow:0] and:lastOnlineLogin];
        int days=[[[lastLoginString componentsSeparatedByString:@","] objectAtIndex:1] intValue];
        if (days<=7) {
            FUser *localUser=[FUser getUser:usrName];
            if (localUser) {
                if ([usrName isEqualToString:localUser.username] && [password isEqualToString:[SFHFKeychainUtils getPasswordForUsername:localUser.username andServiceName:@"fotona" error:nil]]) {
                    [APP_DELEGATE setCurrentLogedInUser:localUser];
                    [APP_DELEGATE setUserFolderPath:[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),localUser.username]];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:[APP_DELEGATE userFolderPath]]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:[APP_DELEGATE userFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
                        [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[APP_DELEGATE userFolderPath]]];
                    }
                    NSArray *arrDir=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
                    for (NSString *s in arrDir) {
                        if (![[s substringToIndex:1] isEqualToString:@"."]) {
                            [self renameFolder:[NSString stringWithFormat:@"%@%@",docDir,s]];
                        }
                    }
                    [self showUserFolder:[NSString stringWithFormat:@".%@",localUser.username]];
                    if(parentiPad != nil)
                    {
                        [parentiPad showFeatured];
                    } else
                    {
                        [parentiPhone showFeatured];
                    }
                }else{
                    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Wrong username or password!" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
                    [alertView show];
                }
            }else{
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Wrong username or password!" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else
        {
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"You have to login online to continue using this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }else
    {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"For first login you need to be connected to internet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)updateProcess{
    /*
     1-guest login
     2-user login
     3-auto login
     */
    if (logintype == 1) {
        [self guestLogin];
    } else if (logintype == 2) {
        [self loginUpdated];
    } else if (logintype == 3) {
        [self autoLoginUpdated];
    }
    
}

-(void)guestLogin{
    logintype = 0;
    if (letToLogin==0)
    {
        FUser *guest=[[FUser alloc] init];
        [guest setUserType:@"0"];
        [guest setUsername:@"guest"];
        [APP_DELEGATE setCurrentLogedInUser:guest];
        [APP_DELEGATE setUserFolderPath:[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"guest"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[APP_DELEGATE userFolderPath]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[APP_DELEGATE userFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
            [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[APP_DELEGATE userFolderPath]]];
        }
        [[NSUserDefaults standardUserDefaults] setValue:guest.username forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *arrDir=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
        for (NSString *s in arrDir)
        {
            if (![[s substringToIndex:1] isEqualToString:@"."])
            {
                [self renameFolder:[NSString stringWithFormat:@"%@%@",docDir,s]];
            }
        }
        [self showUserFolder:@".guest"];
        [[NSUserDefaults standardUserDefaults] setValue:guest.username forKey:@"autoLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(parentiPad != nil)
        {
            [parentiPad showFeatured];
        } else
        {
            [parentiPhone showFeatured];
        }
    }else{
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"" message:@"Some data might missing" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login anyway", nil];
        [av setTag:1];
        [av show];
    }
}

-(void)loginUpdated{
    logintype = 0;
    if([ConnectionHelper isConnected])
    {
        [self loginOnFotona:tmp];
    }else{
        [self loginUserOffline];
        [tmp setEnabled:YES];
    }
}

-(void)autoLoginUpdated
{
    logintype = 0;
    NSString *usrName=[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"];
    if ([usrName isEqualToString:@"guest"]) {
        [self guestLogin];
    }else{
        
        if(parentiPad != nil)
        {
            if ([usrName isEqualToString:@"guest"]) {
                [self guest:parentiPad.loginGuestBtn];
            }else{
                [parentiPad.username setText:usrName];
                [parentiPad.password setText:[SFHFKeychainUtils getPasswordForUsername:usrName andServiceName:@"fotona" error:nil]];
                [self loginUpdated];
            }
        } else
        {
            if ([usrName isEqualToString:@"guest"]) {
                [self guest:parentiPhone.btnGuest];
            }else{
                [parentiPhone.textFieldUser setText:usrName];
                [parentiPhone.textFieldPass setText:[SFHFKeychainUtils getPasswordForUsername:usrName andServiceName:@"fotona" error:nil]];
                [self loginUpdated];
            }
        }
    }
}

-(void) setDelegate
{
    if (![APP_DELEGATE updateInProgress]) {
        [APP_DELEGATE setUpdateInProgress:YES];
        FUpdateContent *updateContent = [FUpdateContent shared];
        updateContent.updateDelegate = self;
        if (parentiPad != nil) {
            [FDownloadManager shared].updateDelegate = self;
            [updateContent updateContent:parentiPad];
        } else{
            [FDownloadManager shared].updateDelegate = self;
            [updateContent updateContent:parentiPhone];
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0) {
        if (buttonIndex==1) {
            MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:parent.view];
            [parent.view addSubview:hud];
            hud.labelText = @"Updating content";
            [hud show:YES];
            if (parentiPad != nil) {
                [FDownloadManager shared].updateDelegate = parentiPad;
            } else{
                [FDownloadManager shared].updateDelegate = parentiPhone;
            }
            //[[FUpdateContent shared] updateContent:self];
            
            letToLogin=0;
        }else{
            if (buttonIndex==2) {
                [self displayComposerSheet];
            }else{
                letToLogin=1;
            }
        }
    }else if (alertView.tag==1) {
        if (buttonIndex==1) {
            FUser *guest=[[FUser alloc] init];
            [guest setUserType:@"0"];
            [guest setUsername:@"guest"];
            [APP_DELEGATE setCurrentLogedInUser:guest];
            if(parentiPad != nil)
            {
                [parentiPad showFeatured];
            } else
            {
                [parentiPhone showFeatured];
            }
        }
        
    }
}

#pragma mark - UserFolder

-(void)showUserFolder:(NSString *)userFolderPath
{
    NSString *oldDirectoryPath = [NSString stringWithFormat:@"%@%@",docDir,userFolderPath];
    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];
    NSString *newDirectoryPath = [[oldDirectoryPath stringByDeletingLastPathComponent]stringByAppendingPathComponent:[userFolderPath substringFromIndex:1]];
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:newDirectoryPath]];
    
    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
    {
        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        
        if (error) {
            // handle error
        }
        
    }
}
-(void)renameFolder:(NSString *)folderPath
{
    NSString *oldDirectoryPath = folderPath;
    
    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];
    
    NSString *newDirectoryPath = [[oldDirectoryPath stringByDeletingLastPathComponent]stringByAppendingPathComponent:[NSString stringWithFormat:@".%@",[folderPath lastPathComponent]]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    [APP_DELEGATE addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:newDirectoryPath]];
    
    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
    {
        
        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        if (error) {
            // handle error
        }
    }
    [[NSFileManager defaultManager] removeItemAtPath:oldDirectoryPath error:nil];
}

#pragma mark - Meil

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    if(parentiPad != nil)
    {
        [parentiPad dismissModalViewControllerAnimated:YES];
    } else
    {
        [parentiPhone dismissModalViewControllerAnimated:YES];
    }
    
}

-(void)displayComposerSheet
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"log.txt"];
    NSLog(@"%@",[Logger getLog]);
    [[Logger getLog] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Check error log"];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"development@4egenus.com"];
    // NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    // NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
    
    [picker setToRecipients:toRecipients];
    // [picker setCcRecipients:ccRecipients];
    // [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    [picker addAttachmentData:myData mimeType:@"text/html" fileName:filePath];
    
    // Fill out the email body text
    NSString *emailBody = @"error log";
    [picker setMessageBody:emailBody isHTML:NO];
    if(parentiPad != nil)
    {
        [parentiPad presentModalViewController:picker animated:YES];
    } else
    {
        [parentiPhone presentModalViewController:picker animated:YES];
    }
}




@end

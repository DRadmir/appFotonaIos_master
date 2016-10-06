//
//  FFolderViewController.m
//  fotona
//
//  Created by Dejan Krstevski on 4/7/14.
//  Copyright (c) 2014 4egenus. All rights reserved.
//

#import "FFolderViewController.h"
#import "FEventViewController.h"


@interface FFolderViewController ()

@end

@implementation FFolderViewController
@synthesize folderContent;
@synthesize subFolder;
@synthesize filesToAdd;
@synthesize iconsForDocs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    iconsForDocs=[[NSMutableDictionary alloc] init];
    [iconsForDocs setValue:@"app_03" forKey:@"txt"];
    [iconsForDocs setValue:@"app_03" forKey:@"doc"];
    [iconsForDocs setValue:@"app_03" forKey:@"docx"];
    [iconsForDocs setValue:@"app_06" forKey:@"xls"];
    [iconsForDocs setValue:@"app_06" forKey:@"xlsx"];
    [iconsForDocs setValue:@"app_08" forKey:@"pdf"];
    [iconsForDocs setValue:@"app_08" forKey:@"ppt"];
    [iconsForDocs setValue:@"app_08" forKey:@"pptx"];
    [iconsForDocs setValue:@"app_10" forKey:@"other"];
    [iconsForDocs setValue:@"app_10" forKey:@"png"];
    [iconsForDocs setValue:@"app_10" forKey:@"jpg"];
    [iconsForDocs setValue:@"app_13" forKey:@"flv"];
    [iconsForDocs setValue:@"app_13" forKey:@"mp4"];
    [iconsForDocs setValue:@"app_16" forKey:@"mp3"];
    [iconsForDocs setValue:@"app_18" forKey:@"attach"];
    
    [folderTitle setText:subFolder];
    hasNewFiles=NO;
    filesToAdd=[[NSMutableArray alloc] init];
    NSArray *arr=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
    for (NSString *str in arr) {
//        NSLog(@"SSSS %@",str);
        if (![[str substringToIndex:1] isEqualToString:@"."] && ![str isEqualToString:[[APP_DELEGATE currentLogedInUser] username]]  )
        {
            hasNewFiles=YES;
            [filesToAdd addObject:str];
            NSLog(@"ima novi %@",str);
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
//    [[self.navigationController navigationBar] setHidden:NO];
}

#pragma mark TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (hasNewFiles) {
        return 2;
    }
    return 1;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (hasNewFiles) {
        if (section==1) {
            return [filesToAdd count];
        }
    }
    return [folderContent count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (hasNewFiles) {
        if (section==1) {
            return @"New files";
        }
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    UIImageView *iconImg=[[UIImageView alloc] initWithFrame:CGRectMake(60, 10, 10, 10)];
    UILabel *textLbl=[[UILabel alloc] initWithFrame:CGRectMake(75, 5, table.frame.size.width-350, 20)];
    [cell addSubview:iconImg];
    [textLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:textLbl];
    if (hasNewFiles) {
        if (indexPath.section==1) {
            NSString *keyForIcon=[[[filesToAdd objectAtIndex:indexPath.row] componentsSeparatedByString:@"."] objectAtIndex:1];
            NSString *iconName=@"";
            if (keyForIcon) {
                iconName=[iconsForDocs objectForKey:keyForIcon];
            }else
            {
                iconsForDocs=[iconsForDocs objectForKey:@"other"];
            }
            [iconImg setImage:[UIImage imageNamed:iconName]];
        
            [iconImg setContentMode:UIViewContentModeScaleAspectFit];
            [textLbl setText:[filesToAdd objectAtIndex:indexPath.row]];
            [textLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        }
        else
        {
            NSString *keyForIcon=[[[folderContent objectAtIndex:indexPath.row] componentsSeparatedByString:@"."] objectAtIndex:1];
            NSString *iconName=@"";
            if (keyForIcon) {
                iconName=[iconsForDocs objectForKey:keyForIcon];
            }else
            {
                iconsForDocs=[iconsForDocs objectForKey:@"other"];
            }
            [iconImg setImage:[UIImage imageNamed:iconName]];
            [iconImg setContentMode:UIViewContentModeScaleAspectFit];
            [textLbl setText:[folderContent objectAtIndex:indexPath.row]];
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
            [btn setFrame:CGRectMake(tableView.frame.size.width-150, 0, 100, 30)];
            [btn setTitle:@"Delete file" forState:UIControlStateNormal];
            [[btn titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [btn setTag:indexPath.row];
            [btn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
        }
    }else
    {
        NSString *iconName=@"";
        if ([[[folderContent objectAtIndex:indexPath.row] componentsSeparatedByString:@"."] count]>1) {
            NSString *keyForIcon=[[[folderContent objectAtIndex:indexPath.row] componentsSeparatedByString:@"."] objectAtIndex:1];
            
            if (keyForIcon) {
                iconName=[iconsForDocs objectForKey:keyForIcon];
            }else
            {
                iconsForDocs=[iconsForDocs objectForKey:@"other"];
            }
        }
        
        [iconImg setImage:[UIImage imageNamed:iconName]];
        [iconImg setContentMode:UIViewContentModeScaleAspectFit];
        [textLbl setText:[folderContent objectAtIndex:indexPath.row]];
        [textLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(tableView.frame.size.width-150, 0, 100, 30)];
        [btn setTitle:@"Delete file" forState:UIControlStateNormal];
        [[btn titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTag:indexPath.row];
        [btn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FEventViewController *paren=(FEventViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    if ([paren isEditing]) {
        
        
    }else
    {
        if (hasNewFiles) {
            if (indexPath.section==1) {
                UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Add file" message:[NSString stringWithFormat:@"Add %@ in %@ folder?",[filesToAdd objectAtIndex:indexPath.row],subFolder] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                indexForFileToAdd=indexPath.row;
                [av setTag:-1];
                [av show];
            }
            else{
                QLPreviewController *previewController = [[QLPreviewController alloc] init];
                previewController.dataSource = self;
                previewController.delegate = self;
                
                // start previewing the document at the current section index
                previewController.currentPreviewItemIndex = indexPath.row;
                [self  presentViewController:previewController animated:YES completion:nil];
            }
        }else
        {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.delegate = self;
            // start previewing the document at the current section index
            previewController.currentPreviewItemIndex = indexPath.row;
            
            [self  presentViewController:previewController animated:YES completion:nil];
        }
    }
}

-(IBAction)deleteFile:(id)sender
{
    NSInteger tag=[(UIButton*)sender tag];
    NSLog(@"delete %@",[folderContent objectAtIndex:tag]);
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Delete file" message:[NSString stringWithFormat:@"Are you sure that you want to delete %@?",[folderContent objectAtIndex:tag]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [av setTag:tag];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag=[alertView tag];
    if (tag==-1) {
        if (buttonIndex==1) {
            NSLog(@"Copy file");
            NSString *fileName=[filesToAdd objectAtIndex:indexForFileToAdd];
            [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@%@",docDir,fileName] toPath:[NSString stringWithFormat:@"%@/%@/%@",[APP_DELEGATE userFolderPath],subFolder,fileName] error:nil];
            [filesToAdd removeObjectAtIndex:indexForFileToAdd];
            if (filesToAdd.count==0) {
                hasNewFiles=NO;
            }
            [folderContent addObject:fileName];
            [table reloadData];
        }
    }else{
        if (buttonIndex==1) {
            NSLog(@"delete");
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@",[APP_DELEGATE userFolderPath],subFolder,[folderContent objectAtIndex:tag]] error:nil];
            [folderContent removeObjectAtIndex:tag];
            [table reloadData];
        }
    }
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 0;
    
    NSIndexPath *selectedIndexPath = [table indexPathForSelectedRow];
    if (selectedIndexPath.section == 0)
        numToPreview = [folderContent count];
    else
        numToPreview = self.folderContent.count;
    
    return numToPreview;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    
    NSIndexPath *selectedIndexPath = [table indexPathForSelectedRow];
    if (selectedIndexPath.section == 0)
    {
        fileURL = [NSURL fileURLWithPath:[[NSString stringWithFormat:@"%@/%@",[APP_DELEGATE userFolderPath],subFolder] stringByAppendingPathComponent:[folderContent objectAtIndex:idx]]];
    }
    else
    {
        fileURL = [self.folderContent objectAtIndex:idx];
    }
    
    return fileURL;
}


-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [APP_DELEGATE setCurrentOrientation:1];
    }else
    {
        [APP_DELEGATE setCurrentOrientation:0];
    }
    [table reloadData];
}



@end

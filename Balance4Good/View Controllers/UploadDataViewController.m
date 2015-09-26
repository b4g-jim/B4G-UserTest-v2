//
//  UploadDataViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "UploadDataViewController.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import "TestDetails.h"
#import "UploadDataSuccessViewController.h"

@interface UploadDataViewController ()

@end

@implementation UploadDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [lblFilesToUpload setText:[self getFilesToUpload]];
    [lblFilesToUpload setNumberOfLines:0];
    [lblFilesToUpload sizeToFit];
}

-(NSString*)getFilesToUpload
{
    NSMutableString *files = [NSMutableString string];
    
    NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Data_Folder error:nil];
    
    [files appendFormat:@"%d Files to upload:\n",allFiles.count];
    
    for(id fileName in allFiles)
    if(![fileName isEqualToString:@".DS_Store"])
    {
        [files appendString:fileName];
        [files appendString:@"\n"];
    }

    return files;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)uploadData:(UIButton *)sender
{
    //success array to store the files uploaded successfully while failure array to store the files that failed to upload
    success = [NSMutableArray array];
    failure = [NSMutableArray array];
    
    //The strategy is to upload files one and by and keep record of the successful and failed ones.
    //Successful ones will be deleted once the upload is complete
 
    alertView = [[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Uploading. Please wait..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [alertView show];
    
    [self uploadFile];
}

- (IBAction)cancel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadFile
{
    //1. Get One File from data folder one by one (we keep currentFileIndex)
    //2. Check if it is .DS_Store. If yes, fetch the next one.
    //3. Upload the file to AWS
    //4. Wait for Upload to Complete
    //5. After Upload, call uploadFile again
    //6. Check if all the files have already been uploaded. If no, start from 1 again
    //7. If all files have been uploaded, delete those files that are uploaded successfully.
    
    NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Data_Folder error:nil];
    
    if(currentFileIndex >= [allFiles count])
    {
        [self DeleteAllSuccessfulFiles];
        [self performSelectorOnMainThread:@selector(uploadFinished) withObject:nil waitUntilDone:YES];
     
        return;
    }
    
    id fileName = [allFiles objectAtIndex:currentFileIndex];
    if([fileName isEqualToString:@".DS_Store"])
    {
        currentFileIndex++;
        fileName = [allFiles objectAtIndex:currentFileIndex];
    }
    
    NSString *singleFilePath = [Data_Folder stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:[Data_Folder stringByAppendingPathComponent:fileName]];
    
    NSString *data = [NSString stringWithContentsOfFile:singleFilePath
                                               encoding:NSUTF8StringEncoding
                                                  error:NULL];
    
    unsigned long fileSize = [data length];
    
    [self uploadFileWithURL:fileURL fileSize:fileSize inBucket:[[NSUserDefaults standardUserDefaults] objectForKey:@"bucket_name"] asfileName:fileName];
}

//Called when upload is finished. If failure count is equal to 0, it shows upload successful screen else it shows upload failure screen

-(void)uploadFinished
{
    [alertView dismissWithClickedButtonIndex:1 animated:YES];

    if([failure count]== 0)
        [self performSegueWithIdentifier:@"uploadSuccessful" sender:nil];
    else
        [self performSegueWithIdentifier:@"uploadFailure" sender:nil];
    
    [failure removeAllObjects];
    [success removeAllObjects];
}

//Delete the successfully uploaded files
-(void)DeleteAllSuccessfulFiles
{
    NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Data_Folder error:nil];
    
    for(int i=0;i<success.count;i++)
    {
        id fileName = [allFiles objectAtIndex:[[success objectAtIndex:i] intValue]];
        NSString *singleFilePath = [Data_Folder stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] removeItemAtPath:singleFilePath error:nil];
    }
    
}

#pragma mark - AWS Upload
//Upload file to AWS
-(void)uploadFileWithURL:(NSURL*)fileURL fileSize:(unsigned long)fileSize inBucket:(NSString*)bucket asfileName:(NSString*)fileName
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = bucket;
    uploadRequest.key = fileName;
    uploadRequest.body = fileURL;
    
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLong:fileSize];
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task)
     {
         if(task.error)
         {
             NSLog(@"Error");
             //if file upload filed, add its index to failure array
             [failure addObject:[NSNumber numberWithInt:currentFileIndex]];
         }
         else
         {
             NSLog(@"Success");
             //1. if file upload filed, add its index to success array
             //2. increment currentFileIndex
             //3. call uploadFile
             
             [success addObject:[NSNumber numberWithInt:currentFileIndex]];
             
             currentFileIndex++;
             [self uploadFile];
             
         }
         return nil;
     }];
    
}


 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//  Get the new view controller using [segue destinationViewController].
//  Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[UploadDataSuccessViewController class]])
    {
        UploadDataSuccessViewController *uploadSuccessful = [segue destinationViewController];
        uploadSuccessful.files_uploaded = [success count];
    }
 }




@end

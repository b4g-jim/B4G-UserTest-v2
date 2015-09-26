//
//  WelcomeViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TestDetails.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Do any additional setup after loading the view.
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
    NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Data_Folder error:nil];

//    int files_count = [self getFilesCount:allFiles];
    //If number of fiels are greater than 0, show the list of files and then show the upload data view controller
    //otherwise show no data to upload view controller
    
//    if(files_count>0)
//        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d Files to Upload",files_count] message:[self getFileNames:allFiles] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    
    if([self getFilesCount:allFiles] > 0)
        [self performSegueWithIdentifier:@"uploadData" sender:nil];
    else
        [self performSegueWithIdentifier:@"noDataToUpload" sender:nil];
}

//Get Counts of all the files (exclude .DS_Store)

-(int)getFilesCount:(NSArray*)allFiles
{
    int countDiff = 0;
    if([allFiles count]==0)
        return 0;
    else
    {
        for(NSString *fileName in allFiles)
        {
            if([fileName isEqualToString:@".DS_Store"])
            {
                countDiff = -1;
                break;
            }
        }
        
        //countDiff = -1 when .DS_Store exits
        //otherwise countDiff = 0
        
        int count = (unsigned int)[allFiles count] + countDiff;
        return count;
    }
}

//Get all the stored JSON file names. Every folder will have a .DS_Store which is not needed

@end

//
//  SettingsViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationItem setHidesBackButton:YES animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadData];
}

//Load already saved data into the text fields
-(void)loadData
{
    [logInterval setText:[NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"updateRate"]]];
    [exerciseTime setText:[NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"total_walk_time"]]];
    [bucket_name setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"bucket_name"]];
    [access_key setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_key"]];
}

//First perform the required checks and in case the validation passes, save the data to UserDefaults and go back to Welcome View Controller else show error alert to user

-(IBAction)save:(id)sender
{
    if([[[logInterval text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter the Update Rate."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[logInterval text] intValue]<=0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Update Rate cannot be less than or equal to 0ms."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[[exerciseTime text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter the Exercise time."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[exerciseTime text] intValue] <10 )
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Maximum Walk Time cannot cannot be less than 10 seconds."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[[bucket_name text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter the Bucket Name."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[[access_key text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter the Access Key."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:[[logInterval text] intValue] forKey:@"updateRate"];
    [[NSUserDefaults standardUserDefaults] setInteger:[[exerciseTime text] intValue] forKey:@"total_walk_time"];
    [[NSUserDefaults standardUserDefaults] setObject:[bucket_name text] forKey:@"bucket_name"];
    [[NSUserDefaults standardUserDefaults] setObject:[access_key text] forKey:@"access_key"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)cancel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)keyboardDidAppear
{
    //If screen is Retina 3.5 inch (iPhone 4S), move the screen 120 points above to accomodate keyboard (and none of the fields are hidden)
    if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        if(([bucket_name isFirstResponder] || [access_key isFirstResponder]) && self.view.frame.origin.y==0)
            [self.view setFrame:CGRectOffset(self.view.frame, 0, -120)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
}


-(void)done
{
    //If screen screen is moved up (y will be less than 0), move it back 120 points down so that it comes back to its original position and then hide keybaord
    
    if(self.view.frame.origin.y<0)
        [self.view setFrame:CGRectOffset(self.view.frame, 0, 120)];
    
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

@end

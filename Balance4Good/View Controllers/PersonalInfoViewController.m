//
//  PersonalInfoViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "PersonalInfoViewController.h"

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    
    //Required in iOS 8 to disbale the automatic scroll view insets adjustment (which was added in iOS 8)
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self.navigationItem setHidesBackButton:YES animated:NO];
}

//this function is called when this view controller is loaded. It retreives the stored data and shows it in the corresponding fields.

-(void)loadData
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    [tName setText:[data objectForKey:@"name"]];
    [tNumber setText:[data objectForKey:@"number"]];
    [tHeight setText:[data objectForKey:@"height"]];
    [tAge setText:[data objectForKey:@"age"]];
    [tWeight setText:[data objectForKey:@"weight"]];

    // if gender is female, select segment at index 1 (which is female) and unselected the already selected one (which is male)
    // we don't cater for male as it is already selected by default
    
    if([[data objectForKey:@"gender"] isEqualToString:@"Female"])
        [scGender setSelectedSegmentIndex:1];

    if([[data objectForKey:@"typicalActivityLevel"] isEqualToString:@"Very Active"])
        [scTypicalActivityLevel setSelectedSegmentIndex:0];
    else if([[data objectForKey:@"typicalActivityLevel"] isEqualToString:@"Usually Sedentary"])
        [scTypicalActivityLevel setSelectedSegmentIndex:2];
    else
        [scTypicalActivityLevel setSelectedSegmentIndex:1];

    if([[data objectForKey:@"currentBalanceLevel"] isEqualToString:@"Good Balance"])
        [scCurrentBalanceLevel setSelectedSegmentIndex:0];
    else if([[data objectForKey:@"currentBalanceLevel"] isEqualToString:@"Poor Balance"])
        [scCurrentBalanceLevel setSelectedSegmentIndex:2];
    else
        [scCurrentBalanceLevel setSelectedSegmentIndex:1];

    
}

- (void)didReceiveMemoryWarning {
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

//We check if any of the field is not entered. In that case, we don't allow the user to save the data and show an alert
//In case all the data is entered, we save the data in UserDefaults and go back to the welcome screen/view controller
- (IBAction)save:(UIButton *)sender
{
    if([[[tName text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter Full Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[tNumber text] length] != 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Test Number should be exactly 6 Numbers" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[tHeight text] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter Height." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[tAge text] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter Age." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if([[tWeight text] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter Weight." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }

    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[tName.text,tNumber.text,tHeight.text,tAge.text, tWeight.text,[scGender titleForSegmentAtIndex:[scGender selectedSegmentIndex]],[scTypicalActivityLevel titleForSegmentAtIndex:[scTypicalActivityLevel selectedSegmentIndex]],[scCurrentBalanceLevel titleForSegmentAtIndex:[scCurrentBalanceLevel selectedSegmentIndex]]] forKeys:@[@"name",@"number",@"height",@"age",@"weight",@"gender",@"typicalActivityLevel",@"currentBalanceLevel"]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"personalInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];    
}

//show a done button when keyboard appears
-(IBAction)keyboardDidAppear
{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
}

//when done, end Editing (Hide Keyboard) and remove the done button
-(void)done
{
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

@end

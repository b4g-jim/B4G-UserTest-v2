//
//  BalanceEvaluationViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "BalanceEvaluationViewController.h"
#import "TestDetails.h"

@interface BalanceEvaluationViewController ()

@end

@implementation BalanceEvaluationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    if(![data objectForKey:@"name"])
    {
        [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please enter 'Personal Information' before starting a test" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self initializeButtons];
}

-(void)initializeButtons
{
    for(UIButton *button in balanceEvaluationType)
    {
        if([button tag] == 2)
            selectedBalanceEvaluationType = [[button titleLabel] text];
        
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0].CGColor;
        
        if(!button.isEnabled)
        {
            [button setBackgroundColor:[UIColor lightGrayColor]];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
    }
}

-(IBAction)changeBalanceEvaluationType:(UIButton*)sender
{
    [sender setSelected:YES];
    [sender setBackgroundColor:[UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    selectedBalanceEvaluationType = [[sender titleLabel] text];
    
    for(UIButton *button in balanceEvaluationType)
    {
        if(![button isEqual:sender] && [button isEnabled])
        {
            [button setSelected:NO];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button setTitleColor:[UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startTest:(UIButton *)sender
{
    //Replace New Line with space
    [[TestDetails sharedInstance] startTestWithSensors:nil andBalanceTestType:[selectedBalanceEvaluationType stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "]];

    [self performSegueWithIdentifier:@"startBalanceEvaluation" sender:nil];
}
@end

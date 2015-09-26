//
//  TestCompleteViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "TestCompleteViewController.h"
#import "WelcomeViewController.h"

@interface TestCompleteViewController ()

@end

@implementation TestCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    // Do any additional setup after loading the view.
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

//Go Back to WelcomeViewController
- (IBAction)backToHomeScreen:(UIButton *)sender
{
    UIViewController *vc = nil;
    
    for(vc in self.navigationController.viewControllers)
    {
        if([vc isKindOfClass:[WelcomeViewController class]])
            break;
    }
    
    [self.navigationController popToViewController:vc animated:YES];
}
@end

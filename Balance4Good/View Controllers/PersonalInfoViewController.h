//
//  PersonalInfoViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

//View Controller for Adding/Changing Personal Data of Tester

#import <UIKit/UIKit.h>

@interface PersonalInfoViewController : UIViewController
{
    __weak IBOutlet UITextField *tName;
    __weak IBOutlet UITextField *tNumber;
    __weak IBOutlet UITextField *tHeight;
    __weak IBOutlet UITextField *tWeight;
    __weak IBOutlet UISegmentedControl *scGender;
    __weak IBOutlet UITextField *tAge;

    __weak IBOutlet UISegmentedControl *scTypicalActivityLevel;
    __weak IBOutlet UISegmentedControl *scCurrentBalanceLevel;
}

- (IBAction)save:(UIButton *)sender;
- (IBAction)cancel:(id)sender;
@end

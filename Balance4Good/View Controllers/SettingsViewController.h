//
//  SettingsViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    
    __weak IBOutlet UITextField *logInterval;
    __weak IBOutlet UITextField *exerciseTime;
    __weak IBOutlet UITextField *bucket_name;
    __weak IBOutlet UITextField *access_key;
}
- (IBAction)cancel:(UIButton *)sender;
@end

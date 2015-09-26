//
//  UploadDataSuccessViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadDataSuccessViewController : UIViewController
{
    
    __weak IBOutlet UILabel *lblUploadStatus;
}

@property int files_uploaded;
- (IBAction)backToHomeScreen:(UIButton *)sender;

@end

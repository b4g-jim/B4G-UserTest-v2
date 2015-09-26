//
//  UploadDataViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadDataViewController : UIViewController
{
    __weak IBOutlet UILabel *lblFilesToUpload;
    NSMutableArray *success,*failure;    //Success will store successful uploads while failure will store unsuccessful uploads
    
    int currentFileIndex;
    
    UIAlertView *alertView;
}
- (IBAction)uploadData:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;

@end

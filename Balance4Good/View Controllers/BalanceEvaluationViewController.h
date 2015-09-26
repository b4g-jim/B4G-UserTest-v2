//
//  BalanceEvaluationViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceEvaluationViewController : UIViewController
{
    IBOutletCollection(UIButton) NSArray *balanceEvaluationType;
    NSString* selectedBalanceEvaluationType;
}
- (IBAction)startTest:(UIButton *)sender;


@end

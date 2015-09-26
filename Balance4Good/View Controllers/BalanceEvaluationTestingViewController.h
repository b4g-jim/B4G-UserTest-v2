//
//  BalanceEvaluationTestingViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface BalanceEvaluationTestingViewController : UIViewController
{
    __weak IBOutlet UILabel *lblTimeLeft;
    int timeLeft;    
}
@property int updateInterval;

@property (strong,nonatomic) NSTimer *countDownTimer;

@property (strong,nonatomic) NSMutableDictionary *current_Values;

@property (strong,nonatomic) CMMotionManager *motionManager;

@property (strong,nonatomic) AVAudioPlayer *audioPlayer;

- (IBAction)stopTest:(UIButton *)sender;
@end

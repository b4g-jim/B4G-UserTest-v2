//
//  StandStillViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEUtility.h"
#import "BLEDevice.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface StandStillViewController : UIViewController<CBPeripheralDelegate>
{
    __weak IBOutlet UIView *roundedCornersView;
    __weak IBOutlet UILabel *lblTimeLeft;
    int timeLeft;
}
@property (strong,nonatomic) CMMotionManager *motionManager;

@property (strong,nonatomic) BLEDevice *devices;
@property (strong,nonatomic) NSTimer *countDownTimer;

@property (strong,nonatomic) NSTimer *logTimer;

@property (strong,nonatomic) AVAudioPlayer *audioPlayer;

@property float logInterval;
@property int updateInterval;

@end

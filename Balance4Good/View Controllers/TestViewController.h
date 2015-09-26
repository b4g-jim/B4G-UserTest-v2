//
//  TestViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BLEDevice.h"
#import "Sensors.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface TestViewController : UIViewController<CBPeripheralDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UIView *roundedCornersView;
    __weak IBOutlet UILabel *accValueX,*accValueY,*accValueZ;
    __weak IBOutlet UILabel *gyroValueX,*gyroValueY,*gyroValueZ;

    __weak IBOutlet UILabel *d2_accValueX,*d2_accValueY,*d2_accValueZ;
    __weak IBOutlet UILabel *d2_gyroValueX,*d2_gyroValueY,*d2_gyroValueZ;

    UIAlertView* loader;
    __weak IBOutlet UILabel *lblTimeLeft;
    
    int timeElapsed;
    int totalWalkTime;
}

@property (strong,nonatomic) BLEDevice *devices;


//@property (strong,nonatomic) sensorIMU3000 *gyroSensor;
//
//@property (strong,nonatomic) sensorTagValues *currentVal;
@property (strong,nonatomic) NSTimer *logTimer;
@property (strong,nonatomic) NSTimer *countUpTimer;

@property float logInterval;
@property int updateInterval;

@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) CMMotionManager *motionManager;

-(IBAction)stopTest:(UIButton*)sender;

@end

//
//  TestViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "TestViewController.h"
#import "StandStillViewController.h"
#import "BLEUtility.h"
#import "TestDetails.h"
#import "WelcomeViewController.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import "Constants.h"
#import "SensorsHelper.h"
#import "Helper.h"

#define ERROR_ALERT 1
#define SUCCESS_ALERT 2

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [roundedCornersView.layer setCornerRadius:6.0];
    [roundedCornersView setClipsToBounds:YES];
    
    self.countUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [self.audioPlayer play];

    totalWalkTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"total_walk_time"];
    [lblTimeLeft setText:[NSString stringWithFormat:@"%d",totalWalkTime]];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
}

-(void)initializeExternalSensors:(BOOL)isThreeSensors
{
    for(CBPeripheral *peripheral in self.devices.peripherals)
        [peripheral setDelegate:self];
    
    if(!isThreeSensors)
        self.logTimer = [NSTimer scheduledTimerWithTimeInterval:(float)self.updateInterval/1000.0f target:self selector:@selector(logValues:) userInfo:nil repeats:YES];
}

-(void)initializeInternalMotionSensors
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = (float)self.updateInterval/1000;
    
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         [self logMotionDataWithAcceleration:motion.userAcceleration gravity:motion.gravity andRotation:motion.rotationRate];
     }];

}

-(void)cancelTimers
{
    //if logTimer is running, invalidate it and set it to null
    if(self.logTimer)
    {
        [self.logTimer invalidate];
        self.logTimer = nil;
    }
    
    //if countUpTimer is running, invalidate it and set it to null
    if(self.countUpTimer)
    {
        [self.countUpTimer invalidate];
        self.countUpTimer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)initialize
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];

    if([[TestDetails sharedInstance] sensorType] > 0)
        [[SensorsHelper sharedHelper] initGyroSensors:self.devices.peripherals.count];
    
    //retreive update rate from Technical Configuration.
    self.updateInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];  //(in milliseconds) minimum update interval for both gyro and accelero
    

    if([[TestDetails sharedInstance] sensorType] == 0)
        [self initializeInternalMotionSensors];
    else if([[TestDetails sharedInstance] sensorType] == 1)
        [self initializeExternalSensors:NO];
    else
    {
        [self initializeInternalMotionSensors];
        [self initializeExternalSensors:YES];
    }
}

-(int)sensorPeriod:(NSString *)Sensor
{
    NSString *val = [self.devices.setupData valueForKey:Sensor];
    return [val intValue];
}

#pragma mark - CBCentralManager Delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheral Delegate

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    //Check if the data is being broadcast by accelerometer sensor. If Yes, read its values and store it
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer data UUID"]]])
    {
        [[SensorsHelper sharedHelper] logAccelerometerData:characteristic forDevice:[[Helper sharedHelper] getDeviceIndex:peripheral inDevices:self.devices.peripherals]];
    }
    
    //Check if the data is being broadcast by gyroscope sensor. If Yes, read its values and store it
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope data UUID"]]])
    {
        [[SensorsHelper sharedHelper] logGyroData:characteristic forDevice:[[Helper sharedHelper] getDeviceIndex:peripheral inDevices:self.devices.peripherals]];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}


#pragma mark - Log Values
-(void)logMotionDataWithAcceleration:(CMAcceleration)acceleration gravity:(CMAcceleration)gravity andRotation:(CMRotationRate)rotation
{
    [[SensorsHelper sharedHelper] logInternalSensorValuesWithAcceleration:acceleration gravity:gravity andRotation:rotation];
}

-(void) logValues:(NSTimer*)timer
{
    [[Helper sharedHelper] logValues:timer];
}

-(void)updateTimer
{
    timeElapsed++;

    //check if time elapsed is greater than or equal to total walk time, then call save.
    //Also update the time elapsed label
    if(timeElapsed >= [[NSUserDefaults standardUserDefaults] integerForKey:@"total_walk_time"])
    {
        [self.audioPlayer play];
        [self cancelTimers];
        [self performSegueWithIdentifier:@"showStandStillScreen" sender:nil];
    }

    int timeLeft = totalWalkTime - timeElapsed;
    
    NSString *timeString = [NSString stringWithFormat:@"%d",timeLeft];
    [lblTimeLeft setText:timeString];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[StandStillViewController class]])
    {
        StandStillViewController *standStillController = [segue destinationViewController];
        standStillController.devices = self.devices;
        self.motionManager = nil;
    }
    
}

-(IBAction)stopTest:(UIButton *)sender
{
    [self cancelTimers];
    [self performSegueWithIdentifier:@"showStandStillScreen" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

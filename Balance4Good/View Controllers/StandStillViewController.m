//
//  StandStillViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "StandStillViewController.h"
#import "SensorsHelper.h"
#import "TestDetails.h"
#import "Helper.h"

@interface StandStillViewController ()

@end

@implementation StandStillViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [roundedCornersView.layer setCornerRadius:6.0];
    [roundedCornersView setClipsToBounds:YES];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    timeLeft = 5;

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


-(void)updateTimer
{
    timeLeft--;
    
    //check if time elapsed is greater than or equal to total walk time, then call save.
    //Also update the time elapsed label
    if(timeLeft <= 0)
    {
        [self.audioPlayer play];

        [self save:nil];
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%d",timeLeft];
    [lblTimeLeft setText:timeString];
}

- (void)save:(UIButton *)sender
{
    [self cancelTimers];
    
//    if([[[TestDetails sharedInstance] dataPoints] count] > 0)
    {
        // In case we have data points, first call endTest to store all data and create its JSON
        // then deconfigure the peripheral
        // and final store the file to the Saved_Data Folder
        // finally show the Test Complete View Controller
        NSString *data = [[TestDetails sharedInstance] endTest];
        
        for(int i=0;i<self.devices.peripherals.count;i++)
        {
            CBPeripheral *peripheral = [self.devices.peripherals objectAtIndex:i];
            [self deconfigureSensorTag:peripheral];
            [peripheral setDelegate:nil];
            peripheral = nil;
        }
        [self.devices.manager setDelegate:nil];
        
        NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
        
        NSLog(@"test_id:%@",[[TestDetails sharedInstance] test_id]);
        
        NSString *fileName = [@"b4g-" stringByAppendingFormat:@"%@.json",[[TestDetails sharedInstance] test_id]];    //test_id is stored at index 1
        NSURL *fileURL = [NSURL fileURLWithPath:[Data_Folder stringByAppendingPathComponent:fileName]];
        
        [data writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    
    [self performSegueWithIdentifier:@"showTestCompleteScreen" sender:nil];
    
}

-(void) deconfigureSensorTag:(CBPeripheral*)peripheral
{
    //Deconfigure Accelerometer and Gyroscope.
    
    //Accelerometer
    CBUUID *sUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer service UUID"]];
    CBUUID *cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer config UUID"]];
    uint8_t data = 0x00;
    [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer data UUID"]];
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    
    //Gyroscope
    sUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope service UUID"]];
    cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope config UUID"]];
    data = 0x00;
    [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope data UUID"]];
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
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

-(void)cancelTimers
{
    //if logTimer is running, invalidate it and set it to null
    if(self.logTimer)
    {
        [self.logTimer invalidate];
        self.logTimer = nil;
    }
    
    //if countUpTimer is running, invalidate it and set it to null
    if(self.countDownTimer)
    {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}


@end

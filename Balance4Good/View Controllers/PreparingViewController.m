//
//  PreparingViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "PreparingViewController.h"
#import "TestViewController.h"
#import "SensorsHelper.h"
#import "TestDetails.h"
#import "BLEUtility.h"
#import "Helper.h"

@interface PreparingViewController ()

@end

@implementation PreparingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [roundedCornersView.layer setCornerRadius:6.0];
    [roundedCornersView setClipsToBounds:YES];
    [self.navigationItem setHidesBackButton:YES animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    timeLeft = 5;
    [self initialize];
}

-(void)initialize
{    
    //retreive update rate from Technical Configuration.
    
    self.updateInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];  //(in milliseconds) minimum update interval for both gyro and accelero

    if([[TestDetails sharedInstance] sensorType] == 0)
        [self initializeInternalMotionSensors];
    else if([[TestDetails sharedInstance] sensorType] == 1)
    {
        [[SensorsHelper sharedHelper] initGyroSensors:self.devices.peripherals.count];
        [self initializeExternalSensors:NO];
    }
    else
    {
        [[SensorsHelper sharedHelper] initGyroSensors:self.devices.peripherals.count];
        [self initializeExternalSensors:YES];
        [self initializeInternalMotionSensors];
    }
    
}

-(void)initializeExternalSensors:(BOOL)isThreeSensors
{
    [[SensorsHelper sharedHelper] initializeValues:YES];
    [self connectExternalSensors];
    
    if(!isThreeSensors)
        self.logTimer = [NSTimer scheduledTimerWithTimeInterval:(float)self.updateInterval/1000.0f target:self selector:@selector(logValues:) userInfo:nil repeats:YES];
}

-(void)initializeInternalMotionSensors
{
    [[SensorsHelper sharedHelper] initializeValues:NO];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = (float)self.updateInterval/1000;
    
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         [self logMotionDataWithAcceleration:motion.userAcceleration gravity:motion.gravity andRotation:motion.rotationRate];
     }];
    
}

-(void)connectExternalSensors
{
    BOOL testConnected = NO;
    
    //Check every peripheral (sensorTag). if it is not connected, connect & configure it and then start getting values.
    // If it is alreayd connected, just configure it and start getting values
    for(CBPeripheral *peripheral in self.devices.peripherals)
    {
        if (![peripheral isConnected])
        {
            self.devices.manager.delegate = self;
            [self.devices.manager connectPeripheral:peripheral options:nil];
        }
        else
        {
            testConnected = YES;
            peripheral.delegate = self;
            [self configureSensorTag:peripheral];
        }
    }
}

-(bool)sensorEnabled:(NSString *)Sensor
{
    NSString *val = [self.devices.setupData valueForKey:Sensor];
    if (val)
    {
        if ([val isEqualToString:@"1"]) return TRUE;
    }
    return FALSE;
}


-(void)updateTimer
{
    timeLeft--;
    
    //check if time elapsed is greater than or equal to total walk time, then call save.
    //Also update the time elapsed label
    if(timeLeft <= 0)
    {
        [self performSegueWithIdentifier:@"startWalkingTest" sender:nil];
        [self cancelTimers];
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%d",timeLeft];
    [lblTimeLeft setText:timeString];
}


#pragma mark - Sensor Configuration

-(void) configureSensorTag:(CBPeripheral*)peripheral
{
    // Configure sensortag, turning on Sensors and setting update period for sensors etc ...
    
    if ([self sensorEnabled:@"Accelerometer active"])
    {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer period UUID"]];
        
        uint8_t periodData = (uint8_t)(self.updateInterval / 10);
        NSLog(@"%d",periodData);
        
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [[SensorsHelper sharedHelper].sensorsEnabled addObject:@"Accelerometer"];
    }
    
    if ([self sensorEnabled:@"Gyroscope active"])
    {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope period UUID"]];
        
        uint8_t periodData = (uint8_t)(self.updateInterval / 10);
        NSLog(@"%d",periodData);
        
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        
        uint8_t data = 0x07;
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [[SensorsHelper sharedHelper].sensorsEnabled addObject:@"Gyroscope"];
    }
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
//All these functions are discussed in WalkingTestViewController.m
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if([service.UUID isEqual:[CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope service UUID"]]])
    {
        [self configureSensorTag:peripheral];
        
        //        if(!self.logTimer)
        //        {
        //            self.logTimer = [NSTimer scheduledTimerWithTimeInterval:(float)self.updateInterval/1000.0f target:self selector:@selector(logValues:) userInfo:nil repeats:YES];
        //            self.countUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        //        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services)
        [peripheral discoverCharacteristics:nil forService:service];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateNotificationStateForCharacteristic %@, error = %@",characteristic.UUID,error);
}

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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[TestViewController class]])
    {
        TestViewController *testController = [segue destinationViewController];
        testController.devices = self.devices;
        self.motionManager = nil;
        [self.devices.manager stopScan];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

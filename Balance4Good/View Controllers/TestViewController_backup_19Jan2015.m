//
//  TestViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "TestViewController.h"
#import "BLEUtility.h"
#import "TestDetails.h"
#import "WelcomeViewController.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import "Constants.h"

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

    self.logTimer = [NSTimer scheduledTimerWithTimeInterval:(float)self.updateInterval/1000.0f target:self selector:@selector(logValues:) userInfo:nil repeats:YES];
    
    self.countUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];

}

-(void)cancel:(BOOL)goBack
{
    if(self.logTimer)
    {
        [self.logTimer invalidate];
        self.logTimer = nil;
    }
    
    if(self.countUpTimer)
    {
        [self.countUpTimer invalidate];
        self.countUpTimer = nil;
    }

    UIViewController *vc = nil;
    
    for(vc in self.navigationController.viewControllers)
    {
        if([vc isKindOfClass:[WelcomeViewController class]])
            break;
    }
    
    [[self.devices manager] stopScan];
    
    if(goBack)
        [self.navigationController popToViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.sensorsEnabled = [[NSMutableArray alloc] init];


    BOOL testConnected = NO;
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


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for(CBPeripheral *peripheral in self.devices.peripherals)
        [self deconfigureSensorTag:peripheral];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.sensorsEnabled = nil;
    self.devices.manager.delegate = nil;
    self.gyroSensors = nil;
    
    self.current_Values = nil;
    
}


-(void)initialize
{
    [self initGyroSensors];
    
    self.updateInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];  //(in milliseconds) minimum update interval for both gyro and accelero
    
  //  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];

    self.current_Values = [NSMutableArray arrayWithCapacity:13];
    [self.current_Values setValue:@"" forKey:@"timestamp"];
    [self.current_Values setValue:@"" forKey:@"S1_AX"];
    [self.current_Values setValue:@"" forKey:@"S1_AY"];
    [self.current_Values setValue:@"" forKey:@"S1_AZ"];
    [self.current_Values setValue:@"" forKey:@"S1_GX"];
    [self.current_Values setValue:@"" forKey:@"S1_GY"];
    [self.current_Values setValue:@"" forKey:@"S1_GZ"];
    [self.current_Values setValue:@"" forKey:@"S2_AX"];
    [self.current_Values setValue:@"" forKey:@"S2_AY"];
    [self.current_Values setValue:@"" forKey:@"S2_AZ"];
    [self.current_Values setValue:@"" forKey:@"S2_GX"];
    [self.current_Values setValue:@"" forKey:@"S2_GY"];
    [self.current_Values setValue:@"" forKey:@"S2_GZ"];

}

-(void)done
{
    //        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
//    [mailComposer setSubject:@"Test Data"];
//    
//    [mailComposer setToRecipients:@[@"hiranasirkhan@gmail.com"]];
//    [mailComposer setMessageBody:data isHTML:NO];
//    
//    [mailComposer setMailComposeDelegate:self];
//    [self presentViewController:mailComposer animated:YES completion:nil];
}

#pragma mark - Sensor Configuration
-(void)initGyroSensors
{
    self.gyroSensors = [NSMutableArray array];
    for(int i=0;i<self.devices.peripherals.count;i++)
    {
        sensorIMU3000 *gyroSensor = [[sensorIMU3000 alloc] init];
        [self.gyroSensors addObject:gyroSensor];
    }
}

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
        [self.sensorsEnabled addObject:@"Accelerometer"];
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
        [self.sensorsEnabled addObject:@"Gyroscope"];
    }
}

-(void) deconfigureSensorTag:(CBPeripheral*)peripheral
{
    if ([self sensorEnabled:@"Accelerometer active"])
    {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Gyroscope active"])
    {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
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

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //NSLog(@"didUpdateValueForCharacteristic = %@",characteristic.UUID);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Accelerometer data UUID"]]])
    {
        int deviceIndex = [self getDeviceIndex:peripheral];

        float x = [sensorKXTJ9 calcXValue:characteristic.value];
        float y = [sensorKXTJ9 calcYValue:characteristic.value];
        float z = [sensorKXTJ9 calcZValue:characteristic.value];

        
        int initial_Index;
        if([self getDeviceIndex:peripheral] == 0)
        {
            accValueX.text = [NSString stringWithFormat:@"X : % 0.3fG",x];
            accValueY.text = [NSString stringWithFormat:@"Y : % 0.3fG",y];
            accValueZ.text = [NSString stringWithFormat:@"Z : % 0.3fG",z];
            initial_Index = 1;
        }
        else
        {
            d2_accValueX.text = [NSString stringWithFormat:@"X : % 0.3fG",x];
            d2_accValueY.text = [NSString stringWithFormat:@"Y : % 0.3fG",y];
            d2_accValueZ.text = [NSString stringWithFormat:@"Z : % 0.3fG",z];

            initial_Index = 7;
        }
        
         [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_AX",deviceIndex+1] atIndex:initial_Index];
        [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_AY",deviceIndex+1] atIndex:initial_Index+1];
        [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_AZ",deviceIndex+1] atIndex:initial_Index+2];
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.devices.setupData valueForKey:@"Gyroscope data UUID"]]])
    {
        int deviceIndex = [self getDeviceIndex:peripheral];
        sensorIMU3000 *gyroSensor;
    
        gyroSensor = [self.gyroSensors objectAtIndex:deviceIndex];
        
        float x = [gyroSensor calcXValue:characteristic.value];
        float y = [gyroSensor calcYValue:characteristic.value];
        float z = [gyroSensor calcZValue:characteristic.value];
        
        int initial_Index;

        if(deviceIndex == 0)
        {
            gyroValueX.text = [NSString stringWithFormat:@"X : % 0.3f°/S",x];
            gyroValueY.text = [NSString stringWithFormat:@"Y : % 0.3f°/S",y];
            gyroValueZ.text = [NSString stringWithFormat:@"Z : % 0.3f°/S",z];
            initial_Index = 4;
        }
        else
        {
            d2_gyroValueX.text = [NSString stringWithFormat:@"X : % 0.3f°/S",x];
            d2_gyroValueY.text = [NSString stringWithFormat:@"Y : % 0.3f°/S",y];
            d2_gyroValueZ.text = [NSString stringWithFormat:@"Z : % 0.3f°/S",z];
            initial_Index = 10;
        }
        
        [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_GX",deviceIndex+1] atIndex:initial_Index];
        [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_GY",deviceIndex+1] atIndex:initial_Index+1];
        [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_GZ",deviceIndex+1] atIndex:initial_Index+2];

//        if([self.current_Values count]==16)
//            [self logValues];
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}

-(int)getDeviceIndex:(CBPeripheral*)peripheral
{
    for(int i=0;i<self.devices.peripherals.count;i++)
    {
        CBPeripheral *peri = [self.devices.peripherals objectAtIndex:i];
        if([peripheral isEqual:peri])
            return i;
    }
    return -1;
}

- (IBAction) handleCalibrateGyro
{
    NSLog(@"Calibrate gyroscope pressed ! ");
    for(sensorIMU3000 *gyroSensor in self.gyroSensors)
        [gyroSensor calibrate];
    
}

- (IBAction)save:(UIButton *)sender
{
    if([[[TestDetails sharedInstance] dataPoints] count] == 0)
    {

        if(!sender)
            [self cancel:YES];
        else
            [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"No Data To Save" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

        return;
    }
    
    NSString *data = [[TestDetails sharedInstance] endTest];
    
    for(CBPeripheral *peripheral in self.devices.peripherals)
        [self deconfigureSensorTag:peripheral];
    
    
    NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
    
    NSLog(@"test_id:%@",[[TestDetails sharedInstance] test_id]);
    
    NSString *fileName = [@"b4g-" stringByAppendingFormat:@"%@.json",[[TestDetails sharedInstance] test_id]];    //test_id is stored at index 1
    NSURL *fileURL = [NSURL fileURLWithPath:[Data_Folder stringByAppendingPathComponent:fileName]];
    
    [data writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self cancel:NO];

    [self performSegueWithIdentifier:@"showTestCompleteVC" sender:nil];
    
}

- (IBAction)cancelTest:(UIButton *)sender
{
    [self cancel:YES];
}


//unsigned long fileSize = [data length];
//[self uploadFileWithURL:fileURL fileSize:fileSize inBucket:[[NSUserDefaults standardUserDefaults] objectForKey:@"bucket_name"] asfileName:fileName];

#pragma mark - Log Values
-(void) logValues:(NSTimer*)timer
{
    NSMutableArray *vals = [NSMutableArray arrayWithArray:self.current_Values];
    
    BOOL dataExists = [self dataExists:vals];
    
    if([[[TestDetails sharedInstance] dataPoints] count] == 0 && !dataExists)
        return;
    
    //Just a redundant check for <50ms data as sometimes we just get only timestamp logged.
    if([vals count] == 0)
        return;
    
//    [vals insertTimeStamp:[[TestDetails sharedInstance] getFormattedTimestamp:YES] atIndex:0];
    
    
    [[[TestDetails sharedInstance] dataPoints] addObject:vals];
    
    [lblDataPointsCount setText:[NSString stringWithFormat:@"%lu",(unsigned long)[[[TestDetails sharedInstance] dataPoints] count]]];
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return ![view isKindOfClass:[UIButton class]];
}

#pragma mark - MFMailComposerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Convert To JSON
-(NSString*) getPrettyPrintedJSONforObject:(id)obj
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)
                                                         error:&error];
    
    if (! jsonData)
    {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

#pragma mark - AWS Upload
-(void)uploadFileWithURL:(NSURL*)fileURL fileSize:(unsigned long)fileSize inBucket:(NSString*)bucket asfileName:(NSString*)fileName
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = bucket;
    uploadRequest.key = fileName;
    uploadRequest.body = fileURL;
    
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLong:fileSize];
    
    [self showLoader];
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task)
     {
         [self hideLoader];
         if(task.error)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:task.error.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry", nil];
             alert.tag = ERROR_ALERT;
             [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"File Upload Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             alert.tag = SUCCESS_ALERT;
             [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
         }
         
         return nil;
     }];
    
}

-(void)showLoader
{
    loader = [[UIAlertView alloc] initWithTitle:@"" message:@"Please wait while file is being uploaded...." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [loader show];
}

-(void)hideLoader
{
    [loader dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag]==SUCCESS_ALERT)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([alertView tag] == ERROR_ALERT)
    {
        if(buttonIndex == 0 )
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self done];
        }
    }
}

#pragma mark - Helper Functions
-(BOOL)dataExists:(NSMutableArray*)array
{
    BOOL result = NO;
    for(int i=0;i<[array count];i++)
    {
        if(![self isEmpty:[array objectAtIndex:i]])
        {
            result = YES;
        }
        else
        {
            [array removeObjectAtIndex:i];
            i--;
        }
    }
    
    return result;
}

-(BOOL)isEmpty:(NSString*)str
{
    NSUInteger loc = [str rangeOfString:@":"].location;
    str = [[str substringFromIndex:loc+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    if([str length] == 0)
        return YES;
    else
        return NO;
}

-(void)updateTimer
{
    timeElapsed++;

    if(timeElapsed >= [[NSUserDefaults standardUserDefaults] integerForKey:@"total_walk_time"])
    {
        [self save:nil];
    }

    int mins = timeElapsed/60;
    int secs = timeElapsed%60;
    
    NSString *timeString = [NSString stringWithFormat:@"%2d:%2d",mins,secs];
    timeString = [timeString stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    [lblTimeElapsed setText:timeString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

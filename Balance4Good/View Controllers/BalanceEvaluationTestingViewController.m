//
//  BalanceEvaluationTestingViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 6/27/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "BalanceEvaluationTestingViewController.h"
#import "TestDetails.h"

@interface BalanceEvaluationTestingViewController ()

@end

@implementation BalanceEvaluationTestingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer prepareToPlay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initialize];
    [self initializeMotionManager];

    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [self.audioPlayer play];

    timeLeft = 30;
}

-(void)initializeMotionManager
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = (float)self.updateInterval/1000;
    
//    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//        NSLog(@"Gyro Available : %d",self.motionManager.gyroAvailable);
//        NSLog(@"Gyro Active : %d",self.motionManager.gyroActive);
//
//        [self logAccelerometerData:accelerometerData.acceleration];
//        if(error)
//            NSLog(@"%@",error);
//    }];
//    
//    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
//        [self logGyroData:gyroData.rotationRate];
//        if(error)
//            NSLog(@"%@",error);
//    }];
//
//    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//        NSLog(@"%f",accelerometerData.acceleration.x);
//        if(error)
//            NSLog(@"%@",error);
//        }];

    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
    {
        [self logMotionDataWithAcceleration:motion.userAcceleration gravity:motion.gravity andRotation:motion.rotationRate];
    }];
}

-(void)initialize
{
    //retreive update rate from Technical Configuration.
    
    self.updateInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];  //(in milliseconds) minimum update interval for both gyro and accelero

    //Initialize all the values. Not that much necessary but still done as a pre-caution
    
    self.current_Values = [NSMutableDictionary dictionaryWithCapacity:13];
    [self.current_Values setObject:@"" forKey:@"timestamp"];
    [self.current_Values setObject:@"" forKey:@"AX"];
    [self.current_Values setObject:@"" forKey:@"AY"];
    [self.current_Values setObject:@"" forKey:@"AZ"];
    [self.current_Values setObject:@"" forKey:@"GX"];
    [self.current_Values setObject:@"" forKey:@"GY"];
    [self.current_Values setObject:@"" forKey:@"GZ"];
    
}


-(void)updateTimer
{
    timeLeft--;

    NSString *timeString = [NSString stringWithFormat:@"%d",timeLeft];
    [lblTimeLeft setText:timeString];
    
    //check if time elapsed is greater than or equal to total walk time, then call save.
    //Also update the time elapsed label
    if(timeLeft <= 0)
    {
        [self.audioPlayer play];
        [self save];
        [self performSegueWithIdentifier:@"showTestCompleteVC" sender:nil];
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    
}

-(void)logMotionDataWithAcceleration:(CMAcceleration)acceleration gravity:(CMAcceleration)gravity andRotation:(CMRotationRate)rotation
{
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",acceleration.x+gravity.x] forKey:@"AX"];
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",acceleration.y+gravity.y] forKey:@"AY"];
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",acceleration.z+gravity.z] forKey:@"AZ"];
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",rotation.x * 180 / M_PI] forKey:@"GX"];
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",rotation.y * 180 / M_PI] forKey:@"GY"];
    [self.current_Values setObject:[NSString stringWithFormat:@" %.3f",rotation.z * 180 / M_PI] forKey:@"GZ"];
    [self.current_Values setObject:[[TestDetails sharedInstance] getFormattedTimestamp:YES] forKey:@"timestamp"];

    [self logValues];
}   


#pragma mark - Log Values
-(void) logValues
{    
    NSMutableDictionary *vals = [NSMutableDictionary dictionaryWithDictionary:self.current_Values];
    
    BOOL dataExists = [self dataExists:vals];
    
    //If data does not exists & there are no data points already,don't log data.
    if([[[TestDetails sharedInstance] dataPoints] count] == 0 && !dataExists)
        return;
    
    //add the data point to the data points array
    [[[TestDetails sharedInstance] dataPoints] addObject:vals];
    
}

#pragma mark - Convert To JSON
//returns JSON in a readable format (pretty printed)
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


#pragma mark - Helper Functions
-(BOOL)dataExists:(NSMutableDictionary*)dataDict
{
    BOOL result = NO;
    for(NSString *key in dataDict.allKeys)
    {
        if(![self isEmpty:[dataDict objectForKey:key]])
        {
            result = YES;
        }
        else
        {
            [dataDict removeObjectForKey:key];
        }
    }
    return result;
}

-(BOOL)isEmpty:(NSString*)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([str length] == 0)
        return YES;
    else
        return NO;
}


- (IBAction)stopTest:(UIButton *)sender
{
    [self save];
    [self performSegueWithIdentifier:@"showTestCompleteVC" sender:nil];
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

-(void)save
{
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
    
//    if([[[TestDetails sharedInstance] dataPoints] count] > 0)
    {
        // In case we have data points, first call endTest to store all data and create its JSON
        // then deconfigure the peripheral
        // and final store the file to the Saved_Data Folder
        // finally show the Test Complete View Controller
        NSString *data = [[TestDetails sharedInstance] endTest];
        
        NSString *Data_Folder = [[TestDetails sharedInstance] getDataFolderPath];
        
        NSLog(@"test_id:%@",[[TestDetails sharedInstance] test_id]);
        
        NSString *fileName = [@"b4g-" stringByAppendingFormat:@"%@.json",[[TestDetails sharedInstance] test_id]];    //test_id is stored at index 1
        NSURL *fileURL = [NSURL fileURLWithPath:[Data_Folder stringByAppendingPathComponent:fileName]];
        
        [data writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        
    }
}
@end

//
//  ExternalSensorsHelper.m
//  Balance4Good
//
//  Created by Hira Daud on 7/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "SensorsHelper.h"
#import "Sensors.h"
#import "TestDetails.h"
#import "Helper.h"

@implementation SensorsHelper

+(SensorsHelper*)sharedHelper
{
    static SensorsHelper *myHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        myHelper = [[self alloc] init];
    });
    
    return myHelper;
    
}

-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

-(void)initializeValues:(BOOL)isExternalSensor
{
    //Initialize all the values. Not that much necessary but still done as a pre-caution
    if(!self.sensorReadings)
        self.sensorReadings = [NSMutableDictionary dictionary];
    else
        [self.sensorReadings removeAllObjects];
    
    if(isExternalSensor)
    {
        [self.sensorReadings setObject:@"" forKey:@"timestamp"];
        [self.sensorReadings setObject:@"" forKey:@"S1_AX"];
        [self.sensorReadings setObject:@"" forKey:@"S1_AY"];
        [self.sensorReadings setObject:@"" forKey:@"S1_AZ"];
        [self.sensorReadings setObject:@"" forKey:@"S1_GX"];
        [self.sensorReadings setObject:@"" forKey:@"S1_GY"];
        [self.sensorReadings setObject:@"" forKey:@"S1_GZ"];
        [self.sensorReadings setObject:@"" forKey:@"S2_AX"];
        [self.sensorReadings setObject:@"" forKey:@"S2_AY"];
        [self.sensorReadings setObject:@"" forKey:@"S2_AZ"];
        [self.sensorReadings setObject:@"" forKey:@"S2_GX"];
        [self.sensorReadings setObject:@"" forKey:@"S2_GY"];
        [self.sensorReadings setObject:@"" forKey:@"S2_GZ"];
    }
    else
    {
        [self.sensorReadings setObject:@"" forKey:@"timestamp"];
        [self.sensorReadings setObject:@"" forKey:@"IN_AX"];
        [self.sensorReadings setObject:@"" forKey:@"IN_AY"];
        [self.sensorReadings setObject:@"" forKey:@"IN_AZ"];
        [self.sensorReadings setObject:@"" forKey:@"IN_GX"];
        [self.sensorReadings setObject:@"" forKey:@"IN_GY"];
        [self.sensorReadings setObject:@"" forKey:@"IN_GZ"];
    }
}
-(void)initGyroSensors:(int)count
{
    self.gyroSensors = [NSMutableArray array];
    for(int i=0;i<count;i++)
    {
        sensorIMU3000 *gyroSensor = [[sensorIMU3000 alloc] init];
        [self.gyroSensors addObject:gyroSensor];
    }
}

-(void)logAccelerometerData:(CBCharacteristic*)characteristic forDevice:(int)deviceIndex
{
    float x = [sensorKXTJ9 calcXValue:characteristic.value];
    float y = [sensorKXTJ9 calcYValue:characteristic.value];
    float z = [sensorKXTJ9 calcZValue:characteristic.value];
    
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_AX",deviceIndex+1]];
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_AY",deviceIndex+1]];
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_AZ",deviceIndex+1]];
    
    if(self.location)
    {
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"lat"];
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"lng"];
    }
}

-(void)logGyroData:(CBCharacteristic*)characteristic forDevice:(int)deviceIndex
{
    sensorIMU3000 *gyroSensor;
    
    gyroSensor = [self.gyroSensors objectAtIndex:deviceIndex];
    
    float x = [gyroSensor calcXValue:characteristic.value];
    float y = [gyroSensor calcYValue:characteristic.value];
    float z = [gyroSensor calcZValue:characteristic.value];
    
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_GX",deviceIndex+1]];
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_GY",deviceIndex+1]];
    [self.sensorReadings setObject:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_GZ",deviceIndex+1]];
    
    if(self.location)
    {
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"lat"];
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"lng"];
    }

}


#pragma mark - Internal Sensor Logging
-(void)logInternalSensorValuesWithAcceleration:(CMAcceleration)acceleration gravity:(CMAcceleration)gravity andRotation:(CMRotationRate)rotation
{
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",acceleration.x+gravity.x] forKey:@"IN_AX"];
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",acceleration.y+gravity.y] forKey:@"IN_AY"];
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",acceleration.z+gravity.z] forKey:@"IN_AZ"];
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",rotation.x * 180 / M_PI] forKey:@"IN_GX"];
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",rotation.y * 180 / M_PI] forKey:@"IN_GY"];
    [self.sensorReadings setObject:[NSString stringWithFormat:@" %.3f",rotation.z * 180 / M_PI] forKey:@"IN_GZ"];
    [self.sensorReadings setObject:[[TestDetails sharedInstance] getFormattedTimestamp:YES] forKey:@"timestamp"];
    
    if(self.location)
    {
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"lat"];
        [self.sensorReadings setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"lng"];
    }
    
    [[Helper sharedHelper] logValues:nil];
}


@end

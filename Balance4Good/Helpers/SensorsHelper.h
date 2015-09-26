//
//  ExternalSensorsHelper.h
//  Balance4Good
//
//  Created by Hira Daud on 7/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface SensorsHelper : NSObject

@property (strong,nonatomic) NSMutableArray *gyroSensors;
@property (strong,nonatomic) NSMutableArray *sensorsEnabled;
@property (strong,nonatomic) NSMutableDictionary *sensorReadings;
@property (strong,nonatomic) CLLocation *location;

+(SensorsHelper*)sharedHelper;

-(void)initializeValues:(BOOL)isExternalSensor;
-(void)initGyroSensors:(int)count;

-(void)logAccelerometerData:(CBCharacteristic*)characteristic forDevice:(int)deviceIndex;
-(void)logGyroData:(CBCharacteristic*)characteristic forDevice:(int)deviceIndex;

-(void)logInternalSensorValuesWithAcceleration:(CMAcceleration)acceleration gravity:(CMAcceleration)gravity andRotation:(CMRotationRate)rotation;
@end

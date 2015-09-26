//
//  TestDetails.h
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

// Class For Storing Test Data

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TestDetails : NSObject<CLLocationManagerDelegate>
{
    CLLocation *location;
}
@property (strong,nonatomic) NSMutableDictionary *testInfo;
@property (strong,nonatomic) NSMutableArray *dataPoints;
@property (strong,nonatomic) NSString *test_id;
@property int sensorType;   //0 = Internal, 1 = External, 2 = Three Sensors

@property (strong,nonatomic) CLLocationManager *locationManager;

+(TestDetails*)sharedInstance;

-(void)startTestWithSensors:(NSString *)sensors andBalanceTestType:(NSString*)balanceTestType;
-(NSString*)endTest;
-(NSString*)getFormattedTimestamp:(BOOL)getMilliseconds;

-(NSString*)getDataFolderPath;
@end

//
//  WalkingTestViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"
#import "TypeClass.h"

@interface WalkingTestViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    IBOutletCollection(UIButton) NSArray *walkingTestType;
    __weak IBOutlet UILabel *lblSensor1_status;
    __weak IBOutlet UILabel *lblSensor2_status;
    
    BLEDevice *device;
    
    NSString *selectedSensor;
    __weak IBOutlet UIView *externalSensorsStatusView;
}

- (IBAction)startTest:(UIButton *)sender;

@property (strong,nonatomic) CBCentralManager *manager;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;

@property (strong,nonatomic) NSMutableArray *current_Values;

-(NSMutableDictionary*) makeSensorTagConfiguration;

- (IBAction)cancel:(UIButton *)sender;

@end

//
//  DevicesViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

//This file is not being used (it was used in the demo version)

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"

@interface DevicesViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView* devicesTablesView;
    BLEDevice *device;
    
    UIBarButtonItem *refresh;
    int time;
    
    NSTimer *timer;
    
    double lastTimestamp;
}

@property (strong,nonatomic) CBCentralManager *manager;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;

@property (strong,nonatomic) NSMutableArray *current_Values;

-(NSMutableDictionary*) makeSensorTagConfiguration;

@end

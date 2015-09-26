//
//  Helper.h
//  Balance4Good
//
//  Created by Hira Daud on 7/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Helper : NSObject

+(Helper*)sharedHelper;
-(void) logValues:(NSTimer*)timer;
-(int)getDeviceIndex:(CBPeripheral*)peripheral inDevices:(NSArray*)peripherals;

@end

//
//  DevicesViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "DevicesViewController.h"
#import "TestViewController.h"
#import "TestDetails.h"

@interface DevicesViewController ()

@end

@implementation DevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];

    refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDevices)];
    
    self.navigationItem.leftBarButtonItem = refresh;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start Test" style:UIBarButtonItemStyleBordered target:self action:@selector(startTest)];
    
    
//   [self justTest];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self initialize];
}

#pragma mark - User Functions

-(void)startTest
{
    if(self.sensorTags.count<1)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"No Sensor Detected Yet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    device = [[BLEDevice alloc] init];
    device.peripherals = self.sensorTags;
    device.manager = self.manager;
    device.setupData = [self makeSensorTagConfiguration];
    
 //   [[TestDetails sharedInstance] startTest];
 //   [self performSegueWithIdentifier:@"startTest" sender:self];
}

-(void)refreshDevices
{
    [self.manager stopScan];
    self.manager = nil;
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
    [devicesTablesView reloadData];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}


//-(void)justTest
//{
//    [[TestDetails sharedInstance] startTest];
//
//    for(int j=0;j<4;j++)
//    {
//        NSMutableArray *current_Values = [NSMutableArray array];
//            if(j==1 || j==3)
//            {
//                [current_Values setValue:@"" forKey:@"S1_AX"];
//                [current_Values setValue:@"" forKey:@"S1_AY"];
//                [current_Values setValue:@"" forKey:@"S1_AZ"];
//                [current_Values setValue:@"" forKey:@"S1_A_timestamp"];
//                [current_Values setValue:@"" forKey:@"S1_GX"];
//                [current_Values setValue:@"" forKey:@"S1_GY"];
//                [current_Values setValue:@"" forKey:@"S1_GZ"];
//                [current_Values setValue:@"" forKey:@"S1_G_timestamp"];
//                [current_Values setValue:@"" forKey:@"S2_AX"];
//                [current_Values setValue:@"" forKey:@"S2_AY"];
//                [current_Values setValue:@"" forKey:@"S2_AZ"];
//                [current_Values setValue:@"" forKey:@"S2_A_timestamp"];
//                [current_Values setValue:@"" forKey:@"S2_GX"];
//                [current_Values setValue:@"" forKey:@"S2_GY"];
//                [current_Values setValue:@"" forKey:@"S2_GZ"];
//                [current_Values setValue:@"" forKey:@"S2_G_timestamp"];
//            }
//            else
//            {
//                
//            [current_Values setValue:@"1" forKey:@"S1_AX"];
//            [current_Values setValue:@"2" forKey:@"S1_AY"];
//            [current_Values setValue:@"3" forKey:@"S1_AZ"];
//            [current_Values setValue:@"4" forKey:@"S1_A_timestamp"];
//            [current_Values setValue:@"5" forKey:@"S1_GX"];
//            [current_Values setValue:@"6" forKey:@"S1_GY"];
//            [current_Values setValue:@"7" forKey:@"S1_GZ"];
//            [current_Values setValue:@"8" forKey:@"S1_G_timestamp"];
//            [current_Values setValue:@"9" forKey:@"S2_AX"];
//            [current_Values setValue:@"10" forKey:@"S2_AY"];
//            [current_Values setValue:@"11" forKey:@"S2_AZ"];
//            [current_Values setValue:@"12" forKey:@"S2_A_timestamp"];
//            [current_Values setValue:@"13" forKey:@"S2_GX"];
//            [current_Values setValue:@"14" forKey:@"S2_GY"];
//            [current_Values setValue:@"15" forKey:@"S2_GZ"];
//            [current_Values setValue:@"16" forKey:@"S2_G_timestamp"];
//            
//
//            }
//            if(j == 3)
//                [current_Values setValue:@"10" forKey:@"S2_AX" atIndex:8];
//
////        if(![self dataExists:current_Values])
////            continue;
//                
////        NSDictionary *val = [NSDictionary dictionaryWithDictionary:dict];
//        
//        [[[TestDetails sharedInstance] dataPoints] addObject:current_Values];
//   //     sleep(100/1000);
//    }
//    
//    NSLog(@"%@",[[TestDetails sharedInstance] endTest]);
//
//    
//    
//}


#pragma mark - TableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sensorTags.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SensorTag_Cell"];
    CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",CFUUIDCreateString(nil, p.UUID)];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(self.sensorTags.count > 1)
            return [NSString stringWithFormat:@"%ld SensorTags Found",(unsigned long)self.sensorTags.count];
        else
            return [NSString stringWithFormat:@"%ld SensorTag Found",(unsigned long)self.sensorTags.count];
    }
    return @"";
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CBCentralManager Delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state == CBCentralManagerStateUnsupported)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Smart Not Supported!" message:@"Your Device does not support Bluetooth Smart. Please switch to iPhone 4S or a later model." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
    else if(central.state == CBCentralManagerStateUnauthorized)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Smart Not Authorized!" message:@"App not authoirzed to use Bluetooth Smart. Please Enable App's Bluetooh Access in 'Settings'." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else if(central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Issues!" message:@"Please turn on Bluetooth" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Found a BLE Device: %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */

    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheral Delegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services Scanned");
    
    [self.manager cancelPeripheralConnection:peripheral];
    for(CBService *s in peripheral.services)
    {
        NSLog(@"Service found: %@",s.UUID);
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])
        {
            NSLog(@"This is SensorTag!");
            found = YES;
        }
    }
    
    if(found)
    {
        //Match if we have this device from before
        for(int ii=0;ii<self.sensorTags.count;ii++)
        {
            CBPeripheral *p = [self.sensorTags objectAtIndexedSubscript:ii];
            if([p isEqual:peripheral])
            {
                [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if(!replace)
        {
            [self.sensorTags addObject:peripheral];
            [devicesTablesView reloadData];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

#pragma mark - SensorTag configuration
-(NSMutableDictionary *) makeSensorTagConfiguration
{
    //We only need accelerometer and Gyroscope so only set up these two and make the other inactive (active = 0)
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    // First we set ambient temperature
    [d setValue:@"0" forKey:@"Ambient temperature active"];
    // Then we set IR temperature
    [d setValue:@"0" forKey:@"IR temperature active"];

    // Then we setup the accelerometer

    [d setValue:@"1" forKey:@"Accelerometer active"];
    [d setValue:@"F000AA10-0451-4000-B000-000000000000"  forKey:@"Accelerometer service UUID"];
    [d setValue:@"F000AA11-0451-4000-B000-000000000000"  forKey:@"Accelerometer data UUID"];
    [d setValue:@"F000AA12-0451-4000-B000-000000000000"  forKey:@"Accelerometer config UUID"];
    [d setValue:@"F000AA13-0451-4000-B000-000000000000"  forKey:@"Accelerometer period UUID"];
    
    //Then we setup the rH sensor
    [d setValue:@"0" forKey:@"Humidity active"];
    
    //Then we setup the magnetometer
    [d setValue:@"0" forKey:@"Magnetometer active"];
    [d setValue:@"500" forKey:@"Magnetometer period"];
    
    //Then we setup the barometric sensor
    [d setValue:@"0" forKey:@"Barometer active"];
    
    [d setValue:@"1" forKey:@"Gyroscope active"];
    [d setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [d setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [d setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];
    [d setValue:@"F000AA53-0451-4000-B000-000000000000" forKey:@"Gyroscope period UUID"];

    NSLog(@"%@",d);
    
    return d;
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
        testController.devices = device;
    }
}

//#pragma mark - Test Functionality
//-(void)initialize
//{
//    time = 0;
//    lastTimestamp = 0;
//    
//    self.current_Values = [NSMutableArray arrayWithCapacity:13];
//    [self.current_Values setValue:@"" forKey:@"timestamp"];
//    [self.current_Values setValue:@"" forKey:@"S1_AX"];
//    [self.current_Values setValue:@"" forKey:@"S1_AY"];
//    [self.current_Values setValue:@"" forKey:@"S1_AZ"];
//    [self.current_Values setValue:@"" forKey:@"S1_GX"];
//    [self.current_Values setValue:@"" forKey:@"S1_GY"];
//    [self.current_Values setValue:@"" forKey:@"S1_GZ"];
//    [self.current_Values setValue:@"" forKey:@"S2_AX"];
//    [self.current_Values setValue:@"" forKey:@"S2_AY"];
//    [self.current_Values setValue:@"" forKey:@"S2_AZ"];
//    [self.current_Values setValue:@"" forKey:@"S2_GX"];
//    [self.current_Values setValue:@"" forKey:@"S2_GY"];
//    [self.current_Values setValue:@"" forKey:@"S2_GZ"];
//
//    [[TestDetails sharedInstance] startTest];
//    
//    timer = [NSTimer scheduledTimerWithTimeInterval:30.0/1000.0 target:self selector:@selector(generateNewValues) userInfo:nil repeats:YES];
//}
//
//-(void)generateNewValues
//{
//    int deviceIndex = arc4random() % 2;
//    
//    int initial_Index;
//    if(deviceIndex == 0)
//        initial_Index = 1;
//    else
//        initial_Index = 7;
//    
//    float x = arc4random() % 16 - 8;
//    float y = arc4random() % 16 - 8;
//    float z = arc4random() % 16 - 8;
//    
//    
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_AX",deviceIndex+1] atIndex:initial_Index];
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_AY",deviceIndex+1] atIndex:initial_Index+1];
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_AZ",deviceIndex+1] atIndex:initial_Index+2];
//    
//
//    x = arc4random() % 30;
//    y = arc4random() % 20;
//    z = arc4random() % 25;
//
//    
//    if(deviceIndex == 0)
//        initial_Index = 4;
//    else
//        initial_Index = 10;
//    
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",x] forKey:[NSString stringWithFormat:@"S%d_GX",deviceIndex+1] atIndex:initial_Index];
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",y] forKey:[NSString stringWithFormat:@"S%d_GY",deviceIndex+1] atIndex:initial_Index+1];
//    [self.current_Values setValue:[NSString stringWithFormat:@"%0.3f",z] forKey:[NSString stringWithFormat:@"S%d_GZ",deviceIndex+1] atIndex:initial_Index+2];
//    
//    [self logValues];
//    
//    if(time == 250)
//    {
//        NSLog(@"%@",[[TestDetails sharedInstance] endTest]);
//        [timer invalidate];
//    }
//    time++;
//
//}
//
//-(void)logValues
//{
//    //Return if all values are not present
//    NSMutableArray *vals = [NSMutableArray arrayWithArray:self.current_Values];
//    
//    NSString *timestamp = [[TestDetails sharedInstance] getFormattedTimestamp:YES];
//
//    BOOL dataExists = [self dataExists:vals];
//    
//    
//    NSLog(@"%.1f", [timestamp doubleValue]-lastTimestamp);
//    
//    
//    lastTimestamp = [timestamp doubleValue];
//    
//    if([[[TestDetails sharedInstance] dataPoints] count] == 0 && !dataExists)
//        return;
//    
//    [vals insertTimeStamp:timestamp atIndex:0];
//    
//    
//    [[[TestDetails sharedInstance] dataPoints] addObject:vals];
//    
//    //Remove the timestamp for the next set of values
//    //as the next set of value will have new timestamp
//    
// //   [self.current_Values removeObjectAtIndex:0];
//}
//
//-(BOOL)dataExists:(NSMutableArray*)array
//{
//    BOOL result = NO;
//    for(int i=0;i<[array count];i++)
//    {
//        if(![self isEmpty:[array objectAtIndex:i]])
//        {
//            result = YES;
//        }
//        else
//        {
//            [array removeObjectAtIndex:i];
//            i--;
//        }
//    }
//
//    if(!result)
//        NSLog(@"%@",self.current_Values);
//    
//    return result;
//}
//
//-(BOOL)isEmpty:(NSString*)str
//{
//    NSUInteger loc = [str rangeOfString:@":"].location;
//    str = [[str substringFromIndex:loc+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    
//    if([str length] == 0)
//        return YES;
//    else
//        return NO;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

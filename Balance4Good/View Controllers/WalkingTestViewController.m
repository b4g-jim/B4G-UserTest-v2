//
//  WalkingTestViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "WalkingTestViewController.h"
#import "TestDetails.h"
#import "PreparingViewController.h"
#import "TypeClass.h"

@interface WalkingTestViewController ()

@end

@implementation WalkingTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];

    [self initializeButtons];
    
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    if(![data objectForKey:@"name"])
    {
        [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please enter 'Personal Information' before starting a test" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }

}

//Initialize ShoeTypes, FloorTypes and Sensors. If you want to add more shoe types, you can add them here. name is what appear in the dropdown list while abbreviation appears in JSON

-(void)initializeButtons
{
    for(UIButton *button in walkingTestType)
    {
        if([button tag] == 0)
            selectedSensor = [[button titleLabel] text];
        
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0].CGColor;
        
        if(!button.isEnabled)
        {
            [button setBackgroundColor:[UIColor lightGrayColor]];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
    }
}

-(IBAction)changeSensorLocation:(UIButton*)sender
{
    [sender setSelected:YES];
    [sender setBackgroundColor:[UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    selectedSensor = [[sender titleLabel] text];

    for(UIButton *button in walkingTestType)
    {
        if(![button isEqual:sender] && [button isEnabled])
        {
            [button setSelected:NO];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button setTitleColor:[UIColor colorWithRed:17.0/255.0 green:78.0/255.0 blue:178.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
    
    if([selectedSensor containsString:@"External"] || [selectedSensor containsString:@"Three"])     //Check if external sensor is selected
    {
        [externalSensorsStatusView setHidden:NO];
        if(!self.manager)
            self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        else
            [self.manager scanForPeripheralsWithServices:nil options:nil];
        
    }
    else
    {
        [externalSensorsStatusView setHidden:YES];
        
        if(self.manager)
            [self.manager stopScan];
    }
}

//Initialize Data when view appears. This means start searching for the bluetooth devices and remove the already discovered devices (and research)
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startTest:(UIButton *)sender
{
    //A few conditions needs to be met in case a test is started. Do not start test if any of the following conditions are met
    //1. If sensor counts is less than two and sensor type is (on both ankles (index == 1))
    //2. If sensor count is less than 1 (No sensor connected)
    //3. If all the personal info is not added
    
#warning Uncomment after implemeting external sensors
    
    if([selectedSensor containsString:@"External"])     //Check if external sensor is selected
    {
        if(self.sensorTags.count<2 && [selectedSensor containsString:@"Both"])
        {
            [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please make sure both the sensors are connected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else if(self.sensorTags.count<1)
        {
            [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please make sure the sensor is connected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else
        {
            //Device is to be passed to the Testing Screen (TestViewController)
            //device.peripherals have the connected sensor Tags
            //device.manager is also transferred ahead (manager is used to connect to Bluetooth Smart Devices)
        
            device = [[BLEDevice alloc] init];
            device.peripherals = self.sensorTags;
            device.manager = self.manager;
            device.setupData = [self makeSensorTagConfiguration];
          

            [[TestDetails sharedInstance] startTestWithSensors:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "] andBalanceTestType:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "]];

            [self performSegueWithIdentifier:@"showTestingScreen" sender:nil];
        }
    }
    else  if([selectedSensor containsString:@"Three"])
    {
        if(self.sensorTags.count<2)
        {
            [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please make sure both the external sensors are connected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else
        {
            device = [[BLEDevice alloc] init];
            device.peripherals = self.sensorTags;
            device.manager = self.manager;
            device.setupData = [self makeSensorTagConfiguration];
            
            
            [[TestDetails sharedInstance] startTestWithSensors:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "] andBalanceTestType:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "]];
            
            [self performSegueWithIdentifier:@"showTestingScreen" sender:nil];
        }
    }
    else
    {
        device = nil;
        [[TestDetails sharedInstance] startTestWithSensors:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "] andBalanceTestType:[selectedSensor stringByReplacingOccurrencesOfString:@"\U00002028" withString:@" "]];
        [self performSegueWithIdentifier:@"showTestingScreen" sender:nil];
    }
}


#pragma mark - CBCentralManager Delegate
//Called when the Manager is initialized. It tell us whether BLE is support or not or whether it is authorized, powered on or off etc.

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
        //scan for all the devices providing any types of services
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //Called when device is discovered
    //Connect to that device
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    //add the discovered peripheral to nDevices as we currently don't know if
    [self.nDevices addObject:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //Once peripheral is connected, search for its services so that we can know if it is a sensorTag or not
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheral Delegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //Once services are discovered, we need to check if it is a SensorTag and if it is a sensorTag is it already added
    //If already added it is replaced else it is added to sensorTags array
    
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services Scanned");
    
    [self.manager cancelPeripheralConnection:peripheral];
    for(CBService *s in peripheral.services)
    {
        NSLog(@"Service found: %@",s.UUID);
        //This is the service UUID that tells us that the device is sensor Tag
        //We check all of the services of the peripheral/bluetooth device.
        
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])
        {
            NSLog(@"This is SensorTag!");
            found = YES;
        }
    }
    
    if(found)
    {
        //Match if we have this device from before
        //If yes, just replace it else add it.
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
        }
        
        //If no sensor tags are connected, both the status labels are OFF
        //If one is connected, first sensor status is ON and second is OFF
        //If both are connectd, both the sensors status are ON
        if([self.sensorTags count]==0)
        {
            [lblSensor1_status setText:@"OFF"];
            [lblSensor2_status setText:@"OFF"];
        }
        else if([self.sensorTags count] == 1)
        {
            [lblSensor1_status setText:@"ON"];
            [lblSensor2_status setText:@"OFF"];
        }
        else
        {
            [lblSensor1_status setText:@"ON"];
            [lblSensor2_status setText:@"ON"];
        }
        
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

#pragma mark - SensorTag configuration
//Configuring SensorTag Device. Taken from The TI Sample Code
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

- (IBAction)cancel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)keyboardDidAppear
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
}


-(void)done
{
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Called when a segue is called to switch from current view controller to the next one
// we are passing the device data (sensorTags, manager etc.) to the TestViewController devices so that they can be used there

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[PreparingViewController class]])
    {
        PreparingViewController *preparingController = [segue destinationViewController];
        preparingController.devices = device;
    }
}



@end

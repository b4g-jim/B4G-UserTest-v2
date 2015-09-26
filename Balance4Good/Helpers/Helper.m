//
//  Helper.m
//  Balance4Good
//
//  Created by Hira Daud on 7/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "Helper.h"
#import "TestDetails.h"
#import "SensorsHelper.h"

@implementation Helper

+(Helper*)sharedHelper
{
    static Helper *myHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        myHelper = [[self alloc] init];
    });
    
    return myHelper;
    
}

-(void) logValues:(NSTimer*)timer
{
    NSMutableDictionary *vals = [NSMutableDictionary dictionaryWithDictionary:[SensorsHelper sharedHelper].sensorReadings];
    
    BOOL dataExists = [self dataExists:vals];
    
    //If data does not exists & there are no data points already,don't log data.
    if([[[TestDetails sharedInstance] dataPoints] count] == 0 && !dataExists)
        return;
    
    //Just a redundant check for <50ms data as sometimes we just get only timestamp logged.
    if([vals count] == 0)
        return;
    
    //add timestamp (only for external sensors
    if(timer)
        [vals setObject:[[TestDetails sharedInstance] getFormattedTimestamp:YES] forKey:@"timestamp"];
    
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

-(int)getDeviceIndex:(CBPeripheral*)peripheral inDevices:(NSArray*)peripherals
{
    for(int i=0;i<peripherals.count;i++)
    {
        CBPeripheral *peri = [peripherals objectAtIndex:i];
        if([peripheral isEqual:peri])
            return i;
    }
    return -1;
}



@end

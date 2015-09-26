//
//  AppDelegate.m
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "AppDelegate.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Please set Initial Values for the Technical Configuration Here
    //Values for AWS ACCESS_KEY, SECRET_KEY and BUCKET_NAME needs to be set in Constants.m
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"updateRate"];
        [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"total_walk_time"];
        [[NSUserDefaults standardUserDefaults] setObject:BUCKET_NAME forKey:@"bucket_name"];
        [[NSUserDefaults standardUserDefaults] setObject:ACCESS_KEY forKey:@"access_key"];

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //Just to make authorization Dialog appear at first run
    self.locationManager = [[CLLocationManager alloc] init];
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];


    //Initial settings for AWS
    // If you change ACCESS_KEY in Constants.m, please do chang SECRET_KEY to its correspoding key otherwise
    // upload won't work
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_key"] secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

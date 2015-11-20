//
//  HRPLocationManager.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLocationManager.h"

@interface HRPLocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *clLocationManager;

@end

@implementation HRPLocationManager

+ (HRPLocationManager *)sharedInstance
{
    static HRPLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(instance == nil)
        {
            if (![CLLocationManager locationServicesEnabled])
            {
                NSLog(@"location services are disabled");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
            {
                NSLog(@"location services are blocked by the user");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
            {
                NSLog(@"location services are enabled");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            {
                NSLog(@"about to show a dialog requesting permission");
            }
            instance = [[HRPLocationManager alloc] init];
            instance.clLocationManager = [[CLLocationManager alloc] init];
            instance.clLocationManager.delegate = instance;
            instance.clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            instance.clLocationManager.distanceFilter = 100.0f;
            instance.clLocationManager.headingFilter = 5;
            if ([instance.clLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [instance.clLocationManager requestWhenInUseAuthorization];
            }
            if ([CLLocationManager locationServicesEnabled])
            {
                [instance.clLocationManager startUpdatingLocation];
            }
        }
    });
    return instance;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"User has denied location services");
    } else
    {
        NSLog(@"Location manager did fail with error: %@", error.localizedFailureReason);
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
    NSDate *date = [NSDate date];
    [date dateByAddingTimeInterval:-60*1];
    if ([self.location.timestamp compare:date] == NSOrderedDescending)
    {
        [self.clLocationManager stopUpdatingLocation];
    }
    self.clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.delegate didUpdateLocation:self.location];
}

@end
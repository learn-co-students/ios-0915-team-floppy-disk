//
//  HRPMapsViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "HRPMapsViewController.h"
#import "CLLocationManager+Shared.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign) CGFloat startingLatitude;
@property (nonatomic, assign) CGFloat startingLongitude;
@property (nonatomic, assign) CGFloat endingLatitude;
@property (nonatomic, assign) CGFloat endingLongitude;

@end

@implementation HRPMapsViewController
{
    GMSMapView *mapView_;
}

- (void)viewDidLoad
{
    self.startingLatitude = 40.693487;
    self.startingLongitude = -74.036034;
    self.endingLatitude = 40.886095;
    self.endingLongitude = -73.877143;
    
    float cameraPositionLatitude = (self.startingLatitude + self.endingLatitude) / 2.0;
    float cameraPositionLongitide = (self.startingLongitude + self.endingLongitude) / 2.0;
    
    //this is not working the way I want it to
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:cameraPositionLatitude longitude:cameraPositionLongitide zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.delegate = self;
    
    self.locationManager = [CLLocationManager sharedManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self locationManagerPermissions];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManagerPermissions
{
    if(IS_OS_8_OR_LATER)
    {
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"])
            {
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"])
            {
                [self.locationManager  requestWhenInUseAuthorization];
            } else
            {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"FOUND YOU: %@", self.locationManager.location);
    self.currentLocation = self.locationManager.location;
    
    [manager stopUpdatingLocation];
    [self updateMapWithCurrentLocation];
}

- (void)updateMapWithCurrentLocation
{
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    // Create a GMSCameraPosition that tells the map to display
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:17];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = mapView_;
    [mapView_ setMinZoom:12 maxZoom:mapView_.maxZoom];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
}

// Called if getting user location fails
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
}

#pragma mark - UIAlertView (should update to viewController)

// Called to send the user to the Settings for this app
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)delegateMapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if(delegateMapView.camera.target.latitude > self.startingLatitude)
    {
        [delegateMapView animateToCameraPosition:[GMSCameraPosition
                                                  cameraWithLatitude:self.startingLatitude
                                                  longitude:delegateMapView.camera.target.longitude
                                                  zoom:delegateMapView.camera.zoom]];
    }
    if(delegateMapView.camera.target.latitude < self.endingLatitude)
    {
        [delegateMapView animateToCameraPosition:[GMSCameraPosition
                                                  cameraWithLatitude:self.endingLatitude
                                                  longitude:delegateMapView.camera.target.longitude
                                                  zoom:delegateMapView.camera.zoom]];
    }
    if(delegateMapView.camera.target.longitude < self.startingLongitude)
    {
        [delegateMapView animateToCameraPosition:[GMSCameraPosition
                                                  cameraWithLatitude:delegateMapView.camera.target.latitude
                                                  longitude:self.startingLongitude
                                                  zoom:delegateMapView.camera.zoom]];
    }
    if(delegateMapView.camera.target.longitude > self.endingLongitude)
    {
        [delegateMapView animateToCameraPosition:[GMSCameraPosition
                                                  cameraWithLatitude:delegateMapView.camera.target.latitude
                                                  longitude:self.endingLongitude
                                                  zoom:delegateMapView.camera.zoom]];
    }
}

@end
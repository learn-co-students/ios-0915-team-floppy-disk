//
//  HRPMapsViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "HRPMapsViewController.h"
#import "HRPLocationManager.h"
#import "HRPAddPostViewController.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate, HRPAddPostViewControllerDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (weak, nonatomic) IBOutlet UIButton *postSongButton;

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
    mapView_.delegate = self;
    
    self.locationManager = [CLLocationManager sharedManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self locationManagerPermissions];
}

-(void)viewDidAppear:(BOOL)animated
{
    //because of this, the marker i've added disappears.  this reloads the view, in a way, by calling the startUpdatingLocation method
    //if the marker were a property on parse, it could be sustained
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
    // this determines the zoom of the camera as soon as the map opens; the higher the number, the more detail we see on the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:18];
//    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//    self.view = mapView_;
    
    mapView_ = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    [self.view insertSubview:mapView_ atIndex:0];
    [mapView_ setMinZoom:12 maxZoom:mapView_.maxZoom];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
}

// Called if getting user location fails
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    // This should be uncommented when we use actual devices to test GPS.
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//    
//    [errorAlerts addAction:okAction];
//    
//    [self presentViewController:errorAlerts animated:YES completion:nil];
}

- (IBAction)postSongButtonTapped:(id)sender
{
//    [self.defaultMarkerImage.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    
    if ([self.postSongButton.titleLabel.text isEqualToString:@"Post a Song"])
    {
        self.postSongButton.titleLabel.text = @"Post Song Here";
        self.postSongButton.backgroundColor = [UIColor blueColor];
    }
    else if ([self.postSongButton.titleLabel.text isEqualToString:@"Post Song Here"])
    {
        CGPoint point = mapView_.center;
        CLLocationCoordinate2D coordinates = [mapView_.projection coordinateForPoint:point];
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.position = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        marker.map = mapView_;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HRPAddPostViewController *addPostDVC = segue.destinationViewController;
    addPostDVC.delegate = self;
}

- (void)addPostViewController:(id)viewController didFinishWithLocation:(CLLocation *)location
{
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    marker.map = mapView_;
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPostViewControllerDidCancel:(HRPAddPostViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
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
#import "HRPTrackSearchViewController.h"
#import "HRPPost.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *defaultMarker;
@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (weak, nonatomic) IBOutlet UIButton *postSongButton;
@property (nonatomic, assign) BOOL readyToPin;
@property (nonatomic, assign) BOOL scrollGestures;
@property (nonatomic, strong) GMSCoordinateBounds *bounds;

@end

@implementation HRPMapsViewController
{
    GMSMapView *mapView_;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavBar];
    
    self.locationManager = [CLLocationManager sharedManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self locationManagerPermissions];
    
    self.defaultMarkerImage.hidden = YES;
    self.readyToPin = NO;
    
    [self.postSongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.postSongButton setBackgroundColor:[UIColor darkGrayColor]];
    
    mapView_.settings.scrollGestures = YES;
    
    //[self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Setup methods

-(void)setupNavBar
{
    self.navigationController.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName:
                                                                 [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]
                                                             }];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [[UINavigationBar appearance] setBarStyle:UIStatusBarStyleLightContent];
//    [self preferredStatusBarStyle];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

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
    
    CGFloat coordinateDifference = 0.1;
    
    CGFloat firstLatitude = coordinate.latitude;
    firstLatitude += coordinateDifference;
    
    CGFloat firstLongitude = coordinate.longitude;
    firstLongitude += coordinateDifference;
    NSLog(@"new latitude: %f, longitude: %f", firstLatitude, firstLongitude);
    
    CLLocationDegrees topLat = firstLatitude;
    CLLocationDegrees topLon = firstLongitude;
    CLLocationCoordinate2D northEastCoordinate = CLLocationCoordinate2DMake(topLat, topLon);
    
    CGFloat secondLatitude = coordinate.latitude;
    secondLatitude -= coordinateDifference;
    
    CGFloat secondLongitude = coordinate.longitude;
    secondLongitude -= coordinateDifference;
    NSLog(@"new latitude: %f, longitude: %f", secondLatitude, secondLongitude);
    
    CLLocationDegrees botLat = secondLatitude;
    CLLocationDegrees botLon = secondLongitude;
    CLLocationCoordinate2D southWestCoordinate = CLLocationCoordinate2DMake(botLat, botLon);
    
    self.bounds = [[GMSCoordinateBounds alloc] init];
    self.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEastCoordinate coordinate:southWestCoordinate];
    
    NSLog(@"BOUNDS: %f, %f || %f, %f", self.bounds.northEast.latitude, self.bounds.northEast.longitude, self.bounds.southWest.latitude, self.bounds.southWest.longitude);
    
    // Create a GMSCameraPosition that tells the map to display
    // this determines the zoom of the camera as soon as the map opens; the higher the number, the more detail we see on the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:18];
    
    //this controls the map size on the view
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - (self.view.bounds.size.height * 0.08));
    mapView_ = [GMSMapView mapWithFrame:rect camera:camera];
    
    //this sets the mapView_ at the very background of the view
    [self.view insertSubview:mapView_ atIndex:0];
    
    mapView_.delegate = self;
    mapView_.indoorEnabled = NO;
    
    [mapView_ setMinZoom:13 maxZoom:mapView_.maxZoom];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if ([self.bounds containsCoordinate:position.target])
    {
        NSLog(@"we are within bounds!");
        NSLog(@"camera: %f, %f", position.target.latitude, position.target.longitude);
        self.scrollGestures = YES;
    }
    else
    {
        NSLog(@"we are not in bounds");
        self.scrollGestures = NO;
        [mapView_ animateToLocation:self.currentLocation.coordinate];
    }
    if (!self.scrollGestures)
    {
        mapView_.settings.scrollGestures = NO;
    }
    else
    {
        mapView_.settings.scrollGestures = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [errorAlerts addAction:okAction];
    
    [self presentViewController:errorAlerts animated:YES completion:nil];
    //    [manager stopUpdatingLocation];
    //this prevents further warnings from the alert controller but also doesn't show a map at all
}

#pragma mark - Action Methods

- (IBAction)postSongButtonTapped:(id)sender
{
    NSLog(@"method entered");
    NSLog(@"button text: %@", self.postSongButton.titleLabel.text);
    
    if (self.defaultMarkerImage.hidden)
    {
        NSLog(@"marker is hidden");
        self.defaultMarkerImage.hidden = NO;
    }
    else
    {
        NSLog(@"marker is NOT hidden");
        self.defaultMarkerImage.hidden = YES;
    }
    [self changeButtonBackground];
}

-(HRPPost *)postWithCurrentMapPosition
{
    CGPoint point = mapView_.center;
    CLLocationCoordinate2D coordinates = [mapView_.projection coordinateForPoint:point];
    
    NSLog(@"inside the block");
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.position = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
    marker.map = mapView_;
    
    CGFloat latitude = marker.position.latitude;
    CGFloat longitude = marker.position.longitude;
    
    NSLog(@"marker: %@", marker);
    NSLog(@"marker.icon = %@", marker.icon);
    NSLog(@"marker.position = (%f, %f)", marker.position.latitude, marker.position.longitude);
    NSLog(@"marker.map = %@", marker.map);
    
    HRPPost *newPost = [[HRPPost alloc] initWithLatitude:latitude Longitude:longitude];
    
    return newPost;
}

- (void)changeButtonBackground
{
    if (self.readyToPin)
    {
        [self.postSongButton setBackgroundColor:[UIColor darkGrayColor]];
        self.readyToPin = NO;
        
        [self performSegueWithIdentifier:@"showTrackViews" sender:nil];
    }
    else
    {
        [self.postSongButton setBackgroundColor:[UIColor orangeColor]];
        self.readyToPin = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"alert controller method hit");
    UIAlertController *confirmPinAlert = [UIAlertController alertControllerWithTitle:@"Confirm Pin" message:@"Post song here?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CLLocationCoordinate2D coordinatesAtMapCenter = [self findCoordinatesAtMapCenter];
        
        NSLog(@"inside the block");

    if([segue.identifier isEqualToString:@"showTrackViews"])
    {
        UINavigationController *navController = segue.destinationViewController;
        HRPTrackSearchViewController *destinVC = navController.viewControllers.firstObject;
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.position = CLLocationCoordinate2DMake(coordinatesAtMapCenter.latitude, coordinatesAtMapCenter.longitude);
        marker.map = mapView_;
        
        NSLog(@"marker: %@", marker);
        NSLog(@"marker.icon = %@", marker.icon);
        NSLog(@"marker.position = (%f, %f)", marker.position.latitude, marker.position.longitude);
        NSLog(@"marker.map = %@", marker.map);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [confirmPinAlert addAction:confirmAction];
    [confirmPinAlert addAction:cancelAction];
    
    [self presentViewController:confirmPinAlert animated:YES completion:nil];
        
        destinVC.post = [self postWithCurrentMapPosition];
     }
    }];
}

- (CLLocationCoordinate2D)findCoordinatesAtMapCenter
{
    CGPoint point = mapView_.center;
    return [mapView_.projection coordinateForPoint:point];
}

@end
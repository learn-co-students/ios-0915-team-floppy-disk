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
#import <Parse/Parse.h>
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *defaultMarker;
@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (weak, nonatomic) IBOutlet UIButton *postSongButton;
@property (nonatomic, assign) BOOL readyToPin;
@property (nonatomic, assign) BOOL scrollGestures;
@property (nonatomic, strong) GMSCoordinateBounds *bounds;
@property (nonatomic, strong) NSArray *parsePosts;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation HRPMapsViewController
{
    GMSMapView *mapView_;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.navCont = self.navigationController;
    
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    self.title = @"HARPY";

    self.locationManager = [CLLocationManager sharedManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self locationManagerPermissions];
    
    self.defaultMarkerImage.hidden = YES;
    self.readyToPin = NO;
    
    [self.postSongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.postSongButton setBackgroundColor:[UIColor colorWithRed:0.18 green:0.21 blue:0.31 alpha:1.0]];
    
    mapView_.settings.scrollGestures = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Parse Geopoints

- (void)queryForHRPosts
{
    if (self.currentLocation)
    {
        CLLocationCoordinate2D currentCoordinate = [self.currentLocation coordinate];
        PFGeoPoint *currentUserGeoPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
        
        NSLog(@"CURRENT USER GEOPOINT: %@", currentUserGeoPoint);
        PFQuery *query = [PFQuery queryWithClassName:@"HRPPost"];
        [query whereKey:@"locationGeoPoint" nearGeoPoint:currentUserGeoPoint withinMiles:100.0];
        query.limit = 10;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        self.navigationItem.titleView = self.activityIndicator;
        [self.activityIndicator startAnimating];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            [self.activityIndicator stopAnimating];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.text = @"HARPY";
            label.textAlignment = NSTextAlignmentCenter;
            self.navigationItem.titleView = label;

            if (!error)
            {
                self.parsePosts = objects;
                NSLog(@"PARSE POSTS: %@", self.parsePosts);
                
                for (NSUInteger i = 0; i < self.parsePosts.count; i++)
                {
                    NSDictionary *HRPPosts = self.parsePosts[i];
                    NSLog(@"PARSE DICTIONARY: %@", HRPPosts);
                    
                    PFGeoPoint *HRPGeoPoint = HRPPosts[@"locationGeoPoint"];
                    NSLog(@"geoPointString %@", HRPGeoPoint);
                    
                    CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                    NSLog(@"postCoordinate %f, %f", postCoordinate.latitude, postCoordinate.longitude);
                    
                    GMSMarker *marker = [[GMSMarker alloc] init];
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                    marker.position = postCoordinate;
                    marker.map = mapView_;
                    NSLog(@"marker: %@", marker);
                    
                    for (PFObject *post in objects) {
                        PFRelation *userRelation = [post relationForKey:@"username"];
                        PFQuery *userUsername = [userRelation query];
                        [userUsername  findObjectsInBackgroundWithBlock:^(NSArray * user, NSError * error2) {
                            for (PFObject *username in user) {
                                NSLog(@"USERNAME: %@", username[@"username"]);
                            }
                        }];
                    }
                }
                
                
            } else
            {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
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
    [self setBounds];
    [self setCamera];
    
    mapView_.delegate = self;
    mapView_.indoorEnabled = NO;
    
    [mapView_ setMinZoom:13 maxZoom:mapView_.maxZoom];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    
    [self queryForHRPosts];
}

- (void)setBounds
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
    
    CLLocationDegrees botLat = secondLatitude;
    CLLocationDegrees botLon = secondLongitude;
    CLLocationCoordinate2D southWestCoordinate = CLLocationCoordinate2DMake(botLat, botLon);
    
    self.bounds = [[GMSCoordinateBounds alloc] init];
    self.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEastCoordinate coordinate:southWestCoordinate];
}

- (void)setCamera
{
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:17];
    
    //this controls the map size on the view
    CGFloat h = self.topLayoutGuide.length;
    CGRect rect = CGRectMake(0, h, self.view.bounds.size.width, self.view.bounds.size.height - (self.view.bounds.size.height * 0.08));
    mapView_ = [GMSMapView mapWithFrame:rect camera:camera];
    
    [self.view insertSubview:mapView_ atIndex:0];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if ([self.bounds containsCoordinate:position.target])
    {
        self.scrollGestures = YES;
    }
    else
    {
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
    NSLog(@"error: %@", error);
    
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [errorAlerts addAction:okAction];
    
//    [self presentViewController:errorAlerts animated:YES completion:nil];
    //    [manager stopUpdatingLocation];
    //this prevents further warnings from the alert controller but also doesn't show a map at all in simulator
}

#pragma mark - Action Methods

- (IBAction)profileButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showUserProfile" sender:self];
}
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
    CLLocationCoordinate2D coordinates = [self findCoordinatesAtMapCenter];
    
    NSLog(@"inside the block");
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.position = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
    marker.map = mapView_;
    NSLog(@"marker in other method: %@", marker);
    
    CGFloat latitude = marker.position.latitude;
    CGFloat longitude = marker.position.longitude;
    NSLog(@"LAT: %f\nLONG: %F", latitude, longitude);
    NSLog(@"marker: %@", marker);
    NSLog(@"marker.icon = %@", marker.icon);
    NSLog(@"marker.position = (%f, %f)", marker.position.latitude, marker.position.longitude);
    NSLog(@"marker.map = %@", marker.map);
    
    HRPPost *newPost = [[HRPPost alloc] initWithLatitude:latitude Longitude:longitude];
    
    return newPost;
}

- (CLLocationCoordinate2D)findCoordinatesAtMapCenter
{
    CGPoint point = mapView_.center;
    return [mapView_.projection coordinateForPoint:point];
}

- (void)changeButtonBackground
{
    if (self.readyToPin)
    {
        [self.postSongButton setBackgroundColor:[UIColor colorWithRed:0.18 green:0.21 blue:0.31 alpha:1.0]];
        self.readyToPin = NO;
        
        [self performSegueWithIdentifier:@"showTrackViews" sender:nil];
    }
    else
    {
        [self.postSongButton setBackgroundColor:[UIColor colorWithRed:0.64 green:0.35 blue:0.34 alpha:1.0]];
        self.readyToPin = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSLog(@"alert controller method hit");
//    UIAlertController *confirmPinAlert = [UIAlertController alertControllerWithTitle:@"Confirm Pin" message:@"Post song here?" preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        CLLocationCoordinate2D coordinatesAtMapCenter = [self findCoordinatesAtMapCenter];
//        
//        NSLog(@"inside the block");
//
    if([segue.identifier isEqualToString:@"showTrackViews"])
    {
        UINavigationController *navController = segue.destinationViewController;
        HRPTrackSearchViewController *destinVC = navController.viewControllers.firstObject;
        
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
//        marker.position = CLLocationCoordinate2DMake(coordinatesAtMapCenter.latitude, coordinatesAtMapCenter.longitude);
//        marker.map = mapView_;
//        
//        NSLog(@"marker: %@", marker);
//        NSLog(@"marker.icon = %@", marker.icon);
//        NSLog(@"marker.position = (%f, %f)", marker.position.latitude, marker.position.longitude);
//        NSLog(@"marker.map = %@", marker.map);
//        
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    
//    [confirmPinAlert addAction:confirmAction];
//    [confirmPinAlert addAction:cancelAction];
    
//    [self presentViewController:confirmPinAlert animated:YES completion:nil];
    
        destinVC.post = [self postWithCurrentMapPosition];
     }
//    }];
}

@end
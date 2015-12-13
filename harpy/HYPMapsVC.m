//
//  HYPMapsVC.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "HYPMapsVC.h"
#import "UIColor+HRPColor.h"
#import <Parse/Parse.h>
#import "CLLocationManager+Shared.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HYPMapsVC () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (nonatomic, strong) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *defaultMarker;
@property (nonatomic, assign) BOOL readyToPin;
@property (nonatomic, assign) BOOL scrollGestures;
@property (nonatomic, strong) GMSCoordinateBounds *bounds;
@property (nonatomic, strong) NSArray *parsePosts;
@property (nonatomic, strong) CLLocation *newestLocation;
@property (nonatomic) UIView *modalView;

@end

@implementation HYPMapsVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager sharedManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    
    self.mapView.settings.scrollGestures = YES;
    self.mapView.delegate = self;
    
    [self locationManagerPermissions];
    [self.locationManager startUpdatingLocation];
    [self queryForHRPosts];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        [query whereKey:@"locationGeoPoint" nearGeoPoint:currentUserGeoPoint withinMiles:3.5];
        query.limit = 10;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             
             if (!error)
             {
                 [self.modalView removeFromSuperview];
                 
                 self.parsePosts = objects;
                 NSLog(@"THERE ARE %lu PARSE POSTS.", self.parsePosts.count);
                 
                 for (NSUInteger i = 0; i < self.parsePosts.count; i++)
                 {
                     NSDictionary *HRPPosts = self.parsePosts[i];
                     NSLog(@"POSTED SONG: %@", HRPPosts[@"songTitle"]);
                     
                     PFGeoPoint *HRPGeoPoint = HRPPosts[@"locationGeoPoint"];
                     NSLog(@"geoPointString %f, %f", HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                     
                     CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                     NSLog(@"postCoordinate %f, %f", postCoordinate.latitude, postCoordinate.longitude);
                     
                     GMSMarker *marker = [[GMSMarker alloc] init];
                     marker.icon = [GMSMarker markerImageWithColor:[UIColor spyroDiscoDance]];
                     marker.position = postCoordinate;
                     marker.map = self.mapView;
                 }
             }
             else if ([error.domain isEqual:PFParseErrorDomain] && error.code == kPFErrorConnectionFailed)
             {
                 //                NSLog(@"Error: %@ %@", error, [error userInfo]);
                 NSLog(@"OH MY GOD THERE WAS AN INTERNET ERRORRRRRRRR");
             }
         }];
    }
}

#pragma mark - Action Methods

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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.newestLocation = self.locationManager.location;
        NSLog(@"FOUND YOU THE FIRST TIME: %@", self.locationManager.location);
        self.currentLocation = self.locationManager.location;
        [self updateMapWithCurrentLocation];
    });
    
    NSTimeInterval locationAge = -[self.newestLocation.timestamp timeIntervalSinceNow];
    //NSLog(@"locationAge %f", locationAge);
    if (locationAge > 300) // 5 mins in seconds
    {
        CLLocation *compareLocation = self.locationManager.location;
        double distance = [self.newestLocation distanceFromLocation:compareLocation];
        //NSLog(@"DISTANCE: %f", distance);
        if (distance > 320) // 0.20 miles in meters
        {
            self.newestLocation = self.locationManager.location;
            //NSLog(@"FOUND YOU AGAIN @: %@", self.locationManager.location);
            self.currentLocation = self.locationManager.location;
            [self updateMapWithCurrentLocation];
        }
        else
        {
            //NSLog(@"YOU DIDNT MOVE ENOUGH");
            self.newestLocation = self.locationManager.location;
        }
    }
}
- (void)updateMapWithCurrentLocation
{
    [self setBounds];
    [self setCamera];
    
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    
    [self.mapView setMinZoom:13 maxZoom:self.mapView.maxZoom];
    
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    [self queryForHRPosts];
}
- (void)setBounds
{
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    CGFloat coordinateDifference = 0.002;
    
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
    CGRect rect = CGRectMake(0, h, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mapView = [GMSMapView mapWithFrame:rect camera:camera];
    
    [self.view insertSubview:self.mapView atIndex:0];
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
        [self.mapView animateToLocation:self.currentLocation.coordinate];
    }
    if (!self.scrollGestures)
    {
        self.mapView.settings.scrollGestures = NO;
    }
    else
    {
        self.mapView.settings.scrollGestures = YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
    
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [errorAlerts addAction:okAction];
}
- (CLLocationCoordinate2D)findCoordinatesAtMapCenter
{
    CGPoint point = self.mapView.center;
    return [self.mapView.projection coordinateForPoint:point];
}



@end


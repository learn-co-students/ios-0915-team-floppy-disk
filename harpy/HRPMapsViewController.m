//
//  HRPMapsViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "HRPMapsViewController.h"
#import "HRPProfileVC.h"
#import "HRPLocationManager.h"
#import "HRPTrackSearchViewController.h"
#import "HRPPost.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "HRPPostFeedViewController.h"
#import "UINavigationController+StatusBarStyle.h"
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate, SPTAuthViewDelegate>


@property (nonatomic, strong) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *defaultMarker;
@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (weak, nonatomic) IBOutlet UIButton *postSongButton;
@property (nonatomic, assign) BOOL readyToPin;
@property (nonatomic, assign) BOOL scrollGestures;
@property (nonatomic, strong) GMSCoordinateBounds *bounds;
@property (nonatomic, strong) NSArray *parsePosts;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CLLocation *newestLocation;

@end

@implementation HRPMapsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    
    
    self.navCont = self.navigationController;
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
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
    [self.postSongButton setBackgroundColor:[UIColor blackColor]];
    
    self.mapView.settings.scrollGestures = YES;
    self.mapView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW WILL APPEAR");
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (auth.session == nil) {
        NSLog(@"STATEMENT 3 TRUE");
        [self openLogInPage];
        [super viewDidAppear:animated];
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
        return;
    }
    if ([auth.session isValid])
    {
        NSLog(@"STATEMENT 1 TRUE");
        [super viewDidAppear:animated];
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
        return;
    }
    if (![auth.session isValid] && auth.hasTokenRefreshService) {
        NSLog(@"STATEMENT 2 TRUE");
        [self renewTokenAndSegue];
        [super viewDidAppear:animated];
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
        return;
    }
    
//    [super viewDidAppear:animated];
//    [self.locationManager startUpdatingLocation];
//    [self queryForHRPosts];
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
                NSLog(@"THERE ARE %lu PARSE POSTS.", self.parsePosts.count);
                
                for (NSUInteger i = 0; i < self.parsePosts.count; i++)
                {
                    NSDictionary *HRPPosts = self.parsePosts[i];
//                    NSLog(@"PARSE DICTIONARY: %@", HRPPosts);
                    NSLog(@"POSTED SONG: %@", HRPPosts[@"songTitle"]);
                    
                    PFGeoPoint *HRPGeoPoint = HRPPosts[@"locationGeoPoint"];
                    NSLog(@"geoPointString %f, %f", HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                    
                    CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                    NSLog(@"postCoordinate %f, %f", postCoordinate.latitude, postCoordinate.longitude);
                    
                    GMSMarker *marker = [[GMSMarker alloc] init];
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                    marker.position = postCoordinate;
                    marker.map = _mapView;
                    
                    for (PFObject *post in objects)
                    {
                        PFRelation *userRelation = [post relationForKey:@"username"];
                        PFQuery *userUsername = [userRelation query];
                        [userUsername  findObjectsInBackgroundWithBlock:^(NSArray * user, NSError * error2) {
                            for (PFObject *username in user)
                            {
                            }
                        }];
                    }
//FROM MERGE CONFLICT                    //marker.map = self.mapView;

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
    NSLog(@"locationAge %f", locationAge);
    if (locationAge > 300) // 5 mins in seconds
    {
        CLLocation *compareLocation = self.locationManager.location;
        double distance = [self.newestLocation distanceFromLocation:compareLocation];
        NSLog(@"DISTANCE: %f", distance);
        if (distance > 320) // 0.20 miles in meters
        {
            self.newestLocation = self.locationManager.location;
            NSLog(@"FOUND YOU AGAIN @: %@", self.locationManager.location);
            self.currentLocation = self.locationManager.location;
            [self updateMapWithCurrentLocation];
        }
        else
        {
            NSLog(@"YOU DIDNT MOVE ENOUGH");
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
    CGRect rect = CGRectMake(0, h, self.view.bounds.size.width, self.view.bounds.size.height - (self.view.bounds.size.height * 0.08));
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
    
//    [self presentViewController:errorAlerts animated:YES completion:nil];
    //    [manager stopUpdatingLocation];
    //this prevents further warnings from the alert controller but also doesn't show a map at all in simulator
}

#pragma mark - Action Methods

- (IBAction)profileButtonTapped:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    HRPProfileVC *profileView = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    profileView.user = [PFUser currentUser];
    [self.navigationController pushViewController:profileView animated:YES];
}
- (IBAction)postSongButtonTapped:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
        
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
    //marker.map = mapView_;
    marker.map = self.mapView;
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
    CGPoint point = self.mapView.center;
    return [self.mapView.projection coordinateForPoint:point];
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
    if([segue.identifier isEqualToString:@"showTrackViews"])
    {
        UINavigationController *navController = segue.destinationViewController;
        HRPTrackSearchViewController *destinVC = navController.viewControllers.firstObject;
    
        destinVC.post = [self postWithCurrentMapPosition];
     }
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    for (NSDictionary *post in self.parsePosts) {
        PFGeoPoint *postGeo = post[@"locationGeoPoint"];
        if (marker.position.latitude == postGeo.latitude &&
            marker.position.longitude == postGeo.longitude) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"postTable" bundle:nil];
            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"postViewNavController"];
            HRPPostFeedViewController *postView = navController.viewControllers.firstObject;
            postView.postsArray = [NSMutableArray new];
            [postView.postsArray addObject:post];
            [self.navigationController pushViewController:postView animated:YES];
            //[self presentViewController:postView animated:YES completion:nil];
        }
    }
    return YES;
}

//spotify login methods


-(void)showSafariVCForSpotifyLogin
{
    //safari VC stuff
}

-(void)sessionUpdatedNotification:(NSNotification *)notification
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        //stay on map
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)renewTokenAndSegue
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        //stay on map
    }];
}

-(void)openLogInPage
{
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error
{
    
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session
{
    
}
-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
    
}

@end
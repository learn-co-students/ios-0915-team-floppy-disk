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
#import "HRPPostPreviewViewController.h"
#import "HRPNetworkAlertVC.h"
#import "HRPUserSearchVC.h"
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate, SPTAuthViewDelegate, loadNewPostPinsDelegate>


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
@property (nonatomic, strong) CLLocation *firstLocation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;
@property (nonatomic) UIView *modalView;

@end

@implementation HRPMapsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    self.title = @"HARPY";
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
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
    
    [self.mapView.bottomAnchor constraintEqualToAnchor:self.postSongButton.topAnchor].active = YES;
    
    HRPPostPreviewViewController *newView = [[HRPPostPreviewViewController alloc]init];
    newView.delegate = self;
}

-(void)dealloc
{
    // for some reason, location manager's delegate property is assign, not weak...
    // that, plus the fact that we have a singleton instance of the location manager, means that we
    // can wind up with the location manager trying to talk to a bum instance of this VC.
    // ugh ugh ugh. so nil-ing it out this way at least fixes up that crash..
    self.locationManager.delegate = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (auth.session == nil) {
        [self openLogInPage];
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
    }
    else if ([auth.session isValid])
    {
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
    }
    else if (![auth.session isValid] && auth.hasTokenRefreshService) {
        [self renewTokenAndSegue];
        [self.locationManager startUpdatingLocation];
        [self queryForHRPosts];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapView clear];
}

#pragma mark - Parse Geopoints

- (void)queryForHRPosts
{
    if (self.currentLocation)
    {
        CLLocationCoordinate2D currentCoordinate = [self.currentLocation coordinate];
        PFGeoPoint *currentUserGeoPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
        
        PFQuery *query = [PFQuery queryWithClassName:@"HRPPost"];
        [query whereKey:@"locationGeoPoint" nearGeoPoint:currentUserGeoPoint withinMiles:3.5];
        query.limit = 20;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        self.navigationItem.titleView = self.activityIndicator;
        [self.activityIndicator startAnimating];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             [self.activityIndicator stopAnimating];
             
             if (!error)
             {
                 [self.modalView removeFromSuperview];
                 
                 UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
                 label.backgroundColor = [UIColor clearColor];
                 label.textColor = [UIColor whiteColor];
                 label.font = [UIFont boldSystemFontOfSize:18];
                 label.text = @"HARPY";
                 label.textAlignment = NSTextAlignmentCenter;
                 self.navigationItem.titleView = label;
                 
                 UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]init];
                 leftButton.action = @selector(profileSecondButtonTapped);
                 leftButton.image = [UIImage imageNamed:@"user.png"];
                 leftButton.target = self;
                 leftButton.tintColor = [UIColor whiteColor];
                 self.navigationItem.leftBarButtonItem = leftButton;
                 
                 UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]init];
                 rightButton.action = @selector(sendToUserSearch);
                 rightButton.image = [UIImage imageNamed:@"search.png"];
                 rightButton.tintColor = [UIColor whiteColor];
                 rightButton.target = self;
                 
                 self.navigationItem.rightBarButtonItem = rightButton;
                 
                 self.parsePosts = objects;
                 for (NSUInteger i = 0; i < self.parsePosts.count; i++)
                 {
                     NSDictionary *HRPPosts = self.parsePosts[i];
                     
                     PFGeoPoint *HRPGeoPoint = HRPPosts[@"locationGeoPoint"];
                     
                     CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                     
                     GMSMarker *marker = [[GMSMarker alloc] init];
                     marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithHue:0.56 saturation:0.95 brightness:1 alpha:1]];
                     marker.position = postCoordinate;
                     marker.map = self.mapView;
                 }
             }
             else if ([error.domain isEqual:PFParseErrorDomain] && error.code == kPFErrorConnectionFailed)
             {
                 [self alertOfflineView];
             }
         }];
    }
}

-(void)alertOfflineView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = @"OFFLINE";
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    if (self.modalView == nil)
    {
        self.modalView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        self.modalView.opaque = NO;
        self.modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [self.view addSubview:self.modalView];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        UIImage* image = [UIImage imageNamed:@"refresh.png"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        [someButton setBackgroundImage:image forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(queryForHRPosts)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:NO];
        UIBarButtonItem *rightbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem = rightbutton;
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
    if (!self.newestLocation.timestamp) {
        self.newestLocation = self.locationManager.location;
        self.currentLocation = self.locationManager.location;
        [self updateMapWithCurrentLocation];
    }
    
    NSTimeInterval locationAge = -[self.newestLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 300) // 5 mins in seconds
    {
        CLLocation *compareLocation = self.locationManager.location;
        double distance = [self.newestLocation distanceFromLocation:compareLocation];
        if (distance > 320) // 0.20 miles in meters
        {
            self.newestLocation = self.locationManager.location;
            self.currentLocation = self.locationManager.location;
            [self updateMapWithCurrentLocation];
        }
        else
        {
            self.newestLocation = self.locationManager.location;
        }
    }
}

- (void)updateMapWithCurrentLocation
{
    [self setBounds];
    [self createMap];
    
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

- (void)createMap
{
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:17];
    
    CGFloat h = self.topLayoutGuide.length;
    CGRect rect = CGRectMake(0, h, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.postSongButton.frame.size.height - 20);
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
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [errorAlerts addAction:okAction];
}

#pragma mark - Action Methods

- (IBAction)profileButtonTapped:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    HRPProfileVC *profileView = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    profileView.user = [PFUser currentUser];
    [self.navigationController pushViewController:profileView animated:YES];
}
- (void)profileSecondButtonTapped
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    HRPProfileVC *profileView = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    profileView.user = [PFUser currentUser];
    [self.navigationController pushViewController:profileView animated:YES];
}
-(void)sendToUserSearch
{
    [self performSegueWithIdentifier: @"showUserSearch" sender: self];
}
- (IBAction)postSongButtonTapped:(id)sender
{
    if (self.defaultMarkerImage.hidden)
    {
        self.defaultMarkerImage.hidden = NO;
    }
    else
    {
        self.defaultMarkerImage.hidden = YES;
    }
    [self changeButtonBackground];
}

-(HRPPost *)postWithCurrentMapPosition
{
    CLLocationCoordinate2D coordinates = [self findCoordinatesAtMapCenter];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.position = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
    
    CGFloat latitude = marker.position.latitude;
    CGFloat longitude = marker.position.longitude;
    
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
        }
    }
    return YES;
}

#pragma login methods


-(void)sessionUpdatedNotification:(NSNotification *)notification
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)renewTokenAndSegue
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
    }];
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    NSLog(@"AUTHVC FAILED : %@",error);
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    [SPTUser requestCurrentUserWithAccessToken:session.accessToken callback:^(NSError *error, SPTUser *object) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            PFUser *currentUser = [PFUser currentUser];
            
            currentUser[@"spotifyCanonical"] = object.canonicalUserName;
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    auth.sessionUserDefaultsKey = object.canonicalUserName;
                }
                else
                {
                    NSLog(@"ERROR: %@", error);
                }
            }];
        }];
    }];
}
-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
    [self openLogInPage];
}

@end
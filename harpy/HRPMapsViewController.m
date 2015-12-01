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
//#import "HRPAddPostViewController.h" ***********
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HRPMapsViewController () <GMSMapViewDelegate/*, HRPAddPostViewControllerDelegate*/>

@property (nonatomic, strong) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultMarkerImage;
@property (weak, nonatomic) IBOutlet UIButton *postSongButton;
@property (nonatomic) BOOL buttonShouldDisappear;
@property (strong, nonatomic) GMSMarker *defaultMarker;

@end

@implementation HRPMapsViewController
{
    GMSMapView *mapView_;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad]; //*************
    [self setupNavBar]; //*************
    
    /*
     self.locationManager = [CLLocationManager sharedManager];
     self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
     self.locationManager.delegate = self;                          ***************   this got moved to viewDidAppear
     
     [self locationManagerPermissions];
     */
    
    self.defaultMarkerImage.hidden = YES;
    
    [self.postSongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.postSongButton setBackgroundColor:[UIColor darkGrayColor]];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    self.postSongButton.hidden = NO;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (self.buttonShouldDisappear)
    {
        self.postSongButton.hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.locationManager = [CLLocationManager sharedManager];               //************
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;             //moved from viewDidLoad
    self.locationManager.delegate = self;                                                   //************
    [self locationManagerPermissions];
    [self.locationManager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:1.0]; //*********
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Setup methods
//*************  this entire section/method has been added
-(void)setupNavBar
{
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName:
                                                    [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]
                                                             }];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"backround_cropped"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:18];
    
    //this controls the map size on the view
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - (self.view.bounds.size.height * 0.08));
    mapView_ = [GMSMapView mapWithFrame:rect camera:camera];
    NSLog(@"bounds of view: %@", NSStringFromCGRect(rect));
    
    //this sets the mapView_ at the very background of the view
    [self.view insertSubview:mapView_ atIndex:0];
    
    //this is a moveable green marker that shows up when the map loads
    self.defaultMarker = [[GMSMarker alloc] init];
    self.defaultMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    self.defaultMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//    self.defaultMarkerImage.hidden = YES; //****************
    self.defaultMarker.map = mapView_;
    [self.defaultMarker setDraggable:true];
    
    // Use some kind of data to identify each marker, marker does not have 'tag' but 'userData' that is an 'id' type
    //    [self.defaultMarker setUserData:<#(id)#>];
    
    mapView_.delegate = self;
    mapView_.indoorEnabled = NO;
    mapView_.settings.scrollGestures = NO; //scroll gestures locked here
    
    [mapView_ setMinZoom:13 maxZoom:mapView_.maxZoom];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
}

// Called if getting user location fails
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController *errorAlerts = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [errorAlerts addAction:okAction];
    
    [self presentViewController:errorAlerts animated:YES completion:nil];
}

#pragma mark - Action Methods

- (IBAction)postSongButtonTapped:(id)sender
{
    NSString *enterPostSongOverlay = @"Post a Song";
    NSString *pinSongHere = @"Pin Track";
    self.buttonShouldDisappear = YES;
    
    if (self.defaultMarkerImage.hidden)
    {
        self.defaultMarkerImage.hidden = NO;
    }
    else
    {
        self.defaultMarkerImage.hidden = YES;
    }
    if ([self.postSongButton.titleLabel.text isEqualToString:enterPostSongOverlay])
    {
        [self.postSongButton setTitle:pinSongHere forState:UIControlStateNormal];
        [self.postSongButton setBackgroundColor:[UIColor blackColor]];
    }
    else if ([self.postSongButton.titleLabel.text isEqualToString:pinSongHere])
    {
        self.buttonShouldDisappear = NO;
        
        [self.postSongButton setTitle:enterPostSongOverlay forState:UIControlStateNormal];
        [self.postSongButton setBackgroundColor:[UIColor darkGrayColor]];
        
        [self presentConfirmPinAlertController];
    }
}

//this makes the postSongButton disappear when finger is moving on screen
- (void)handlePans
{
    self.postSongButton.hidden = YES;
}

- (void)presentConfirmPinAlertController
{
    UIAlertController *confirmPinAlert = [UIAlertController alertControllerWithTitle:@"Confirm Pin" message:@"Post song here?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CGPoint point = mapView_.center;
        CLLocationCoordinate2D coordinates = [mapView_.projection coordinateForPoint:point];
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.position = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        marker.map = mapView_;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [confirmPinAlert addAction:confirmAction];
    [confirmPinAlert addAction:cancelAction];
    
    [self presentViewController:confirmPinAlert animated:YES completion:nil];
}

#pragma mark - Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    HRPAddPostViewController *addPostDVC = segue.destinationViewController;           ***********
//    addPostDVC.delegate = self;
//}

#pragma mark - Modal View Controller

//// the methods below are for use with the modal view controller (+) button on top of the maps view.  it's all connected to the delegate and protocol of the HRPAddPostViewController class
//- (void)addPostViewController:(id)viewController didFinishWithLocation:(CLLocation *)location
//{
//    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
//    
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
//    marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);      *******************
//    marker.map = mapView_;
//    
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//}
//- (void)addPostViewControllerDidCancel:(HRPAddPostViewController *)viewController
//{
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//}

@end
//
//  HRPAddPostViewController.m
//  harpy
//
//  Created by Amy Joscelyn on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPAddPostViewController.h"
//#import "HRPMapsViewController.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface HRPAddPostViewController ()

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation HRPAddPostViewController
{
    GMSMapView *mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentLocation = self.locationManager.location;
}

- (IBAction)submitButtonTapped:(id)sender
{
        CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        marker.map = mapView_;
    
    [self.delegate addPostViewController:self didFinishWithLocation:self.currentLocation]; //we might not actually need to know the location, this can always be adjusted later
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate addPostViewControllerDidCancel:self];
}

@end

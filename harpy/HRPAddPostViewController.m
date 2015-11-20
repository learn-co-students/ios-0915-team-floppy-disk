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

//from Google Places API Guide
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation HRPAddPostViewController
{
    GMSMapView *mapView_;
    GMSPlacesClient *_placesClient;
    GMSPlacePicker *_placePicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _placesClient = [[GMSPlacesClient alloc] init];
    
    self.currentLocation = self.locationManager.location;
}

- (IBAction)getCurrentPlace:(UIButton *)sender
{
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil)
        {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        self.nameLabel.text = @"No current place";
        self.addressLabel.text = @"";
        
        if (placeLikelihoodList != nil)
        {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil)
            {
                self.nameLabel.text = place.name;
                self.addressLabel.text = [[place.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
            }
        }
    }];
}

- (IBAction)pickPlace:(UIButton *)sender
{
    //this works even when there is no designated location, which is why the places picked are so far away
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001,
                                                                  center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001,
                                                                  center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        if (place != nil)
        {
            self.nameLabel.text = place.name;
            self.addressLabel.text = [[place.formattedAddress
                                       componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
        } else
        {
            self.nameLabel.text = @"No place selected";
            self.addressLabel.text = @"";
        }
    }];
}

- (IBAction)submitButtonTapped:(id)sender
{
    [self.delegate addPostViewController:self didFinishWithLocation:self.currentLocation]; //we might not actually need to know the location, this can always be adjusted later
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate addPostViewControllerDidCancel:self];
}

@end

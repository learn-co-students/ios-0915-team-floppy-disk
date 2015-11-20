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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _placesClient = [[GMSPlacesClient alloc] init];
    
    self.currentLocation = self.locationManager.location;
}

#pragma mark - Action Methods

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

- (IBAction)submitButtonTapped:(id)sender
{
    [self.delegate addPostViewController:self didFinishWithLocation:self.currentLocation]; //we might not actually need to know the location, this can always be adjusted later
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate addPostViewControllerDidCancel:self];
}

@end

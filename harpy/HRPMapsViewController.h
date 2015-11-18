//
//  HRPMapsViewController.h
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "ViewController.h"
#import "HRPLocationManager.h"
#import <UIKit/UIKit.h>

@interface HRPMapsViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation* location;

/// The location manager used to receive location updates.
@property (nonatomic,strong) CLLocationManager *locationManager;

/// An alert view used to notify the user of errors.
@property (nonatomic,strong) UIAlertController *alertView;

@end

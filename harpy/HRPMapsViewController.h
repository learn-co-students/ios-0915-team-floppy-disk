//
//  HRPMapsViewController.h
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLocationManager+Shared.h"

@interface HRPMapsViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) UINavigationController *navCont;

/// The location manager used to receive location updates.
@property (nonatomic,strong) CLLocationManager *locationManager;

@end
//
//  HRPMapsViewController.h
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLocationManager+Shared.h"

@protocol loadNewPostPinsDelegate <NSObject>

- (void)queryForHRPosts;

@end

@interface HRPMapsViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic,strong) CLLocationManager *locationManager;

- (void)queryForHRPosts;

@end
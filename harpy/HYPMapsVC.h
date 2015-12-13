//
//  HYPMapsVC.h
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLocationManager+Shared.h"

@protocol loadNewPostPinsDelegate <NSObject>

@end

@interface HYPMapsVC : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

//
//  CLLocationManager+Shared.h
//  harpy
//
//  Created by Kiara Robles on 11/16/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (Shared)

+ (CLLocationManager *)sharedManager;

@end
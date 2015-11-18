//
//  HRPLocationManager.h
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol LocationManagerDelegate <NSObject>

- (void)didUpdateLocation:(CLLocation *)location;

@end

@interface HRPLocationManager : NSObject

@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

+ (HRPLocationManager *)sharedInstance;

@end
//
//  CLLocationManager+Shared.m
//  harpy
//
//  Created by Kiara Robles on 11/16/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "CLLocationManager+Shared.h"

@implementation CLLocationManager (Shared)

+ (CLLocationManager *)sharedManager;
{
    static CLLocationManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CLLocationManager alloc] init];
    });
    return _sharedManager;
}

@end
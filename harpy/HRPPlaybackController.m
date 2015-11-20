//
//  HRPPlaybackController.m
//  harpy
//
//  Created by Phil Milot on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPlaybackController.h"

@implementation HRPPlaybackController

#pragma mark - Singleton Methods

+(id)sharedController {
    static HRPPlaybackController *_sharedController;
    static dispatch_once_t onceToken;
    dispatch_once(onceToken, ^{
        _sharedController = [[HRPPlaybackController alloc]init];
    });
    return _sharedController;
}

@end

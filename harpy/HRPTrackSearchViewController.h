//
//  HRPTrackSearchViewController.h
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPPost.h"

@interface HRPTrackSearchViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *songArray;
@property (strong, nonatomic) HRPPost *post;

@end

//
//  HRPPostPreviewViewController.h
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPTrack.h"
#import "HRPPost.h"

@interface HRPPostPreviewViewController : UIViewController

@property (nonatomic, strong) HRPTrack *track;
@property (nonatomic, strong) HRPPost *post;

@end

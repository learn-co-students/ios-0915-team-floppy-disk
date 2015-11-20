//
//  HRPAddPostViewController.h
//  harpy
//
//  Created by Amy Joscelyn on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPLocationManager.h"
//#import "CLLocationManager+Shared.h"
@class HRPAddPostViewController;

@protocol HRPAddPostViewControllerDelegate <NSObject>

- (void)addPostViewControllerDidCancel: (HRPAddPostViewController *)viewController;

- (void)addPostViewController:(id)viewController didFinishWithLocation: (CLLocation *)location;

@end

//@interface FISViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@interface HRPAddPostViewController : UIViewController

@property (nonatomic, weak) id<HRPAddPostViewControllerDelegate> delegate;

@end

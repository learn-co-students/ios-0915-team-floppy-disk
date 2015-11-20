//
//  UIViewController+PresentViewController.h
//  harpy
//
//  Created by Kiara Robles on 11/20/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PresentViewController)

@property (nonatomic) NSString *redirectUrl;
@property (retain, nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, assign) id delegate;

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissViewControllerAnimated:(BOOL)animated;

@end
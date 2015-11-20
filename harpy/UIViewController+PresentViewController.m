//
//  UIViewController+PresentViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/20/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "UIViewController+PresentViewController.h"

@implementation UIViewController (PresentViewController)

#pragma mark - Modal Animation

- (UIViewController *)topViewController
{
    if ([self respondsToSelector:@selector(presentedViewController)] == YES)
    {
        return [self presentedViewController];
    }
    else
        if ([self respondsToSelector:@selector(modalViewController)] == YES)
        {
            return [self modalViewController];
        }
    
    return nil;
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)] == YES)
    {
        [self presentViewController:viewController animated:animated completion:nil];
    }
    else
    {
        [self presentModalViewController:viewController animated:animated];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)] == YES)
    {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
    else 
    {
        [self dismissModalViewControllerAnimated:animated];
    }
}

@end
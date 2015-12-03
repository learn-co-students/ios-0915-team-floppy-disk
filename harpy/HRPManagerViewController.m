//
//  HRPManagerViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPManagerViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface HRPManagerViewController ()

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation HRPManagerViewController

#pragma mark - Navigation & Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogout:) name:UserDidLogOutNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogin:) name:UserDidLogInNotificationName object:nil];
    
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:LoggedInUserDefaultsKey];
    
    if (isLoggedIn) {
        [self showHome];
    } else {
        [self showLogIn];
    }
}

#pragma mark Send to designated view controller
-(void)showLogIn {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:LogInViewControllerStoryboardID];
    
    [self setEmbeddedViewController:viewController];
}

-(void)showHome {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:HomeViewControllerStoryboardID];
    
    [self setEmbeddedViewController:viewController];
}


#pragma mark NSNotificationCenter handlers

-(void)handleUserDidLogout:(NSNotification *)notification {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoggedInUserDefaultsKey];
    
    [self showLogIn];
}

-(void)handleUserDidLogin:(NSNotification *)notification {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LoggedInUserDefaultsKey];
    
    [self showHome];
}


#pragma mark Child view controllers

-(void)setEmbeddedViewController:(UIViewController *)controller {
    
    if ([self.childViewControllers containsObject:controller]) {
        return;
    }
    
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        
        if (vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        
        [vc removeFromParentViewController];
    }
    
    if (!controller) {
        return;
    }
    
    [self addChildViewController:controller];
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}



@end

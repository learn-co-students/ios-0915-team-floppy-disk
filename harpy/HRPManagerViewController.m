//
//  HRPManagerViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPManagerViewController.h"
#import <Parse/Parse.h>

@interface HRPManagerViewController ()

@end

@implementation HRPManagerViewController

#pragma mark - Navigation & Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![PFUser currentUser])
    {
        [self performSelector:@selector(showLoginsStoryboard) withObject:nil afterDelay:0];
    }
    else
    {
        [self performSelector:@selector(showMapsStoryboard) withObject:nil afterDelay:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)showLoginsStoryboard
{
    [self performSegueWithIdentifier:@"sendToLogins" sender:self];
}
- (void)showMapsStoryboard
{
    [self performSegueWithIdentifier:@"sendToMaps" sender:self];
}



@end

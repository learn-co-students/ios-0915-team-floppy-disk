//
//  HRPChangePasswordVC.m
//  harpy
//
//  Created by Kiara Robles on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPChangePasswordVC.h"

@interface HRPChangePasswordVC () <UINavigationControllerDelegate>

@end

@implementation HRPChangePasswordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup methods


- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

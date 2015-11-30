//
//  HRPChangePasswordVC.m
//  harpy
//
//  Created by Kiara Robles on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPChangePasswordVC.h"

@interface HRPChangePasswordVC ()

@end

@implementation HRPChangePasswordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavBar];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup methods

-(void)setupNavBar
{
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],
                                                            }];
}

@end

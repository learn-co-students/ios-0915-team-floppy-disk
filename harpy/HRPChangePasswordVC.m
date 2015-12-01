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
    [self setupNavBar];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup methods

-(void)setupNavBar
{
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName:
                                                                 [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]
                                                             }];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"backround_cropped"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

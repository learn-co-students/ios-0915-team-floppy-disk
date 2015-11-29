//
//  HRPLoginAndSignupViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/28/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLoginAndSignupViewController.h"

@interface HRPLoginAndSignupViewController ()

@end

@implementation HRPLoginAndSignupViewController

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backround_iphone5"];
    self.view.backgroundColor =[[UIColor alloc] initWithPatternImage:backgroundImage];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

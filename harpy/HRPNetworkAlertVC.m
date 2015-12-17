//
//  HRPNetworkAlertVC.m
//  harpy
//
//  Created by Kiara Robles on 12/10/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPNetworkAlertVC.h"
#import "HRPNetworkAlertView.h"

@interface HRPNetworkAlertVC ()

@property (nonatomic) HRPNetworkAlertView *alertView;

@end

@implementation HRPNetworkAlertVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.alertView = [[HRPNetworkAlertView alloc] init];
    [self.view addSubview:self.alertView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

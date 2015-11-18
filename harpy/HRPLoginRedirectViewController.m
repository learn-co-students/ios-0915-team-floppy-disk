//
//  HRPLoginRedirectViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLoginRedirectViewController.h"
#import "HRPLoginRedirect.h"
#import "AppDelegate.h"

@interface HRPLoginRedirectViewController ()

@end

@implementation HRPLoginRedirectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [HRPLoginRedirect launchSpotify];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

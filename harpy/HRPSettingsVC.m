//
//  HRPSettingsVC.m
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPSettingsVC.h"
#import "HRPParseNetworkService.h"

@interface HRPSettingsVC () <UINavigationControllerDelegate>

@property (strong, nonatomic) HRPParseNetworkService *parseService;



- (IBAction)logout:(id)sender;

@end

@implementation HRPSettingsVC

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action methods

- (IBAction)logout:(id)sender
{
    NSLog(@"CLICKED: logout button");
    
    {
        [self.parseService logout];
        //pop to root view
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end

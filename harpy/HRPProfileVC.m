//
//  HRPProfileVC.m
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPProfileVC.h"
#import "HRPParseNetworkService.h"
#import "HRPUser.h"


@interface HRPProfileVC ()

@property (weak, nonatomic) IBOutlet UILabel *username;

@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserProfile];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)setupUserProfile
{
    PFUser *currentUser = [PFUser currentUser];
    self.username.text = currentUser.username;
}


@end

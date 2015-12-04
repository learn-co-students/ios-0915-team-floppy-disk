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
#import "PFFile.h"
#import <QuartzCore/QuartzCore.h> // Needed to round UIImage
#import "HRPMapsViewController.h"

@interface HRPProfileVC ()

@property (weak, nonatomic) IBOutlet UILabel *postCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *realName;
@property (weak, nonatomic) IBOutlet UILabel *shortBio;
@property (nonatomic) PFUser *currentUser;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserProfile];
    
    self.parseService = [HRPParseNetworkService sharedService];
    self.currentUser = [PFUser currentUser];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveUserAvatar];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Profile Setup

- (void)setupUserProfile
{
    self.userAvatar.layer.cornerRadius = 45;
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    [self.userAvatar.layer setBorderColor: [ironColor CGColor]];
    [self.userAvatar.layer setBorderWidth: 1.0];
    self.userAvatar.clipsToBounds = YES;
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    PFUser *currentUser = [PFUser currentUser];
    self.navigationItem.title = currentUser.username;
    
    NSString *realName = currentUser[@"realName"];
    self.realName.text = realName;
    
    NSString *shortBio = currentUser[@"shortBio"];
    self.shortBio.text = shortBio;
}
- (void)retrieveUserAvatar
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"USER: %@", objects);
            PFObject *user = [objects objectAtIndex:0];
            PFFile *file = [user objectForKey:@"userAvatar"];
            NSLog(@"FILE: %@", file);
            
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
            {
                if (!error)
                {
                    self.userAvatar.image = [UIImage imageWithData:data];
                    UIImage *image = [UIImage imageWithData:data];
                    NSLog(@"IMAGE: %@", image);
                }
            }];
        }
        else
        {
            NSLog(@"ERROR: %@ %@", error, [error userInfo]);
        }
    }];
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

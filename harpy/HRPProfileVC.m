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

@interface HRPProfileVC ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (nonatomic) PFUser *currentUser;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserProfile];
    
    self.userAvatar = [[UIImageView alloc] init];
    [self.view addSubview:self.userAvatar];
    
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
    PFUser *currentUser = [PFUser currentUser];
    
    self.username.text = currentUser.username;
    
    self.navigationItem.title = currentUser.username;
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName: [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0f]}];
    
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
                
                    CGRect rect = CGRectMake(0,0,100,100); // Would prefer to do without CGRect
                    UIImage *userAvatar = [self imageWithImage:image scaledToSize:rect.size];
                    self.userAvatar = [[UIImageView alloc] initWithImage:userAvatar];
                    
                    CGRect viewBounds = [[self view] frame];
                    [self.userAvatar.layer setPosition:CGPointMake(viewBounds.size.width / 4.85, viewBounds.size.height / 4.6 - viewBounds.origin.y)];
                    
                    [self.view addSubview:self.userAvatar];
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

@end

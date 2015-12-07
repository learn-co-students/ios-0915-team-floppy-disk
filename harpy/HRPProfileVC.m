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
@property (weak, nonatomic) IBOutlet UIButton *mapviewButton;
@property (weak, nonatomic) IBOutlet UIButton *listViewButton;
@property (weak, nonatomic) IBOutlet UITableView *postsTableview;
@property (weak, nonatomic) IBOutlet UICollectionView *postsCollectionview;

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
    self.userAvatar.clipsToBounds = YES;
    self.userAvatar.layer.masksToBounds = YES;
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        self.userAvatar.layer.cornerRadius = 54;
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        self.userAvatar.layer.cornerRadius = 59;
    }
    else
    {
        self.userAvatar.layer.cornerRadius = 45;
    }
    
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    [self.userAvatar.layer setBorderColor: [ironColor CGColor]];
    [self.userAvatar.layer setBorderWidth: 1.0];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *usernameString = currentUser.username;
    usernameString = [usernameString uppercaseString];
    self.navigationItem.title = usernameString;
    
    NSString *realName = currentUser[@"realName"];
    self.realName.text = realName;
    
    NSString *shortBio = currentUser[@"shortBio"];
    self.shortBio.text = shortBio;
}
- (void)setupPostsTableview
{
    
}
- (void)setupPostsCollectionview
{
    
}
- (void)queryForHRPosts
{
    
        PFQuery *query = [PFQuery queryWithClassName:@"HRPPost"];
    
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             
             if (!error)
             {
                 self.parsePosts = objects;
                 NSLog(@"PARSE POSTS: %@", self.parsePosts);
                 
                 for (NSUInteger i = 0; i < self.parsePosts.count; i++)
                 {
                     NSDictionary *HRPPosts = self.parsePosts[i];
                     NSLog(@"PARSE DICTIONARY: %@", HRPPosts);
                     
                     PFGeoPoint *HRPGeoPoint = HRPPosts[@"locationGeoPoint"];
                     NSLog(@"geoPointString %@", HRPGeoPoint);
                     
                     CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(HRPGeoPoint.latitude, HRPGeoPoint.longitude);
                     NSLog(@"postCoordinate %f, %f", postCoordinate.latitude, postCoordinate.longitude);
                     
                     GMSMarker *marker = [[GMSMarker alloc] init];
                     marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                     marker.position = postCoordinate;
                     marker.map = mapView_;
                     NSLog(@"marker: %@", marker);
                     
                     for (PFObject *post in objects) {
                         PFRelation *userRelation = [post relationForKey:@"username"];
                         PFQuery *userUsername = [userRelation query];
                         [userUsername  findObjectsInBackgroundWithBlock:^(NSArray * user, NSError * error2) {
                             for (PFObject *username in user) {
                                 NSLog(@"USERNAME: %@", username[@"username"]);
                             }
                         }];
                     }
                 }
                 
                 
             } else
             {
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
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
- (UIView*)createCircleViewWithRadius:(int)radius
{
    // circle view
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.layer.cornerRadius = radius;
    circle.layer.masksToBounds = YES;
    
    // border
    circle.layer.borderColor = [UIColor whiteColor].CGColor;
    circle.layer.borderWidth = 1;
    
    // gradient background color
    CAGradientLayer *gradientBg = [CAGradientLayer layer];
    gradientBg.frame = circle.frame;
    gradientBg.colors = [NSArray arrayWithObjects:
                         (id)[UIColor redColor].CGColor,
                         (id)[UIColor blackColor].CGColor,
                         nil];
    // vertical gradient
    gradientBg.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    // gradient background
    CALayer *layer = circle.layer;
    layer.masksToBounds = YES;
    [layer insertSublayer:gradientBg atIndex:0];
    
    return circle;
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Naviagation

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action methods

- (IBAction)listmenuClicked:(id)sender
{
    
}
- (IBAction)mapmenuClicked:(id)sender
{
    NSLog(@"Map menu clicked");
}

@end

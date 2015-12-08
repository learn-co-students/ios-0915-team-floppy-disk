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

@interface HRPProfileVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *followOrEditButton;
@property (weak, nonatomic) IBOutlet UILabel *postCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *realName;
@property (weak, nonatomic) IBOutlet UILabel *shortBio;
@property (weak, nonatomic) IBOutlet UIButton *mapviewButton;
@property (weak, nonatomic) IBOutlet UIButton *listViewButton;
@property (weak, nonatomic) IBOutlet UITableView *postsTableview;
@property (nonatomic, strong) NSArray *userPosts;

@property (nonatomic) PFUser *currentUser;
@property (nonatomic) BOOL isCurrentUser;
@property (nonatomic) PFObject *userObject;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserProfile];
    [self retrieveUser];
    
    self.postsTableview.delegate = self;
    self.postsTableview.dataSource = self;
    self.postsTableview.delegate = self;
    
    self.parseService = [HRPParseNetworkService sharedService];
    
    if (self.user != [PFUser currentUser])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self.followOrEditButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self retrieveHRPosts];
}
- (void)viewWillAppear:(BOOL)animated
{

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
    
    NSString *usernameString = self.user.username;
    usernameString = [usernameString uppercaseString];
    self.navigationItem.title = usernameString;
    
    NSString *realName = self.user[@"realName"];
    self.realName.text = realName;
    
    NSString *shortBio = self.user[@"shortBio"];
    self.shortBio.text = shortBio;
}

#pragma mark - Parse Queries

- (void)retrieveUser
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:self.user.objectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"USER: %@", objects);
            self.userObject = [objects objectAtIndex:0];
            [self retrieveUserAvatar];
        }
        else
        {
            NSLog(@"ERROR: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void)retrieveUserAvatar
{
    PFFile *file = [self.userObject objectForKey:@"userAvatar"];
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
- (void)retrieveHRPosts
{
    PFRelation *userPosts = [self.user relationForKey:@"HRPPosts"];
    PFQuery *query = [userPosts query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            self.userPosts = objects;
            [self.postsTableview reloadData];
            NSLog(@"PARSE POSTS: %@", self.userPosts);
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
//- (UIImage *)retrieveParsePhoto:(PFFile *)photoOrAlbumArt
//{
//    NSLog(@"FILE: %@", photoOrAlbumArt);
//    
//    [photoOrAlbumArt getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
//     {
//         if (!error)
//         {
//             UIImage *image = [UIImage imageWithData:data];
//             NSLog(@"IMAGE: %@", image);
//         }
//     }];
//    
//    return image;
//}

#pragma mark - Helper methods

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
#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userPosts.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.postsTableview dequeueReusableCellWithIdentifier:@"postsCell" forIndexPath:indexPath];
    NSDictionary *HRPPosts = [self.userPosts objectAtIndex:[indexPath row]];
    
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    
    PFFile *albumArt = HRPPosts[@"albumArt"];
    UIImageView *albumArtView = (UIImageView *)[cell viewWithTag:2];
    albumArtView.layer.masksToBounds = YES;
    if (albumArt)
    {
        [albumArt getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                albumArtView.image = [UIImage imageWithData:data];
                [albumArtView.layer setBorderColor: [ironColor CGColor]];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }

    UILabel *songTitleLabel = (UILabel *)[cell viewWithTag:1];
    NSString *songTitleString = HRPPosts[@"songTitle"];
    songTitleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0];
    songTitleLabel.text = songTitleString;
    
    UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:3];
    NSString *artistNameString = HRPPosts[@"artistName"];
    artistNameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    artistNameLabel.text = artistNameString;
    
    UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:4];
    NSString *albumNameString = HRPPosts[@"albumName"];
    albumNameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    albumNameLabel.text = albumNameString;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
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

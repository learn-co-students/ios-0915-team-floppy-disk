//
//  HRPProfileVC.m
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPProfileVC.h"
#import "HRPParseNetworkService.h"
#import "HRPEditProfileTableVC.h"
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
@property (weak, nonatomic) IBOutlet UIStackView *stackViewButtons;

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
    [self setupFollowersAndFans];
    
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
//    self.stackViewButtons.clipsToBounds = NO;
//    self.stackViewButtons.layer.shadowOffset = CGSizeMake(-15, 20);
//    self.stackViewButtons.layer.shadowRadius = 5;
//    self.stackViewButtons.layer.shadowOpacity = 0.5;
//    [self.view bringSubviewToFront:self.stackViewButtons];
    [self retrieveHRPosts];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Profile Setup

- (void)setupFollowersAndFans
{
    PFRelation *followingCount = self.user[@"following"];
    NSLog(@"FOLLOWERS: %@", followingCount);
}
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

#pragma mark - UIScrollViewDelegate

- (void)changeScrollBarColorFor:(UIScrollView *)scrollView
{
    for ( UIView *view in scrollView.subviews ) {
        
        if (view.tag == 0 && [view isKindOfClass:UIImageView.class])
        {
            UIImageView *imageView = (UIImageView *)view;
            imageView.backgroundColor = [UIColor darkGrayColor];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewDidScroll");
    
    float shadowOffset = (scrollView.contentOffset.y/1);
    
    // Make sure that the offset doesn't exceed 3 or drop below 0.5
    shadowOffset = MIN(MAX(shadowOffset, 0), 1);
    
    //Ensure that the shadow radius is between 1 and 3
    float shadowRadius = MIN(MAX(shadowOffset, 0), 1);
    
    self.stackViewButtons.layer.shadowOffset = CGSizeMake(100, shadowOffset);
    self.stackViewButtons.layer.shadowRadius = shadowRadius;
    self.stackViewButtons.layer.shadowColor = [UIColor blackColor].CGColor;
    self.stackViewButtons.layer.shadowOpacity = 0.20;
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

#pragma mark - Overrides

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat customTableCellHeight = self.postsTableview.frame.size.height/3;
    
    return customTableCellHeight;
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
- (IBAction)followOrEditButtonClicked:(id)sender
{
    if ([self.followOrEditButton.titleLabel.text isEqual: @"Follow"])
    {
        PFRelation *relationFollow = [[PFUser currentUser] objectForKey:@"following"];
        [relationFollow addObject:self.user];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"FOLLOWER SAVED");
            
            PFRelation *relation = [[PFUser currentUser] objectForKey:@"following"];
            PFQuery *query = [relation query];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                NSLog(@"FOLLOWER ARRAY: %@", objects);
            }];
        }];
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Edit Profile"])
    {
        HRPEditProfileTableVC *editProfileView = [[HRPEditProfileTableVC alloc] init];
        [self presentViewController:editProfileView animated:YES completion:nil];
    }
}

@end

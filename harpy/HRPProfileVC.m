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
#import <Spotify/Spotify.h>

@interface HRPProfileVC () <UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicPlayerBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottom;
@property (weak, nonatomic) IBOutlet UIView *musicPlayerView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *followOrEditButton;
@property (weak, nonatomic) IBOutlet UILabel *postCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *realName;
@property (weak, nonatomic) IBOutlet UILabel *shortBio;
@property (weak, nonatomic) IBOutlet UITableView *postsTableview;
@property (nonatomic, strong) NSArray *userPosts;
@property (nonatomic, strong) NSArray *userFollowing;
@property (nonatomic, strong) NSArray *userFans;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic) PFUser *currentUser;
@property (nonatomic) PFObject *userObject;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@property (strong, nonatomic) IBOutlet UIImageView *coverArtView;
@property (strong, nonatomic) IBOutlet UILabel *playPauseLabel;
@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) SPTAudioStreamingController *player;

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
    
    self.playPauseLabel.text = @"";
    self.songNameLabel.text = @"";
    self.artistNameLabel.text = @"";
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self retrieveHRPosts];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Profile Setup

- (void)setupFollowersAndFans
{
    //PFRelation *followingCount = self.user[@"following"];
    PFRelation *relation = [self.user relationForKey:@"following"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
         NSLog(@"FOLLOWERS: %@", self.user);
        self.userFollowing = results;
        self.followingCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFollowing.count];
    }];

    PFQuery *fansQuery = [PFUser query];
    [fansQuery whereKey:@"following" equalTo:self.user];
    [fansQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        // so i think this will return all the users who are following self.user
        NSLog(@"FANS: %@", objects);
        self.userFans = objects;
        self.fansCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFans.count];
        
        for (PFUser *user in self.userFans)
        {
            if ([[PFUser currentUser] isEqual:user])
            {
                [self.followOrEditButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            }
        }
    }];
}
- (void)updatePostCount
{
    self.postCount.text = [NSString stringWithFormat:@"%i", (int)self.userPosts.count];
}
- (void)setupUserProfile
{
    self.userAvatar.clipsToBounds = YES;
    self.userAvatar.layer.masksToBounds = YES;
    
    NSLog(@"[[UIScreen mainScreen] bounds].size.height: %f", [[UIScreen mainScreen] bounds].size.height);
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        self.userAvatar.layer.cornerRadius = 54;
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        self.userAvatar.layer.cornerRadius = 59;
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 320.0f)
    {
        self.userAvatar.layer.cornerRadius = 38;
        
        if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            self.userAvatar.layer.cornerRadius = 45;
        }
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
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    PFFile *imageFile = [self.user objectForKey:@"userAvatar"];
    if (imageFile)
    {
        [self.userAvatar.layer setBorderColor: [ironColor CGColor]];
        [self.userAvatar.layer setBorderWidth: 1.0];
        self.userAvatar.layer.masksToBounds = YES;
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                self.userAvatar.image = [UIImage imageWithData:data];
                self.userAvatar.highlightedImage = [UIImage imageWithData:data];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }
}
- (void)retrieveHRPosts
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.titleView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    PFRelation *userPosts = [self.user relationForKey:@"HRPPosts"];
    PFQuery *query = [userPosts query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            [self.activityIndicator stopAnimating];
            self.navigationItem.titleView = nil;
            NSString *usernameString = self.user.username;
            usernameString = [usernameString uppercaseString];
            self.navigationItem.title = usernameString;
            
            self.userPosts = objects;
            [self.postsTableview reloadData];
            [self updatePostCount];
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
    
    UIButton *playSongButton = (UIButton *)[cell viewWithTag:5];
    [playSongButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Overrides

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalCellView = self.postsTableview.frame.size.height;
    CGFloat numberOfPostRows = 5;
    
    if ([[UIScreen mainScreen] bounds].size.width == 320.0f)
    {
        numberOfPostRows = 3;
    }
    
    CGFloat customTableCellHeight = totalCellView/numberOfPostRows;
    
    return customTableCellHeight;
}

#pragma mark - Naviagation

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    if (self.player.isPlaying == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    }
    self.player = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action methods


- (IBAction)followOrEditButtonClicked:(id)sender
{
    
    if ([self.followOrEditButton.titleLabel.text isEqual: @"Follow"])
    {
        NSLog(@"THE LABEL CHANGED");
        [self.followOrEditButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        self.fansCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFans.count +1];
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Edit Profile"])
    {
        NSLog(@"THE LABEL DOES NOT NEED TO CHANGE");
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Unfollow"])
    {
        NSLog(@"THE LABEL CHANGED");
        [self.followOrEditButton setTitle:@"Follow" forState:UIControlStateNormal];
        NSInteger totalFans = self.userFans.count - 1;
        if (totalFans < 0) {
            totalFans = 0;
        }
        self.fansCountLabel.text = [NSString stringWithFormat:@"%li", (long)totalFans];
    }
    
    
    if ([self.followOrEditButton.titleLabel.text isEqual: @"Follow"])
    {
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *followingRelation = [currentUser relationForKey:@"following"];
        [followingRelation addObject:self.user];
        
        PFRelation *fanRelation = [self.user relationForKey:@"fans"];
        [fanRelation addObject: currentUser];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil)
            {
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil)
                    {
                        NSLog(@"followers saved!!!!!!!!!");
                    }
                    else
                    {
                        NSLog(@"ERROR: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Edit Profile"])
    {
        HRPEditProfileTableVC *editProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfileTableVC"];
        [self.navigationController pushViewController:editProfileView animated:YES];
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Unfollow"])
    {
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *followingRelation = [currentUser relationForKey:@"following"];
        [followingRelation removeObject:self.user];
        
        PFRelation *fanRelation = [self.user relationForKey:@"fans"];
        [fanRelation removeObject:currentUser];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil)
            {
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil)
                    {
                        NSLog(@"fan deleted!!!!!!!!!");
                    }
                    else
                    {
                        NSLog(@"ERROR: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR FROM PROFILE VC: SPOTIFY AUTH: %@", error);
        }
    }];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    
    if (self.player.isPlaying == NO) {
        CGFloat musicPlayerHeight = self.musicPlayerView.frame.size.height;
        self.tableviewBottom.constant = musicPlayerHeight;
        self.musicPlayerBottom.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:nil];

        NSLog(@"%@", self.userPosts);
        //button should change to a pause
        UITableViewCell *cell = (UITableViewCell *)[[[[[sender superview] superview] superview] superview] superview];
        
        NSIndexPath *indexpath = [self.postsTableview indexPathForCell: cell];
        //this is only hitting the first row!!!
        
        NSDictionary *postInView = self.userPosts[indexpath.row];
                
        self.songNameLabel.text = postInView[@"songTitle"];
        self.artistNameLabel.text = postInView[@"artistName"];
        self.playPauseLabel.text = @"Playing";
        self.coverArtView.image = [UIImage imageNamed:@"white_pause"];
        
        [self handleNewSession];
        NSString *urlString = postInView[@"songURL"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        [self.player playURIs:@[ url ] fromIndex:0 callback:^(NSError *error) {
            //do we want option to stop song?
        }];
        [sender setImage:[UIImage imageNamed:@"black_stop"] forState:UIControlStateNormal];
    
    } else if (self.player.isPlaying == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.playPauseLabel.text = @"Paused";
        self.coverArtView.image = [UIImage imageNamed:@"white_play"];
    }
}
- (IBAction)playerViewTapped:(UITapGestureRecognizer *)sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    
    if ([self.playPauseLabel.text isEqualToString:@"Playing"]) {
        self.playPauseLabel.text = @"Paused";
        self.coverArtView.image = [UIImage imageNamed:@"white_play"];
    } else if ([self.playPauseLabel.text isEqualToString:@"Paused"]) {
        self.playPauseLabel.text = @"Playing";
        self.coverArtView.image = [UIImage imageNamed:@"white_pause"];
    }
    
}

@end

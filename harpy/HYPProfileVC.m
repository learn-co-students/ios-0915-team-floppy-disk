//
//  HYPProfileVC.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HYPProfileVC.h"
#import "HYPQueryable.h"
#import "HRPParseNetworkService.h"
#import "HRPEditProfileTableVC.h"
#import "HRPUser.h"
#import <QuartzCore/QuartzCore.h>
#import <Spotify/Spotify.h>

@interface HYPProfileVC () <UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableviewUserProfile;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSettings;

@property (nonatomic, strong) NSArray *userPosts;
@property (nonatomic, strong) NSArray *userFollowing;
@property (nonatomic, strong) NSArray *userFans;

@property (nonatomic) PFUser *currentUser;
@property (nonatomic) PFObject *userObject;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (strong, nonatomic) SPTAudioStreamingController *player;

@end

@implementation HYPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrieveUser];
    
    self.tableviewUserProfile.delegate = self;
    self.tableviewUserProfile.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.parseService = [HRPParseNetworkService sharedService];
    
    if (self.user == nil)
    {
        self.user = self.currentUser;
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        }
        else
        {
            NSLog(@"ERROR: %@ %@", error, [error userInfo]);
        }
    }];
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
    UITableViewCell *cell;
    
    NSDictionary *HRPPosts = [self.userPosts objectAtIndex:[indexPath row]];
    
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
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellUserHeader" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.user != self.currentUser)
        {
            self.navigationItem.rightBarButtonItem = nil;
            //[self.followOrEditButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    if (indexPath.row >= 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellPost" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    CGFloat customTableCellHeight = 89;
    
    return customTableCellHeight;
}

#pragma mark - Naviagation

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    if ([self.player isPlaying] == YES) {
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
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *followingRelation = [currentUser relationForKey:@"following"];
        //        PFObject *object = [PFObject objectWithClassName:@"User"];
        //        object[@"objectId"] = self.user.objectId;
        [followingRelation addObject:self.user];
        
        PFRelation *fanRelation = [self.user relationForKey:@"fans"];
        [fanRelation addObject: currentUser];
        
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil)
            {
                NSLog(@"followers saved!!!!!!!!!");
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil)
                    {
                        NSLog(@"followers saved!!!!!!!!!");
                    }
                    else
                    {
                        NSLog(@"followers saved!!!!!!!!!");
                    }
                }];
            }
            else
            {
                NSLog(@"followers saved!!!!!!!!!");
            }
        }];
    }
    else if ([self.followOrEditButton.titleLabel.text isEqual: @"Edit Profile"])
    {
        HRPEditProfileTableVC *editProfileView = [[HRPEditProfileTableVC alloc] init];
        [self presentViewController:editProfileView animated:YES completion:nil];
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
    
    //    PFFile *albumFile = postInView[@"albumArt"];
    //    if (albumFile) {
    //        [albumFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //                if (!error) {
    //                    self.coverArtView.image = [UIImage imageWithData:data];
    //                } else {
    //                    self.coverArtView.image = [UIImage imageNamed:@"spotify"];
    //                }
    //            }];
    //        }];
    //    }
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


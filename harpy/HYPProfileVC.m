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
#import "UIColor+HRPColor.h"
#import <QuartzCore/QuartzCore.h>
#import <Spotify/Spotify.h>

@interface HYPProfileVC () <UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableviewUserProfile;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSettings;

@property (nonatomic, strong) NSArray *userPosts;
@property (nonatomic, strong) NSArray *userFollowing;
@property (nonatomic, strong) NSArray *userFans;

@property (nonatomic) PFUser *currentUser;
@property (nonatomic) NSDictionary *dictionaryUser;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (strong, nonatomic) SPTAudioStreamingController *player;

@end

@implementation HYPProfileVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableviewUserProfile.delegate = self;
    self.tableviewUserProfile.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.parseService = [HRPParseNetworkService sharedService];
    
    self.currentUser = [PFUser currentUser];
    if (!self.user)
    {
        self.user = self.currentUser;
    }
    if (self.user != self.currentUser)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self retrieveHRPosts];
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

- (void)retrieveHRPosts
{
    PFRelation *userPosts = [self.user relationForKey:@"HRPPosts"];
    PFQuery *query = [userPosts query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            self.userPosts = objects;
            [self.tableviewUserProfile reloadData];
            NSLog(@"PARSE POSTS: %@", self.userPosts);
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellUserHeader" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.user != self.currentUser)
        {
            self.navigationItem.rightBarButtonItem = nil;
            //Change Follow Button
        }
        
        PFFile *userAvatarFile = self.user[@"userAvatar"];
        UIImageView *userAvatarView = (UIImageView *)[cell viewWithTag:1];
        userAvatarView.layer.masksToBounds = YES;
        if (userAvatarFile)
        {
            [userAvatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    userAvatarView.image = [UIImage imageWithData:data];
                }
                else {
                    NSLog(@"ERROR: %@ %@", error, [error userInfo]);
                }
            }];
        }
        
        NSString *realNameString = self.user[@"realName"];
        UILabel *realNameLabel = (UILabel *)[cell viewWithTag:2];
        realNameLabel.text = realNameString;
        
        NSString *shortBioString = self.user[@"shortBio"];
        UILabel *shortBioLabel = (UILabel *)[cell viewWithTag:3];
        shortBioLabel.text = shortBioString;
        
        UILabel *postsCountLabel = (UILabel *)[cell viewWithTag:4];
        postsCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userPosts.count];
        
        UILabel *followingCountLabel = (UILabel *)[cell viewWithTag:5];
        PFRelation *relation = [self.user relationForKey:@"following"];
        PFQuery *query = [relation query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.userFollowing = results;
            followingCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFollowing.count];
        }];
        
        UILabel *fansCountLabel = (UILabel *)[cell viewWithTag:6];
        PFQuery *fansQuery = [PFUser query];
        [fansQuery whereKey:@"following" equalTo:self.user];
        [fansQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.userFans = results;
            fansCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFans.count];
        }];
    }
    if (indexPath.row >= 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellPost" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        PFFile *albumArtFile = HRPPosts[@"albumArt"];
        UIImageView *albumArtView = (UIImageView *)[cell viewWithTag:1];
        albumArtView.layer.masksToBounds = YES;
        if (albumArtFile)
        {
            [albumArtFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    albumArtView.image = [UIImage imageWithData:data];
                }
                else {
                    NSLog(@"ERROR: %@ %@", error, [error userInfo]);
                }
            }];
        }
        
        NSString *songTitleString = HRPPosts[@"songTitle"];
        UILabel *songTitleLabel = (UILabel *)[cell viewWithTag:2];
        songTitleLabel.text = songTitleString;
        
        NSString *artistNameString = HRPPosts[@"artistName"];
        UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:3];
        artistNameLabel.text = artistNameString;
        
        NSString *albumNameString = HRPPosts[@"albumName"];
        UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:4];
        albumNameLabel.text = albumNameString;
    }
    
    return cell;
}

#pragma mark - Overrides

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalCellView = self.view.frame.size.height;
    CGFloat customTableCellHeight = totalCellView/10;
    
    if (indexPath.row == 0)
    {
        customTableCellHeight = totalCellView/3;
    }
    if (indexPath.row >= 1)
    {
        customTableCellHeight = totalCellView - (totalCellView/3);
    }
    
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

@end


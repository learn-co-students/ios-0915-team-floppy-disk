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
    
    NSString *usernameString = self.user.username;
    usernameString = [usernameString uppercaseString];
    self.navigationItem.title = usernameString;
    
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
    self.userPosts = [[NSArray alloc]init];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float shadowOffset = (scrollView.contentOffset.y/1);
    shadowOffset = MIN(MAX(shadowOffset, 0), 1);
    float shadowRadius = MIN(MAX(shadowOffset, 0), 1);
    
    
    self.navigationController.view.layer.shadowOffset = CGSizeMake(0, shadowOffset);
    self.navigationController.view.layer.shadowRadius = shadowRadius;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.view.layer.shadowOpacity = 0.20;
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.userPosts.count)
    {
        NSInteger cellHeader = 1;
        return self.userPosts.count + cellHeader;
    }
    else
    {
        NSInteger cellHeader = 1;
        NSInteger cellsInEmptyUserProfile = 5;
        return cellsInEmptyUserProfile + cellHeader;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellUserHeader" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.user != self.currentUser)
        {
            self.navigationItem.rightBarButtonItem = nil;
            //Change Follow Button
        }
        
        if (self.userPosts.count >= indexPath.row)
        {
            PFFile *userAvatarFile = self.user[@"userAvatar"];
            UIImageView *userAvatarView = (UIImageView *)[cell viewWithTag:1];
            CGFloat cornerRadius = userAvatarView.frame.size.height/2;
            userAvatarView.layer.cornerRadius = cornerRadius;
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
        else
        {
            UIImageView *userAvatarView = (UIImageView *)[cell viewWithTag:1];
            CGFloat cornerRadius = userAvatarView.frame.size.height/2;
            userAvatarView.layer.cornerRadius = cornerRadius;
            userAvatarView.layer.masksToBounds = YES;
            userAvatarView.image = [self imageWithColor:[UIColor whiteColor]];
            
            UILabel *realNameLabel = (UILabel *)[cell viewWithTag:2];
            realNameLabel.text = @"";
            
            UILabel *shortBioLabel = (UILabel *)[cell viewWithTag:3];
            shortBioLabel.text = @"";
            
            UILabel *postsCountLabel = (UILabel *)[cell viewWithTag:4];
            postsCountLabel.text = @"";
            
            UILabel *followingCountLabel = (UILabel *)[cell viewWithTag:5];
            followingCountLabel.text = @"";

            UILabel *fansCountLabel = (UILabel *)[cell viewWithTag:6];
            fansCountLabel.text = @"";
        }
    }
    if (indexPath.row >= 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellPost" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.userPosts.count >= indexPath.row)
        {
            NSDictionary *HRPPosts = [self.userPosts objectAtIndex:indexPath.row - 1];
            
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
        if (self.userPosts.count < indexPath.row)
        {
            UIImageView *albumArtView = (UIImageView *)[cell viewWithTag:1];
            albumArtView.layer.masksToBounds = YES;
            albumArtView.image = [self imageWithColor:[UIColor whiteColor]];
            
            UILabel *songTitleLabel = (UILabel *)[cell viewWithTag:2];
            songTitleLabel.text = @"";
            
            UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:3];
            artistNameLabel.text = @"";
            
            UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:4];
            albumNameLabel.text = @"";
        }
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
    CGFloat totalCellView = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    
    CGFloat customTableCellHeight = totalCellView/10;
    CGFloat headerCellHeight = totalCellView/3;
    CGFloat numberOfPostRows = 5;
    
    if (indexPath.row == 0)
    {
        customTableCellHeight = headerCellHeight;
    }
    if (indexPath.row >= 1)
    {
        customTableCellHeight = totalCellView - headerCellHeight;
        customTableCellHeight = customTableCellHeight/numberOfPostRows;
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

#pragma mark - Helper

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


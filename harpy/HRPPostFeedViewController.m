//
//  HRPPostFeedViewController.m
//  harpy
//
//  Created by Phil Milot on 12/4/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostFeedViewController.h"
#import <Spotify/Spotify.h>

@interface HRPPostFeedViewController () <UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottom;
@property (weak, nonatomic) IBOutlet UIStackView *musicPlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicplayViewBottom;


@property (strong, nonatomic) IBOutlet UIImageView *albumArtView;
@property (strong, nonatomic) IBOutlet UILabel *playPauseLabel;
@property (strong, nonatomic) IBOutlet UILabel *songnameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *postTableView;

@property (strong, nonatomic) SPTAudioStreamingController *player;

@end


@implementation HRPPostFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.postTableView.delegate = self;
    self.postTableView.dataSource = self;
    
    self.playPauseLabel.text = @"";
    self.songnameLabel.text = @"";
    self.artistNameLabel.text = @"";
    
    self.navigationItem.title = self.postsArray[0][@"songTitle"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.postTableView dequeueReusableCellWithIdentifier:@"postContentCell" forIndexPath:indexPath];
    
    NSDictionary *postsFromArray = self.postsArray[indexPath.row];
    
    UIButton *playSongButton = (UIButton *)[cell viewWithTag:1];
    [playSongButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playSongButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *coverArt = (UIImageView *)[cell viewWithTag:2];
    PFFile *albumFile = postsFromArray[@"albumArt"];
    if (albumFile) {
        [albumFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!error) {
                    coverArt.image = [UIImage imageWithData:data];
                } else {
                    coverArt.image = [UIImage imageNamed:@"spotify"];
                }
            }];
        }];
    }
    
    UILabel *captionLabel = (UILabel *)[cell viewWithTag:6];
    captionLabel.text = postsFromArray[@"caption"];

    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:8];
    UIImageView *profileThumbnail = (UIImageView *)[cell viewWithTag:7];
    
    profileThumbnail.clipsToBounds = YES;
    profileThumbnail.layer.masksToBounds = YES;
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    [profileThumbnail.layer setBorderColor: [ironColor CGColor]];
    [profileThumbnail.layer setBorderWidth: 1.0];
    
    for (PFObject *post in self.postsArray) {
        PFRelation *userRelation = [post relationForKey:@"username"];
        PFQuery *postUsername = [userRelation query];
        [postUsername findObjectsInBackgroundWithBlock:^(NSArray * users, NSError * error) {
            for (PFObject *username in users) {
                NSString *usernameFromBlock = username[@"username"];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    usernameLabel.text = usernameFromBlock;
                }];
                [self getUserProfilePictureForUser:usernameFromBlock WithCompletion:^(NSData *imageData) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        profileThumbnail.image = [UIImage imageWithData:imageData];
                    }];
                }];
            }
        }];
    }
    
    UILabel *daysLabel = (UILabel *)[cell viewWithTag:9];
    PFObject *postInDictionary = self.postsArray[0];
    NSString *timeSincePost = [self getDaysSincePost:postInDictionary];
    
    daysLabel.text = timeSincePost;
    
    return cell;
}

-(NSString *)getDaysSincePost:(PFObject *)post {
    
    NSDate *date = [post createdAt];
    
    //NSLog(@"%@", date);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];

    NSDateFormatter *currentFormat = [[NSDateFormatter alloc]init];
    [currentFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDate = [currentFormat stringFromDate:[NSDate date]];
    
    NSDateFormatter *diffFormat = [[NSDateFormatter alloc]init];
    [diffFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *start = [diffFormat dateFromString:stringFromDate];
    NSDate *end = [diffFormat dateFromString:currentDate];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dayComps = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:start toDate:end options:NSCalendarWrapComponents];
    
    NSInteger daysSince = [dayComps day];
    NSInteger hoursSince = [dayComps hour];
    NSInteger minutesSince = [dayComps minute];
    NSInteger secondsSince = [dayComps second];
    
    NSString *timeSince = @"";
    
    if (daysSince >= 1) {
        timeSince = [NSString stringWithFormat:@"%lid", daysSince];
    } else if (daysSince < 1 && hoursSince >= 1) {
        timeSince = [NSString stringWithFormat:@"%lih", hoursSince];
    } else if (hoursSince < 1 && minutesSince >= 1) {
        timeSince = [NSString stringWithFormat:@"%lim", minutesSince];
    } else if (minutesSince < 1) {
        timeSince = [NSString stringWithFormat:@"%lis", secondsSince];
    }
    
    return timeSince;

}

-(void)getUserProfilePictureForUser:(NSString *)user WithCompletion:(void (^)(NSData *imageData))completion{
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" matchesRegex:user];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * user, NSError * error) {
        if (!error) {
            PFUser *userFromSearch = user[0];
            PFFile *imageFile  = [userFromSearch objectForKey:@"userAvatar"];
            if (imageFile) {
                [imageFile getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
                    completion(data);
                }];
            }
        }
    }];
}

-(void)handleNewSession
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil)
    {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
    }];
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    CGFloat musicPlayerHeight = self.musicPlayView.frame.size.height;
    self.tableviewBottom.constant = musicPlayerHeight;
    self.musicplayViewBottom.constant = 0;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
    
    if (self.player.isPlaying == NO)
    {
        NSIndexPath *indexPath = [self.postTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
        
        NSDictionary *postInView = self.postsArray[indexPath.row];
        
        self.songnameLabel.text = postInView[@"songTitle"];
        self.artistNameLabel.text = postInView[@"artistName"];
        self.playPauseLabel.text = @"Playing";
        self.albumArtView.image = [UIImage imageNamed:@"white_pause"];
        
        [self handleNewSession];
        NSString *urlString = postInView[@"songURL"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        [self.player playURIs:@[ url ] fromIndex:0 callback:^(NSError *error) {
            [sender setImage:[UIImage imageNamed:@"black_stop"] forState:UIControlStateNormal];
        }];
    } else if (self.player.isPlaying == YES)
    {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.playPauseLabel.text = @"Paused";
        self.albumArtView.image = [UIImage imageNamed:@"white_play"];
    }
}

- (IBAction)playerViewTapped:(UITapGestureRecognizer *)sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    
    if ([self.playPauseLabel.text isEqualToString:@"Playing"]) {
        self.playPauseLabel.text = @"Paused";
        self.albumArtView.image = [UIImage imageNamed:@"white_play"];
    } else if ([self.playPauseLabel.text isEqualToString:@"Paused"]) {
        self.playPauseLabel.text = @"Playing";
        self.albumArtView.image = [UIImage imageNamed:@"white_pause"];
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    if (self.player.isPlaying == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    }
    self.player = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

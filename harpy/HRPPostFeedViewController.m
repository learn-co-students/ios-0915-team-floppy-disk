//
//  HRPPostFeedViewController.m
//  harpy
//
//  Created by Phil Milot on 12/4/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostFeedViewController.h"
#import <Spotify/Spotify.h>

@interface HRPPostFeedViewController () <UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *albumArtView;
@property (strong, nonatomic) IBOutlet UILabel *playPauseLabel;
@property (strong, nonatomic) IBOutlet UILabel *songnameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *postTableView;

@end

@implementation HRPPostFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postTableView.delegate = self;
    self.postTableView.dataSource = self;
    
    self.playPauseLabel.text = @"";
    self.songnameLabel.text = @"";
    self.artistNameLabel.text = @"";
}

-(void)initializeEmptyPostArray {
    self.postsArray = [NSMutableArray new];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger count = self.postsArray.count;
    NSInteger numberOfRows = (NSInteger)count * 2;
    return numberOfRows;
}

//height method

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {
        UITableViewCell *cell2 = [self.postTableView dequeueReusableCellWithIdentifier:@"postContentCell" forIndexPath:indexPath];
        
        NSUInteger arraySpot = indexPath.row - (indexPath.row/2);
        
        UIButton *playSongButton = (UIButton *)[cell2 viewWithTag:1];
        //add button actions
        
        UIImageView *coverArt = (UIImageView *)[cell2 viewWithTag:2];
        //use arraySpot?
        PFFile *albumFile = self.postsArray[0][@"albumArt"];
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
        
        UIImageView *spotifyLogo = (UIImageView *)[cell2 viewWithTag:3];
        spotifyLogo.image = [UIImage imageNamed:@"spotify"];
        
        UILabel *likesLabel = (UILabel *)[cell2 viewWithTag:4];
        //relation
        
        UILabel *commentsLabel = (UILabel *)[cell2 viewWithTag:5];
        commentsLabel.text = self.postsArray[0][@"comments"];
        
        UILabel *captionLabel = (UILabel *)[cell2 viewWithTag:6];
        captionLabel.text = self.postsArray[0][@"caption"];
        
        return cell2;
    } else {
        UITableViewCell *cell1 = [self.postTableView dequeueReusableCellWithIdentifier:@"userInfoCell" forIndexPath:indexPath];
        
        NSUInteger arraySpot = 0;
        PFObject *post = [[PFObject alloc]init];
        if (indexPath.row > 1) {
            arraySpot = (indexPath.row + 1) / 2;
            post = self.postsArray[arraySpot];
        } else if (indexPath.row == 1) {
            arraySpot = 1;
            post = self.postsArray[arraySpot];
        }
        
        //add cell properties
        UILabel *usernameLabel = (UILabel *)[cell1 viewWithTag:2];
        UIImageView *profileThumbnail = (UIImageView *)[cell1 viewWithTag:1];
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
        
        UILabel *daysLabel = (UILabel *)[cell1 viewWithTag:3];
        NSInteger daysSincePost = [self getDaysSincePost:post];
        daysLabel.text = [NSString stringWithFormat:@"%ldd", daysSincePost];
        
        
        
        return cell1;
    }
}

-(NSInteger)getDaysSincePost:(PFObject *)post {
    
    NSDate *date = [post createdAt];
    
    NSLog(@"%@", date);
    //get date posted
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    NSLog(@"DATE POSTED: %@", stringFromDate);
    
    //get current date
    NSDateFormatter *currentFormat = [[NSDateFormatter alloc]init];
    [currentFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [currentFormat stringFromDate:[NSDate date]];
    NSLog(@"CURRENT DATE: %@", currentDate);
    
    //get difference of days
    NSDateFormatter *diffFormat = [[NSDateFormatter alloc]init];
    [diffFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *start = [diffFormat dateFromString:stringFromDate];
    NSDate *end = [diffFormat dateFromString:currentDate];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *gregComps = [calendar components:NSCalendarUnitDay fromDate:start toDate:end options:NSCalendarWrapComponents];
    
    NSLog(@"DAYS SINCE POST: %ld", [gregComps day]);
    
    return [gregComps day];
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

@end

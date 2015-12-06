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
        
        
        //add cell properties
        
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
        
        return cell1;
    }
}

@end

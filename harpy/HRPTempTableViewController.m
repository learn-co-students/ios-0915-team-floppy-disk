//
//  HRPTempTableViewController.m
//  harpy
//
//  Created by Phil Milot on 11/20/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPTempTableViewController.h"
#import <Spotify/Spotify.h>
#import "HRPTrackCreator.h"
#import "HRPTrack.h"
#import "HRPTempViewController.h"

@interface HRPTempTableViewController ()

@property (nonatomic, strong) NSMutableArray *trackForTable;


@end

@implementation HRPTempTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HRPTrackCreator generateTracksFromSearch:@"Stainless" WithCompletion:^(NSArray *tracks) {
        self.trackForTable = [NSMutableArray arrayWithArray:tracks];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trackForTable.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
    HRPTrack *track  = self.trackForTable[indexPath.row];
    
    UILabel *songNameLabel = (UILabel *)[cell viewWithTag:1];
    songNameLabel.text = track.songTitle;
    
    UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:2];
    artistNameLabel.text = track.artistName;
    
    UILabel *albumLabel = (UILabel *)[cell viewWithTag:3];
    albumLabel.text = track.albumName;
    
    return cell;
}






// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    HRPTempViewController *destVC = segue.destinationViewController;
    NSIndexPath *path = self.tableView.indexPathForSelectedRow;
    HRPTrack *selectedTrack = self.trackForTable[path.row];
    destVC.track = selectedTrack;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 109.0;
}

@end

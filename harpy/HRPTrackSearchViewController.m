//
//  HRPTrackSearchViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPTrackSearchViewController.h"
#import "HRPTrack.h"
#import "HRPTrackCreator.h"
#import "HRPPostPreviewViewController.h"

@interface HRPTrackSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *songSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (strong, nonatomic) NSMutableArray *filteredSongArray;
@property (strong, nonatomic) NSArray *originalArray;
//may not need original array

@end

@implementation HRPTrackSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.songSearchBar.delegate = self;
    self.songTableView.delegate = self;
    self.songTableView.dataSource = self;

    [self initializeEmptySongArray];

}

- (void) viewWillAppear:(BOOL)animated {
    [self.songTableView deselectRowAtIndexPath:[self.songTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

-(void)initializeEmptySongArray {
    self.songArray = [NSMutableArray new];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.songSearchBar.text isEqualToString:@""]) {
        return self.songArray.count;
    } else {
        return self.filteredSongArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 109.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
    HRPTrack *track  = self.filteredSongArray[indexPath.row];
    
    UILabel *songNameLabel = (UILabel *)[cell viewWithTag:1];
    songNameLabel.text = track.songTitle;
    
    UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:2];
    artistNameLabel.text = track.artistName;
    
    UILabel *albumLabel = (UILabel *)[cell viewWithTag:3];
    albumLabel.text = track.albumName;
    
    UIImageView *coverArt = (UIImageView *)[cell viewWithTag:4];
    if (track.spotifyLogo == nil) {
        coverArt.image = [UIImage imageWithData:track.albumCoverArt];
    } else {
        coverArt.image = track.spotifyLogo;
    }
    
    return cell;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        self.filteredSongArray = self.songArray;
        [self.songTableView reloadData];
    }
    
    [HRPTrackCreator generateTracksFromSearch:searchText WithCompletion:^(NSArray *tracks) {
        self.filteredSongArray = [NSMutableArray arrayWithArray:tracks];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.songTableView reloadData];
        }];
    }];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text = [NSString stringWithFormat:@""];
    self.filteredSongArray = self.songArray;
    [self.songTableView reloadData];
    [searchBar resignFirstResponder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    HRPPostPreviewViewController *destinVC = segue.destinationViewController;
    NSIndexPath *indexPath = self.songTableView.indexPathForSelectedRow;
    HRPTrack *track = self.filteredSongArray[indexPath.row];
    destinVC.track = track;
    
}


@end

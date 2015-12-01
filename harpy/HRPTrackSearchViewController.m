//
//  HRPTrackSearchViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "HRPTrackSearchViewController.h"
#import "HRPTrack.h"
#import "HRPTrackCreator.h"
#import "HRPPostPreviewViewController.h"

@interface HRPTrackSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SPTAudioStreamingDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *songSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (strong, nonatomic) NSMutableArray *filteredSongArray;

@property (strong, nonatomic) IBOutlet UIImageView *playerCoverView;
@property (strong, nonatomic) IBOutlet UILabel *playStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerSongLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerArtistLabel;


@property (strong, nonatomic) SPTAudioStreamingController *player;

@end

@implementation HRPTrackSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.songSearchBar.delegate = self;
    self.songTableView.delegate = self;
    self.songTableView.dataSource = self;

    [self initializeEmptySongArray];
    self.playStatusLabel.text = @"";
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
    
    UIButton *playTrackButton = (UIButton *)[cell viewWithTag:5];
    [playTrackButton addTarget:self action:@selector(cellPlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
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
    destinVC.post = self.post;
}

- (IBAction)cellPlayButtonTapped:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self.songTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    HRPTrack *trackAtCell = self.filteredSongArray[indexPath.row];
    self.playerSongLabel.text = trackAtCell.songTitle;
    self.playerArtistLabel.text = trackAtCell.artistName;
    self.playerCoverView.image = [UIImage imageWithData:trackAtCell.albumCoverArt];
    self.playStatusLabel.text = @"Playing";
    
    [self handleNewSession];
    NSString *urlString = [NSString stringWithFormat:trackAtCell.spotifyURI];
    NSURL *url = [NSURL URLWithString:urlString];
    //NSURL *url = trackAtCell.spotifyURI;
    
    [self.player playURIs:@[ url ] fromIndex:0 callback:^(NSError *error) {
        NSLog(@"%@", error);
        
    }];
}


- (IBAction)playerViewTapped:(UITapGestureRecognizer *)sender {
    
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    
    if ([self.playStatusLabel.text isEqualToString:@"Playing"]) {
        self.playStatusLabel.text = @"Paused";
    } else if ([self.playStatusLabel.text isEqualToString:@"Paused"]) {
        self.playStatusLabel.text = @"Playing";
    }
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        //is this an audioStreamingDelegate issue? if so, must moce to AppDelegate
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
    
    
}

@end

//
//  HRPTempViewController.m
//  harpy
//
//  Created by Phil Milot on 11/20/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPTempViewController.h"
#import <Spotify/Spotify.h>

@interface HRPTempViewController () <SPTAudioStreamingDelegate>

@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverArtView;
@property (strong, nonatomic) NSString *playbackURI;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;

@property (strong, nonatomic) SPTAudioStreamingController *player;

@end

@implementation HRPTempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.songNameLabel.text = self.track.songTitle;
    self.artistNameLabel.text = self.track.artistName;
    self.albumNameLabel.text = self.track.albumName;
    self.coverArtView.image = [UIImage imageWithData:self.track.albumCoverArt];
    self.playbackURI = [NSString stringWithFormat:self.track.spotifyURI];
    
//    [self.coverArtView addSubview:self.songNameLabel];
//    [self.coverArtView addSubview:self.artistNameLabel];
//    [self.coverArtView addSubview:self.albumNameLabel];
//    [self.coverArtView addSubview:self.playPauseButton];
    
    [self handleNewSession];
    
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
}

- (IBAction)playPauseButtonTapped:(UIButton *)sender {
    
    
    NSURL *url = [NSURL URLWithString:self.playbackURI];
    [self.player playURIs:@[ url ] fromIndex:0 callback:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    NSLog(@"Button Tapped!");
    
}

@end

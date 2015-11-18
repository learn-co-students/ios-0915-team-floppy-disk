//
//  HRPSpotifyViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPSpotifyViewController.h"
#import <Spotify/Spotify.h>

@interface HRPSpotifyViewController ()

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

@implementation HRPSpotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)play:(id)sender {

}
- (IBAction)pause:(id)sender {
}
- (IBAction)stop:(id)sender {
}

@end

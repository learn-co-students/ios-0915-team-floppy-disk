//
//  HRPTrack.h
//  harpy
//
//  Created by Phil Milot on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>


@interface HRPTrack : NSObject

@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSURL *spotifyURI;
@property (nonatomic, strong) NSData *albumCoverArt;
@property (nonatomic, strong) NSNumber *songPopularity;



-(instancetype)initWithSongTitle:(NSString *)title artistName:(NSString *)artist albumName:(NSString *)album spotifyURL:(NSURL *)url coverArt:(NSData *)cover songPopularity:(NSNumber *)popularity;

-(void)trackDidStartPlayback;

-(void)trackDidPausePlayback;

-(void)songDidStopPlayback;

-(void)songDidSkipForwards;

-(void)songDidSkipBackwards;

@end

//
//  HRPTrack.m
//  harpy
//
//  Created by Phil Milot on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPTrack.h"

@interface HRPTrack ()




@end

@implementation HRPTrack

-(instancetype)initWithSongTitle:(NSString *)title artistName:(NSString *)artist albumName:(NSString *)album spotifyURL:(NSURL *)url coverArt:(NSData *)cover songPopularity:(NSNumber *)popularity {
    self = [super init];
    if (self) {
        _songTitle = title;
        _artistName = artist;
        _albumName = album;
        _spotifyURI = url;
        _albumCoverArt = cover;
        _songPopularity = popularity;
    }
    return self;
}

-(void)trackDidStartPlayback{
    
    
}

//-(void)trackDidPausePlayback;
//
//-(void)songDidStopPlayback;
//
//-(void)songDidSkipForwards;
//
//-(void)songDidSkipBackwards;

@end

//
//  HRPTrack.h
//  harpy
//
//  Created by Phil Milot on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface HRPTrackCreator : NSObject


+(void)searchSpotifyForTrack:(NSString *)track WithCompletion:(void (^)(NSArray *trackList))completion;

+(void)getSingleTrackDataFromURI:(NSURL *)trackURI WithCompletion:(void (^)(NSDictionary *trackInfo))completion;

@end

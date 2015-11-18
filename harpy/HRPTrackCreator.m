//
//  HRPTrack.m
//  harpy
//
//  Created by Phil Milot on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPTrackCreator.h"
#import "HRPTrack.h"

@implementation HRPTrackCreator

+(void)searchSpotifyForTrack:(NSString *)track WithCompletion:(void (^)(NSArray *trackList))completion {
    
    NSString *formattedTrack = [track stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [SPTSearch performSearchWithQuery:formattedTrack queryType:SPTQueryTypeTrack offset:0 accessToken:nil callback:^(NSError *error, SPTListPage *results) {
         NSArray *songArray = results.items;
         NSMutableArray *trackURIArray = [[NSMutableArray alloc]init];
         for (SPTPartialTrack *songPointer in songArray) {
             NSURL *trackURI = songPointer.playableUri;
             [trackURIArray addObject:trackURI];
         }
        completion(trackURIArray);
    }];
}

+(void)getSingleTrackDataFromURI:(NSURL *)trackURI WithCompletion:(void (^)(NSDictionary *trackInfo))completion {
    
    
    NSURLRequest *request = [SPTTrack createRequestForTrack:trackURI withAccessToken:nil market:nil error:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *trackData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *trackDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        completion(trackDict);
    }];
    [trackData resume];
}

+(void)generateTracksFromSearch:(NSString *)searchKeyword WithCompletion:(void (^)(NSArray *tracks))completion {
    [HRPTrackCreator searchSpotifyForTrack:searchKeyword WithCompletion:^(NSArray *trackList) {
        __block NSMutableArray *songDataArray = [[NSMutableArray alloc]init];
        for (NSURL *url in trackList) {
            [HRPTrackCreator getSingleTrackDataFromURI:url WithCompletion:^(NSDictionary *trackInfo) {
                
                NSString *songName = trackInfo[@"name"];
                NSString *artistName = trackInfo[@"artists"][@"name"];
                NSString *albumName = trackInfo[@"album"][@"name"];
                NSURL *spotifyURL = trackInfo[@"uri"];
                NSNumber *songPopularity = trackInfo[@"popularity"];
                
                NSDictionary *coverArtURLLocation = trackInfo[@"album"][@"images"][1];
                NSURL *coverArtURL = coverArtURLLocation[@"url"];
                NSData *coverArt = [[NSData alloc] initWithContentsOfURL:coverArtURL];
                
                HRPTrack *newTrack = [[HRPTrack alloc] initWithSongTitle:songName artistName:artistName albumName:albumName spotifyURL:spotifyURL coverArt:coverArt songPopularity:songPopularity];
                [songDataArray addObject:newTrack];
                if (songDataArray.count == trackList.count) {
                    NSLog(@"%@", songDataArray);
                    completion(songDataArray);
                }
            }];
        }
        
    }];
}

@end

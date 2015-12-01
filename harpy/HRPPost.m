//
//  HRPPost.m
//  harpy
//
//  Created by Phil Milot on 11/30/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPost.h"
#import <Parse/Parse.h>

@implementation HRPPost

-(instancetype)initWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

-(void)createPostForTrack:(HRPTrack *)track withCaption:(NSString *)caption WithCompletion:(void (^)(BOOL success))completion {
    //******* does not include functionality to add photo to post
    
    
    //set up for parse
    PFObject *post = [PFObject objectWithClassName:@"HRPPost"];
    PFUser *currentUser = [PFUser currentUser];
    
    //setting post properties to track properties
    self.postSongTitle = track.songTitle;
    self.postArtistName = track.artistName;
    self.postAlbumName = track.albumName;
    
    NSString *urlString = (NSString *)track.spotifyURI;
    self.postSongURL = urlString;
    
    self.postAlbumArt = track.albumCoverArt;
    PFFile *albumcover = [PFFile fileWithName:@"album_cover" data:track.albumCoverArt];

    post[@"username"] = currentUser;
    post[@"songTitle"] = self.postSongTitle;
    post[@"artistName"] = self.postArtistName;
    post[@"albumName"] = self.postAlbumName;
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.latitude longitude:self.longitude];
    post[@"locationGeoPoint"] = point;
    
    post[@"comments"] = [NSNull null];
    post[@"likes"] = [NSNull null];
    post[@"songURL"] = urlString;
    post[@"albumArt"] = albumcover;
    
    post[@"postPhoto"] = [NSNull null];
    
    post[@"caption"] = caption;
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            completion(NO);
        } else {
            completion(YES);
        }
    }];
}

@end

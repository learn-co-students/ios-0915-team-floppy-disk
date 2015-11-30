//
//  HRPPost.m
//  harpy
//
//  Created by Phil Milot on 11/30/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPost.h"
#import "HRPTrack.h"
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

-(void)createPostForTrack:(HRPTrack *)track {
    
    PFObject *post = [PFObject objectWithClassName:@"HRPPost"];
    PFUser *currentUser = [PFUser currentUser];
    NSString *urlString = (NSString *)track.spotifyURI;
    PFFile *albumcover = [PFFile fileWithName:@"album_cover" data:track.albumCoverArt];
    
    
}

@end

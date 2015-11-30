//
//  HRPPost.h
//  harpy
//
//  Created by Phil Milot on 11/30/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HRPTrack.h"

@interface HRPPost : NSObject

@property (nonatomic, strong) NSString *postSongTitle;
@property (nonatomic, strong) NSString *postArtistName;
@property (nonatomic, strong) NSString *postAlbumName;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSString *postSongURL;
@property (nonatomic, strong) NSData *postAlbumArt;
@property (nonatomic, strong) NSData *postPhoto;

-(instancetype)initWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude;

-(void)createPostForTrack:(HRPTrack *)track withCaption:(NSString *)caption WithCompletion:(void (^)(BOOL success))completion;

@end

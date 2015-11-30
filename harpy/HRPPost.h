//
//  HRPPost.h
//  harpy
//
//  Created by Phil Milot on 11/30/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HRPPost : NSObject

@property (nonatomic, strong) NSString *postSongTitle;
@property (nonatomic, strong) NSString *postArtistName;
@property (nonatomic, strong) NSString *postAlbumName;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSString *postLocationName;
@property (nonatomic, strong) NSMutableDictionary *postComments;
@property (nonatomic, strong) NSMutableArray *postLikes;
@property (nonatomic, strong) NSString *songURL;
@property (nonatomic, strong) NSData *postSongURL;
@property (nonatomic, strong) NSData *postPhoto;

-(instancetype)initWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude;

@end

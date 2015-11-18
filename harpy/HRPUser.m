//
//  HRPUser.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUser.h"

@implementation HRPUser

-(instancetype)initWithUserID:(NSString *)userID userName:(NSString *)userName email:(NSString *)email createAt:(NSDate *)createAt HRPUsersfollowers:(NSMutableArray *)HRPUsersfollowers HRPFans:(NSMutableArray *)HRPFans profileImage:(UIImage *)profileImage HRPPosts:(NSArray *)HRPPosts HRPPostLikes:(NSArray *)HRPPostLikes spotifyID:(NSString *)spotifyID spotifyPremium:(BOOL *)spotifyPremium{
    if (self == [super init]) {
        _userName = userName;
        _email = email;
        _createAt = createAt;
        _HRPUsersfollowers = HRPUsersfollowers;
        _HRPFans = HRPFans;
        _profileImage = profileImage;
        _HRPPosts = HRPPosts;
        _HRPPostLikes = HRPPostLikes;
        _spotifyID = spotifyID;
        _spotifyPremium = spotifyPremium;
    }
    return self;
}

-(instancetype)initWithUserID:(NSString *)userID userName:(NSString *)userName email:(NSString *)email{
    if (self == [super init]) {
        _userID = userID;
        _userName = userName;
        _email = email;
    }
    return self;
}

@end

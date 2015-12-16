//
//  HRPUser.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HRPUser : NSObject

@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *password;
@property (strong,nonatomic) NSString *email;
@property (strong,nonatomic) NSDate *createAt;
@property (strong,nonatomic) NSMutableArray *HRPUsersfollowers;
@property (strong,nonatomic) NSMutableArray *HRPFans;
@property (strong,nonatomic) UIImage *profileImage;
@property (strong,nonatomic) NSArray *HRPPosts;
@property (strong,nonatomic) NSArray *HRPPostLikes;
@property (strong,nonatomic) NSString *spotifyID;
@property (nonatomic) BOOL spotifyPremium;

-(instancetype)initWithUsername:(NSString *)userName password:(NSString *)password;
-(instancetype)initWithUserID:(NSString *)userID userName:(NSString *)userName email:(NSString *)email password:(NSString *)password;

@end

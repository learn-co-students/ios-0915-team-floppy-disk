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

/*TODO: Figure out whitch should be private or readonly*/

@property (strong,nonatomic) NSString *userID; // Called property objectId by parse
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *password; // Not in init method
@property (strong,nonatomic) NSString *email;
@property (strong,nonatomic) NSDate *createAt;
@property (strong,nonatomic) NSMutableArray *HRPUsersfollowers;
@property (strong,nonatomic) NSMutableArray *HRPFans;
@property (strong,nonatomic) UIImage *profileImage;
@property (strong,nonatomic) NSArray *HRPPosts;
@property (strong,nonatomic) NSArray *HRPPostLikes;
@property (strong,nonatomic) NSString *spotifyID;
@property (nonatomic) BOOL spotifyPremium;

-(instancetype)initWithUserID:(NSString *)userID userName:(NSString *)userName email:(NSString *)email createAt:(NSDate *)createAt HRPUsersfollowers:(NSMutableArray *)HRPUsersfollowers HRPFans:(NSMutableArray *)HRPFans profileImage:(UIImage *)profileImage HRPPosts:(NSArray *)HRPPosts HRPPostLikes:(NSArray *)HRPPostLikes spotifyID:(NSString *)spotifyID spotifyPremium:(BOOL *)spotifyPremium;

-(instancetype)initWithUserID:(NSString *)userID UserName:(NSString *)userName email:(NSString *)email;

@end

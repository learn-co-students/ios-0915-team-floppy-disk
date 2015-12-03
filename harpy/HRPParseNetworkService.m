//
//  HRPParseNetworkService.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPParseNetworkService.h"
#import "HRPUser.h"
#import <Spotify/Spotify.h>

@interface HRPParseNetworkService ( )

@end

@implementation HRPParseNetworkService

#pragma mark - Singleton Methods

+(id)sharedService
{
    static HRPParseNetworkService *mySharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedService = [[self alloc] init];
    });
    return mySharedService;
}

#pragma mark - Parse Network Methods

-(void)loginApp:(NSString *)username password:(NSString *)password completionHandler:(void (^)(HRPUser *user, NSError *error))completionHandler
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            PFUser *currentUser = [PFUser currentUser];
            HRPUser *user = [[HRPUser alloc]initWithUsername:currentUser.username password:currentUser.password];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                completionHandler(user, nil);
            }];
        }
        else if ([error.domain isEqual: @"Parse"] && error.code == (int)101)
        {
            completionHandler(nil, error);
             NSLog(@"ERROR: %@ %@", error, [error userInfo]);
        }
    }];
}
-(void)createUser:(NSString *)username email:(NSString *)email password:(NSString *)password completionHandler:(void (^)(HRPUser *user, NSError *error))completionHandler
{
    PFUser *user = [[PFUser alloc]init];
    user.username = username;
    user.email = email;
    user.password = password;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             PFUser *currentUser = [PFUser currentUser];
             HRPUser *user = [[HRPUser alloc]initWithUserID:currentUser.objectId
                                                   userName:currentUser.username
                                                      email:currentUser.email
                                                   password:currentUser.password];
             [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                 completionHandler(user, nil);
             }];
         }
         else
         {
             [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                 completionHandler(nil, error);
                 NSLog(@"ERROR: %@ %@", error, [error userInfo]);
             }];
         }
     }];
}
- (void)logout
{
    [PFUser logOutInBackground];
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.sessionUserDefaultsKey = nil;
}


+ (void)getPhotoForUser:(PFUser *)user WithBlock:(void (^)(UIImage *photo))completionBlock
{
    PFFile *imageFile = [user objectForKey:@"photo"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:result];
            completionBlock(image);
        }
    }];
}

@end
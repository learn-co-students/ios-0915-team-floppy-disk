//
//  HRPParseNetworkService.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPParseNetworkService.h"
#import "HRPUser.h"

@interface HRPParseNetworkService ( )


@end

@implementation HRPParseNetworkService

+(id)sharedService {
    static HRPParseNetworkService *mySharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedService = [[self alloc] init];
    });
    return mySharedService;
}

-(void)loginApp:(NSString *)username password:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler {
    NSError *error;
    [PFUser logInWithUsername:username password:password error:&error];
    if (error) {
        NSLog(@"ERROR: %@ %@", error, [error userInfo]);
    } else {
        PFUser *currentUser = [PFUser currentUser];
        HRPUser *user = [[HRPUser alloc]initWithUsername:currentUser.username password:currentUser.password];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            completionHandler(user);
        }];
    }
}

-(void)createUser:(NSString *)username email:(NSString *)email password:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler {
    NSError *error;
    PFUser *user = [[PFUser alloc]init];
    user.username = username;
    user.email = email;
    user.password = password;
    if (error) {
        NSLog(@"ERROR: %@ %@", error, [error userInfo]);
    } else {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFUser *currentUser = [PFUser currentUser];
            HRPUser *user = [[HRPUser alloc]initWithUserID:currentUser.objectId
                                                  userName:currentUser.username
                                                     email:currentUser.email
                                                  password:currentUser.password];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                completionHandler(user);
            }];
        }];
    }
}

@end
//
//  HRPParseNetworkService.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPParseNetworkService.h"
#import "HRPUser.h"
#import <Parse/Parse.h>

@implementation HRPParseNetworkService

+(id)sharedService {
    static HRPParseNetworkService *mySharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedService = [[self alloc] init];
    });
    return mySharedService;
}

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler {
    NSError *error;
    [PFUser logInWithUsername:username password:password error:&error];
    if (error) {
        // Do Something
    } else {
        PFUser *currentUser = [PFUser currentUser];
        HRPUser *user = [[HRPUser alloc]initWithUserID:currentUser.objectId UserName:currentUser.username email:currentUser.email];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            completionHandler(user);
        }];
    }
}

-(void)createUserWithEmail:(NSString *)email completionHandler:(void (^)(HRPUser *user))completionHandler {
    NSError *error;
    PFUser *user = [[PFUser alloc]init];
    user.email = email;
    if (error) {
        // Do Something
    } else {
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFUser *currentUser = [PFUser currentUser];
        HRPUser *user = [[HRPUser alloc]initWithUserID:currentUser.objectId UserName:nil email:currentUser.email];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            completionHandler(user);
        }];
    }];
    }
}


//-(void)createUser:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler {
//    PFUser *user = [[PFUser alloc]init];
//    user.username = username;
//    user.password = password;
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        PFUser *currentUser = [PFUser currentUser];
//        HRPUser *user = [[HRPUser alloc]initWithUserID:currentUser.objectId UserName:nil email:currentUser.email];
//        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//            completionHandler(user);
//        }];
//    }];
//}

@end

//
//  HRPParseNetworkService.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class HRPUser;

@interface HRPParseNetworkService : NSObject

@property (nonatomic) HRPUser *user;

+(id)sharedService;

-(void)loginApp:(NSString *)username password:(NSString *)password completionHandler:(void (^)(HRPUser *user, NSError *error))completionHandler;
-(void)createUser:(NSString *)username email:(NSString *)email password:(NSString *)password completionHandler:(void (^)(HRPUser *user, NSError *error))completionHandler;
- (void)logout;

@end

//
//  HRPParseNetworkService.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HRPUser;

@interface HRPParseNetworkService : NSObject

+(id)sharedService;

-(void)loginApp:(NSString *)username password:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler;
-(void)createUser:(NSString *)username email:(NSString *)email password:(NSString *)password completionHandler:(void (^)(HRPUser *user))completionHandler;

@end

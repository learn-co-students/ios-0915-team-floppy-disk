//
//  HRPValidationManager.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>

// extern: define constants/strings for notification names and dictionary keys
extern NSString *const kHRPValidationManagerUsernameKey;
extern NSString *const kHRPValidationManagerEmailAddressKey;
extern NSString *const kHRPValidationManagerPasswordKey;

@interface HRPValidationManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)validateValue:(NSString *)value forKey:(NSString *)key;

+ (NSString *)usernameRegex;
+ (NSString *)emailAddressRegex;
+ (NSString *)passwordRegex;

@end

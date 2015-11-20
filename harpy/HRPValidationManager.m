//
//  HRPValidationManager.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPValidationManager.h"
#import <Parse/Parse.h>

NSString * const kHRPValidationManagerUsernameKey = @"kMQValidationManagerUsernameKey";
NSString * const kHRPValidationManagerEmailAddressKey = @"kMQValidationManagerEmailAddressKey";
NSString * const kHRPValidationManagerPasswordKey = @"kMQValidationManagerPasswordKey";

@interface HRPValidationManager ()

@property (nonatomic) BOOL parseQueryUsers;

@end

@implementation HRPValidationManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static HRPValidationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HRPValidationManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - Private methods

- (BOOL)validateValue:(NSString *)value forKey:(NSString *)key
{
    if (!value || value.length == 0) {
        return NO;
    }
    BOOL valid = NO;
    NSRegularExpression *regex;
    if ([key isEqualToString:kHRPValidationManagerUsernameKey]) {
        // Username.
         regex = [[NSRegularExpression alloc] initWithPattern:[[self class] usernameRegex] options:NSRegularExpressionCaseInsensitive error:nil];
    } else if ([key isEqualToString:kHRPValidationManagerEmailAddressKey]) {
        // Email Address.
        regex = [[NSRegularExpression alloc] initWithPattern:[[self class] emailAddressRegex] options:NSRegularExpressionCaseInsensitive error:nil];
    } else if ([key isEqualToString:kHRPValidationManagerPasswordKey]) {
        // Password.
        regex = [[NSRegularExpression alloc] initWithPattern:[[self class] passwordRegex] options:NSRegularExpressionCaseInsensitive error:nil];
    } else {
        // Invalid key.
        return NO;
    }
    NSUInteger results = [regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
    if (results > 0) {
        valid = YES;
    }
    
    return valid;
}

#pragma mark - Public methods

+ (NSString *)usernameRegex
{
    return @"^[A-Za-z0-9]{4,20}$";
}
+ (NSString *)emailAddressRegex
{
    return @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
}
+ (NSString *)passwordRegex
{
    return @"^(?=.*\\d+)(?=.*[A-Za-z])[0-9a-zA-Z!@#$%^&*()]{6,20}$";
}


@end
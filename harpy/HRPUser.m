//
//  HRPUser.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUser.h"

@implementation HRPUser

-(instancetype)initWithUsername:(NSString *)userName password:(NSString *)password {
    if (self == [super init]) {
        _userName = userName;
        _password = password;
    }
    return self;
}

-(instancetype)initWithUserID:(NSString *)userID userName:(NSString *)userName email:(NSString *)email password:(NSString *)password {
    if (self == [super init]) {
        _userID = userID;
        _userName = userName;
        _email = email;
        _password = password;
    }
    return self;
}


@end

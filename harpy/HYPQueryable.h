//
//  HYPQueryable.h
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface HYPQueryable : NSObject

- (NSArray *)queryUser:(PFUser *)user withRelationForKey:(NSString *)key;

@end

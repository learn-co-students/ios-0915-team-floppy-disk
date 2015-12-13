//
//  HYPQueryable.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HYPQueryable.h"

@interface HYPQueryable ()

@property (nonatomic, strong) NSArray *arrayReturn;

@end

@implementation HYPQueryable

- (NSArray *)queryUser:(PFUser *)user withRelationForKey:(NSString *)key
{
    PFRelation *relation = [user relationForKey:key];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            self.arrayReturn = results;
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    return self.arrayReturn;
}

//- (NSArray *)queryUser:(PFUser *)user withRelationForKeyAndOrderByDescending:(NSString *)key
//{
//    PFRelation *relation = [user relationForKey:key];
//    PFQuery *query = [relation query];
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable results, NSError * _Nullable error) {
//        if (!error)
//        {
//            return results;
//        }
//        else
//        {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//}
//
//
////PFRelation *followingCount = self.user[@"following"];
//PFRelation *relation = [self.user relationForKey:@"following"];
//PFQuery *query = [relation query];
//[query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//    NSLog(@"FOLLOWERS: %@", self.user);
//    self.userFollowing = results;
//    self.followingCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFollowing.count];
//}];
//
//PFQuery *fansQuery = [PFUser query];
//[fansQuery whereKey:@"following" equalTo:self.user];
//[fansQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//    // so i think this will return all the users who are following self.user
//    NSLog(@"FANS: %@", objects);
//    self.userFans = objects;
//    self.fansCountLabel.text = [NSString stringWithFormat:@"%i", (int)self.userFans.count];
//}];

@end

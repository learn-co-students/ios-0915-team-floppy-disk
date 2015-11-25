//
//  HRPUserSearchVC.m
//  harpy
//
//  Created by Kiara Robles on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUserSearchVC.h"
#import "HRPUser.h"
#import <Parse/Parse.h>

@interface HRPUserSearchVC ()  <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSMutableArray *users;

@end

@implementation HRPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    
    [self initializeEmptyUsersArray];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error) {
            NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
            self.users = [objects mutableCopy];
            [self.userTableView reloadData];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
//    PFQuery *query = [PFUser query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        
//        if (!error)
//        {
//            NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
//            self.users = [objects mutableCopy];
//        } else
//        {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.userTableView deselectRowAtIndexPath:[self.userTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

-(void)initializeEmptyUsersArray {
    self.users = [NSMutableArray new];
}


- (void)fetchAllUsers:(void (^)(NSArray *, BOOL, NSError *))completionBlock {
    
    PFQuery *userQuery = [PFUser query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
            if (!error) {
                completionBlock(objects, YES, error);
                
                NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
                self.users = [objects mutableCopy];
                [self.userTableView reloadData];
                
            } else {
                completionBlock(@[], NO, error);
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
    }];
}

#pragma mark - Search bar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.userTableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    PFUser *user = [self.users objectAtIndex:[indexPath row]]; // Add one since array count starts at 0
    cell.textLabel.text = user.username;
    
    return cell;
}

@end

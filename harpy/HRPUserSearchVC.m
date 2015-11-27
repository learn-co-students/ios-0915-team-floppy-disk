//
//  HRPUserSearchVC.m
//  harpy
//
//  Created by Kiara Robles on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUserSearchVC.h"
#import "HRPUser.h"
#import "HRPParseNetworkService.h"

@interface HRPUserSearchVC ()  <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSMutableArray *users;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (strong, nonatomic) NSMutableArray *userAndAvatars;

@end

@implementation HRPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.parseService = [HRPParseNetworkService sharedService];
    
    [self initializeEmptyUsersArray];
    [self setupNavBar];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error)
        {
            NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
            self.users = [objects mutableCopy];
            
            [self.userTableView reloadData];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.userTableView deselectRowAtIndexPath:[self.userTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

-(void)initializeEmptyUsersArray {
    self.users = [NSMutableArray new];
    self.userAndAvatars = [NSMutableArray new];
}

-(void)setupNavBar
{
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],
                                                            }];
}

- (void)fetchAllUsers:(void (^)(NSArray *, BOOL, NSError *))completionBlock
{
    PFQuery *userQuery = [PFUser query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error)
        {
            completionBlock(objects, YES, error);
            NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
            self.users = [objects mutableCopy];
            [self fetchAllUsersAvatars];
            [self.userTableView reloadData];
                
        } else {
            completionBlock(@[], NO, error);
                
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
}
-(void)fetchAllUsersAvatars
{
    for (PFUser *user in self.users)
    {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:user.objectId];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                NSLog(@"USER: %@", objects);
                PFObject *user = [objects objectAtIndex:0];
                PFFile *file = [user objectForKey:@"userAvatar"];
                NSLog(@"FILE: %@", file);
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                 {
                     if (!error)
                     {
                         UIImage *image = [UIImage imageWithData:data];
                         NSLog(@"IMAGE: %@", image);
                         [self.userAndAvatars addObject:image];
                     }
                 }];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }
    NSLog(@"%@", self.userAndAvatars);
}

//        PFFile *imageFile = [user objectForKey:@"userAvatar"];
//        [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
//            if (!error)
//            {
//                UIImage *image = [UIImage imageWithData:result];
//                [self.userAndAvatars setObject:image forKey:user.username];
//            }
//        }];

//- (void)getPhotoForUser:(PFUser *)user WithBlock:(void (^)(UIImage *photo))completionBlock
//{
//    PFFile *imageFile = [user objectForKey:@"userAvatar"];
//    [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
//        if (!error)
//        {
//            UIImage *image = [UIImage imageWithData:result];
//            completionBlock(image);
//        }
//    }];
//}

//#pragma mark - Search bar methods
//
//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//
//}
//
//#pragma mark - UITableViewDataSource Methods
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.users.count;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 95.0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [self.userTableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
//    PFUser *user = [self.users objectAtIndex:[indexPath row]];
//    UIImage *avatar = [self.userAndAvatars objectAtIndex:[indexPath row]];
//    
//    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1];
//    usernameLabel.text = user.username;
//    
//    UIImage *userAvatar = (UIImage *)[cell viewWithTag:2];
//    userAvatar = avatar;
//    
//    return cell;
//}


@end

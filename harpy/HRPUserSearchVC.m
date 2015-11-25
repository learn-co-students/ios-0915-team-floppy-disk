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

@interface HRPUserSearchVC ()

@property (weak, nonatomic) IBOutlet UITextView *testView;
@property (strong, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property (nonatomic) PFUser *user;

@end

@implementation HRPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Search bar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.userSearchBar.text];
    self.user = (PFUser *)[query getFirstObject];
}


@end

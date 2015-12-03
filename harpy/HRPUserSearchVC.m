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
#import <QuartzCore/QuartzCore.h>

@interface HRPUserSearchVC ()  <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSMutableArray *users;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableViewUI];
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.userSearchBar.delegate = self;
    self.parseService = [HRPParseNetworkService sharedService];
    
    [self initializeEmptyUsersArray];
    
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
- (void) viewWillAppear:(BOOL)animated
{
    [self.userTableView deselectRowAtIndexPath:[self.userTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

-(void) setupTableViewUI
{
    UIColor *desertStormGreyUIColor = [UIColor colorWithHue:0 saturation:0 brightness:0.97 alpha:1];
    UIImage *desertStormGreyColorImage = [self imageWithColor:desertStormGreyUIColor];
    
    self.userTableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = desertStormGreyUIColor;
    
    [[self searchSubviewsForTextFieldIn:self.userSearchBar] setBackgroundColor:desertStormGreyUIColor];
    self.userSearchBar.backgroundImage = desertStormGreyColorImage;
    
    for (id object in [[[self.userSearchBar subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            UITextField *textFieldObject = (UITextField *)object;
            UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
            textFieldObject.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
            textFieldObject.layer.borderColor = [ironColor CGColor];
            textFieldObject.layer.borderWidth = 1.0;
            textFieldObject.layer.cornerRadius = 13;
            break;
        }
    }
    
    [[UIBarButtonItem appearanceWhenContainedIn:[self.userSearchBar class], nil] setTintColor:[UIColor darkGrayColor]];
}

- (UITextField*)searchSubviewsForTextFieldIn:(UIView*)view
{
    if ([view isKindOfClass:[UITextField class]]) {
        return (UITextField*)view;
    }
    UITextField *searchedTextField;
    for (UIView *subview in view.subviews) {
        searchedTextField = [self searchSubviewsForTextFieldIn:subview];
        if (searchedTextField) {
            break;
        }
    }
    return searchedTextField;
}


- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Setup methods

-(void)initializeEmptyUsersArray
{
    self.users = [NSMutableArray new];
}
- (void)fetchAllUsers:(void (^)(NSArray *, BOOL, NSError *))completionBlock
{
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = 10;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error)
        {
            completionBlock(objects, YES, error);
            NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
            self.users = [objects mutableCopy];
            [self.userTableView reloadData];
                
        }
        else
        {
            completionBlock(@[], NO, error);
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Search bar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) {
        PFQuery *userQuery = [PFUser query];
        searchText = [searchText lowercaseString];
        [userQuery whereKey:@"username" hasPrefix:searchText];
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
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = [NSString stringWithFormat:@""];
    [self.userTableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if ([self.userSearchBar.text isEqualToString:@""])
//    {
//        return 1;
//    }
//    else
//    {
        return self.users.count;
//    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.userTableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    PFUser *user = [self.users objectAtIndex:[indexPath row]];
    
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"spinner.png"];
    cell.imageView.layer.cornerRadius =  42.5;
    [cell.imageView.layer setBorderColor: [ironColor CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
    cell.imageView.layer.masksToBounds = YES;
    PFFile *imageFile = [user objectForKey:@"userAvatar"];
    if (imageFile)
    {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.highlightedImage = [UIImage imageWithData:data];
            }
            else
            {
                NSLog(@"ERROR: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1];
    usernameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:15.0];
    usernameLabel.text = user.username;
    
    UILabel *realnameLabel = (UILabel *)[cell viewWithTag:3];
    NSString *realnameString = user[@"realName"];
    realnameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    realnameLabel.text = realnameString;

    UILabel *shortbioLabel = (UILabel *)[cell viewWithTag:4];
    NSString *shortbioString = user[@"shortBio"];
    shortbioLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    shortbioLabel.text = shortbioString;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

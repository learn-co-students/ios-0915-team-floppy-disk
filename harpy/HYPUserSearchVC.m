//
//  HYPUserSearchVC.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HYPUserSearchVC.h"
#import "UIColor+HRPColor.h"
#import "HRPUser.h"
#import "HYPProfileVC.h"
#import "HRPParseNetworkService.h"
#import <QuartzCore/QuartzCore.h>

@interface HYPUserSearchVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchbarUser;
@property (strong, nonatomic) UISearchBar *searchbarUserInTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableviewUser;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSMutableArray *users;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HYPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableViewUI];
    
    self.tableviewUser.delegate = self;
    self.tableviewUser.dataSource = self;
    self.searchbarUser.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.searchbarUser setShowsCancelButton:NO animated:NO];
    self.parseService = [HRPParseNetworkService sharedService];
    
    [self initializeEmptyUsersArray];
    
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = 20;
    [userQuery orderByDescending:@"createdAt"];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.text = @"USER SEARCH";
            label.textAlignment = NSTextAlignmentCenter;
            self.navigationItem.titleView = label;
            
            self.users = [objects mutableCopy];
            [self.tableviewUser reloadData];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.tableviewUser deselectRowAtIndexPath:[self.tableviewUser indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)changeScrollBarColorFor:(UIScrollView *)scrollView
{
    for ( UIView *view in scrollView.subviews ) {
        
        if (view.tag == 0 && [view isKindOfClass:UIImageView.class])
        {
            UIImageView *imageView = (UIImageView *)view;
            imageView.backgroundColor = [UIColor darkGrayColor];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float shadowOffset = (scrollView.contentOffset.y/1);
    shadowOffset = MIN(MAX(shadowOffset, 0), 1);
    float shadowRadius = MIN(MAX(shadowOffset, 0), 1);
    
    self.searchbarUser.layer.shadowOffset = CGSizeMake(0, shadowOffset);
    self.searchbarUser.layer.shadowRadius = shadowRadius;
    self.searchbarUser.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchbarUser.layer.shadowOpacity = 0.20;
    
    self.searchbarUserInTableView.layer.shadowOffset = CGSizeMake(0, shadowOffset);
    self.searchbarUserInTableView.layer.shadowRadius = shadowRadius;
    self.searchbarUserInTableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchbarUserInTableView.layer.shadowOpacity = 0.20;
}

#pragma mark - Setup methods

-(void)initializeEmptyUsersArray
{
    self.users = [NSMutableArray new];
}
-(void) setupTableViewUI
{
    self.searchbarUser.keyboardAppearance = UIKeyboardAppearanceLight;
    
    UIImage *whiteColorImage = [self imageWithColor:[UIColor whiteColor]];
    self.tableviewUser.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    [[self searchSubviewsForTextFieldIn:self.searchbarUser] setBackgroundColor:[UIColor whiteColor]];
    self.searchbarUser.backgroundImage = whiteColorImage;
    [self.view bringSubviewToFront:self.searchbarUser];
    
    for (id object in [[[self.searchbarUser subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            UITextField *textFieldObject = (UITextField *)object;
            textFieldObject.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0];
            textFieldObject.placeholder = @"Type to search";
            textFieldObject.layer.borderColor = [[UIColor ironColor] CGColor];
            textFieldObject.layer.borderWidth = 1.0;
            textFieldObject.layer.cornerRadius = 13;
        
            break;
        }
    }
    [[UIBarButtonItem appearanceWhenContainedIn:[self.searchbarUser class], nil] setTintColor:[UIColor darkGrayColor]];
}

#pragma mark - Helper methods

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Search bar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
        
        [self.users removeAllObjects];
    }
    
    if (![searchText isEqualToString:@""]) {
        PFQuery *userQuery = [PFUser query];
        searchText = [searchText lowercaseString];
        [userQuery whereKey:@"username" hasPrefix:searchText];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
            if (!error)
            {
                NSLog(@"PFUser COUNT: %lu", (unsigned long)objects.count);
                self.users = [objects mutableCopy];
                
                [self.tableviewUser reloadData];
            }
            else
            {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}
- (UITextField*)searchSubviewsForTextFieldIn:(UIView*)view
{
    if ([view isKindOfClass:[UITextField class]])
    {
        return (UITextField*)view;
    }
    UITextField *searchedTextField;
    for (UIView *subview in view.subviews)
    {
        searchedTextField = [self searchSubviewsForTextFieldIn:subview];
        if (searchedTextField)
        {
            break;
        }
    }
    return searchedTextField;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarCancelButtonClicked called");
    [searchBar resignFirstResponder];
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = [NSString stringWithFormat:@""];
    [self.tableviewUser reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalCellView = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.searchbarUser.frame.size.height - 20;
    
    CGFloat numberOfUserRows = 5;
    CGFloat customTableCellHeight = totalCellView/numberOfUserRows;
    
    return customTableCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableviewUser dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    cell.preservesSuperviewLayoutMargins = NO;
    cell.layoutMargins = UIEdgeInsetsZero;
    PFUser *user = [self.users objectAtIndex:[indexPath row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"periwinkleImage.png"];
    cell.imageView.layer.cornerRadius =  cell.imageView.frame.size.height/2;
    [cell.imageView.layer setBorderColor: [[UIColor ironColor] CGColor]];
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
    usernameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0];
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
    
    UIImage *whiteColorImage = [self imageWithColor:[UIColor whiteColor]];
    
    self.searchbarUserInTableView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
    self.searchbarUserInTableView.delegate = self;
    [self.searchbarUserInTableView setShowsCancelButton:NO animated:NO];
    self.searchbarUserInTableView.keyboardAppearance = UIKeyboardAppearanceLight;
    self.searchbarUserInTableView.backgroundImage = whiteColorImage;
    [[self searchSubviewsForTextFieldIn:self.searchbarUserInTableView] setBackgroundColor:[UIColor whiteColor]];
    self.searchbarUserInTableView.text = @"";
    
    for (id object in [[[self.searchbarUserInTableView subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            self.searchbarUserInTableView.text = @"";
            UITextField *textFieldObject = (UITextField *)object;
            textFieldObject.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0];
            textFieldObject.placeholder = @"Type to search";
            textFieldObject.layer.borderColor = [[UIColor ironColor] CGColor];
            textFieldObject.layer.borderWidth = 1.0;
            textFieldObject.layer.cornerRadius = 13;
            
            break;
        }
    }
    
    [[UIBarButtonItem appearanceWhenContainedIn:[self.searchbarUser class], nil] setTintColor:[UIColor darkGrayColor]];
    
    [sectionHeaderView addSubview:self.searchbarUserInTableView];
    
    return sectionHeaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
    PFUser *user = [self.users objectAtIndex:[indexPath row]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"main" bundle:nil];
    HYPProfileVC *profileView = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    profileView.user = user;
    [self.navigationController pushViewController:profileView animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews {
    if ([self.tableviewUser respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableviewUser setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableviewUser respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableviewUser setLayoutMargins:UIEdgeInsetsZero];
    }
}
# pragma mark- Navigation methods

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

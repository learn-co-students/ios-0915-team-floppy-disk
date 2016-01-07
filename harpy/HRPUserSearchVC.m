//
//  HRPUserSearchVC.m
//  harpy
//
//  Created by Kiara Robles on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUserSearchVC.h"
#import "HRPUser.h"
#import "HRPProfileVC.h"
#import "HRPParseNetworkService.h"
#import <QuartzCore/QuartzCore.h>

@interface HRPUserSearchVC ()  <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic) UIScrollViewIndicatorStyle indicatorStyle;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSMutableArray *users;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (nonatomic) UIView *modalView;

@end

@implementation HRPUserSearchVC

#pragma mark - Lifecyle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableViewUI];
    
    [self.userSearchBar setShowsCancelButton:NO animated:NO];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userTableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.userSearchBar.delegate = self;
    self.parseService = [HRPParseNetworkService sharedService];
    
    [self initializeEmptyUsersArray];
    [self loadNewestUsers];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.userTableView deselectRowAtIndexPath:[self.userTableView indexPathForSelectedRow] animated:animated];
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
    
    self.userSearchBar.layer.shadowOffset = CGSizeMake(0, shadowOffset);
    self.userSearchBar.layer.shadowRadius = shadowRadius;
    self.userSearchBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.userSearchBar.layer.shadowOpacity = 0.20;
}

#pragma mark - Setup methods

-(void)initializeEmptyUsersArray
{
    self.users = [NSMutableArray new];
}
- (void)loadNewestUsers
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    self.navigationItem.titleView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = 19;
    [userQuery orderByDescending:@"createdAt"];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error)
        {
            [self.activityIndicator stopAnimating];
            [self.modalView removeFromSuperview];
            self.navigationItem.rightBarButtonItem = nil;
            
            self.navigationItem.titleView = nil;
            NSString *usernameString = @"USER SEARCH";
            self.navigationItem.title = usernameString;
            
            self.users = [objects mutableCopy];
            [self.userTableView reloadData];
        }
        else if ([error.domain isEqual:PFParseErrorDomain] && error.code == kPFErrorConnectionFailed)
        {
            [self alertOfflineView];
        }
        else
        {
            //NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
-(void) setupTableViewUI
{
    self.userSearchBar.keyboardAppearance = UIKeyboardAppearanceLight;
    
    UIImage *whiteColorImage = [self imageWithColor:[UIColor whiteColor]];
    self.userTableView.backgroundColor = [UIColor whiteColor];
    
    UIColor *desertStormColor = [UIColor colorWithHue:0 saturation:0 brightness:0.99 alpha:1];
    self.view.backgroundColor = desertStormColor;
    [[self searchSubviewsForTextFieldIn:self.userSearchBar] setBackgroundColor:[UIColor whiteColor]];
    self.userSearchBar.backgroundImage = whiteColorImage;
    [self.view bringSubviewToFront:self.userSearchBar];
    
    for (id object in [[[self.userSearchBar subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            UITextField *textFieldObject = (UITextField *)object;
            UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
            textFieldObject.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0];
            textFieldObject.placeholder = @"Type to search";
            textFieldObject.layer.borderColor = [ironColor CGColor];
            textFieldObject.layer.borderWidth = 1.0;
            textFieldObject.layer.cornerRadius = 13;
            
            break;
        }
    }
    
    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[self.userSearchBar class]]].tintColor = [UIColor darkGrayColor];
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
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        self.navigationItem.titleView = self.activityIndicator;
        [self.activityIndicator startAnimating];
        
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
            if (!error)
            {
                [self.activityIndicator stopAnimating];
                [self.modalView removeFromSuperview];
                
                NSString *usernameString = @"USER SEARCH";
                self.navigationItem.title = usernameString;
                
                self.users = [objects mutableCopy];
                
                [self.userTableView reloadData];
            }
            else if ([error.domain isEqual:PFParseErrorDomain] && error.code == kPFErrorConnectionFailed)
            {
                [self alertOfflineView];
            }
            else
            {
                //NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
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
    return self.users.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalCellView = self.userTableView.frame.size.height;
    CGFloat numberOfPostRows = 5;
    
    CGFloat customTableCellHeight = totalCellView/numberOfPostRows;
    
    return customTableCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.userTableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    PFUser *user = [self.users objectAtIndex:[indexPath row]];
    
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"periwinkleImage.png"];
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
                //NSLog(@"ERROR: %@ %@", error, [error userInfo]);
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [self.users objectAtIndex:[indexPath row]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    HRPProfileVC *profileView = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    profileView.user = user;
    [self.navigationController pushViewController:profileView animated:YES];
}

# pragma mark- Navigation methods

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertOfflineView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = @"OFFLINE";
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    UIImage *backButtonHomeImage = [[UIImage imageNamed:@"left_Arrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonHomeImage  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    if (self.modalView == nil)
    {
        self.modalView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        self.modalView.opaque = NO;
        self.modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [self.view addSubview:self.modalView];
        
        UIImage* image = [UIImage imageNamed:@"refresh.png"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        [someButton setBackgroundImage:image forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(loadNewestUsers)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:NO];
        UIBarButtonItem *rightbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem = rightbutton;
    }
}

@end

//
//  HRPTrackSearchViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "HRPTrackSearchViewController.h"
#import "HRPTrack.h"
#import "HRPTrackCreator.h"
#import "HRPPostPreviewViewController.h"
#import <Parse/Parse.h>

@interface HRPTrackSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SPTAudioStreamingDelegate>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottom;
@property (weak, nonatomic) IBOutlet UIView *musicView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicviewBottom;

@property (strong, nonatomic) IBOutlet UISearchBar *songSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (strong, nonatomic) NSMutableArray *filteredSongArray;

@property (strong, nonatomic) IBOutlet UIImageView *playerCoverView;
@property (strong, nonatomic) IBOutlet UILabel *playStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerSongLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerArtistLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) SPTAudioStreamingController *player;

@end

@implementation HRPTrackSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableViewUI];
    [self.songSearchBar setShowsCancelButton:NO animated:NO];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.songTableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    
    self.songSearchBar.delegate = self;
    self.songTableView.delegate = self;
    self.songTableView.dataSource = self;

    [self initializeEmptySongArray];
    self.playStatusLabel.text = @"";
    self.playerSongLabel.text = @"";
    self.playerArtistLabel.text = @"";
    
    self.tableviewBottom.constant = 0;
    self.musicviewBottom.constant = -89;
    [self.view setNeedsUpdateConstraints];
    
    self.navigationItem.hidesBackButton = YES;  // We do a custom image for the back button on the post preview VC
    
//    self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
//    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage new];
//    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_Arrow"] style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(-60, 0) forBarMetrics:UIBarMetricsDefault];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.songTableView deselectRowAtIndexPath:[self.songTableView indexPathForSelectedRow] animated:animated];
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
    
    // Make sure that the offset doesn't exceed 3 or drop below 0.5
    shadowOffset = MIN(MAX(shadowOffset, 0), 1);
    
    //Ensure that the shadow radius is between 1 and 3
    float shadowRadius = MIN(MAX(shadowOffset, 0), 1);
    
    self.songSearchBar.layer.shadowOffset = CGSizeMake(0, shadowOffset);
    self.songSearchBar.layer.shadowRadius = shadowRadius;
    self.songSearchBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.songSearchBar.layer.shadowOpacity = 0.20;
}

#pragma mark - Setup methods

-(void)initializeEmptySongArray
{
    self.songArray = [NSMutableArray new];
}
-(void) setupTableViewUI
{
    self.songSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    UIImage *whiteColorImage = [self imageWithColor:[UIColor whiteColor]];
    self.songTableView.backgroundColor = [UIColor clearColor];
    
    UIColor *desertStormColor = [UIColor colorWithHue:0 saturation:0 brightness:0.97 alpha:1];
    self.view.backgroundColor = desertStormColor;
    [[self searchSubviewsForTextFieldIn:self.songSearchBar] setBackgroundColor:[UIColor whiteColor]];
    self.songSearchBar.backgroundImage = whiteColorImage;
    [self.view bringSubviewToFront:self.songSearchBar];
    
    for (id object in [[[self.songSearchBar subviews] objectAtIndex:0] subviews])
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
    
    [[UIBarButtonItem appearanceWhenContainedIn:[self.songSearchBar class], nil] setTintColor:[UIColor darkGrayColor]];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.songSearchBar.text isEqualToString:@""]) {
        return self.songArray.count;
    } else {
        return self.filteredSongArray.count;
    }
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
        
        self.filteredSongArray = self.songArray;
        [self.songTableView reloadData];
    }
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    self.navigationItem.titleView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    [HRPTrackCreator generateTracksFromSearch:searchText WithCompletion:^(NSArray *tracks) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.activityIndicator stopAnimating];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(@"{{0,0},{100,44}}")];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.text = @"SEARCH SONGS";
            label.textAlignment = NSTextAlignmentCenter;
            self.navigationItem.titleView = label;
            
            self.filteredSongArray = [tracks mutableCopy];
            [self.songTableView reloadData];
        }];
    }];
    
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
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text = [NSString stringWithFormat:@""];
    self.filteredSongArray = self.songArray;
    [self.songTableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 89.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
    UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
    
    HRPTrack *track  = self.filteredSongArray[indexPath.row];
    
    UILabel *songNameLabel = (UILabel *)[cell viewWithTag:1];
    songNameLabel.text = track.songTitle;
    songNameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0];
    
    UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:2];
    artistNameLabel.text = track.artistName;
    artistNameLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    
    UILabel *albumLabel = (UILabel *)[cell viewWithTag:3];
    albumLabel.text = track.albumName;
    albumLabel.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:12.0];
    
    UIImageView *coverArt = (UIImageView *)[cell viewWithTag:4];
    if (track.spotifyLogo == nil) {
        coverArt.image = [UIImage imageWithData:track.albumCoverArt];
        [coverArt.layer setBorderColor: [ironColor CGColor]];
    } else {
        coverArt.image = track.spotifyLogo;
        [coverArt.layer setBorderColor: [ironColor CGColor]];
    }
    
    UIButton *playTrackButton = (UIButton *)[cell viewWithTag:5];
    [playTrackButton addTarget:self action:@selector(cellPlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *postTrackButton = (UIButton *)[cell viewWithTag:6];
    [postTrackButton addTarget:self action:@selector(cellPostButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    HRPPostPreviewViewController *destinVC = segue.destinationViewController;
    NSIndexPath *indexPath = self.songTableView.indexPathForSelectedRow;
    HRPTrack *track = self.filteredSongArray[indexPath.row];
    destinVC.track = track;
    destinVC.post = self.post;
}

- (IBAction)cellPlayButtonTapped:(UIButton *)sender {
    
    if (self.player.isPlaying == NO) {
        CGFloat musicPlayerHeight = self.musicView.frame.size.height;
        self.tableviewBottom.constant = musicPlayerHeight;
        self.musicviewBottom.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:nil];
        
        NSIndexPath *indexPath = [self.songTableView indexPathForCell:(UITableViewCell *)[[[[[sender superview] superview] superview] superview] superview]];
        HRPTrack *trackAtCell = self.filteredSongArray[indexPath.row];
        self.playerSongLabel.text = trackAtCell.songTitle;
        self.playerArtistLabel.text = trackAtCell.artistName;
        self.playerCoverView.image = [UIImage imageNamed:@"white_pause"];
        self.playStatusLabel.text = @"Playing";
        
        [self handleNewSession];
        NSString *urlString = [NSString stringWithFormat:trackAtCell.spotifyURI];
        NSURL *url = [NSURL URLWithString:urlString];
        //NSURL *url = trackAtCell.spotifyURI;
        
        [self.player playURIs:@[ url ] fromIndex:0 callback:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        [sender setImage:[UIImage imageNamed:@"black_stop"] forState:UIControlStateNormal];
    } else if (self.player.isPlaying == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.playStatusLabel.text = @"Paused";
        self.playerCoverView.image = [UIImage imageNamed:@"white_play"];
    }
}

-(void)cellPostButtonTapped:(UIButton *)sender {
    if ([self.player isPlaying] == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    }
    self.player = nil;
}


- (IBAction)playerViewTapped:(UITapGestureRecognizer *)sender {
    
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    
    if ([self.playStatusLabel.text isEqualToString:@"Playing"]) {
        self.playStatusLabel.text = @"Paused";
        self.playerCoverView.image = [UIImage imageNamed:@"white_play"];
    } else if ([self.playStatusLabel.text isEqualToString:@"Paused"]) {
        self.playStatusLabel.text = @"Playing";
        self.playerCoverView.image = [UIImage imageNamed:@"white_pause"];
    }
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
    
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    if ([self.player isPlaying] == YES) {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    }
    self.player = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard {
    [self.songSearchBar resignFirstResponder];
}

@end

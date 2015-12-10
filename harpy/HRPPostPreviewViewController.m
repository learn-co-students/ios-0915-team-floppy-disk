//
//  HRPPostPreviewViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostPreviewViewController.h"
#import <Parse/Parse.h>
#import "HRPPost.h"


@interface HRPPostPreviewViewController () <UITextViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UITextView *postCaptionTextView;

@end

@implementation HRPPostPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.track.spotifyLogo == nil) {
        self.albumArtImageView.image = [UIImage imageWithData:self.track.albumCoverArt];
    } else {
        self.albumArtImageView.image = self.track.spotifyLogo;
    }
    
    self.songTitleLabel.text = self.track.songTitle;
    self.artistNameLabel.text = self.track.artistName;
    self.albumNameLabel.text = self.track.albumName;
    NSString *latLong = [NSString stringWithFormat:@"%f, %f", self.post.latitude, self.post.longitude];
    self.locationLabel.text = latLong;
    
}


//- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)uploadPhotoButtonTapped:(UIButton *)sender {
    //upload photo
}

- (IBAction)addLocationButtonTapped:(UIButton *)sender {
    //add location to be pinned on map
}

//needs to be adjusted in order to take either album art or a picture
- (IBAction)postTrackButtonTapped:(UIButton *)sender {
    
    [self.post createPostForTrack:self.track withCaption:self.postCaptionTextView.text WithCompletion:^(BOOL success) {
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    [self.delegate queryForHRPosts];
                }];
            }];
        }
    }];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    self.albumArtImageView = nil;
    self.songTitleLabel = nil;
    self.artistNameLabel = nil;
    self.albumNameLabel = nil;
    self.locationLabel = nil;
    self.postCaptionTextView = nil;
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end

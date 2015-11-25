//
//  HRPPostPreviewViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostPreviewViewController.h"

@interface HRPPostPreviewViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UITextView *postCaptionTextView;
@property (assign, nonatomic) BOOL textViewEdited;

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
    self.textViewEdited = NO;
}


- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadPhotoButtonTapped:(UIButton *)sender {
    //upload photo
}

- (IBAction)addLocationButtonTapped:(UIButton *)sender {
    //add location to be pinned on map
}

- (IBAction)postTrackButtonTapped:(UIButton *)sender {
    //post track
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (self.textViewEdited == NO) {
        self.postCaptionTextView.text = @"";
        self.textViewEdited = YES;
    }
    return self.textViewEdited;
}


@end

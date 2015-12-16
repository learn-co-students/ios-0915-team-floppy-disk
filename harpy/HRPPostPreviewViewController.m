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


@interface HRPPostPreviewViewController () <UITextViewDelegate, UINavigationControllerDelegate, UITextViewDelegate>



@property (strong, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UITextView *postCaptionTextView;

@end

@implementation HRPPostPreviewViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.track.spotifyLogo == nil) {
        self.albumArtImageView.image = [UIImage imageWithData:self.track.albumCoverArt];
    } else {
        self.albumArtImageView.image = self.track.spotifyLogo;
    }
    
    [self.postCaptionTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.postCaptionTextView.layer setBorderWidth: 1.0];
    self.postCaptionTextView.layer.masksToBounds = YES;

    self.songTitleLabel.text = self.track.songTitle;
    self.artistNameLabel.text = self.track.artistName;
    self.albumNameLabel.text = self.track.albumName;
    NSString *latLong = [NSString stringWithFormat:@"%f, %f", self.post.latitude, self.post.longitude];
    self.locationLabel.text = latLong;
    
    self.postCaptionTextView.delegate = self;
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

#pragma mark - Action methods

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


- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Overrides

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end

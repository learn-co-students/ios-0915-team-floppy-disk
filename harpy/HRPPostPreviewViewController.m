//
//  HRPPostPreviewViewController.m
//  harpy
//
//  Created by Phil Milot on 11/24/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostPreviewViewController.h"
#import <Parse/Parse.h>

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

//needs to be adjusted in order to take either album art or a picture
- (IBAction)postTrackButtonTapped:(UIButton *)sender {
    
    NSLog(@"post button tapped");

    PFObject *post = [PFObject objectWithClassName:@"HRPPost"];
    PFUser *currentUser = [PFUser currentUser];
    NSString *urlString = (NSString *)self.track.spotifyURI;
    PFFile *albumcover = [PFFile fileWithName:@"album_cover" data:self.track.albumCoverArt];
    
    // will not work unless logged in
    post[@"username"] = currentUser;
    
    post[@"songTitle"] = self.track.songTitle;
    post[@"artistName"] = self.track.artistName;
    post[@"albumName"] = self.track.albumName;

    // where is geo location being saved?
    post[@"locationGeoPoint"] = [NSNull null];

    //dictionary will start empty
    post[@"comments"] = [NSNull null];
    NSLog(@"comments made");

    //array will start empty
    post[@"likes"] = [NSNull null];
    NSLog(@"likes made");

    post[@"songURL"] = urlString;
    NSLog(@"song url made");

    post[@"albumArt"] = albumcover;
    NSLog(@"alvum art made");

    //nil unless photo is added
    post[@"postPhoto"] = [NSNull null];
    NSLog(@"post photo made");

    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"holla atcha boi");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

//
//  HRPPostTableViewCell.m
//  harpy
//
//  Created by Phil Milot on 12/1/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPostTableViewCell.h"

@implementation HRPPostTableViewCell
@synthesize profileThumbnail = _profileThumbnail;
@synthesize usernameLabel = _usernameLabel;
@synthesize mainImageView = _mainImageView;
@synthesize playButton = _playButton;
@synthesize spotifyLogoView = _spotifyLogoView;
@synthesize likesLabel = _likesLabel;
@synthesize postCaptionLabel = _postCaptionLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

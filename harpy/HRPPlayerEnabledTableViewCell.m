//
//  HRPPlayerEnabledTableViewCell.m
//  Harpy Music
//
//  Created by Phil Milot on 12/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPPlayerEnabledTableViewCell.h"

@implementation HRPPlayerEnabledTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetailsFromTrack:(HRPTrack *)track {
    
    self.songNameLabel.text = track.songTitle;
    self.artistNameLabel.text = track.artistName;
    self.albumLabel.text = track.albumName;
    self.coverArt.image = [self imageFromTrack:track];
    //_playTrackButton.imageView.image = [UIImage imageNamed:@"play"];
    
}

-(UIImage *)imageFromTrack:(HRPTrack *)track {
    if (track.spotifyLogo == nil) {
        return [UIImage imageWithData:track.albumCoverArt];
    } else {
        return track.spotifyLogo;
    }
}




@end

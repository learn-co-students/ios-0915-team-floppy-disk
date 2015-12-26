//
//  HRPPlayerEnabledTableViewCell.h
//  Harpy Music
//
//  Created by Phil Milot on 12/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPTrack.h"

@interface HRPPlayerEnabledTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverArt;
@property (strong, nonatomic) IBOutlet UIButton *playTrackButton;

-(void)setCellDetailsFromTrack:(HRPTrack *)track;


@end

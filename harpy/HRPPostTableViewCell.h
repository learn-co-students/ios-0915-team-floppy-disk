//
//  HRPPostTableViewCell.h
//  harpy
//
//  Created by Phil Milot on 12/1/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPPostTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *spotifyLogoView;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *postCaptionLabel;

@end

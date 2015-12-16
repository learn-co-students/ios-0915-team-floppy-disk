//
//  HRPProfileVC.h
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <Parse/Parse.h>
#import <Spotify/Spotify.h>

@interface HRPProfileVC : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *userAvatar;
@property (nonatomic) PFUser *user;

@end

//
//  HRPProfileVC.h
//  harpy
//
//  Created by Kiara Robles on 11/23/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface HRPProfileVC : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, retain) IBOutlet UIImageView *userAvatar;

@end

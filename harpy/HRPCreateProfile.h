//
//  HRPCreateProfile.h
//  harpy
//
//  Created by Kiara Robles on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPSignupVC : UIViewController

@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) UITextField *email;
@property (nonatomic, strong) NSString *emailString;
@property (weak, nonatomic) IBOutlet UIView *inputView;
//@property (nonatomic, strong) IBOutlet UIImageView *photo;
//@property (weak, nonatomic) IBOutlet UIButton *userProfilePhoto;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property UIImage *userImage;

@end
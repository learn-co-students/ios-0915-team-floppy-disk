//
//  HRPSignupVC.h
//  harpy
//
//  Created by Kiara Robles on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPSignupVC : UIViewController

// Passed from HRPLoginOrSignupVC
@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) UITextField *email;

@property (weak, nonatomic) IBOutlet UIView *inputView;


@property (nonatomic, strong) NSString *emailString;

@end

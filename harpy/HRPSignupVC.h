//
//  HRPSignupVC.h
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

@end
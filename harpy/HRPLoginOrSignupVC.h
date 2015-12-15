//
//  HRPLoginOrSignupVC.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSUInteger, HRPViewControllerTags)
{
    HRPViewControllerEmailTextFieldTag = 1,
    HRPViewControllerUsernameTextFieldTag,
    HRPViewControllerPasswordNewTextFieldTag,
    HRPViewControllerPasswordConfirmTextFieldTag,
};

@interface HRPLoginOrSignupVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *inputView;

- (IBAction)signUp:(id)sender;
- (IBAction)logIn:(id)sender;

@end

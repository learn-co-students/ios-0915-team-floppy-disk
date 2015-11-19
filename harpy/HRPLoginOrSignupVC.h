//
//  HRPLoginOrSignupVC.h
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSUInteger, HRPViewControllerTags) {
    HRPViewControllerUsernameTextFieldTag = 1,
    HRPViewControllerEmailTextFieldTag = 2,
    HRPViewControllerPasswordTextFieldTag = 3
};

@interface HRPLoginOrSignupVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *displayMessage;
- (IBAction)signUp:(id)sender;
- (IBAction)logIn:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *inputView;

@end

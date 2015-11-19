//
//  HRPSignupVC.m
//  harpy
//
//  Created by Kiara Robles on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPSignupVC.h"
#import "HRPValidationManager.h"
#import "HRPParseNetworkService.h"

@interface HRPSignupVC ()

@property (nonatomic) UITextField *passwordNew;
@property (nonatomic) UITextField *passwordConfirm;

@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPSignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInputView];
    
    NSLog(@"self.userNameNew (%@) and self.email (%@) were passed!", self.userNameNew.text, self.email.text);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];

    // Set parse and user shared instance
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupInputView {
    int fieldHeight = 30;
    
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, fieldHeight)];
//    self.email.placeholder = self.email.text;
    self.email.text = self.emailString;
    self.email.textAlignment = NSTextAlignmentCenter;
    self.email.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.email.adjustsFontSizeToFitWidth = YES;
    self.email.keyboardType = UIKeyboardTypeEmailAddress;
    self.email.returnKeyType = UIReturnKeyNext;
    self.email.delegate = self;
    [self.inputView addSubview:self.email];
    
    self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 300, fieldHeight)];
    self.passwordNew.placeholder = @"Password";
    self.passwordNew.textAlignment = NSTextAlignmentCenter;
    self.passwordNew.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.passwordNew.adjustsFontSizeToFitWidth = YES;
    self.passwordNew.keyboardType = UIKeyboardTypeEmailAddress; // Should change
    self.passwordNew.returnKeyType = UIReturnKeyNext;
    self.passwordNew.delegate = self;
    self.passwordNew.secureTextEntry = YES;
    [self.inputView addSubview:self.passwordNew];
    
    self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 300, fieldHeight)];
    self.passwordConfirm.placeholder = @"Password";
    self.passwordConfirm.textAlignment = NSTextAlignmentCenter;
    self.passwordConfirm.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.passwordConfirm.adjustsFontSizeToFitWidth = YES;
    self.passwordConfirm.keyboardType = UIKeyboardTypeEmailAddress; // Should change
    self.passwordConfirm.returnKeyType = UIReturnKeyGo;
    self.passwordConfirm.delegate = self;
    self.passwordConfirm.secureTextEntry = YES;
    [self.inputView addSubview:self.passwordConfirm];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField == self.passwordConfirm) {
        textField.tag = 3;
    }
    NSLog(@"textField.tag: %ld", (long)textField.tag);
    NSLog(@"textField.text: %@", textField.text);
    
    [self isTextFieldValid:textField];
}
-(BOOL)isTextFieldValid:(UITextField *)textField
{
    HRPValidationManager *validationManager = [HRPValidationManager sharedManager];
    BOOL valid = NO;
    
    if (textField.tag == 3) {
        valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerPasswordKey];
    }
    if ([self.passwordNew isEqual:self.passwordNew]) {
        
        // Popup to confim password
        // Popup to ask for spofity connection
        [self.parseService createUser:self.userNameNew.text email:self.email.text password:self.passwordNew.text completionHandler:^(HRPUser *user) {
        
        }];
    }
    
    NSLog(@"%@ isValid: %@", textField.text, valid ? @"YES" : @"NO");
    return valid;
}



@end

//
//  HRPSignupVC.m
//  harpy
//
//  Created by Kiara Robles on 11/19/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPSignupVC.h"
#import "HRPLoginRedirect.h"
#import "HRPValidationManager.h"
#import "HRPParseNetworkService.h"
#import "UIViewController+PresentViewController.h"
#import <Spotify/Spotify.h>
#import "HRPSpotifyViewController.h"
#import "HRPLoginRedirect.h"
@import SafariServices;

@interface HRPSignupVC () <SPTAuthViewDelegate>

@property (nonatomic) UITextField *passwordNew;
@property (nonatomic) UITextField *passwordConfirm;
@property (nonatomic) UIButton *signup;
@property (nonatomic) BOOL spotifyPremium;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (strong, nonatomic) UIViewController *spotifySignupRedirect ;

@end

@implementation HRPSignupVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupInputView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Accessors

- (void)setupInputView
{
    int fieldHeight = 30;
    
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, fieldHeight)];
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
    
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setFrame:CGRectMake(40, 120, 215, 40)];
    [self.signup setTitle:@"Signup" forState:UIControlStateNormal];
    [self.signup setExclusiveTouch:YES];
    [self.inputView addSubview:self.signup];
}

#pragma mark - Action Methods

-(void)signupButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: signup button");
    BOOL valid = [self isTextFieldValid:self.passwordConfirm];
    
    if ([self.passwordNew.text isEqual:self.passwordConfirm.text] && valid == YES)
    {
        NSLog(@"PASSWORDS: match and are valid.");
        [self callEmailCheckAlertController];
    }
    else if ([self.passwordNew.text isEqual:self.passwordConfirm.text] == NO && (valid == YES))
    {
        NSLog(@"PASSWORDS: do not match but are valid.");
        [self callPasswordValidationAlertController];
    }
    else if ([self.passwordNew.text isEqual:self.passwordConfirm.text] && valid == NO)
    {
        NSLog(@"PASSWORDS: match but are not valid.");
        [self callPasswordStrengthValidationAlertController];
    }
    else if ([self.passwordNew.text isEqual:self.passwordConfirm.text] == NO && (valid == NO))
    {
        NSLog(@"PASSWORDS: do not match and are not valid.");
        [self callPasswordValidationAlertController];
    }
    else
    {
        NSLog(@"PASSWORDS: case not considered.");
    }
}

#pragma mark - Overrides

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    
    if (textField == self.passwordConfirm)
    {
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
    
    if (textField.tag == 3)
    {
        valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerPasswordKey];
    }

    NSLog(@"%@ isValid: %@", textField.text, valid ? @"YES" : @"NO");
    return valid;
}

#pragma mark - Alert Controller Methods

-(void)callPasswordStrengthValidationAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"That password isnt strong enough. :[" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)callPasswordValidationAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Those passwords don't match" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)callEmailCheckAlertController
{
    NSString *string = @"You entered your email as:";
    NSString *message = [NSString stringWithFormat:@"%@\n%@", string, self.email.text];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Is this correct?" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spotifyPremium = YES;
        [self callSpotifyLogInAlertController];
    }];
    
    UIAlertAction *noAccountAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spotifyPremium = NO;
        [self spotifySignupPopup];
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:noAccountAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)callSpotifyLogInAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Thanks!" message:@"Do you have a Spotify account?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spotifyPremium = YES;
        [self spotifyLoginPopup];
        [self callParse];
    }];
    
    UIAlertAction *noAccountAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spotifyPremium = NO;
        [self spotifySignupPopup];
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:noAccountAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

# pragma mark - Parse

- (void)callParse
{
    [self.parseService createUser:self.userNameNew.text email:self.email.text password:self.passwordNew.text completionHandler:^(HRPUser *user, NSError *error) {
        if (user)
        {
            NSLog(@"Created user: %@.", user);
        }
        else
        {
            // Error handeling
        }
    }];
}

# pragma mark - Spotify

-(void)spotifyLoginPopup
{
    [HRPLoginRedirect launchSpotify];
}
-(void)spotifySignupPopup
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.spotify.com/signup/"]];
    [self presentViewController:safariVC animated:YES];
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error
{
    
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session
{

}
-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
    
}

@end

//
//  HRPLoginOrSignupVC.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "AppDelegate.h"
#import "HRPLoginOrSignupVC.h"
#import "HRPLoginRedirect.h"
#import "HRPParseNetworkService.h"
#import "HRPValidationManager.h"
#import <Spotify/Spotify.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
@import SafariServices;

@interface HRPLoginOrSignupVC () <SPTAuthViewDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL spotifyPremium;
@property (nonatomic) UIButton *login;
@property (nonatomic) UIButton *signup;
@property (nonatomic) UIGestureRecognizer *tapper;

@property (nonatomic) UITextField *email;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *passwordConfirm;
@property (nonatomic) UITextField *passwordNew;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITextField *textFieldString;
@property (nonatomic) UITextField *userName;
@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) NSString *userMessage;

@property (nonatomic) UIView *underline;
@property (weak, nonatomic) IBOutlet UIView *underlineView;
@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (atomic, readwrite) SPTAuthViewController *authViewController;

@end

@implementation HRPLoginOrSignupVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSignup];
    [self setupLogin];
    [self.navigationController setNavigationBarHidden:YES];

    [self setHiddenStatus];
    
    self.underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 0.5)];
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.5, 0)];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.5, 0)];
    }
    else
    {
        [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.05, 0)];
    }
    self.underline.backgroundColor = [UIColor whiteColor];
    [self.underlineView addSubview:self.underline];
    
    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapper];
    
    self.parseService = [HRPParseNetworkService sharedService];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCompleted:) name:@"sessionUpdated" object:nil];

}
- (void)setHiddenStatus
{
    self.email.hidden = NO;
    self.userNameNew.hidden = NO;
    self.passwordNew.hidden = NO;
    self.passwordConfirm.hidden = NO;
    self.signup.hidden = NO;
    
    self.userName.hidden = YES;
    self.password.hidden = YES;
    self.login.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNotificationObserver];
}

- (void)setNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.email];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationObserver];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.email];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.passwordNew];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];
}

#pragma mark - Custom Accessors

-(void)setupSignup
{
    int fieldHeight = 30;
    int fieldWidth = 275;
    int radius = 20;

    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        fieldHeight = 45;
        fieldWidth = 315;
        radius = 27;
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        fieldHeight = 53;
        fieldWidth = 345;
        radius = 32;
    }
    
    [self setupEmailWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    [self setupNewUsernameWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    [self setupNewPasswordWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    [self setupConfirmPasswordnameWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    
    NSArray *textFields = @[ self.email, self.userNameNew, self.passwordNew, self.passwordConfirm ];
    
    [self setupCommonPropertiesForTextFields:textFields withCornerRadius:radius];
    
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.signup setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [self setupCommonPropertiesForButton:self.signup withFieldHeight:fieldHeight fieldWidth:fieldWidth andCornerRadius:radius];
}

- (void)setupEmailWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.email.returnKeyType = UIReturnKeyNext;
    [self.email setCenter: CGPointMake(self.view.center.x, self.email.center.y + fieldHeight / 2)];
}

- (void)setupNewUsernameWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.userNameNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userNameNew.returnKeyType = UIReturnKeyNext;
    [self.userNameNew setCenter: CGPointMake(self.view.center.x, self.userNameNew.center.y + fieldHeight * 2.16)];
}

- (void)setupNewPasswordWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.passwordNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordNew.returnKeyType = UIReturnKeyNext;
    self.passwordNew.secureTextEntry = YES;
    [self.passwordNew setCenter: CGPointMake(self.view.center.x, self.passwordNew.center.y + fieldHeight * 3.83)];
}

- (void)setupConfirmPasswordnameWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.passwordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"CONFIRM PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordConfirm.returnKeyType = UIReturnKeyGo;
    self.passwordConfirm.secureTextEntry = YES;
    [self.passwordConfirm setCenter: CGPointMake(self.view.center.x, self.passwordConfirm.center.y + fieldHeight * 5.5)]; // 165!!
}
-(void)setupLogin
{
    int fieldHeight = 30;
    int fieldWidth = 275;
    int radius = 20;
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f) //6
    {
        fieldHeight = 45;
        fieldWidth = 315;
        radius = 27;
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f) //6s
    {
        fieldHeight = 53;
        fieldWidth = 345;
        radius = 32;
    }
    
    [self setupUsernameWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    [self setupPasswordWithFieldHeight:fieldHeight withFeildWidth:fieldWidth];
    
    NSArray *textFields = @[ self.userName, self.password ];
    
    [self setupCommonPropertiesForTextFields:textFields withCornerRadius:radius];
    
    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [self setupCommonPropertiesForButton:self.login withFieldHeight:fieldHeight fieldWidth:fieldWidth andCornerRadius:radius];
}

- (void)setupUsernameWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.returnKeyType = UIReturnKeyDefault;
    [self.userName setCenter: CGPointMake(self.view.center.x, self.userName.center.y + fieldHeight / 2)];
}

- (void)setupPasswordWithFieldHeight:(int)fieldHeight withFeildWidth:(int)fieldWidth
{
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 8)];
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDefault;
    self.password.secureTextEntry = YES;
    [self.password setCenter: CGPointMake(self.view.center.x, self.password.center.y + fieldHeight * 2.16)]; // !!
}

- (void)setupCommonPropertiesForTextFields:(NSArray *)textFields withCornerRadius:(int)radius
{
    for (NSUInteger i = 0; i < textFields.count; i++)
    {
        UITextField *textField = textFields[i];
        
        textField.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = [UIColor whiteColor];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardAppearance = UIKeyboardAppearanceDark;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
        textField.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = radius;
        
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        textField.delegate = self;
        
        [self.inputView addSubview:textField];
    }
}

- (void)setupCommonPropertiesForButton:(UIButton *)button withFieldHeight:(int)fieldHeight fieldWidth:(int)fieldWidth andCornerRadius:(int)cornerRadius
{
    [button setFrame:CGRectMake(0, 0, fieldWidth, fieldHeight + 10)];
    [button setCenter: CGPointMake(self.view.center.x, self.signup.center.y + fieldHeight * 7.16)];
    
    button.layer.cornerRadius = cornerRadius;
    button.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    
    button.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setExclusiveTouch:YES];
    
    [self.inputView addSubview:button];
}

#pragma mark - Action Methods

- (IBAction)signUp:(id)sender
{
    self.email.hidden = NO;
    self.login.hidden = YES;
    self.password.hidden = YES;
    self.passwordConfirm.hidden = NO;
    self.passwordNew.hidden = NO;
    self.signup.hidden = NO;
    self.userName.hidden = YES;
    self.userNameNew.hidden = NO;
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.5, 0)];
                         }
                         completion:nil];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f) //6s
    {
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.5, 0)];
                         }
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.underline setCenter: CGPointMake(self.view.frame.size.width / 5.05, 0)];
                         }
                         completion:nil];
    }
}

- (IBAction)logIn:(id)sender
{
    self.email.hidden = YES;
    self.login.hidden = NO;
    self.password.hidden = NO;
    self.passwordConfirm.hidden = YES;
    self.passwordNew.hidden = YES;
    self.signup.hidden = YES;
    self.userName.hidden = NO;
    self.userNameNew.hidden = YES;
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        [UIView animateWithDuration:1
                                       delay:0
                                     options:UIViewAnimationOptionCurveLinear
                                  animations:^{
                                      [self.login  setCenter: CGPointMake(self.view.center.x, (self.login.frame.size.height * 3.83) - 20)];
                                      [self.underline setCenter: CGPointMake(self.view.frame.size.width - (self.view.frame.size.width / 5.6), 0)];
                                  }
                                  completion:nil];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        [UIView animateWithDuration:1
                                       delay:0
                                     options:UIViewAnimationOptionCurveLinear
                                  animations:^{
                                      [self.login  setCenter: CGPointMake(self.view.center.x, (self.login.frame.size.height * 3.83) - 10)];
                                      [self.underline setCenter: CGPointMake(self.view.frame.size.width - (self.view.frame.size.width / 5.8), 0)];
                                  }
                                  completion:nil];
    }
    else
    {
        [UIView animateWithDuration:1
                                       delay:0
                                     options:UIViewAnimationOptionCurveLinear
                                  animations:^{
                                      [self.login  setCenter: CGPointMake(self.view.center.x, (self.login.frame.size.height * 3.83) - 20)];
                                      [self.underline setCenter: CGPointMake(self.view.frame.size.width - (self.view.frame.size.width / 5.3), 0)];
                                  }
                                  completion:nil];
    }
}

-(void)signupButtonClicked:(UIButton *)sender
{
    BOOL validEmail = [self isTextFieldValid:self.email];
    BOOL validPasswordNew = [self isTextFieldValid:self.passwordNew];
    BOOL validPasswordConfirm = [self isTextFieldValid:self.passwordConfirm];
    BOOL validPasswordMatch = [self.passwordNew.text isEqual:self.passwordConfirm.text];
    
    if ([self.email.text isEqual: @""] || [self.userNameNew.text isEqual: @""] || [self.passwordNew.text isEqual: @""]|| [self.passwordConfirm.text isEqual: @""])
    {
        [self alertControllerAllFieldsRequired];
    }
    else if (validEmail == NO)
    {
        [self alertControllerEmailValidation];
    }
    else if (validPasswordMatch == NO)
    {
        [self alertControllerPasswordMatchValidation];
    }
    else if (validPasswordNew == NO && validPasswordConfirm == NO)
    {
        [self alertControllerPasswordStrengthValidation];
    }
    else if (validPasswordMatch == YES && validPasswordNew == YES && validPasswordConfirm == YES)
    {
        [self alertControllerEmailConfirmation];
    }
}

-(void)loginButtonClicked:(UIButton *)sender
{
    NSString *usernameStringLowercased = [self.userName.text lowercaseString];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if ((self.userName.text.length == 0)  || (self.password.text.length ==  0))
    {
        [self alertControllerLoginInvalid];
    }
    else
    {
        [self.parseService loginApp:usernameStringLowercased password:self.password.text completionHandler:^(HRPUser *user, NSError *error)
        {
            if (user)
            {
                PFUser *user = [PFUser currentUser];
                NSString *canonicalUsername = user[@"spotifyCanonical"];
                auth.sessionUserDefaultsKey = canonicalUsername;
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
                
                [self showMapsStoryboard];
            }
            else
            {
                self.userMessage = error.localizedDescription;
                [self alertControllerParseError];
            }
        }];

    }
}

#pragma mark - Overrides

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.email)
    {
        [textField resignFirstResponder];
        [self.userNameNew becomeFirstResponder];
    }
    else if (textField == self.userNameNew)
    {
        [textField resignFirstResponder];
        [self.passwordNew becomeFirstResponder];
    }
    else if (textField == self.passwordNew)
    {
        [textField resignFirstResponder];
        [self.passwordConfirm becomeFirstResponder];
    }
    else if (textField == self.passwordConfirm)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    
    if (textField == self.email)
    {
        textField.tag = HRPViewControllerEmailTextFieldTag;
    }
    else if (textField == self.userNameNew)
    {
        textField.tag = HRPViewControllerUsernameTextFieldTag;
    }
    else if (textField == self.passwordNew)
    {
        textField.tag = HRPViewControllerPasswordNewTextFieldTag;
    }
    else if (textField == self.passwordConfirm)
    {
        textField.tag = HRPViewControllerPasswordConfirmTextFieldTag;
    }
    
    [self isTextFieldValid:textField];
}

#pragma mark - Navigation

- (void)showCreateProfileView
{
    [self performSegueWithIdentifier:@"sendToSignup" sender:self];
}

- (void)showMapsStoryboard
{
    [self performSegueWithIdentifier:@"sendToMaps" sender:self];
}

#pragma mark - Instance Methods

-(BOOL)isTextFieldValid:(UITextField *)textField
{
    BOOL valid = NO;
    if (!textField.text.length == 0 || textField.tag == 3 || textField.tag == 4)
    {
        HRPValidationManager *validationManager = [HRPValidationManager sharedManager];
        switch (textField.tag)
        {
            case HRPViewControllerEmailTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerEmailAddressKey];
                break;
            case HRPViewControllerUsernameTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerUsernameKey];
                break;
            case HRPViewControllerPasswordNewTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerPasswordKey];
                break;
            case HRPViewControllerPasswordConfirmTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerPasswordKey];
                break;
        }
    }
    
    return valid;
}

-(void)createParseUser
{
    PFUser *user = [PFUser new];
    
    NSString *usernameLowercase = [self.userNameNew.text lowercaseString];
    user.username = usernameLowercase;
    user.password = self.passwordConfirm.text;
    user.email = self.email.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.userMessage = @"Registration was successful";
        if (succeeded)
        {
            [self showCreateProfileView];
        }
        else
        {
            self.userMessage = error.localizedDescription;
            [self alertControllerParseError];
        }
    }];
}

#pragma mark - Alert Controller Methods

-(void)alertControllerParseError
{
    NSString *string = self.userMessage;
    string = [NSString stringWithFormat:@"%@%@",[[string substringToIndex:1] uppercaseString],[string substringFromIndex:1] ];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerAllFieldsRequired
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please enter values for username and password fields" preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerPasswordMatchValidation
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Those passwords don't match." preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerPasswordStrengthValidation
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Try making a stronger password." preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerEmailValidation
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Not a valid email address." preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerUsernameValidation
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Not a great username try again." preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
    }];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertControllerEmailConfirmation
{
    NSString *string = @"The email address you entered is:";
    NSString *message = [NSString stringWithFormat:@"%@\n%@", string, self.email.text];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Is this correct?" message:message preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        NSLog(@"EMAIL: is confirmed.");
        [self createParseUser];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerLoginInvalid
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please enter values for username and password fields" preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)loginCompleted:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        [self createParseUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
        
        [self showCreateProfileView];
    }
}

-(void)openLogInPage
{
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error
{
    
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    NSLog(@"auth: %@", auth);
    
    [SPTUser requestCurrentUserWithAccessToken:session.accessToken callback:^(NSError *error, SPTUser *object) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            PFUser *currentUser = [PFUser currentUser];
            
            currentUser[@"spotifyCanonical"] = object.canonicalUserName;
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    auth.sessionUserDefaultsKey = object.canonicalUserName;
                }
                else
                {
                    NSLog(@"ERROR: %@", error);
                }
            }];
        }];
    }];
}
-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
    [self openLogInPage];
}

@end

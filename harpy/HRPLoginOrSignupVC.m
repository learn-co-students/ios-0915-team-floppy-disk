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
#import "HRPSpotifyViewController.h"
#import "HRPValidationManager.h"
#import "UIViewController+PresentViewController.h"
#import <Spotify/Spotify.h>
#import <QuartzCore/QuartzCore.h> // Required for boarder color
#import "Constants.h"
@import SafariServices;

@interface HRPLoginOrSignupVC () <SPTAuthViewDelegate, UITextFieldDelegate>

//@property (nonatomic) BOOL blockUserBool; TODO
@property (nonatomic) BOOL spotifyPremium; // add to parse

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

@property (nonatomic) UIView *underline;
@property (weak, nonatomic) IBOutlet UIView *underlineView;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPLoginOrSignupVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSignup];
    [self setupLogin];
    [self.navigationController setNavigationBarHidden:YES]; // Carries over from other VC's

    [self setHiddenStatus];
    
    self.underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 0.5)];
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
    
    [self setupEmailWithFieldHeight:fieldHeight];
    [self setupNewUsernameWithFieldHeight:fieldHeight];
    [self setupNewPasswordWithFieldHeight:fieldHeight];
    [self setupConfirmPasswordnameWithFieldHeight:fieldHeight];
    
    NSArray *textFields = @[ self.email, self.userNameNew, self.passwordNew, self.passwordConfirm ];
    
    [self setupCommonPropertiesForTextFields:textFields];
    [self setupSignupButton];
}

- (void)setupEmailWithFieldHeight:(int)fieldHeight
{
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.email.returnKeyType = UIReturnKeyNext;
    [self.email setCenter: CGPointMake(self.view.center.x, self.email.center.y + 15)]; // !!
}

- (void)setupNewUsernameWithFieldHeight:(int)fieldHeight
{
    self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.userNameNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userNameNew.returnKeyType = UIReturnKeyNext;
    [self.userNameNew setCenter: CGPointMake(self.view.center.x, self.userNameNew.center.y + 65)]; // !!
}

- (void)setupNewPasswordWithFieldHeight:(int)fieldHeight
{
    self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.passwordNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordNew.returnKeyType = UIReturnKeyNext;
    self.passwordNew.secureTextEntry = YES;
    [self.passwordNew setCenter: CGPointMake(self.view.center.x, self.passwordNew.center.y + 115)]; // !!
}

- (void)setupConfirmPasswordnameWithFieldHeight:(int)fieldHeight
{
    self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.passwordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"CONFIRM PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordConfirm.returnKeyType = UIReturnKeyGo;
    self.passwordConfirm.secureTextEntry = YES;
    [self.passwordConfirm setCenter: CGPointMake(self.view.center.x, self.passwordConfirm.center.y + 165)]; // !!
}

- (void)setupSignupButton
{
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.signup setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted]; //are these used? (blackColor, StateHighlighted)
    
    [self setupCommonPropertiesForButton:self.signup];
}

-(void)setupLogin
{
    int fieldHeight = 30;
    
    [self setupUsernameWithFieldHeight:fieldHeight];
    [self setupPasswordWithFieldHeight:fieldHeight];
    
    NSArray *textFields = @[ self.userName, self.password ];
    
    [self setupCommonPropertiesForTextFields:textFields];
    [self setupLoginButton];
}

- (void)setupUsernameWithFieldHeight:(int)fieldHeight
{
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.returnKeyType = UIReturnKeyDefault;
    [self.userName setCenter: CGPointMake(self.view.center.x, self.userName.center.y + 15)]; // !!
}

- (void)setupPasswordWithFieldHeight:(int)fieldHeight
{
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDefault;
    self.password.secureTextEntry = YES;
    [self.password setCenter: CGPointMake(self.view.center.x, self.password.center.y + 65)]; // !!
}

- (void)setupLoginButton
{
    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted]; //are these used?
    
    [self setupCommonPropertiesForButton:self.login];
}

- (void)setupCommonPropertiesForTextFields:(NSArray *)textFields
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
        textField.layer.cornerRadius = 20.0f;
        
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        textField.delegate = self; // Required for dismissing the keyboard programmatically
        
        [self.inputView addSubview:textField];
    }
}

- (void)setupCommonPropertiesForButton:(UIButton *)button
{
    [button setFrame:CGRectMake(0, 0, 275, 40)];
    [button setCenter: CGPointMake(self.view.center.x, self.signup.center.y + 215)];
    
    button.layer.cornerRadius = 20.0f;
    button.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    
    button.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setExclusiveTouch:YES];
    
    [self.inputView addSubview:button];
}

#pragma mark - Action Methods

- (IBAction)signUp:(id)sender
{
    //self.displayMessage.text = @"SIGN UP TO FIND MUSIC CURATED LOCALLY";
    self.email.hidden = NO;
    self.login.hidden = YES;
    self.password.hidden = YES;
    self.passwordConfirm.hidden = NO;
    self.passwordNew.hidden = NO;
    self.signup.hidden = NO;
    self.userName.hidden = YES;
    self.userNameNew.hidden = NO;
    
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewAnimationCurveLinear
                              animations:^{
                                  [self.underline setCenter: CGPointMake(27, 0)];
                              }
                              completion:nil];
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
    
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewAnimationCurveLinear
                              animations:^{
                                  [self.login  setCenter: CGPointMake(self.view.center.x, 135)];
                                  [self.underline setCenter: CGPointMake(222, 0)];
                              }
                              completion:nil];
}

-(void)signupButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: signup button");
    
    BOOL validEmail = [self isTextFieldValid:self.email];
    // BOOL validUsername = [self isTextFieldValid:self.userNameNew];
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
    NSLog(@"CLICKED: login button");
    
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
                NSLog(@"RESULT user %@ is logged in.", user);
                
                PFUser *user = [PFUser currentUser];
                NSString *canonicalUsername = user[@"spotifyCanonical"];
                auth.sessionUserDefaultsKey = canonicalUsername;
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
                
                [self showMapsStoryboard];
            }
            else
            {
                [self alertControllerLoginInvalid];
            }
        }];

    }
}

#pragma mark - Overrides

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (self.signup.state == UIControlStateHighlighted)
//    {
//        [self.signup setHighlighted:NO];
//        self.signup.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Semibold" size:10.0];
//    }
//    if (self.login.state == UIControlStateHighlighted)
//    {
//        [self.login setHighlighted:NO];
//        self.login.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Semibold" size:10.0];
//    }
//}

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
    NSLog(@"textField.tag: %ld", (long)textField.tag);
    NSLog(@"textField.text: %@", textField.text);
    
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
    NSLog(@"TEST: %@ with tag %ld is %@", textField.text, (long)textField.tag, valid ? @"YES" : @"NO");
    
    return valid;
}

-(void)createParseUser
{
    PFUser *user = [PFUser new];
    
    NSString *usernameLowercase = [self.userNameNew.text lowercaseString];
    user.username = usernameLowercase;
    user.password = self.passwordConfirm.text;
    user.email = self.email.text;
    
/* UNCOMMENT THESE LINE WHEN TESTING SPOTIFY LOGINS */
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTSession *session = auth.session;
    [SPTUser requestCurrentUserWithAccessToken:session.accessToken callback:^(NSError *error, NSString *object) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            user[@"spotifyCanonical"] = object;
            auth.sessionUserDefaultsKey = object;
        }];
    }];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        NSString *userMessage = @"Registration was successful";
        if (succeeded)
        {
            NSLog(@"CREATED: %@", user);
            [self showCreateProfileView];
            NSLog(@"SENT: to showCreateProfileView");
        }
        else
        {
            userMessage = error.localizedDescription;
        }
    }];
}

#pragma mark - Alert Controller Methods

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
        [self alertControllerSpotifyVerify];
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

-(void)alertControllerSpotifyVerify
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Do you have a Spotify account?" preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        self.spotifyPremium = YES;
        //[self createParseUser]; // DELETE THESE LINE WHEN TESTING SPOTIFY CALL BACKS
        [self spotifyLoginPopup];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        self.spotifyPremium = NO;
        [self spotifySignupPopup];
        
                SPTAuth *auth = [SPTAuth defaultInstance];
                if (auth.session && [auth.session isValid])
                {
                    [self createParseUser];
                    [self showCreateProfileView];
                }
    }];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

# pragma mark - Spotify

-(void)spotifyLoginPopup
{
    [HRPLoginRedirect launchSpotifyFromViewController:self];
}

-(void)spotifySignupPopup
{
    
    NSURL *spotifyURL = [NSURL URLWithString:@"https://www.spotify.com/signup/"];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:spotifyURL];
    [self presentViewController:safariVC animated:YES];
}

-(void)loginCompleted:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        [self createParseUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
        
        [self showCreateProfileView];
    }
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

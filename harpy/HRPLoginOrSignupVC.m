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
@import SafariServices;

@interface HRPLoginOrSignupVC () <SPTAuthViewDelegate>

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
//@property (nonatomic, strong) HRPSignupVC *sendToSignupVC;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPLoginOrSignupVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSignup];
    [self setupLogin];
    [self.navigationController setNavigationBarHidden:YES]; // Carrys over from other VC's
    
    //self.displayMessage.text = @"SIGN UP TO FIND MUSIC CURATED LOCALLY";
    self.email.hidden = NO;
    self.login.hidden = YES;
    self.password.hidden = YES;
    self.passwordConfirm.hidden = NO;
    self.passwordNew.hidden = NO;
    self.signup.hidden = NO;
    self.userName.hidden = YES;
    self.userNameNew.hidden = NO;
    
//    self.underline = [[UIView alloc] initWithFrame:CGRectMake(55, 0, 55, 0.5)];
//    self.underline.backgroundColor = [UIColor whiteColor];
//    [self.inputView addSubview:self.underline];
    
    self.underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 0.5)];
    self.underline.backgroundColor = [UIColor whiteColor];
    [self.underlineView addSubview:self.underline];
    
    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapper];
    
    [self.signup setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.email];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.email];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.passwordNew];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.passwordConfirm];
}

#pragma mark - Custom Accessors

-(void)setupSignup
{
    int fieldHeight = 30;
    
    //self.email.adjustsFontSizeToFitWidth = YES; //adjust the font size to fit width.
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.email.autocorrectionType = UITextAutocorrectionTypeNo;
    self.email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.email.delegate = self; // Required for dismissing the keyboard programically
    self.email.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.email.keyboardAppearance = UIKeyboardAppearanceDark;
    self.email.keyboardType = UIKeyboardTypeEmailAddress;
    self.email.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.email.layer.borderWidth = 1;
    self.email.layer.cornerRadius = 20.0f;
    self.email.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.email.leftViewMode = UITextFieldViewModeAlways;
    self.email.returnKeyType = UIReturnKeyNext;
    self.email.textAlignment = NSTextAlignmentLeft;
    self.email.textColor = [UIColor whiteColor];
    [self.email setCenter: CGPointMake(self.view.center.x, self.email.center.y + 15)];
    [self.inputView addSubview:self.email];
    
    self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.userNameNew.adjustsFontSizeToFitWidth = YES;
    self.userNameNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userNameNew.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameNew.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameNew.delegate = self;
    self.userNameNew.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.userNameNew.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userNameNew.keyboardType = UIKeyboardTypeEmailAddress;
    self.userNameNew.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.userNameNew.layer.borderWidth = 1;
    self.userNameNew.layer.cornerRadius = 20.0f;
    self.userNameNew.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.userNameNew.leftViewMode = UITextFieldViewModeAlways;
    self.userNameNew.returnKeyType = UIReturnKeyNext;
    self.userNameNew.textAlignment = NSTextAlignmentLeft;
    self.userNameNew.textColor = [UIColor whiteColor];
    [self.userNameNew setCenter: CGPointMake(self.view.center.x, self.userNameNew.center.y + 65)];
    [self.inputView addSubview:self.userNameNew];
    
    self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.passwordNew.adjustsFontSizeToFitWidth = YES;
    self.passwordNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordNew.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordNew.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordNew.delegate = self;
    self.passwordNew.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.passwordNew.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordNew.keyboardType = UIKeyboardTypeEmailAddress; // Should change
    self.passwordNew.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.passwordNew.layer.borderWidth = 1;
    self.passwordNew.layer.cornerRadius = 20.0f;
    self.passwordNew.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.passwordNew.leftViewMode = UITextFieldViewModeAlways;
    self.passwordNew.returnKeyType = UIReturnKeyNext;
    self.passwordNew.secureTextEntry = YES;
    self.passwordNew.textAlignment = NSTextAlignmentLeft;
    self.passwordNew.textColor = [UIColor whiteColor];
    [self.passwordNew setCenter: CGPointMake(self.view.center.x, self.passwordNew.center.y + 115)];
    [self.inputView addSubview:self.passwordNew];
    
    self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.passwordConfirm.adjustsFontSizeToFitWidth = YES;
    self.passwordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"CONFIRM PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordConfirm.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordConfirm.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordConfirm.delegate = self;
    self.passwordConfirm.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.passwordConfirm.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordConfirm.keyboardType = UIKeyboardTypeEmailAddress; // Should change
    self.passwordConfirm.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.passwordConfirm.layer.borderWidth = 1;
    self.passwordConfirm.layer.cornerRadius = 20.0f;
    self.passwordConfirm.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.passwordConfirm.leftViewMode = UITextFieldViewModeAlways;
    self.passwordConfirm.returnKeyType = UIReturnKeyGo;
    self.passwordConfirm.secureTextEntry = YES;
    self.passwordConfirm.textAlignment = NSTextAlignmentLeft;
    self.passwordConfirm.textColor = [UIColor whiteColor];
    [self.passwordConfirm setCenter: CGPointMake(self.view.center.x, self.passwordConfirm.center.y + 165)];
    [self.inputView addSubview:self.passwordConfirm];
    
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.signup.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    self.signup.layer.cornerRadius = 20.0f;
    self.signup.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setExclusiveTouch:YES];
    [self.signup setFrame:CGRectMake(0, 0, 275, 40)];
    [self.signup setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.signup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signup setCenter: CGPointMake(self.view.center.x, self.signup.center.y + 215)];
    [self.inputView addSubview:self.signup];
}
-(void)setupLogin
{
    int fieldHeight = 30;
    
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.userName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    self.userName.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userName.textColor = [UIColor whiteColor];
    self.userName.textAlignment = NSTextAlignmentLeft;
    self.userName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userName.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.userName.adjustsFontSizeToFitWidth = YES;
    self.userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.returnKeyType = UIReturnKeyDefault;
    self.userName.layer.cornerRadius = 20.0f;
    self.userName.layer.borderWidth = 1;
    self.userName.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.userName.delegate = self;
    [self.userName setCenter: CGPointMake(self.view.center.x, self.userName.center.y + 15)];
    [self.inputView addSubview:self.userName];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.password.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.password.leftViewMode = UITextFieldViewModeAlways;
    self.password.keyboardAppearance = UIKeyboardAppearanceDark;
    self.password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.password.textColor = [UIColor whiteColor];
    self.password.textAlignment = NSTextAlignmentLeft;
    self.password.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.password.adjustsFontSizeToFitWidth = YES;
    self.password.keyboardType = UIKeyboardTypeEmailAddress;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDefault;
    self.password.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.password.layer.cornerRadius = 20.0f;
    self.password.layer.borderWidth = 1;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    [self.password setCenter: CGPointMake(self.view.center.x, self.password.center.y + 65)];
    [self.inputView addSubview:self.password];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.login.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    self.login.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.login.layer.cornerRadius = 20.0f;
    [self.login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.login addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setFrame:CGRectMake(0, 0, 275, 40)];
    [self.login setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.login setExclusiveTouch:YES];
    [self.login  setCenter: CGPointMake(self.view.center.x, self.login.center.y + 215)];
    [self.inputView addSubview:self.login];
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
                                  //[self.underline setCenter: CGPointMake(82, 0)];
                                  [self.underline setCenter: CGPointMake(27, 0)];
                              }
                              completion:nil];
}
- (IBAction)logIn:(id)sender
{
    //self.displayMessage.text = @"LOG IN TO FIND MUSIC CURATED LOCALLY";
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
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if ((self.userName.text.length == 0)  || (self.password.text.length ==  0))
    {
        [self alertControllerLoginInvalid];
    }
    else
    {
        [self.parseService loginApp:self.userName.text password:self.password.text completionHandler:^(HRPUser *user, NSError *error)
        {
            if (user)
            {
                NSLog(@"RESULT user %@ is logged in.", user);
                
                PFUser *user = [PFUser currentUser];
                NSString *canonicalUsername = user[@"spotifyCanonical"];
                auth.sessionUserDefaultsKey = canonicalUsername;
                
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
        [self spotifyLoginPopup];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        self.spotifyPremium = NO;
        [self spotifySignupPopup];

//        SPTAuth *auth = [SPTAuth defaultInstance];
//        if (auth.session && [auth.session isValid])
//        {
//            [self createParseUser];
//            [self showCreateProfileView];
//        }
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
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.spotify.com/signup/"]];
    [self presentViewController:safariVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCompleted:) name:@"sessionUpdated" object:nil];
}

-(void)loginCompleted:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES];
    
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        [self createParseUser];
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


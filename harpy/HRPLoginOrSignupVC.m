//
//  HRPLoginOrSignupVC.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLoginOrSignupVC.h"
#import "HRPSignupVC.h"
#import "HRPValidationManager.h"
#import "HRPParseNetworkService.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h> // Required for boarder color

@interface HRPLoginOrSignupVC ()

@property (nonatomic) UIGestureRecognizer *tapper;
@property (nonatomic) UIView *underline;

// Sign up properties
@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) UITextField *email;
@property (nonatomic) UITextField *passwordNew;
@property (nonatomic) UITextField *passwordConfirm;
@property (nonatomic) UIButton *signup;

// Login properties
@property (nonatomic) UITextField *userName;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITextField *textFieldString;
@property (nonatomic) UIButton *login;
@property (nonatomic) BOOL blockUserBool;

@property (nonatomic, strong) HRPSignupVC *sendToSignupVC;
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
    
    self.displayMessage.text = @"SIGN UP TO FIND MUSIC CURATED LOCALLY";
    self.email.hidden = NO;
    self.login.hidden = YES;
    self.password.hidden = YES;
    self.passwordConfirm.hidden = NO;
    self.passwordNew.hidden = NO;
    self.signup.hidden = NO;
    self.userName.hidden = YES;
    self.userNameNew.hidden = NO;
    
    self.underline = [[UIView alloc] initWithFrame:CGRectMake(55, 0, 55, 0.5)];
    self.underline.backgroundColor = [UIColor whiteColor];
    [self.inputView addSubview:self.underline];
    
    self.inputView.layer.backgroundColor = [[UIColor clearColor]CGColor];
    
    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapper];
    
    [self.signup setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backround_iphone5"];
    self.view.backgroundColor =[[UIColor alloc] initWithPatternImage:backgroundImage];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set up notifications for text field validity
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.email];
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.userNameNew];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.email];
}

#pragma mark - Custom Accessors

-(void)setupSignup
{
    int fieldHeight = 30;
    
    //self.email.adjustsFontSizeToFitWidth = YES; //adjust the font size to fit width.
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.email.autocorrectionType = UITextAutocorrectionTypeNo;
    self.email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.email.delegate = self; // Required for dismissing the keyboard programically
    self.email.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
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
    
    
    self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.userNameNew.adjustsFontSizeToFitWidth = YES;
    self.userNameNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userNameNew.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameNew.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameNew.delegate = self;
    self.userNameNew.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
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
    [self.userNameNew setCenter: CGPointMake(self.view.center.x, self.userNameNew.center.y + 60)];
    [self.inputView addSubview:self.userNameNew];
    
    self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.passwordNew.adjustsFontSizeToFitWidth = YES;
    self.passwordNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordNew.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordNew.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordNew.delegate = self;
    self.passwordNew.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
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
    [self.passwordNew setCenter: CGPointMake(self.view.center.x, self.passwordNew.center.y + 110)];
    [self.inputView addSubview:self.passwordNew];
    
    self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.passwordConfirm.adjustsFontSizeToFitWidth = YES;
    self.passwordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"CONFIRM PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordConfirm.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordConfirm.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordConfirm.delegate = self;
    self.passwordConfirm.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
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
    [self.passwordConfirm setCenter: CGPointMake(self.view.center.x, self.passwordConfirm.center.y + 160)];
    [self.inputView addSubview:self.passwordConfirm];
    
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.signup.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    self.signup.layer.cornerRadius = 20.0f;
    self.signup.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setExclusiveTouch:YES];
    [self.signup setFrame:CGRectMake(0, 0, 250, 40)];
    [self.signup setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.signup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signup setCenter: CGPointMake(self.view.center.x, self.signup.center.y + 210)];
    [self.inputView addSubview:self.signup];
}
-(void)setupLogin
{
    int fieldHeight = 30;
    
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.userName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    self.userName.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userName.textColor = [UIColor whiteColor];
    self.userName.textAlignment = NSTextAlignmentLeft;
    self.userName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userName.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
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
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, fieldHeight + 8)];
    self.password.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.password.leftViewMode = UITextFieldViewModeAlways;
    self.password.keyboardAppearance = UIKeyboardAppearanceDark;
    self.password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.password.textColor = [UIColor whiteColor];
    self.password.textAlignment = NSTextAlignmentLeft;
    self.password.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:10.0];
    self.password.adjustsFontSizeToFitWidth = YES;
    self.password.keyboardType = UIKeyboardTypeEmailAddress;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDefault;
    self.password.layer.borderColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5]CGColor];
    self.password.layer.cornerRadius = 20.0f;
    self.password.layer.borderWidth = 1;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    [self.password setCenter: CGPointMake(self.view.center.x, self.password.center.y + 60)];
    [self.inputView addSubview:self.password];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.login.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    self.login.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.login.layer.cornerRadius = 20.0f;
    [self.login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.login addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setFrame:CGRectMake(0, 0, 250, 40)];
    [self.login setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.login setExclusiveTouch:YES];
    [self.login  setCenter: CGPointMake(self.view.center.x, self.login.center.y + 210)];
    [self.inputView addSubview:self.login];
}

#pragma mark - Action Methods

- (IBAction)signUp:(id)sender
{
    self.displayMessage.text = @"SIGN UP TO FIND MUSIC CURATED LOCALLY";
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
                                  [self.underline setCenter: CGPointMake(80, 0)];
                              }
                              completion:nil];
}
- (IBAction)logIn:(id)sender
{
    self.displayMessage.text = @"LOG IN TO FIND MUSIC CURATED LOCALLY";
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
                                  [self.login  setCenter: CGPointMake(self.view.center.x, 125)];
                                  [self.underline setCenter: CGPointMake(self.view.center.x + 90, 0)];
                              }
                              completion:nil];
}
-(void)signupButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: signup button");
    
    if ([self isTextFieldValid:self.userNameNew] ==  YES && [self isTextFieldValid:self.email] ==  YES)
    {
        [self performSegueWithIdentifier:@"sendToSignup" sender:sender];
    }
    else if ([self isTextFieldValid:self.userNameNew] ==  YES && [self isTextFieldValid:self.email] ==  NO)
    {
        [self callBadEmailAlertController];
    }
    else if ([self isTextFieldValid:self.userNameNew] ==  NO && [self isTextFieldValid:self.email] ==  YES)
    {
        [self callBadUsernameAlertController];
    }
}
-(void)loginButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: login button");
    
    if ((self.userName.text.length == 0)  || (self.password.text.length ==  0))
    {
        [self callLoginInvalid];
    }
    else
    {
        [self.parseService loginApp:self.userName.text password:self.password.text completionHandler:^(HRPUser *user, NSError *error)
        {
            if (user)
            {
                NSLog(@"RESULT user %@ is logged in.", user);
                //[self showMapsStoryboard];
                [self performSelector:@selector(showMapsStoryboard) withObject:nil afterDelay:0];
            }
            else
            {
                UIAlertController *alert;
                alert = [UIAlertController alertControllerWithTitle:@"That login doesnt seem to work\n try again." message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                              {
                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                              }];
                
                [alert addAction:errorAction];
                
                [self presentViewController:alert animated:YES completion:nil];
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
    if (textField == self.userNameNew)
    {
        textField.tag = HRPViewControllerUsernameTextFieldTag;
    }
    
    [self isTextFieldValid:textField];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"sendToSignup"])
    {
        HRPSignupVC *vc = segue.destinationViewController;
        vc.userNameNew = self.userNameNew;
        vc.emailString = self.email.text;
    }
}
- (void)showMapsStoryboard
{
    [self performSegueWithIdentifier:@"sendToMaps" sender:self];
}

#pragma mark - Instance Methods

-(BOOL)isTextFieldValid:(UITextField *)textField
{
    BOOL valid = NO;
    if ([textField.text length] == 0)
    {
        // To stop it from being called when empty
    } else
    {
        HRPValidationManager *validationManager = [HRPValidationManager sharedManager];
        switch (textField.tag)
        {
            case HRPViewControllerUsernameTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerUsernameKey];
                break;
            case HRPViewControllerEmailTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerEmailAddressKey];
                break;
            case HRPViewControllerPasswordTextFieldTag:
                valid = [validationManager validateValue:textField.text forKey:kHRPValidationManagerPasswordKey];
                break;
        }
        NSLog(@"TEST: %@ is %@", textField.text, valid ? @"YES" : @"NO");
    }
    
    return valid;
}

#pragma mark - Alert Controller Methods

-(void)callBadEmailAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Can't work with that email address\n try again." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)callBadUsernameAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not a great username\n try again." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)callLoginInvalid
{
    NSLog(@"RESULT is not a valid entry");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please enter values for username and password fields"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end


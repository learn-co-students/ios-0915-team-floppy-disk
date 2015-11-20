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

@interface HRPLoginOrSignupVC ()

// Sign up properties
@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) UITextField *email;
@property (nonatomic) UIButton *signup;

// Login properties
@property (nonatomic) UITextField *userName;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITextField *textFieldString;
@property (nonatomic) UIButton *login;
@property (nonatomic) BOOL blockUserBool;
@property(nonatomic, strong) HRPSignupVC *sendToSignupVC;

@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPLoginOrSignupVC

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSignup];
    [self setupLogin];
    
    self.displayMessage.text = @"Sign up to find music curated locally";
    self.email.hidden = NO;
    self.userNameNew.hidden = NO;
    self.userName.hidden = YES;
    self.password.hidden = YES;
    
    self.login.hidden = YES;
    self.signup.hidden = NO;
    
    self.parseService = [HRPParseNetworkService sharedService];
}
-(void)viewDidAppear:(BOOL)animated{
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
    
    self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, fieldHeight)];
    self.userNameNew.placeholder = @"Username";
    self.userNameNew.textAlignment = NSTextAlignmentCenter;
    self.userNameNew.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.userNameNew.adjustsFontSizeToFitWidth = YES;
    self.userNameNew.keyboardType = UIKeyboardTypeEmailAddress;
    self.userNameNew.returnKeyType = UIReturnKeyNext;
    self.userNameNew.delegate = self;
    [self.inputView addSubview:self.userNameNew];
    
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 300, fieldHeight)];
    self.email.placeholder = @"Enter your email";
    self.email.textAlignment = NSTextAlignmentCenter;
    self.email.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.email.adjustsFontSizeToFitWidth = YES; //adjust the font size to fit width.
    self.email.keyboardType = UIKeyboardTypeEmailAddress; //keyboard type (not sure if this is working)
    self.email.returnKeyType = UIReturnKeyNext; // "next" Key type for keyboard
    self.email.delegate = self; // Required for dismissing the keyboard programically
    [self.inputView addSubview:self.email];
    
    self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.signup setFrame:CGRectMake(40, 80, 215, 40)];
    [self.signup setTitle:@"Signup" forState:UIControlStateNormal];
    [self.signup setExclusiveTouch:YES];
    [self.inputView addSubview:self.signup];
}
-(void)setupLogin
{
    int fieldHeight = 30;
    
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, fieldHeight)];
    self.userName.placeholder = @"Username";
    self.userName.textAlignment = NSTextAlignmentCenter;
    self.userName.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.userName.adjustsFontSizeToFitWidth = YES;
    self.userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.returnKeyType = UIReturnKeyDefault;
    self.userName.delegate = self;
    [self.inputView addSubview:self.userName];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 300, fieldHeight)];
    self.password.placeholder = @"Password";
    self.password.textAlignment = NSTextAlignmentCenter;
    self.password.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
    self.password.adjustsFontSizeToFitWidth = YES;
    self.password.keyboardType = UIKeyboardTypeEmailAddress;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDefault;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    [self.inputView addSubview:self.password];
    
    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setFrame:CGRectMake(40, 80, 215, 40)];
    [self.login setTitle:@"Login" forState:UIControlStateNormal];
    [self.login setExclusiveTouch:YES];
    [self.inputView addSubview:self.login];
}

#pragma mark - Action Methods

/*BUG: Does not allow text field input if constrants are applied on Storyboard*/
- (IBAction)signUp:(id)sender
{
    self.displayMessage.text = @"Sign up to find music curated locally";
    
    self.email.hidden = NO;
    self.userNameNew.hidden = NO;
    self.userName.hidden = YES;
    self.password.hidden = YES;
    
    self.login.hidden = YES;
    self.signup.hidden = NO;
}
- (IBAction)logIn:(id)sender
{
    self.displayMessage.text = @"Log in to see music curated locally";
    
    self.email.hidden = YES;
    self.userNameNew.hidden = YES;
    self.userName.hidden = NO;
    self.password.hidden = NO;
    
    self.login.hidden = NO;
    self.signup.hidden = YES;
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
        // TODO: Catch failed login return
        [self.parseService loginApp:self.userName.text password:self.password.text completionHandler:^(HRPUser *user) {
        NSLog(@"RESULT user %@ is logged in.", user);
        }];
    }
}

#pragma mark - Overrides

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // Required for dismissing the keyboard programically
    
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

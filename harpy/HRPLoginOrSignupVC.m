//
//  HRPLoginOrSignupVC.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLoginOrSignupVC.h"
#import "HRPParseNetworkService.h"
#import "AppDelegate.h"

@interface HRPLoginOrSignupVC ()

@property (nonatomic) UITextField *userNameNew;
@property (nonatomic) UITextField *passwordNew;
@property (nonatomic) UITextField *passwordConfirm;
@property (nonatomic) UITextField *email;
@property (nonatomic) UITextField *userName;
@property (nonatomic) UITextField *password;
@property (nonatomic) UIButton *login;
@property (nonatomic) UIButton *signup;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPLoginOrSignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseService = [HRPParseNetworkService sharedService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*BUG: Does not allow input if constrants are applied on Storyboard*/
- (IBAction)signUp:(id)sender {
    self.displayMessage.text = @"Sign up to find music curated locally";
    
    self.email.hidden = NO;
    self.userNameNew.hidden = NO;
    self.passwordNew.hidden = NO;
    self.passwordConfirm.hidden = NO;
    
    self.userName.hidden = YES;
    self.password.hidden = YES;
    self.login.hidden = YES;
    self.signup.hidden = NO;
    
    static dispatch_once_t onceToken; // Using dispatch_once to avoid multiple instances of the input fields
    dispatch_once(&onceToken, ^{
        int fieldHeight = 30;
        
        self.email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, fieldHeight)];
        self.email.placeholder = @"Enter your email";
        self.email.textAlignment = NSTextAlignmentCenter;
        self.email.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
        self.email.adjustsFontSizeToFitWidth = YES; //adjust the font size to fit width.
        self.email.keyboardType = UIKeyboardTypeEmailAddress; //keyboard type (not sure if this is working)
        self.email.returnKeyType = UIReturnKeyDone; // "done" Key type for keyboard
        self.email.returnKeyType = UIReturnKeyDefault;
        self.email.delegate = self; // Required for dismissing the keyboard programically
        [self.inputView addSubview:self.email];
        
        self.userNameNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 300, fieldHeight)];
        self.userNameNew.placeholder = @"Username";
        self.userNameNew.textAlignment = NSTextAlignmentCenter;
        self.userNameNew.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
        self.userNameNew.adjustsFontSizeToFitWidth = YES;
        self.userNameNew.keyboardType = UIKeyboardTypeEmailAddress;
        self.userNameNew.returnKeyType = UIReturnKeyDone;
        self.userNameNew.returnKeyType = UIReturnKeyDefault;
        self.userNameNew.delegate = self;
        [self.inputView addSubview:self.userNameNew];
        
        self.passwordNew = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 300, fieldHeight)];
        self.passwordNew.placeholder = @"Password";
        self.passwordNew.textAlignment = NSTextAlignmentCenter;
        self.passwordNew.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
        self.passwordNew.adjustsFontSizeToFitWidth = YES;
        self.passwordNew.keyboardType = UIKeyboardTypeEmailAddress; // Should change
        self.passwordNew.returnKeyType = UIReturnKeyDone;
        self.passwordNew.returnKeyType = UIReturnKeyDefault;
        self.passwordNew.delegate = self;
        self.passwordNew.secureTextEntry = YES;
        [self.inputView addSubview:self.passwordNew];
        
        self.passwordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(0, 120, 300, fieldHeight)];
        self.passwordConfirm.placeholder = @"Password";
        self.passwordConfirm.textAlignment = NSTextAlignmentCenter;
        self.passwordConfirm.font = [UIFont fontWithName:@"helvetica-neue" size:14.0];
        self.passwordConfirm.adjustsFontSizeToFitWidth = YES;
        self.passwordConfirm.keyboardType = UIKeyboardTypeEmailAddress; // Should change
        self.passwordConfirm.returnKeyType = UIReturnKeyDone;
        self.passwordConfirm.returnKeyType = UIReturnKeyDefault;
        self.passwordConfirm.delegate = self;
        self.passwordConfirm.secureTextEntry = YES;
        [self.inputView addSubview:self.passwordConfirm];
        
        self.signup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.signup addTarget:self action:@selector(signupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.signup setFrame:CGRectMake(30, 160, 215, 40)];
        [self.signup setTitle:@"SignUp" forState:UIControlStateNormal];
        [self.signup setExclusiveTouch:YES];
        [self.inputView addSubview:self.signup];
    });
}
- (IBAction)logIn:(id)sender {
    self.displayMessage.text = @"Log in to see music curated locally";
    
    self.email.hidden = YES;
    self.userNameNew.hidden = YES;
    self.passwordNew.hidden = YES;
    self.passwordConfirm.hidden = YES;
    
    self.userName.hidden = NO;
    self.password.hidden = NO;
    
    self.login.hidden = NO;
    self.signup.hidden = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
        [self.login setFrame:CGRectMake(30, 80, 215, 40)];
        [self.login setTitle:@"Login" forState:UIControlStateNormal];
        [self.login setExclusiveTouch:YES];
        [self.inputView addSubview:self.login];
    });
}
-(void) signupButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: signup button");
    [self.parseService createUser:self.userNameNew.text email:self.email.text password:self.passwordNew.text completionHandler:^(HRPUser *user) {
        
    }];
}
-(void) loginButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED: login button");
}
// Required for dismissing the keyboard programically
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end

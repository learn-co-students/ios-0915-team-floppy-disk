//
//  HRPCreateProfileVC.m
//  harpy
//
//  Created by Kiara Robles on 11/29/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPCreateProfileVC.h"
#import "HRPParseNetworkService.h"
#import "UIViewController+PresentViewController.h"

@interface HRPCreateProfileVC () <UIImagePickerControllerDelegate>

//@property (nonatomic) UIImage *userImage;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (nonatomic) UIGestureRecognizer *tapper;
@property (nonatomic) UITextField *realName;
@property (nonatomic) UITextField *shortBio;
@property (nonatomic) UIButton *createProfile;
@property (weak, nonatomic) UIImage *userImage;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPCreateProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupProfile];
    [self.navigationController setNavigationBarHidden:YES]; // Carrys over from other VC's
    
    UIImage * buttonImage = [UIImage imageNamed:@"plusPhoto"];
    [self.photoButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupProfile
{
    int fieldHeight = 30;
    
    self.realName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.realName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.realName.leftViewMode = UITextFieldViewModeAlways;
    self.realName.keyboardAppearance = UIKeyboardAppearanceDark;
    self.realName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"NAME" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.realName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.realName.textColor = [UIColor blackColor];
    self.realName.textAlignment = NSTextAlignmentLeft;
    self.realName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.realName.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.realName.adjustsFontSizeToFitWidth = YES;
    self.realName.keyboardType = UIKeyboardTypeEmailAddress;
    self.realName.returnKeyType = UIReturnKeyDone;
    self.realName.returnKeyType = UIReturnKeyDefault;
    self.realName.layer.cornerRadius = 20.0f;
    self.realName.layer.borderWidth = 1;
    self.realName.layer.borderColor = [[[UIColor darkGrayColor]colorWithAlphaComponent:0.5]CGColor];
    self.realName.delegate = self;
    [self.realName setCenter: CGPointMake(self.view.center.x, self.realName.center.y + 75)];
    [self.inputView addSubview:self.realName];
    
    self.shortBio = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 275, fieldHeight + 8)];
    self.shortBio.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.shortBio.leftViewMode = UITextFieldViewModeAlways;
    self.shortBio.keyboardAppearance = UIKeyboardAppearanceDark;
    self.shortBio.autocorrectionType = UITextAutocorrectionTypeNo;
    self.shortBio.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SHORT BIO" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.shortBio.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.shortBio.textColor = [UIColor blackColor];
    self.shortBio.textAlignment = NSTextAlignmentLeft;
    self.shortBio.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.shortBio.adjustsFontSizeToFitWidth = YES;
    self.shortBio.keyboardType = UIKeyboardTypeEmailAddress;
    self.shortBio.returnKeyType = UIReturnKeyDone;
    self.shortBio.returnKeyType = UIReturnKeyDefault;
    self.shortBio.layer.borderColor = [[[UIColor darkGrayColor]colorWithAlphaComponent:0.5]CGColor];
    self.shortBio.layer.cornerRadius = 20.0f;
    self.shortBio.layer.borderWidth = 1;
    self.shortBio.delegate = self;
    [self.shortBio setCenter: CGPointMake(self.view.center.x, self.shortBio.center.y + 125)];
    [self.inputView addSubview:self.shortBio];
    
    self.createProfile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.createProfile.layer.backgroundColor = [[UIColor colorWithRed:0.17 green:0.62 blue:0.90 alpha:1.0]CGColor];
    self.createProfile.titleLabel.font = [UIFont fontWithName:@"SFUIDisplay-Medium" size:14.0];
    self.createProfile.layer.cornerRadius = 20.0f;
    [self.createProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createProfile addTarget:self action:@selector(createProfileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.createProfile setFrame:CGRectMake(0, 0, 275, 40)];
    [self.createProfile setTitle:@"CREATE PROFILE" forState:UIControlStateNormal];
    [self.createProfile setExclusiveTouch:YES];
    [self.createProfile  setCenter: CGPointMake(self.view.center.x, self.createProfile.center.y + 175)];
    [self.inputView addSubview:self.createProfile];
}
-(void)createProfileButtonClicked:(UIButton *)sender
{
    NSLog(@"CLICKED:create profile button");
    
    if (![self.realName.text isEqualToString:@""])
    {
        NSString *realNameText = self.realName.text;
        PFUser *newUser = [PFUser currentUser];
        newUser[@"realName"] = realNameText;
        [newUser saveInBackground];
    }
    if (![self.shortBio.text isEqualToString:@""])
    {
        [[PFUser currentUser] setObject:self.shortBio.text forKey:@"shortBio"];
        NSString *shortBio = [[PFUser currentUser] objectForKey:@"shortBio"];
        NSLog(@"%@", shortBio);
    }
    
    [self performSegueWithIdentifier:@"sendToMaps" sender:self];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.realName)
    {
        [textField resignFirstResponder];
        [self.shortBio becomeFirstResponder];
    }
    else if (textField == self.shortBio)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)setImage:(UIImage *)image withCompletion:(void(^)())completion
{
    PFUser *currentUser = [PFUser currentUser];
    NSData *data = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            currentUser[@"userAvatar"] = imageFile;
            NSLog(@"PARSE: uploaded userAvatar");
        }
        completion();
    }];
}

- (IBAction)onSelectProfileImageButtonTapped:(UIButton *)sender
{
    UIImagePickerController *pickerController = [UIImagePickerController new];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePicker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.userImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.userPhoto.image = self.userImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (self.userPhoto != nil)
    {
        [self.photoButton setBackgroundImage:nil forState:UIControlStateNormal];
        
        PFUser *currentuser = [PFUser currentUser];
        NSData *selectedImage = UIImageJPEGRepresentation(self.userImage, 1);
        PFFile *imageFile = [PFFile fileWithName:@"image" data:selectedImage];
        currentuser[@"userAvatar"] = imageFile;
    }
}

@end

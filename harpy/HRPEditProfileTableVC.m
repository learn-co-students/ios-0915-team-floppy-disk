//
//  HRPEditProfileTableVC.m
//  harpy
//
//  Created by Kiara Robles on 12/7/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPEditProfileTableVC.h"
#import "HRPParseNetworkService.h"
#import "Constants.h"

@interface HRPEditProfileTableVC () <UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (weak, nonatomic) UIImage *userImage;
@property (weak, nonatomic) UIImageView *userAvatar;
@property (weak, nonatomic) UITextField *realNameTextField;
@property (weak, nonatomic) UITextField *shortBioTextField;
@property (nonatomic) PFFile *ownedImageFile;
@property (nonatomic) PFUser *currentUser;

@end

@implementation HRPEditProfileTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.98 alpha:1];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"profileHeaderCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"userPhotoCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        PFUser *currentUser = [PFUser currentUser];
        
        UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
        self.userAvatar = (UIImageView *)[cell viewWithTag:1];
        PFFile *imageFile = [currentUser objectForKey:@"userAvatar"];
        if (imageFile)
        {
            self.userAvatar.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.delegate = self;
            [self.userAvatar addGestureRecognizer:tapGesture];
            
            self.userAvatar.image = [UIImage imageNamed:@"periwinkleImage.png"];
            self.userAvatar.layer.cornerRadius =  47;
            [self.userAvatar.layer setBorderColor: [ironColor CGColor]];
            [self.userAvatar.layer setBorderWidth: 1.0];
            self.userAvatar.layer.masksToBounds = YES;
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    self.userAvatar.image = [UIImage imageWithData:data];
                    self.userAvatar.highlightedImage = [UIImage imageWithData:data];
                }
                else
                {
                    NSLog(@"ERROR: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }
    if (indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nameInputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *realNameString = self.currentUser[@"realName"];
        self.realNameTextField = (UITextField *)[cell viewWithTag:3];
        self.realNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:realNameString attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        self.realNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.realNameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.realNameTextField.borderStyle = NO;
    }
    if (indexPath.row == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"bioInputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *shortBioString = self.currentUser[@"shortBio"];
        self.shortBioTextField = (UITextField *)[cell viewWithTag:4];
        self.shortBioTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:shortBioString attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        self.shortBioTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.shortBioTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.shortBioTextField.borderStyle = NO;
    }
    
    return cell;
}

#pragma mark - Overrides

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat customTableCellHeight = 0.0;
    
    if (indexPath.row == 0)
    {
        customTableCellHeight = self.view.frame.size.height/13;
    }
    if (indexPath.row == 1)
    {
        customTableCellHeight = self.view.frame.size.height/5;
    }
    if (indexPath.row == 2)
    {
        customTableCellHeight = self.view.frame.size.height/13;
    }
    if (indexPath.row == 3)
    {
        customTableCellHeight = self.view.frame.size.height/13;
    }
    
    return customTableCellHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected at %ld", indexPath.row);
    if(indexPath.row == 1)
    {
        [self onSelectProfileImageButtonTapped];
    }
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}
- (void) hideKeyboard {
    [self.realNameTextField resignFirstResponder];
    [self.shortBioTextField resignFirstResponder];
}

#pragma mark - UIImagePicker Delegate Methods

//- (void)setImage:(UIImage *)image withCompletion:(void(^)())completion
//{
//    NSData *data = UIImagePNGRepresentation(image);
//    self.ownedImageFile = [PFFile fileWithName:@"image.png" data:data];
//    [self.ownedImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            self.currentUser[@"userAvatar"] = self.ownedImageFile;
//            NSLog(@"PARSE: uploaded userAvatar");
//        }
//        completion();
//    }];
//}
- (void)onSelectProfileImageButtonTapped
{
    UIImagePickerController *pickerController = [UIImagePickerController new];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.userImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.userAvatar.image = self.userImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action Methods

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonPressed:(id)sender
{
    PFFile *oldImageFile = [self.currentUser objectForKey:@"userAvatar"];
    
    if (self.ownedImageFile)
    {
        [self.currentUser setObject:self.ownedImageFile forKey:@"userAvatar"];
    }
    if (![self.realNameTextField.text isEqual:@""])
    {
        NSString *newName = self.realNameTextField.text;
        self.currentUser[@"realName"] = newName;
    }
    if (![self.shortBioTextField.text isEqual: @""])
    {
        NSString *newBio = self.shortBioTextField.text;
        self.currentUser[@"shortBio"] = newBio;
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"save user with new image success!");
            }];
        }
    }];
}
- (void) tapGesture: (id)sender
{
    [self onSelectProfileImageButtonTapped];
}


@end

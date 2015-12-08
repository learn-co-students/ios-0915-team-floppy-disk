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

@interface HRPEditProfileTableVC () <UIImagePickerControllerDelegate>

@property (strong, nonatomic) HRPParseNetworkService *parseService;
@property (weak, nonatomic) UIImage *userImage;
@property (weak, nonatomic) UIImageView *userAvatar;
@property (weak, nonatomic) UIButton *photoButton;

@end

@implementation HRPEditProfileTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.98 alpha:1];
    [self.photoButton setBackgroundImage:nil forState:UIControlStateNormal];
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
    return 3;
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
        
        self.photoButton = (UIButton *)[cell viewWithTag:2];
        UIColor *ironColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
        PFFile *imageFile = [currentUser objectForKey:@"userAvatar"];
        if (imageFile)
        {
            self.userAvatar = (UIImageView *)[cell viewWithTag:1];
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
    if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nameInputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

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

#pragma mark - UIImagePicker Delegate Methods

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
    PFUser *user = [PFUser currentUser];
    
    if (self.userAvatar != nil)
    {
        NSData *selectedImage = UIImageJPEGRepresentation(self.userImage, 1);
        PFFile *imageFile = [PFFile fileWithName:@"image" data:selectedImage];
        [user setObject:imageFile forKey:@"userAvatar"];
    }

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){ NSLog(@"save user with new image success!"); }
    }];
}


@end

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
@property (weak, nonatomic) UIImage *userImage;
@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPCreateProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES]; // Carrys over from other VC's
    
    UIImage * buttonImage = [UIImage imageNamed:@"plusPhoto"];
    [self.photoButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    self.parseService = [HRPParseNetworkService sharedService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setImage:(UIImage *)image withCompletion:(void(^)())completion
{
    PFUser *currentUser = [PFUser currentUser];
    NSData *data = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            currentUser[@"userAvatar"] = imageFile;
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
    
    // If user sets an image remove the placeholder
    if (self.userPhoto)
    {
        [self.photoButton setBackgroundImage:nil forState:UIControlStateNormal];
        //self.userImage.images.alpha = 1;
    }
}

@end

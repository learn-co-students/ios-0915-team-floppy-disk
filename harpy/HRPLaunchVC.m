//
//  HRPLaunchVC.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLaunchVC.h"

@interface HRPLaunchVC ()

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoHeight;
@property (strong, nonatomic) SKSplashView *splashView;

@end

@implementation HRPLaunchVC

- (void)viewDidLoad {
    //[super viewDidLoad];
    NSLog(@"animation did happen");


    [self introSplash];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)introSplash {
    
    NSLog(@"animation did happen");

    CGFloat logoHeight = self.logo.frame.size.height;
    self.logoHeight.constant = logoHeight +  100;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:3.0
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}
@end

//
//  HRPLaunchVC.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLaunchVC.h"

@interface HRPLaunchVC ()

@property (strong, nonatomic) SKSplashView *splashView;

@end

@implementation HRPLaunchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

    [self introSplash];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)introSplash {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:imageView];

    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"harpy.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0.25098 green:0.6 blue:1.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeNone];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 3; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
}
@end

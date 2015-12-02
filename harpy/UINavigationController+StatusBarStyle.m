//
//  UINavigationController+StatusBarStyle.m
//  harpy
//
//  Created by Kiara Robles on 12/1/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "UINavigationController+StatusBarStyle.h"

@interface UINavigationController_StatusBarStyle ()

@end

@implementation UINavigationController_StatusBarStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

@end

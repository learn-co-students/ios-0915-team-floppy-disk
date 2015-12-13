//
//  UIColor+HRPColor.m
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "UIColor+HRPColor.h"

@implementation UIColor (HRPColor)

+ (instancetype)ironColor;
{
    return [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1];
}
+ (instancetype)crailColor;
{
    return [UIColor colorWithHue:0.01 saturation:0.51 brightness:0.63 alpha:1];
}
+ (instancetype)seanceColor;
{
    return [UIColor colorWithHue:0.8 saturation:0.59 brightness:0.46 alpha:1];
}
+ (instancetype)spyroDiscoDance;
{
    return [UIColor colorWithHue:0.56 saturation:0.94 brightness:1 alpha:1];
}

@end

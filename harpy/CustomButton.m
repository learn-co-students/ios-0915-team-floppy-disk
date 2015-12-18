//
//  UIButton+GoogleMapsPost.m
//  harpy
//
//  Created by Kiara Robles on 12/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "CustomButton.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomButton ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])){
        [self setupView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setupView];
}

# pragma mark - main

- (void)setupView
{
}

- (void)highlightView
{
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.layer.shadowOpacity = 0.25;
}

- (void)clearHighlightView {
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowOpacity = 0.5;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [self highlightView];
    } else {
        [self clearHighlightView];
    }
    [super setHighlighted:highlighted];
}




@end
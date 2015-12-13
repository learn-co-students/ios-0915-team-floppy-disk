//
//  HYPProfileVC.h
//  harpy
//
//  Created by Kiara Robles on 12/12/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface HYPProfileVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) PFUser *user;

@end

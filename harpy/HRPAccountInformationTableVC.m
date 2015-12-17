//
//  HRPAccountInformationTableVC.m
//  harpy
//
//  Created by Kiara Robles on 12/8/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPAccountInformationTableVC.h"
#import "HRPParseNetworkService.h"

@interface HRPAccountInformationTableVC ()

@property (strong, nonatomic) HRPParseNetworkService *parseService;

@end

@implementation HRPAccountInformationTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.title = @"ACCOUNT INFORMATION";
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.98 alpha:1];
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"emailHeaderCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"passwordHeaderCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"oldPasswordCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newPasswordCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"comfirmPasswordCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"spacyCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalCellView = self.view.frame.size.height * 0.768;
    CGFloat customTableCellHeight = totalCellView/10;
    
    if (indexPath.row == 0 || indexPath.row == 2)
    {
        customTableCellHeight = totalCellView/8;
    }
    if (indexPath.row == 6)
    {
        customTableCellHeight = totalCellView - (totalCellView/8*2 + totalCellView/10*4);
    }
    
    return customTableCellHeight;
}

@end

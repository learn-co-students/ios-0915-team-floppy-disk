//
//  HRPUserSearchTableVC.m
//  harpy
//
//  Created by Kiara Robles on 11/27/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPUserSearchTableVC.h"

@interface HRPUserSearchTableVC ()

@end

@implementation HRPUserSearchTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Users";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"username";
        
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        self.imageKey = @"userAvatar";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 7;
    }
    return self;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:self.textKey];
    cell.detailTextLabel.text = [NSString stringWithFormat:@" %@", [object objectForKey:@"username"]];
    
    cell.imageView.image = [UIImage imageNamed:@"image"];
    PFFile *imageFile = [object objectForKey:@"userAvatar"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        cell.imageView.image = [UIImage imageWithData:data];
    }];
     
    return cell;
}

@end

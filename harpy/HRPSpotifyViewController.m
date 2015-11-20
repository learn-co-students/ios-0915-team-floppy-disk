//
//  HRPSpotifyViewController.m
//  harpy
//
//  Created by Kiara Robles on 11/17/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPSpotifyViewController.h"
#import <Spotify/Spotify.h>
#import "HRPLoginRedirect.h"

@interface HRPSpotifyViewController () <SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation HRPSpotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[HRPLoginRedirect launchSpotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    self.firstLoad = YES;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

//segues to player if notification center revceives an update on renewed session
-(void)sessionUpdatedNotification:(NSNotification *)notification {
    //if (self.navigationController.topViewController == self) {
        SPTAuth *auth = [SPTAuth defaultInstance];
        if (auth.session && [auth.session isValid]) {
            
            
            [self performSegueWithIdentifier:@"playerSegue" sender:nil];
        //}
    }
}

//segue to player
-(void)showSegue {
    self.firstLoad = NO;
    [self performSegueWithIdentifier:@"playerSegue" sender:nil];
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error {
    
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session {
    //segue to initial app view
}

-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
}

-(void)openLogInPage {
    
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}

-(void)renewTokenAndSegue {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        [self showSegue];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"VIEW APPEARED");
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (auth.session == nil) {
        NSLog(@"entered first if statement");
        return;
    }
    
    if ([auth.session isValid] && self.firstLoad) {
        NSLog(@"entered second if statement");
        [self showSegue];
    }
    
    if (![auth.session isValid] && auth.hasTokenRefreshService) {
        NSLog(@"entered third if statement");

        [self renewTokenAndSegue];
    }
    
}
- (IBAction)logInClicked:(UIButton *)sender {
    [self openLogInPage];
}

@end

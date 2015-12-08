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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    self.firstLoad = YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"VIEW APPEARED");
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (auth.session == nil)
    {
        NSLog(@"entered first if statement");
        return;
    }
    
    if ([auth.session isValid] && self.firstLoad)
    {
        NSLog(@"entered second if statement");
        [self showSegue];
    }
    
    if (![auth.session isValid] && auth.hasTokenRefreshService)
    {
        NSLog(@"entered third if statement");
        [self renewTokenAndSegue];
    }
}

#pragma mark - Overrides

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Navigation

- (IBAction)logInClicked:(UIButton *)sender
{
    [self openLogInPage];
}
-(void)showSegue
{
    self.firstLoad = NO;
    [self performSegueWithIdentifier:@"playerSegue" sender:nil];
}
-(void)sessionUpdatedNotification:(NSNotification *)notification
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid])
    {
        [self performSegueWithIdentifier:@"playerSegue" sender:nil];
    }
}

#pragma mark - Spotify Authorization

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error
{
    
}
-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session
{
    
}
-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
    
}
-(void)openLogInPage
{
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}
-(void)renewTokenAndSegue
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        [self showSegue];
    }];
}


@end

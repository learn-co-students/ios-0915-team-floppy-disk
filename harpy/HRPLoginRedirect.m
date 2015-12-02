//
//  HRPLoginRedirect.m
//  harpy
//
//  Created by Kiara Robles on 11/18/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "HRPLoginRedirect.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import <SafariServices/SafariServices.h>

@implementation HRPLoginRedirect

#pragma mark - Spotify

+ (void)launchSpotifyFromViewController:(UIViewController *)presentingViewController
{    
    // Get API key from sharedApplication AppDelegate
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *redirectString = @"harpy-app://authorize";
    NSURL *redirectURL = [NSURL URLWithString:redirectString];
    NSString *spotifyClientId = appDelegate.spotifyClientId;
    
    // Spotify authentication
    [[SPTAuth defaultInstance] setClientID:spotifyClientId];
    [[SPTAuth defaultInstance] setRedirectURL:redirectURL];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];

    // OpenUrl: from sharedApplication AppDelegate
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:loginURL];
    [presentingViewController presentViewController:safariVC animated:YES completion:nil];
    
//    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
    
}

@end

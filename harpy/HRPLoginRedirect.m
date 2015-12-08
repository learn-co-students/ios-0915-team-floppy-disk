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
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthUserReadPrivateScope]];

    // OpenUrl: from sharedApplication AppDelegate
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:loginURL];
    [presentingViewController presentViewController:safariVC animated:YES completion:nil];
    
//    SPTAuth *auth = [SPTAuth defaultInstance];
//    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
//        // This is the callback that'll be triggered when auth is completed (or fails).
//        
//        if (error != nil)
//        {
//            NSLog(@"*** Auth error: %@", error);
//            return;
//        }
//        
//        
//        auth.session = session;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
//        
//    };
//    
//    if ([auth canHandleURL:loginURL])
//    {
//        [auth handleAuthCallbackWithTriggeredAuthURL:loginURL callback:authCallback];
//    }
    
//    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
    
}

@end

//
//  AppDelegate.m
//  harpy
//
//  Created by Kiara Robles on 11/16/15.
//  Copyright © 2015 teamFloppyDisk. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h> // Required for Spotify
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "HRPTrackCreator.h"
#import "HRPTrack.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName:
                                                                 [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]
                                                             }];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"backround_cropped"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTranslucent:NO];
    
    
    // Get API Key from key.plist (hidden by .gitignore)
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    
    // Google Keys
    NSString *googleMapAPIKey = [plistDictionary objectForKey:@"googleMapAPIKey"];
    [GMSServices provideAPIKey:googleMapAPIKey];
    
    // Spotify Keys
    NSString *spotifyClientId = [plistDictionary objectForKey:@"spotifyClientId"];
    self.spotifyClientId = spotifyClientId;
    NSString *spotifyClientSecret = [plistDictionary objectForKey:@"spotifyClientSecret"];

    // Parse Keys
    NSString *parseApplicationKey = [plistDictionary objectForKey:@"parseApplicationKey"];
    NSString *parseClientKey = [plistDictionary objectForKey:@"parseClientKey"];

    [Parse enableLocalDatastore];
    [Parse setApplicationId:parseApplicationKey
                  clientKey:parseClientKey];
    
    // Spotify Authorization Initializers
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = spotifyClientId;
    auth.requestedScopes = @[SPTAuthStreamingScope];
    auth.redirectURL = [NSURL URLWithString:@"harpy-app://authorize"];
    auth.tokenSwapURL = [NSURL URLWithString:@"https://ios-0915-floppy-disk.herokuapp.com/swap"];
    auth.tokenRefreshURL = [NSURL URLWithString:@"https://ios-0915-floppy-disk.herokuapp.com/refresh"];
    
    // Canonical username (currently Phils) needs to be saved so that different users can have persistent sessions
    auth.sessionUserDefaultsKey = @"125204578";
    
    
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
//    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
    // This is the callback that'll be triggered when auth is completed (or fails).
        
    if (error != nil)
    {
        NSLog(@"*** Auth error: %@", error);
        return;
    }
        
    auth.session = session;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    
    };
    
    if ([auth canHandleURL:url])
    {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    return NO;
    
    
}

@end

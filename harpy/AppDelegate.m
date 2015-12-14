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
#import "SKSplashView.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSFontAttributeName:
                                                                 [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]
                                                             }];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ [UIImagePickerController class] ]].translucent = YES;
    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[ [UIImagePickerController class] ]].tintColor = [UIColor whiteColor];
    

    NSLog(@"width is :%f",[[UIScreen mainScreen] bounds].size.width);
    
    if ([[UIScreen mainScreen] bounds].size.width == 375.0f)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background_cropped_6"] forBarMetrics:UIBarMetricsDefault];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 414.0f)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background_cropped_6s"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"backround_cropped"] forBarMetrics:UIBarMetricsDefault];
    }

    
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
    auth.requestedScopes = @[SPTAuthStreamingScope, SPTAuthUserReadPrivateScope];
    auth.redirectURL = [NSURL URLWithString:@"harpy-app://authorize"];
    auth.tokenSwapURL = [NSURL URLWithString:@"https://ios-0915-floppy-disk.herokuapp.com/swap"];
    auth.tokenRefreshURL = [NSURL URLWithString:@"https://ios-0915-floppy-disk.herokuapp.com/refresh"];
    NSLog(@"%@", auth.session.accessToken);
    [SPTUser requestCurrentUserWithAccessToken:auth.session.accessToken callback:^(NSError *error, id object) {
        NSLog(@"%@", object);
    }];
    PFUser *current = [PFUser currentUser];
    if (current != nil) {
        NSString *string = current[@"spotifyCanonical"];
        auth.sessionUserDefaultsKey = string;
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
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

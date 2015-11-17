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
@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Get API Key from key.plist (hidden by .gitignore)
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    
    NSString *googleMapAPIKey = [plistDictionary objectForKey:@"googleMapAPIKey"];
    NSLog(@"googleMapAPIKey: %@", googleMapAPIKey);
    [GMSServices provideAPIKey:googleMapAPIKey];
    
    NSString *spotifyClientId = [plistDictionary objectForKey:@"spotifyClientId"];
    NSLog(@"spotifyClientId: %@", spotifyClientId);
    NSString *spotifyClientSecret = [plistDictionary objectForKey:@"spotifyClientSecret"];
    NSLog(@"spotifyClientSecret: %@", spotifyClientSecret);

    NSString *parseApplicationKey = [plistDictionary objectForKey:@"parseApplicationKey"];
    NSLog(@"parseApplicationKey: %@", parseApplicationKey);
    NSString *parseClientKey = [plistDictionary objectForKey:@"parseClientKey"];
    NSLog(@"parseClientKey: %@", parseClientKey);
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"parseApplicationKey"
                  clientKey:@"parseClientKey"];
    
    return YES;
}

@end

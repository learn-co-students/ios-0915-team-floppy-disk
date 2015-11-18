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
#import "HRPTrackCreator.h"
#import "HRPTrack.h"

@import GoogleMaps;

@interface AppDelegate ()

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Get API Key from key.plist (hidden by .gitignore)
    NSLog(@"API KEYS FROM KEYS.PLIST");
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    
    NSString *googleMapAPIKey = [plistDictionary objectForKey:@"googleMapAPIKey"];
    NSLog(@"googleMapAPIKey: %@", googleMapAPIKey);
    [GMSServices provideAPIKey:googleMapAPIKey];
    
    NSString *spotifyClientId = [plistDictionary objectForKey:@"spotifyClientId"];
    self.spotifyClientId = spotifyClientId;
    NSLog(@"spotifyClientId: %@", self.spotifyClientId);
    NSString *spotifyClientSecret = [plistDictionary objectForKey:@"spotifyClientSecret"];
    NSLog(@"spotifyClientSecret: %@", spotifyClientSecret);

    NSString *parseApplicationKey = [plistDictionary objectForKey:@"parseApplicationKey"];
    NSLog(@"parseApplicationKey: %@", parseApplicationKey);
    NSString *parseClientKey = [plistDictionary objectForKey:@"parseClientKey"];
    NSLog(@"parseClientKey: %@", parseClientKey);
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"parseApplicationKey"
                  clientKey:@"parseClientKey"];
    NSLog(@"____________________________________");
    
    return YES;
}

@end

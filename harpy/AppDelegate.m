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
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (error != nil) {
                NSLog(@"***Auth Error: %@", error);
                return;
            }
            [self playUsingSession:session];
        }];
        return YES;
    }
    return NO;
}
-(void)playUsingSession:(SPTSession *)session {
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        NSURL *trackURI = [NSURL URLWithString:@"spotify:track:5veIeQ8tk07IlIp34NeI8s"];
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}


@end

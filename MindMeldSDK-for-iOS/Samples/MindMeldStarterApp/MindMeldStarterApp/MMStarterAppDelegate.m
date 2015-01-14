//
//  MMStarterAppDelegate.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMStarterAppDelegate.h"

#import <MindMeldSDK/MMEnvironment.h>
#import <MindMeldSDK/MMListener.h>

@interface MMStarterAppDelegate ()

@end

@implementation MMStarterAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    /*****
     *  (1)
     *  This method configures the audio session for a listener by setting the
     *  AVAudioSessionCategory to AVAudioSessionPlayAndRecord and activating the
     *  session. See the AVAudioSession documentation if you would like to manage
     *  the audio session differently.
     *****/
    [MMListener prepareAudioSession];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    /*****
     *  (2)
     *  Configure audio session when the app returns from the background.
     *****/
    [MMListener prepareAudioSession];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

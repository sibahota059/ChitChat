//
//  CGAppDelegate.m
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGAppDelegate.h"
#import "CGUserManager.h"
#import "CGPeer.h"
#import "CGUserDetailViewController.h"
#import "CGConstants.h"

@implementation CGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set Navigation Bar constants.
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearance] setBarTintColor:AppLightBlueColor()];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // CHeck if current peer is there or not.
    CGPeer *peer = [CGUserManager currentPeer];
    if (!peer.peerName) {
        UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CGUserDetailViewController* loginViewController = [mainstoryboard  instantiateViewControllerWithIdentifier:@"CGUserDetailViewController"];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:loginViewController animated:NO completion:NULL];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

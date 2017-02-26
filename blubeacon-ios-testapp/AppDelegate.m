//
//  AppDelegate.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 19/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "BLUBeaconDetailViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate{
    int beaconNo;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

    if ([splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    }

    splitViewController.delegate = self;

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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    if (![svc respondsToSelector:@selector(displayModeButtonItem)]) {
        UINavigationController *navigationController = [svc.viewControllers lastObject];
        UIViewController *detailViewController = [navigationController.viewControllers lastObject];
        detailViewController.navigationItem.leftBarButtonItem = barButtonItem;
    }
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if (![svc respondsToSelector:@selector(displayModeButtonItem)]) {
        UINavigationController *navigationController = [svc.viewControllers lastObject];
        UIViewController *detailViewController = [navigationController.viewControllers lastObject];
        detailViewController.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[BLUBeaconDetailViewController class]] && ([(BLUBeaconDetailViewController *)[(UINavigationController *)secondaryViewController topViewController] beacon] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end

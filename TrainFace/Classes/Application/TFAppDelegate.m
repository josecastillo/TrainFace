//
//  AppDelegate.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFAppDelegate.h"
#import "TFDetailViewController.h"
#import "UIImage+TFSubwayLine.h"
#import "TFLiveDataSource.h"

#import "Constants.h"

@interface TFAppDelegate ()

@end

@implementation TFAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserDefaultsKeyLines]) {
        NSArray *lines = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"A", @"C", @"E", @"B", @"D", @"F", @"M", @"G", @"J", @"Z", @"L", @"N", @"Q", @"R"];
        [defaults setObject:lines forKey:kUserDefaultsKeyLines];
        [defaults synchronize];
    }

    WCSession *session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // At minimum, refresh subway status every 15 minutes.
    [application setMinimumBackgroundFetchInterval:15*60];

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

#pragma mark - WCSession Delegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSString *command = message[@"command"];
    if ([command isEqualToString:@"RequestLineImages"]) {
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        NSArray *lines = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"A", @"C", @"E", @"B", @"D", @"F", @"M", @"G", @"J", @"Z", @"L", @"N", @"Q", @"R"];
        for (NSString *lineName in lines) {
            UIImage *lineImage = [UIImage imageForSubwayLine:lineName withSize:32];
            NSData *pngData = UIImagePNGRepresentation(lineImage);
            NSString *filename = [NSString stringWithFormat:@"%@.png", lineName];
            response[filename] = pngData;
        }
        replyHandler(@{@"images" : response});
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *oldTimestamp = [[TFLiveDataSource defaultSource] status][kLiveDataSourceKeyTimestamp];
    [[TFLiveDataSource defaultSource] refresh:^(NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
            return;
        }
        NSString *newTimestamp = [[TFLiveDataSource defaultSource] status][kLiveDataSourceKeyTimestamp];
        if ([newTimestamp isEqualToString:oldTimestamp]) {
            completionHandler(UIBackgroundFetchResultNoData);
        } else {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}

@end

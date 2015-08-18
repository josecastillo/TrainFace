//
//  ExtensionDelegate.m
//  TrainFaceWatchKitApp Extension
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "Constants.h"
#import <ClockKit/ClockKit.h>

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    WCSession *session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    self.session = session;
}

- (void)applicationDidBecomeActive {
    // If we don't have line images, fetch them from the host app now.
    NSURL *containerUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *testUrl = [[containerUrl URLByAppendingPathComponent:@"R"] URLByAppendingPathExtension:@"png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[testUrl path]]) {
        [self.session sendMessage:@{@"command" : @"RequestLineImages"}
                replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    NSDictionary *files = replyMessage[@"images"];
                    for (NSString *filename in files) {
                        NSData *imageData = files[filename];
                        NSURL *outputUrl = [containerUrl URLByAppendingPathComponent:filename];
                        [imageData writeToURL:outputUrl atomically:NO];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TFWDataUpdate" object:self];
                } errorHandler:nil];
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    NSDictionary *lines = applicationContext[kUserDefaultsKeyLines];
    NSDictionary *serviceStatus = applicationContext[kUserDefaultsKeyServiceStatus];
    [[NSUserDefaults standardUserDefaults] setObject:lines forKey:kUserDefaultsKeyLines];
    [[NSUserDefaults standardUserDefaults] setObject:serviceStatus forKey:kUserDefaultsKeyServiceStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TFWDataUpdate" object:self];
    for (CLKComplication *complication in [[CLKComplicationServer sharedInstance] activeComplications]) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:complication];
    }
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

@end

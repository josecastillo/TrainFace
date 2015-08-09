//
//  AppDelegate.h
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface TFAppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


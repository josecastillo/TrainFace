//
//  ExtensionDelegate.h
//  TrainFaceWatchKitApp Extension
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

typedef void (^TFWRefreshCompletionHandler)(BOOL newData);

@interface ExtensionDelegate : NSObject <WKExtensionDelegate, WCSessionDelegate>
@property (nonatomic, strong) WCSession *session;

- (void)refresh:(TFWRefreshCompletionHandler)completionHandler;

@end

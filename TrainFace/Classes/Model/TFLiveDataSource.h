//
//  TFLiveDataSource.h
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TFLiveDataSourceCompletionHandler)(NSError *error);

@interface TFLiveDataSource : NSObject

+ (instancetype)defaultSource;

- (void)refresh:(TFLiveDataSourceCompletionHandler)completionHandler;
- (NSDictionary *)status;

@end

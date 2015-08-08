//
//  TFLiveDataSource.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFLiveDataSource.h"

@implementation TFLiveDataSource

static TFLiveDataSource *instance;

+ (instancetype)defaultSource {
    if(!instance) {
        instance = [self new];
    }
    return instance;
}

- (NSDictionary *)status {
    return @{};
}

@end

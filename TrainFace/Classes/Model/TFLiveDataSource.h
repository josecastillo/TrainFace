//
//  TFLiveDataSource.h
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFLiveDataSource : NSObject

+ (instancetype)defaultSource;

- (NSDictionary *)status;

@end

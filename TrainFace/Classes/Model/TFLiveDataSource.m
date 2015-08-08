//
//  TFLiveDataSource.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFLiveDataSource.h"
#import "Constants.h"

@interface TFLiveDataSource ()
@property (nonatomic, strong) NSDictionary *systemStatus;
@end

@implementation TFLiveDataSource

static TFLiveDataSource *instance;

+ (instancetype)defaultSource {
    if(!instance) {
        instance = [self new];
    }
    return instance;
}

- (void)refresh:(TFLiveDataSourceCompletionHandler)completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *serviceUrl = [NSURL URLWithString:@"https://www.joeycastillo.com/trainbrain/current.json"];
    [[session dataTaskWithRequest:[NSURLRequest requestWithURL:serviceUrl]
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            completionHandler(error);
                        });
                        return;
                    }
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    if (!result) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            completionHandler(error);
                        });
                        return;
                    }
                    // The web service returns an array of line status object.
                    // For the app, we need the lines stored as key value pairs.
                    NSMutableDictionary *systemStatus = [NSMutableDictionary dictionary];
                    NSMutableDictionary *lines = [NSMutableDictionary dictionary];
                    for (NSDictionary *line in result[kLiveDataSourceKeyLines]) {
                        NSString *lineName = line[kLiveDataSourceKeyLine];
                        lines[lineName] = line;
                    }
                    systemStatus[kLiveDataSourceKeyTimestamp] = result[kLiveDataSourceKeyTimestamp];
                    systemStatus[kLiveDataSourceKeyLines] = [NSDictionary dictionaryWithDictionary:lines];
                    self.systemStatus = systemStatus;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        completionHandler(nil);
                    });
                }] resume];
}

- (NSDictionary *)status {
    return self.systemStatus;
}

@end

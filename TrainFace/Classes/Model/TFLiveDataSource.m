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
    return @{
             @"timestamp": @"8/8/2015 12:52:00 PM",
             @"lines":
                 @{
                     @"1" : @{@"line" : @"1", @"status": @"GOOD SERVICE",   @"alert" : @2},
                     @"2" : @{@"line" : @"2", @"status": @"SERVICE CHANGE", @"alert" : @4, @"detail_short" : @"Due to NYPD activity at Simpson St, southbound [2] and [5] trains are running express E 180 St to 149 St-Grand Concourse."},
                     @"3" : @{@"line" : @"3", @"status": @"GOOD SERVICE",   @"alert" : @2},
                     @"4" : @{@"line" : @"4", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"5" : @{@"line" : @"5", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"6" : @{@"line" : @"6", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"7" : @{@"line" : @"7", @"status": @"PLANNED WORK",   @"alert" : @3, @"detail_short" : @"[7] No trains between Queensboro Plaza and Times Sq-42 St[E] [F] [N] [S] trains and [SB] free shuttle buses provide alternate service"},
                     @"A" : @{@"line" : @"A", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"C" : @{@"line" : @"C", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"E" : @{@"line" : @"E", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"B" : @{@"line" : @"B", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"D" : @{@"line" : @"D", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"F" : @{@"line" : @"F", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"M" : @{@"line" : @"M", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"G" : @{@"line" : @"G", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"J" : @{@"line" : @"J", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"Z" : @{@"line" : @"Z", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"L" : @{@"line" : @"L", @"status": @"SUSPENDED",      @"alert" : @5, @"detail_short" : @"Due to FDNY activity at Broadway Junction, [L] train service is suspended in both directions."},
                     @"N" : @{@"line" : @"N", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"Q" : @{@"line" : @"Q", @"status": @"GOOD SERVICE",   @"alert" : @1},
                     @"R" : @{@"line" : @"R", @"status": @"GOOD SERVICE",   @"alert" : @1},
                 }
             };
}

@end

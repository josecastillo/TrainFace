//
//  ComplicationController.m
//  TrainFaceWatchKitApp Extension
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "ComplicationController.h"

#import "Constants.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Complication-specific logic

- (CLKComplicationTimelineEntry *)modularLargeEntryForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp {
    // Simplest case: If there's only one entry, and it's "Good Service", display "good service" indicator.
    if (([statusMessages count] == 1) && [[statusMessages anyObject] isEqualToString:@"GOOD SERVICE"]) {
        CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
        template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Service Status"];
        template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"All lines"];
        template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"OK"];
        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
        template.row2Column2TextProvider = [CLKTimeTextProvider textProviderWithDate:timestamp];

        return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
    }

    // Otherwise, there are disruptions in the system.
    // We want to prioritize bigger disruptions; this just makes sure the most severe things come first.
    NSMutableArray *sortedStatusMessages = [NSMutableArray arrayWithCapacity:2];
    if ([statusMessages containsObject:@"SUSPENDED"]) {
        [sortedStatusMessages addObject:@"SUSPENDED"];
    }
    if ([statusMessages containsObject:@"SERVICE CHANGE"]) {
        [sortedStatusMessages addObject:@"SERVICE CHANGE"];
    }
    if ([statusMessages containsObject:@"DELAYS"]) {
        [sortedStatusMessages addObject:@"DELAYS"];
    }
    if ([statusMessages containsObject:@"PLANNED WORK"]) {
        [sortedStatusMessages addObject:@"PLANNED WORK"];
    }

    // This dictionary maps status messages to their shortened counterparts.
    NSDictionary *shortStatusMessages = @{@"PLANNED WORK" : @"Work",
                                          @"DELAYS" : @"Delay",
                                          @"SUSPENDED" : @"Suspend",
                                          @"SERVICE CHANGE" : @"Change"};

    // If at this juncture, we only have one type of disruption, we can use the same template (one disruption, updated date).
    if ([sortedStatusMessages count] == 1) {
        NSString *statusMessage = [sortedStatusMessages firstObject];
        NSDictionary *lines = serviceStatus[kLiveDataSourceKeyLines];
        NSMutableString *trainsAffected = [NSMutableString string];
        for (NSString *lineName in [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyLines]) {
            if ([lines[lineName][kLiveDataSourceKeyStatus] isEqualToString:statusMessage]) {
                [trainsAffected appendString:lineName];
            }
        }
        CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
        template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Service Status"];
        template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:trainsAffected];
        template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:shortStatusMessages[statusMessage]];
        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
        template.row2Column2TextProvider = [CLKTimeTextProvider textProviderWithDate:timestamp];

        return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
    }

    // If we have two or more status messages, ditch the title line.
    if ([sortedStatusMessages count] >= 2) {
        NSDictionary *lines = serviceStatus[kLiveDataSourceKeyLines];
        NSMutableArray *trainsAffectedList = [NSMutableArray array];
        for (NSString *statusMessage in sortedStatusMessages) {
            NSMutableString *trainsAffected = [NSMutableString string];
            for (NSString *lineName in [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyLines]) {
                if ([lines[lineName][kLiveDataSourceKeyStatus] isEqualToString:statusMessage]) {
                    [trainsAffected appendString:lineName];
                }
            }
            [trainsAffectedList addObject:trainsAffected];
        }

        CLKComplicationTemplateModularLargeColumns *template = [[CLKComplicationTemplateModularLargeColumns alloc] init];
        template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:trainsAffectedList[0]];
        template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:shortStatusMessages[sortedStatusMessages[0]]];
        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:trainsAffectedList[1]];
        template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:shortStatusMessages[sortedStatusMessages[1]]];

        if ([sortedStatusMessages count] == 2) {
            // If we have exactly two disruptions, line 3 is the "updated" line.
            template.row3Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
            template.row3Column2TextProvider = [CLKTimeTextProvider textProviderWithDate:timestamp];
        } else if ([sortedStatusMessages count] == 3) {
            // If we have exactly three disruptions, line 3 is the third one.
            template.row3Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:trainsAffectedList[2]];
            template.row3Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:shortStatusMessages[sortedStatusMessages[3]]];
        } else {
            // If the system is well and truly messed, add a plus sign to the lines and indicate multiple issues.
            template.row3Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:[trainsAffectedList[2] stringByAppendingString:@"+"]];
            template.row3Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Issues"];
        }

        return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
    }
    return nil;
}

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate distantPast]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate distantFuture]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    NSDictionary *serviceStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyServiceStatus];

    // First off, translate the timestamp into a date for display.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"M/d/yyyy h:mm:ss a";
    NSDate *timestamp = [dateFormatter dateFromString:serviceStatus[kLiveDataSourceKeyTimestamp]];

    // There's some logic that goes into figuring out what template to display for a certain level of service disruption.
    // First we figure out how many unique status messages we have to display.
    NSCountedSet *statusMessages = [NSCountedSet set];
    NSDictionary *lines = serviceStatus[kLiveDataSourceKeyLines];
    for (NSString *lineName in lines) {
        [statusMessages addObject:lines[lineName][kLiveDataSourceKeyStatus]];
    }

    // Now we hand it off to complication-specific methods that figure out how to display what we know.
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge: {
            handler([self modularLargeEntryForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp]);
            return;
        default:
            break;
        }
    }
    handler(nil);
}


#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Request an update in an hour.
    handler([[NSDate date] dateByAddingTimeInterval:60 * 60]);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
        {
            CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
            template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Service Status"];
            template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"All lines"];
            template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"OK"];
            template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
            template.row2Column2TextProvider = [CLKTimeTextProvider textProviderWithDate:[NSDate date]];
            handler(template);
        }
            break;
        default:
            break;
    }
    handler(nil);
}

@end

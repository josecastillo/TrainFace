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
    CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
    // Simplest case: If there's only one entry, and it's "Good Service", display "good service" indicator.
    if (([statusMessages count] == 1) && [[statusMessages anyObject] isEqualToString:@"GOOD SERVICE"]) {
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

    NSDictionary *lines = serviceStatus[kLiveDataSourceKeyLines];
    
    NSMutableArray *trainsAffectedList = [NSMutableArray array];
    for (NSString *statusMessage in sortedStatusMessages) {
        NSMutableArray *trainsAffected = [NSMutableArray array];
        for (NSString *lineName in [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyLines]) {
            if ([lines[lineName][kLiveDataSourceKeyStatus] isEqualToString:statusMessage]) {
                [trainsAffected addObject:lineName];
            }
        }
        [trainsAffectedList addObject:trainsAffected];
    }
    
    // Row 1 will always be some affected trains.
    NSString *longTrainsAffected;
    NSString *shortTrainsAffected;
    NSString *accessibleTrainsAffected;
    NSString *statusMessage;
    NSString *accessibleStatusMessage;
    
    static NSUInteger maxLength = 8;
    
    longTrainsAffected = [trainsAffectedList[0] componentsJoinedByString:@""];
    if ([longTrainsAffected length] > maxLength) {
        shortTrainsAffected = [[longTrainsAffected substringToIndex:maxLength - 1] stringByAppendingString:@"+"];
    } else {
        shortTrainsAffected = longTrainsAffected;
    }
    accessibleTrainsAffected = [[trainsAffectedList[0] componentsJoinedByString:@", "] stringByAppendingString:@" trains"];
    statusMessage = shortStatusMessages[sortedStatusMessages[0]];
    accessibleStatusMessage = sortedStatusMessages[0];
    
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Service Status"];
    template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:shortTrainsAffected shortText:nil accessibilityLabel:accessibleTrainsAffected];
    template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:statusMessage];
    
    if ([trainsAffectedList count] == 1) {
        // If we only have one disruption line, make line 3 the last updated timestamp.
        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
        template.row2Column2TextProvider = [CLKTimeTextProvider textProviderWithDate:timestamp];
    } else if ([trainsAffectedList count] == 2) {
        // If we only have two disruption lines, make line 3 the last updated timestamp.
        longTrainsAffected = [trainsAffectedList[1] componentsJoinedByString:@""];
        if ([longTrainsAffected length] > maxLength) {
            shortTrainsAffected = [[longTrainsAffected substringToIndex:maxLength - 1] stringByAppendingString:@"+"];
        } else {
            shortTrainsAffected = longTrainsAffected;
        }
        accessibleTrainsAffected = [[trainsAffectedList[1] componentsJoinedByString:@", "] stringByAppendingString:@" trains"];
        statusMessage = shortStatusMessages[sortedStatusMessages[1]];
        accessibleStatusMessage = sortedStatusMessages[1];
        
        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:shortTrainsAffected shortText:nil accessibilityLabel:accessibleTrainsAffected];
        template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:statusMessage shortText:nil accessibilityLabel:accessibleStatusMessage];
    } else {
        // There are three or more lines affected; lump them all and say "Multiple Issues".
        NSMutableArray *remainingLines = [NSMutableArray array];
        for (NSArray *array in trainsAffectedList) {
            [remainingLines addObjectsFromArray:array];
        }
        
        // Sorted so the lines we care about are first.
        NSMutableArray *sortedTrainsAffected = [NSMutableArray array];
        for (NSString *lineName in [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyLines]) {
            if ([remainingLines containsObject:lineName]) {
                [sortedTrainsAffected addObject:lineName];
            }
        }
        
        // From here it's like we did before.
        longTrainsAffected = [sortedTrainsAffected componentsJoinedByString:@""];
        if ([longTrainsAffected length] > maxLength) {
            shortTrainsAffected = [[longTrainsAffected substringToIndex:maxLength - 1] stringByAppendingString:@"+"];
        } else {
            shortTrainsAffected = longTrainsAffected;
        }
        accessibleTrainsAffected = [[sortedTrainsAffected componentsJoinedByString:@", "] stringByAppendingString:@" trains"];
        statusMessage = @"Issues";
        accessibleStatusMessage = @"Multiple Issues";

        template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:shortTrainsAffected shortText:nil accessibilityLabel:accessibleTrainsAffected];
        template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:statusMessage shortText:nil accessibilityLabel:accessibleStatusMessage];
    }
    
    return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
}

- (CLKImageProvider *)imageProviderForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp complicationType:(CLKComplicationFamily)family {
    CLKImageProvider *retVal = nil;
    switch (family) {
        case CLKComplicationFamilyModularSmall:
            retVal = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Modular"]];
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            retVal = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
            break;
        case CLKComplicationFamilyCircularSmall:
            retVal = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Circular"]];
            break;
        default:
            return nil;
    }
    
    retVal.accessibilityLabel = @"Subway status";
    
    return retVal;
}

- (CLKTextProvider *)textProviderForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp complicationType:(CLKComplicationFamily)family {
    // If there's only one entry, and it's "Good Service", tell them everything's OK.
    if (([statusMessages count] == 1) && [[statusMessages anyObject] isEqualToString:@"GOOD SERVICE"]) {
        return [CLKSimpleTextProvider textProviderWithText:@"OK"];
    }
    
    NSMutableArray *trainsAffected = [NSMutableArray array];
    NSDictionary *lines = serviceStatus[kLiveDataSourceKeyLines];
    
    // Otherwise, we just want to show all affected lines in the user's defined order.
    for (NSString *lineName in [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyLines]) {
        if (![lines[lineName][kLiveDataSourceKeyStatus] isEqualToString:@"GOOD SERVICE"]) {
            [trainsAffected addObject:lineName];
        }
    }
    
    NSUInteger maxLength;
    switch (family) {
        case CLKComplicationFamilyModularSmall:
            maxLength = 6;
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            maxLength = 7;
            break;
        case CLKComplicationFamilyCircularSmall:
            maxLength = 3;
            break;
        default:
            maxLength = 5;
    }
    
    NSString *longTrainsAffected = [trainsAffected componentsJoinedByString:@""];
    NSString *shortTrainsAffected;
    if ([longTrainsAffected length] > maxLength) {
        shortTrainsAffected = [[longTrainsAffected substringToIndex:maxLength - 1] stringByAppendingString:@"+"];
    } else {
        shortTrainsAffected = longTrainsAffected;
    }
    NSString *accessibleTrainsAffected = [NSString stringWithFormat:@"Issues on %@ trains.", [trainsAffected componentsJoinedByString:@", "]];

    return [CLKSimpleTextProvider textProviderWithText:shortTrainsAffected shortText:nil accessibilityLabel:accessibleTrainsAffected];
}

- (CLKComplicationTimelineEntry *)modularSmallEntryForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp {
    CLKComplicationTemplateModularSmallStackImage *template = [[CLKComplicationTemplateModularSmallStackImage alloc] init];
    template.line1ImageProvider = [self imageProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyModularSmall];
    template.line2TextProvider = [self textProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyModularSmall];
    
    return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
}

- (CLKComplicationTimelineEntry *)circularSmallEntryForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp {
    CLKComplicationTemplateCircularSmallStackImage *template = [[CLKComplicationTemplateCircularSmallStackImage alloc] init];
    template.line1ImageProvider = [self imageProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyCircularSmall];
    template.line2TextProvider = [self textProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyCircularSmall];
    
    return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
}

- (CLKComplicationTimelineEntry *)utilitarianSmallEntryForStatus:(NSDictionary *)serviceStatus withMessages:(NSCountedSet *)statusMessages timestamp:(NSDate *)timestamp {
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.imageProvider = [self imageProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyUtilitarianSmall];
    template.textProvider = [self textProviderForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp complicationType:CLKComplicationFamilyUtilitarianSmall];
    
    return [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
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
        }
        case CLKComplicationFamilyModularSmall: {
            handler([self modularSmallEntryForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp]);
            return;
        }
        case CLKComplicationFamilyCircularSmall: {
            handler([self circularSmallEntryForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp]);
            return;
        }
        case CLKComplicationFamilyUtilitarianSmall: {
            handler([self utilitarianSmallEntryForStatus:serviceStatus withMessages:statusMessages timestamp:timestamp]);
            return;
        }
        default:
            break;
    }
    handler(nil);
}


#pragma mark Update Scheduling

- (void)requestedUpdateDidBegin {
    CLKComplicationServer *complicationServer = [CLKComplicationServer sharedInstance];
    for (CLKComplication *complication in complicationServer.activeComplications) {
        [complicationServer reloadTimelineForComplication:complication];
    }
}

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
            template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"No Data"];
            template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Updated"];
            template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Never"];
            handler(template);
        }
            break;
        case CLKComplicationFamilyModularSmall:
        {
            CLKComplicationTemplateModularSmallStackImage *template = [[CLKComplicationTemplateModularSmallStackImage alloc] init];
            template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Modular"]];
            template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"---"];
            handler(template);
        }
            break;
        case CLKComplicationFamilyUtilitarianSmall:
        {
            CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
            template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"-"];
            handler(template);
        }
            break;
        case CLKComplicationFamilyCircularSmall:
        {
            CLKComplicationTemplateCircularSmallStackImage *template = [[CLKComplicationTemplateCircularSmallStackImage alloc] init];
            template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Circular"]];
            template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"--"];
            handler(template);
        }
            break;
        default:
            break;
    }
    handler(nil);
}

@end

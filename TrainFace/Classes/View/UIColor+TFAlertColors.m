//
//  UIColor+TFAlertColors.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "UIColor+TFAlertColors.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (TFAlertColors)

// Based on the Homeland Security Advisory System colors
// Omitted: blue "Guarded" level (0x147BCE) and yellow "Elevated" level (0xF9DD00)

+ (UIColor *)colorForAlertLevel:(NSInteger)alert {
    switch (alert) {
        case 1:
        case 2:
            return UIColorFromRGB(0x00AC6B);
        case 3:
            return UIColorFromRGB(0xFF9600);
        case 4:
        case 5:
            return UIColorFromRGB(0xFF0020);
        default:
            return [UIColor blackColor];
    }
}

@end

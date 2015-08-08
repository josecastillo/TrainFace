//
//  UIImage+CircleImage.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "UIImage+TFSubwayLine.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIImage (TFSubwayLine)

+ (UIImage *)imageForSubwayLine:(NSString *)line withSize:(CGFloat)size {
    UIColor *color;

    // Determine color for circle based on MTA style guide: http://web.mta.info/developers/resources/line_colors.htm
    if ([@"123" containsString:line])
        color = UIColorFromRGB(0xEE352E);
    else if ([@"456" containsString:line])
        color = UIColorFromRGB(0x00933C);
    else if ([line isEqualToString:@"7"])
        color = UIColorFromRGB(0xB933AD);
    else if ([@"ACE" containsString:line])
        color = UIColorFromRGB(0x2850AD);
    else if ([@"BDFM" containsString:line])
        color = UIColorFromRGB(0xFF6319);
    else if ([@"JZ" containsString:line])
        color = UIColorFromRGB(0x996633);
    else if ([line isEqualToString:@"G"])
        color = UIColorFromRGB(0x6CBE45);
    else if ([line isEqualToString:@"L"])
        color = UIColorFromRGB(0xA7A9AC);
    else if ([@"NQR" containsString:line])
        color = UIColorFromRGB(0xFCCC0A);
    else
        color = [UIColor clearColor];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    // Draw the circle, inset by 10% of the input size
    CGFloat inset = floorf(size * 0.1f / 2.0f);
    CGRect rect = CGRectMake(0, 0, size, size);
    [color setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, inset, inset)] fill];

    // Set up text attributes. Note that NQR lines display the line name in black; all others are white.
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:size * .57];
    UIColor *textColor = [@"NQR" containsString:line] ? [UIColor blackColor] : [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : textColor,
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     };
    CGSize textSize = [line sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - textSize.height)/2.0f, rect.size.width, textSize.height);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [line drawInRect:textRect withAttributes:textAttributes];

    UIGraphicsPopContext();
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end

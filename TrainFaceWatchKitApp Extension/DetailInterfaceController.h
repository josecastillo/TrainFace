//
//  DetailInterfaceController.h
//  TrainFace
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface DetailInterfaceController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *detailLabel;

@property (nonatomic, strong) NSDictionary *trainStatus;

@end

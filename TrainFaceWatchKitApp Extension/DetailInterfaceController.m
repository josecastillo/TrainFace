//
//  DetailInterfaceController.m
//  TrainFace
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "DetailInterfaceController.h"
#import "Constants.h"
#import "UIColor+TFAlertColors.h"

@interface DetailInterfaceController ()

@end

@implementation DetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary *lineStatus = context;
    NSString *line = lineStatus[kLiveDataSourceKeyLine];
    NSURL *containerUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *imageUrl = [[containerUrl URLByAppendingPathComponent:line] URLByAppendingPathExtension:@"png"];

    self.statusLabel.text = lineStatus[kLiveDataSourceKeyStatus];
    self.statusLabel.textColor = [UIColor colorForAlertLevel:[lineStatus[kLiveDataSourceKeyAlertLevel] integerValue]];
    self.detailLabel.text = lineStatus[kLiveDataSourceKeyDetailShort];
    [self.imageView setImageData:[NSData dataWithContentsOfURL:imageUrl]];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end




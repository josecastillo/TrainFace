//
//  InterfaceController.m
//  TrainFaceWatchKitApp Extension
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "InterfaceController.h"
#import "TFWTrainRow.h"
#import "UIColor+TFAlertColors.h"

#import "Constants.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)refreshTable:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *lines = [defaults arrayForKey:kUserDefaultsKeyLines];
    NSURL *containerUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSDictionary *systemStatus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserDefaultsKeyServiceStatus];
    if (systemStatus) {
        [self.tableView setNumberOfRows:lines.count withRowType:kCellIdentifierDefault];
    } else {
        [self.tableView setNumberOfRows:0 withRowType:kCellIdentifierDefault];
    }

    for (int i = 0 ; i < self.tableView.numberOfRows ; i++) {
        NSString *line = lines[i];
        NSDictionary *lineStatus = systemStatus[kLiveDataSourceKeyLines][line];
        TFWTrainRow *row = [self.tableView rowControllerAtIndex:i];
        row.textLabel.text = lineStatus[kLiveDataSourceKeyStatus];
        row.textLabel.textColor = [UIColor colorForAlertLevel:[lineStatus[kLiveDataSourceKeyAlertLevel] integerValue]];
        NSURL *imageUrl = [[containerUrl URLByAppendingPathComponent:line] URLByAppendingPathExtension:@"png"];
        [row.imageView setImageData:[NSData dataWithContentsOfURL:imageUrl]];
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self refreshTable:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"TFWDataUpdate" object:nil];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TFWDataUpdate" object:nil];
    [super didDeactivate];
}

@end




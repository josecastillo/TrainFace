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
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSDictionary *systemStatus;
@end


@implementation InterfaceController

- (void)refreshTable:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lines = [defaults arrayForKey:kUserDefaultsKeyLines];
    NSURL *containerUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    
    self.systemStatus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserDefaultsKeyServiceStatus];
    if (self.systemStatus) {
        [self.tableView setNumberOfRows:self.lines.count withRowType:kCellIdentifierDefault];
    } else {
        [self.tableView setNumberOfRows:0 withRowType:kCellIdentifierDefault];
    }

    for (int i = 0 ; i < self.tableView.numberOfRows ; i++) {
        NSString *line = self.lines[i];
        NSDictionary *lineStatus = self.systemStatus[kLiveDataSourceKeyLines][line];
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

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    NSString *lineName = self.lines[rowIndex];
    return self.systemStatus[kLiveDataSourceKeyLines][lineName];
}

@end




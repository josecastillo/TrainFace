//
//  InterfaceController.m
//  TrainFaceWatchKitApp Extension
//
//  Created by Joey Castillo on 8/9/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "InterfaceController.h"
#import "TFWTrainRow.h"
#import "Constants.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    NSArray *lines = @[@"F", @"M", @"L"];
    
    [self.tableView setNumberOfRows:lines.count withRowType:kCellIdentifierDefault];
    for (int i = 0 ; i < self.tableView.numberOfRows ; i++) {
        TFWTrainRow *row = [self.tableView rowControllerAtIndex:i];
        row.textLabel.text = [NSString stringWithFormat:@"%@: SUSPENDED", lines[i]];
    }
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




//
//  MasterViewController.h
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFDetailViewController;

@interface TFMasterViewController : UITableViewController

@property (strong, nonatomic) TFDetailViewController *detailViewController;

@end


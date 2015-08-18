//
//  MasterViewController.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFMasterViewController.h"
#import "TFDetailViewController.h"
#import "TFLiveDataSource.h"
#import "UIImage+TFSubwayLine.h"
#import "UIColor+TFAlertColors.h"

#import "Constants.h"

@interface TFMasterViewController ()

@property (atomic, strong) NSMutableArray *lines;
@property (atomic, strong) NSDictionary *systemStatus;

@end

@implementation TFMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    timestampLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    timestampLabel.textAlignment = NSTextAlignmentCenter;
    self.toolbarItems = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:timestampLabel],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          ];
    self.timestampLabel = timestampLabel;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUI)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];

    [self refresh:self.navigationItem.rightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lines = [[defaults arrayForKey:kUserDefaultsKeyLines] mutableCopy];
    [self reloadUI];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadUI {
    self.systemStatus = [[TFLiveDataSource defaultSource] status];
    if (self.systemStatus) {
        self.timestampLabel.text = [NSString stringWithFormat:@"Updated: %@", self.systemStatus[kLiveDataSourceKeyTimestamp]];
    } else {
        self.timestampLabel.text = @"No data! Try refreshing.";
    }
    [self.tableView reloadData];
}

- (void)refresh:(UIBarButtonItem *)sender {
    [[TFLiveDataSource defaultSource] refresh:^(NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Refreshing Status"
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Try Again"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [self refresh:self.navigationItem.rightBarButtonItem];
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
        }

        [self reloadUI];
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kSegueShowLineDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *line = self.lines[indexPath.row];
        TFDetailViewController *controller = (TFDetailViewController *)[segue destinationViewController];
        [controller setDetailItem:self.systemStatus[kLiveDataSourceKeyLines][line]];
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *line = self.lines[sourceIndexPath.row];
    [self.lines removeObjectAtIndex:sourceIndexPath.row];
    [self.lines insertObject:line atIndex:destinationIndexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.lines forKey:kUserDefaultsKeyLines];
    [defaults synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.systemStatus ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierDefault forIndexPath:indexPath];
    
    NSString *line = self.lines[indexPath.row];
    NSDictionary *lineStatus = self.systemStatus[kLiveDataSourceKeyLines][line];
    cell.textLabel.text = lineStatus[kLiveDataSourceKeyStatus];
    cell.textLabel.textColor = [UIColor colorForAlertLevel:[lineStatus[@"alert"] integerValue]];
    
    cell.imageView.image = [UIImage imageForSubwayLine:line withSize:44];
    cell.imageView.accessibilityLabel = [line stringByAppendingString:@" Train"];
    return cell;
}

@end

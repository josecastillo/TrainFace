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
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = YES;
    [self refresh:self.navigationItem.rightBarButtonItem];
    self.lines = [[[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsKeyLines] mutableCopy];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(UIBarButtonItem *)sender {
    self.systemStatus = [[TFLiveDataSource defaultSource] status];
    [self.tableView reloadData];
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
    
    [[NSUserDefaults standardUserDefaults] setObject:self.lines forKey:kUserDefaultsKeyLines];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierDefault forIndexPath:indexPath];
    
    NSString *line = self.lines[indexPath.row];
    NSDictionary *lineStatus = self.systemStatus[kLiveDataSourceKeyLines][line];
    cell.textLabel.text = line;
    cell.detailTextLabel.text = lineStatus[kLiveDataSourceKeyStatus];
    return cell;
}

@end

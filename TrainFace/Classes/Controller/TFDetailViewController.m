//
//  DetailViewController.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFDetailViewController.h"

@interface TFDetailViewController ()

@end

@implementation TFDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
    
    [self configureView];
}

- (void)configureView {
    self.lineLabel.text = self.detailItem[@"line"];
    self.statusLabel.text = self.detailItem[@"status"];
    self.textView.text = self.detailItem[@"detail_short"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

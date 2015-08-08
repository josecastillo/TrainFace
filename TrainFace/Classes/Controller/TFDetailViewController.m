//
//  DetailViewController.m
//  TrainFace
//
//  Created by Joey Castillo on 8/8/15.
//  Copyright © 2015 Panchromatic, LLC. All rights reserved.
//

#import "TFDetailViewController.h"
#import "UIImage+TFSubwayLine.h"

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
    self.lineImageView.image = [UIImage imageForSubwayLine:self.detailItem[@"line"] withSize:100.0f];
    self.lineLabel.text = [self.detailItem[@"line"] stringByAppendingString:@" Train"];
    self.statusLabel.text = self.detailItem[@"status"];
    // FIXME: Text view is not scrolled to top when detail view appears. 
    self.textView.text = self.detailItem[@"detail"];
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

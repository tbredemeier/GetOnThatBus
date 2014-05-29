//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by tbredemeier on 5/28/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *routesLabel;
@property (strong, nonatomic) IBOutlet UILabel *transfersLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.name;
    self.addressLabel.text = self.address;
    self.routesLabel.text = self.routes;
    self.transfersLabel.text = self.transfers;
}

@end

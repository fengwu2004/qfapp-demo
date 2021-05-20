//
//  ViewController.m
//  qfapp-demo
//
//  Created by ky on 22/09/2017.
//  Copyright © 2017 yellfun. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import "ARMapViewController.h"
#import "TestCMViewController.h"
#import "OurdoorToIndoorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onEnter:(id)sender {
    
    MapViewController *vc = [[MapViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onARMap:(id)sender {
    
    ARMapViewController *vc = [ARMapViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onOutdoorToIndoor:(id)sender {
    
    OurdoorToIndoorViewController *vc = [OurdoorToIndoorViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTestSensor:(id)sender {
    
    TestCMViewController *vc = [TestCMViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
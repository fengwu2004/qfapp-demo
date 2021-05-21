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
#import "OurdoorToIndoorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//标准室内地图
- (IBAction)onEnter:(id)sender {
    
    MapViewController *vc = [[MapViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//AR室内地图
- (IBAction)onARMap:(id)sender {
    
    ARMapViewController *vc = [ARMapViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//室内外切换
- (IBAction)onOutdoorToIndoor:(id)sender {
    
    OurdoorToIndoorViewController *vc = [OurdoorToIndoorViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end

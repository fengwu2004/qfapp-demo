//
//  TestCMViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "TestCMViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface TestCMViewController ()

@property(nonatomic) CMMotionManager *cmMgr;
@property(nonatomic) NSOperationQueue *queue;

@end

@implementation TestCMViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupCoreMotion];
}

- (void)setupCoreMotion {
    
    _cmMgr = [[CMMotionManager alloc] init];
    
    _queue = [NSOperationQueue new];
    
    _cmMgr.gyroUpdateInterval = 0.2;
    
    __weak TestCMViewController *weakSelf = self;
    
    [_cmMgr startGyroUpdatesToQueue:_queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            
        [weakSelf updateGryoData:gyroData];
    }];
}

- (void)updateGryoData:(CMGyroData *)gyroData {
    
    CMRotationRate acc = gyroData.rotationRate;
    
    NSLog(@"%f", acc.x);
}

- (void)dealloc {
    
    [_cmMgr stopGyroUpdates];
}

@end

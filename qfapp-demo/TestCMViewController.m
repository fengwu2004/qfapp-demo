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
    
    _cmMgr.accelerometerUpdateInterval = 1.0/30.0;
    
    [_cmMgr startAccelerometerUpdatesToQueue:_queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
        [self updateAccelerometerData:accelerometerData];
    }];
}

- (void)updateAccelerometerData:(CMAccelerometerData *)accelerometerData {
    
    CMAcceleration acc = accelerometerData.acceleration;
    
    NSLog(@"%f, %f, %f", acc.x, acc.y, acc.z);
}

@end

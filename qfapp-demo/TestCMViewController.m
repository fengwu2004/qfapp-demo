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
    
    _cmMgr.deviceMotionUpdateInterval = 0.5;
    
    __weak TestCMViewController *weakSelf = self;
    
    [_cmMgr startDeviceMotionUpdatesToQueue:_queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
        [weakSelf updatMotion:motion];
    }];
}

- (void)updatMotion:(CMDeviceMotion *)motion {
    
    NSLog(@"yaw = %f, pitch = %f, roll = %f", motion.attitude.yaw * 180/M_PI, motion.attitude.pitch * 180/M_PI, motion.attitude.roll * 180/M_PI);
}

- (void)dealloc {
    
    [_cmMgr stopDeviceMotionUpdates];
}

@end

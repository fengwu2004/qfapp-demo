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
@property(nonatomic) IBOutlet UILabel *yaw;
@property(nonatomic) IBOutlet UILabel *pitch;
@property(nonatomic) IBOutlet UILabel *roll;
@property(nonatomic) IBOutlet UILabel *heading;

@end

@implementation TestCMViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupCoreMotion];
}

- (void)setupCoreMotion {
    
    _cmMgr = [[CMMotionManager alloc] init];
    
    _queue = [NSOperationQueue new];
    
    _cmMgr.deviceMotionUpdateInterval = 0.05;
    
    __weak TestCMViewController *weakSelf = self;
    
    [_cmMgr startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:_queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf updatMotion:motion];
        });
    }];
    
//    [_cmMgr startDeviceMotionUpdatesToQueue:_queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//    
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            [weakSelf updatMotion:motion];
//        });
//    }];
}

- (void)updatMotion:(CMDeviceMotion *)motion {
    
    _yaw.text = [NSString stringWithFormat:@"%.2f", fmod(270 - motion.attitude.yaw * 180/M_PI, 360)];
    
    _pitch.text = [NSString stringWithFormat:@"%.2f", motion.attitude.pitch * 180/M_PI];
    
    _roll.text = [NSString stringWithFormat:@"%.2f", motion.attitude.roll * 180/M_PI];
    
    _heading.text = [NSString stringWithFormat:@"%.2f", motion.heading];
    
//    NSLog(@"yaw = %f, pitch = %f, roll = %f", motion.attitude.yaw * 180/M_PI, motion.attitude.pitch * 180/M_PI, motion.attitude.roll * 180/M_PI);
}

- (void)dealloc {
    
    [_cmMgr stopDeviceMotionUpdates];
}

@end

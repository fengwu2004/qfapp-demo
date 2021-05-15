//
//  TestVideoCaptureViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "TestVideoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TestVideoCaptureViewController ()

@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic) AVCaptureDeviceInput *videoInput;
@property(nonatomic) AVCaptureSession *session;

@end

@implementation TestVideoCaptureViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubviews];
}

- (void)setupSubviews {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    
    _session = [[AVCaptureSession alloc] init];
    
    [_session addInput:_videoInput];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    _previewLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    [self.view.layer addSublayer:_previewLayer];
    
    [_session startRunning];
}

- (void)dealloc {
    
    [_session stopRunning];
}


@end

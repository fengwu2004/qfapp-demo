//
//  TestARViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "TestARViewController.h"
#import <WebKit/WebKit.h>
#import "IDRBaseLocationServer.h"
#import <AVFoundation/AVFoundation.h>

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]


@interface TestARViewController ()

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;
@property(nonatomic) NSTimer *timer;

@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic) AVCaptureDeviceInput *videoInput;
@property(nonatomic) AVCaptureSession *session;

@end

@implementation TestARViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];

    [self setupPreview];
    
    [self setupWebview];
    
//    [self startTestBeacons];
}

- (void)setupWebview {
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    _webView.backgroundColor = UIColor.clearColor;
    
    [self.view addSubview:_webView];

    [self setup];
}

- (void)setupPreview {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    
    _session = [[AVCaptureSession alloc] init];
    
    [_session addInput:_videoInput];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    _previewLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    [self.view.layer addSublayer:_previewLayer];
    
    [_session startRunning];
}

- (void)setup {

    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfzar/?&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    [_webView loadRequest:request];

//    _locateServer = [[IDRBaseLocationServer alloc] init];
//
//    [_locateServer setBeaconUUID:@[@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]];
//
//    _locateServer.delegate = self;
//
//    [_locateServer startUpdateBeacons];
}

- (NSString *)createTestBeacons {
    
    NSMutableArray *beacons = [NSMutableArray new];
    
    for (NSInteger i = 9011; i < 9016; ++i) {
        
        NSString *major = [NSString stringWithFormat:@"16161"];
        
        NSString *minor = [NSString stringWithFormat:@"%ld", i];
        
        NSString *rss = [NSString stringWithFormat:@"-70"];
        
        NSString *accuracy = [NSString stringWithFormat:@"%.2f", 6.9];
        
        if (!major || !minor || !rss || !accuracy) {
            
            NSLog(@"error");
        }
        
        NSDictionary *beaconDict = [[NSDictionary alloc] initWithObjects:@[major, rss, minor, accuracy] forKeys:@[@"major",@"rssi",@"minor",@"accuracy"]];
        
        [beacons addObject:beaconDict];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:beacons options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

- (void)startTestBeacons {
    
    __weak TestARViewController *weakSelf = self;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSString *beacons = [weakSelf createTestBeacons];
        
        [weakSelf didGetRangeBeacons:beacons];
    }];
}

#pragma mark IDRBaseLocationServerDelegate

- (void)didGetRangeBeacons:(NSString*)beaconsStr {
  
    if (beaconsStr) {

        NSString *js = [NSString stringWithFormat:@"doLocate(%@)", beaconsStr];

        [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
          
          NSLog(@"定位成功");
        }];
    }
}

- (void)dealloc {
  
    [_locateServer stopUpdateBeacons];
    
    [_timer invalidate];
}
@end

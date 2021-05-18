//
//  ARMapViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "ARMapViewController.h"
#import <WebKit/WebKit.h>
#import "IDRBaseLocationServer.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>
#import "Masonry/Masonry.h"
#import "YYWeakProxy.h"
#import "RequestSensorPermission_JS.h"

#define MyJSInterface @"MyJSInterface"
#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface ARMapViewController () <IDRBaseLocationServerDelegate, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;
@property(nonatomic) NSTimer *timer;

@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic) AVCaptureDeviceInput *videoInput;
@property(nonatomic) AVCaptureSession *session;

@end

@implementation ARMapViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];
    
    [self setupPreview];

    [self setupWebview];
}

- (void)setupPreview {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    
    _session = [[AVCaptureSession alloc] init];
    
    [_session addInput:_videoInput];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    _previewLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    [self.view.layer addSublayer:_previewLayer];
}

- (void)setupWebview {
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    
    WKUserContentController *userContentController = [WKUserContentController new];
    
    id target = [YYWeakProxy proxyWithTarget:self];
        
    [userContentController addScriptMessageHandler:target name:MyJSInterface];
    
    config.userContentController = userContentController;
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    CGRect rect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    _webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    
    _webView.backgroundColor = UIColor.clearColor;

    _webView.opaque = NO;
    
    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.right.mas_equalTo(self.view);
        
        make.top.equalTo(self.view.mas_topMargin);
        
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfzar/?&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    _webView.navigationDelegate = self;
    
    _webView.UIDelegate = self;

    [_webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self startLocate];
    
    [self startTestBeacons];
    
    [webView evaluateJavaScript:RequestSensorPermission_js() completionHandler:^(id _Nullable, NSError * _Nullable error) {
            
        NSLog(@"运行成功");
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if (![message.name isEqual:MyJSInterface]) {
        
        return;
    }
    
    NSString *functionName = message.body[@"functionName"];
    
    if ([functionName isEqual:@"startAR"]) {
        
        [self onStartAR];
        
        return;
    }
    
    if ([functionName isEqual:@"stopAR"]) {
        
        [self onStopAR];
        
        return;
    }
}

- (void)onStartAR {
    
    [_session startRunning];
}

- (void)onStopAR {
    
    [_session stopRunning];
}

- (void)startLocate {
    
    if (_locateServer) {
        
        return;
    }

    _locateServer = [[IDRBaseLocationServer alloc] init];

    [_locateServer setBeaconUUID:@[@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]];

    _locateServer.delegate = self;

    [_locateServer start];
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
    
    __weak ARMapViewController *weakSelf = self;
    
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

- (void)didGetEuler:(double)yaw pitch:(double)pitch roll:(double)roll {
    
    NSString *js = [NSString stringWithFormat:@"updateEuler(%f, %f, %f)", M_PI - yaw, -1 * pitch, roll];

    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
      
      NSLog(@"更新欧拉角成功");
    }];
}

- (void)dealloc {
  
    [_locateServer stop];
    
    [_session stopRunning];
    
    [_timer invalidate];
}

@end

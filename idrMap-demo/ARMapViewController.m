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
#import <Masonry/Masonry.h>
#import "YYWeakProxy.h"

#define MyJSInterface @"MyJSInterface"
#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface ARMapViewController () <IDRBaseLocationServerDelegate, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;

@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic) AVCaptureDeviceInput *videoInput;
@property(nonatomic) AVCaptureSession *session;

@property(nonatomic) BOOL arStarted;

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
    
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    CGRect rect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    _webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    
    _webView.backgroundColor = UIColor.clearColor;

    _webView.opaque = NO;
    
    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.bottom.left.right.mas_equalTo(self.view);
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
    
    [_previewLayer setHidden:NO];
    
    _arStarted = YES;
}

- (void)onStopAR {
    
    [_session stopRunning];
    
    [_previewLayer setHidden:YES];
    
    _arStarted = NO;
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
    
    if (_arStarted) {
        
        NSString *js = [NSString stringWithFormat:@"updateEuler(%f, %f, %f)", yaw, -1 * pitch, roll];

        [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
          
          NSLog(@"更新欧拉角成功");
        }];
    }
    else {
        
        NSString *js = [NSString stringWithFormat:@"updateDeviceAlphaDeg(%f)", yaw * 180/M_PI];

        [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
          
          NSLog(@"更新方向角成功");
        }];
    }
}

- (void)dealloc {
  
    [_locateServer stop];
    
    [_session stopRunning];
}

@end

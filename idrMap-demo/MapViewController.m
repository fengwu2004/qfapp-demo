//
//  MapViewController.m
//  qfapp-demo
//
//  Created by ky on 22/09/2017.
//  Copyright © 2017 yellfun. All rights reserved.
//

#import "MapViewController.h"
#import <WebKit/WebKit.h>
#import "IDRBaseLocationServer.h"
#import <Masonry/Masonry.h>

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface MapViewController () <IDRBaseLocationServerDelegate, WKNavigationDelegate, WKUIDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;

@end

@implementation MapViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];

    [self setupWebview];
}

- (void)setupWebview {
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:config];

    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.bottom.left.right.mas_equalTo(self.view);
    }];
  
    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfz2/?regionId=16194197598672889&startCarNav=0&unitName=670&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    _webView.navigationDelegate = self;
    
    _webView.UIDelegate = self;

    [_webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    //开启定位
    if (!_locateServer) {
        
        _locateServer = [[IDRBaseLocationServer alloc] init];
    }

    _locateServer.delegate = self;
    
    [_locateServer setBeaconUUID:@[@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]];

    [_locateServer start];
}

#pragma mark IDRBaseLocationServerDelegate

//定位回调
- (void)didGetRangeBeacons:(NSString*)beaconsStr {
  
    if (beaconsStr) {

        NSString *js = [NSString stringWithFormat:@"doLocate(%@)", beaconsStr];

        [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
          
          NSLog(@"定位成功");
        }];
    }
}

- (void)didGetEuler:(double)yaw pitch:(double)pitch roll:(double)roll {
    
    NSString *js = [NSString stringWithFormat:@"updateDeviceAlphaDeg(%f)", yaw * 180/M_PI];

    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
      
      NSLog(@"更新方向角成功");
    }];
}

#pragma mark IDRBaseLocationServerDelegate --end

- (void)dealloc {
  
    [_locateServer stop];
}


@end

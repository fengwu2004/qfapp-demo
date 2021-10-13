//
//  MapViewController.m
//  qfapp-demo
//
//  Created by ky on 22/09/2017.
//  Copyright © 2017 yellfun. All rights reserved.
//

#import "MapViewController.h"
#import<WebKit/WebKit.h>
#import "IDRBaseLocationServer.h"
#import "Masonry/Masonry.h"
#import "EBAppStorePay.h"

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface MapViewController () <IDRBaseLocationServerDelegate, WKNavigationDelegate, WKUIDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;
@property(nonatomic) UIButton *openAR;
@property(nonatomic) EBAppStorePay *pay;

@end

@implementation MapViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];
    
    _pay = [[EBAppStorePay alloc] init];

    [self setupWebview];
    
    [self setupButs];
}

- (void)setupButs {
    
    _openAR = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 60, 60)];
    
    _openAR.layer.cornerRadius = 3;
    
    [_openAR setTitle:@"AR" forState:UIControlStateNormal];
    
    [_openAR setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    
    _openAR.layer.borderWidth = 1;
    
    _openAR.layer.borderColor = UIColor.blueColor.CGColor;
    
    [_openAR addTarget:self action:@selector(doOpenAR) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_openAR];
}

- (void)doOpenAR {
    
    [_pay startBuyToAppStore:@"fiveyuanartest"];
}

- (void)setupWebview {
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:config];

    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.right.mas_equalTo(self.view);
        
        make.top.equalTo(self.view.mas_topMargin);
        
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
  
    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfz2/?regionId=16194197598672889&startCarNav=0&unitName=670&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    _webView.navigationDelegate = self;
    
    _webView.UIDelegate = self;

    [_webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    //js获取运动传感器权限
    [webView evaluateJavaScript:RequestSensorPermission_js() completionHandler:^(id obj, NSError * error) {
            
        NSLog(@"运行成功");
    }];
    
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

#pragma mark IDRBaseLocationServerDelegate --end



- (void)dealloc {
  
    [_locateServer stop];
}


@end

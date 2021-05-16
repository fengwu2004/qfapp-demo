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

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface MapViewController () <IDRBaseLocationServerDelegate, WKNavigationDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;

@end

@implementation MapViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];

    [self setupWebview];
}

- (void)setupWebview {
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.right.mas_equalTo(self.view);
        
        make.top.equalTo(self.view.mas_topMargin);
        
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
  
    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/hnav3.3/?regionId=16194197598672889&unitName=670&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    _webView.navigationDelegate = self;

    [_webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    if (!_locateServer) {
        
        _locateServer = [[IDRBaseLocationServer alloc] init];
    }

    _locateServer.delegate = self;
    
    [_locateServer setBeaconUUID:@[@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]];

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

#pragma mark IDRBaseLocationServerDelegate --end

- (void)dealloc {
  
    [_locateServer stop];
}


@end

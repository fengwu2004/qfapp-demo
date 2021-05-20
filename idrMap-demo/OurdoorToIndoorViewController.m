//
//  OurdoorToIndoorViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/18.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "OurdoorToIndoorViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "IDRBaseLocationServer.h"
#import "Masonry/Masonry.h"
#import<WebKit/WebKit.h>

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface OurdoorToIndoorViewController () <AMapNaviCompositeManagerDelegate, WKNavigationDelegate, WKUIDelegate, IDRBaseLocationServerDelegate>

@property(nonatomic) AMapNaviCompositeManager *compositeManager;
@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;

@end

@implementation OurdoorToIndoorViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.compositeManager = [[AMapNaviCompositeManager alloc] init];
    
    self.compositeManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startNavi];
}

- (void)startNavi {
    
    AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];
    //传入终点坐标
    [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:26.6454 longitude:106.647334] name:nil POIId:nil];
    
    [config setStartNaviDirectly:YES];
    //启动
    [self.compositeManager presentRoutePlanViewControllerWithOptions:config];
}

- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager didArrivedDestination:(AMapNaviMode)naviMode {
    
    [self.compositeManager dismissWithAnimated:YES];
    
    [self setupWebview];
}

- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager didBackwardAction:(AMapNaviCompositeVCBackwardActionType)backwardActionType {
    
    [self setupWebview];
}

- (void)setupWebview {
    
    if (_webView) {
        
        return;
    }
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:config];

    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.right.mas_equalTo(self.view);
        
        make.top.equalTo(self.view.mas_topMargin);
        
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfz2/?regionId=16194197598672889&startCarNav=30&unitName=670&uuid=%@", PhoneUUID];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    _webView.navigationDelegate = self;
    
    _webView.UIDelegate = self;

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

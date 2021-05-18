//
//  TestWKViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "TestWKViewController.h"
#import <WebKit/WebKit.h>
#import "RequestSensorPermission_JS.h"

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface TestWKViewController () <WKUIDelegate, WKNavigationDelegate>

@property(nonatomic) WKWebView *webView;
@end

@implementation TestWKViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    
    redView.backgroundColor = UIColor.redColor;
    
    [self.view addSubview:redView];

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    _webView.UIDelegate = self;

    [self.view addSubview:_webView];

    NSString *urlStr = [NSString stringWithFormat:@"https://wx.indoorun.com/ya/ysfzar/"];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    [_webView loadRequest:request];
    
    _webView.navigationDelegate = self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [webView evaluateJavaScript:RequestSensorPermission_js() completionHandler:^(id _Nullable, NSError * _Nullable error) {
            
        NSLog(@"运行成功");
    }];
}

@end

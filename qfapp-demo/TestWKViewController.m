//
//  TestWKViewController.m
//  qfapp-demo
//
//  Created by li on 2021/5/15.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import "TestWKViewController.h"
#import <WebKit/WebKit.h>

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface TestWKViewController ()

@property(nonatomic) WKWebView *webView;
@end

@implementation TestWKViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    
    redView.backgroundColor = UIColor.redColor;
    
    [self.view addSubview:redView];

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

    _webView.backgroundColor = UIColor.clearColor;

    _webView.opaque = NO;
    
    _webView.scrollView.backgroundColor = UIColor.clearColor;

    [self.view addSubview:_webView];

    NSString *regionId = @"14461702595360009";

    NSString *urlStr = [NSString stringWithFormat:@"http://wx.indoorun.com/indoorun/app/parking/webapp/index.html?uuid=%@&regionId=%@", PhoneUUID, regionId];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    [_webView loadRequest:request];
}

@end

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

#define PhoneUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@interface MapViewController () <IDRBaseLocationServerDelegate>

@property(nonatomic) WKWebView *webView;
@property(nonatomic) IDRBaseLocationServer *locateServer;

@end

@implementation MapViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

    [self.view addSubview:_webView];

    [self setup];
}

- (void)setup {
  
    NSString *regionId = @"14461702595360009";

    NSString *urlStr = [NSString stringWithFormat:@"http://wx.indoorun.com/indoorun/app/parking/webapp/index.html?uuid=%@&regionId=%@", PhoneUUID, regionId];

    NSURL *url = [[NSURL alloc] initWithString:urlStr];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    [_webView loadRequest:request];

    _locateServer = [[IDRBaseLocationServer alloc] init];

    _locateServer.delegate = self;
    
    [_locateServer setBeaconUUID:@[@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]];

    [_locateServer start];

    [_locateServer startUpdateBeacons];
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

- (void)didGetEuler:(double)x y:(double)y z:(double)z {
    
    NSString *js = [NSString stringWithFormat:@"updateEuler(%f, %f, %f)", x, y, z];

    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
      
      NSLog(@"更新欧拉角成功");
    }];
}

#pragma mark IDRBaseLocationServerDelegate --end

- (void)dealloc {
  
    [_locateServer stopUpdateBeacons];
}


@end

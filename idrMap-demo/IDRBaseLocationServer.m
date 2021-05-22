//
//  YFBeaconManager.m
//  YFMapKit
//
//  Created by Sincere on 16/1/20.
//  Copyright © 2016年 Sincere. All rights reserved.
//

#import "IDRBaseLocationServer.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface IDRBaseLocationServer ()<CLLocationManagerDelegate>

@property (nonatomic, retain) NSArray *uuidStrings;

@property (nonatomic, retain) NSMutableArray<CLBeaconRegion *> *beaconRegions;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL isReceiveBeacons;

@property (nonatomic, retain) CLHeading *heading;

@property (nonatomic) NSTimer *beaconsUpdateTimer;

@property (nonatomic) NSMutableArray *beacons;

@property(nonatomic) CMMotionManager *cmMgr;

@property(nonatomic) NSOperationQueue *queue;

@end

@implementation IDRBaseLocationServer

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
        
        _locationManager.headingFilter = 5;
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    return self;
}

- (void)setBeaconUUID:(NSArray*)uuidStrings {
    
    [self stopUpdateBeacons];
    
    self.uuidStrings = uuidStrings;
    
    _beaconRegions = [[NSMutableArray alloc] init];
    
    [self configureManagers];
}

- (void)startCoreMotion {
    
    if (![self.delegate respondsToSelector:@selector(didGetEuler:pitch:roll:)]) {
        
        return;
    }
    
    _cmMgr = [[CMMotionManager alloc] init];
    
    _queue = [NSOperationQueue new];
    
    _cmMgr.deviceMotionUpdateInterval = 1.0/30.0;
    
    __weak IDRBaseLocationServer *weakSelf = self;
    
    [_cmMgr startDeviceMotionUpdatesToQueue:_queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        
        [weakSelf updatMotion:motion];
    }];
}

- (void)updatMotion:(CMDeviceMotion *)motionData {
    
    double roll = motionData.attitude.roll;
    
    double pitch = motionData.attitude.pitch;
    
    double yaw = fmod(1.5 * M_PI - motionData.attitude.yaw, 2 * M_PI);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(didGetEuler:pitch:roll:)]) {
            
            [self.delegate didGetEuler:yaw pitch:pitch roll:roll];
        }
    });
}


#pragma mark - 开启服务配置

-(void)configureManagers {
    
    for (NSString *uuidString in _uuidStrings) {
        
        if (uuidString.length != 36) {
            
            continue;
        }
        
        NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        
        if (!beaconRegion) {
            
            continue;
        }
        
        [_beaconRegions addObject:beaconRegion];
    }
}

#pragma mark - 开始获取蓝牙信息

- (void)start {
    
    [self startUpdateBeacons];
    
    [self startCoreMotion];
}

- (void)stop {
    
    [self stopUpdateBeacons];
    
    [self stopCoreMotion];
}

- (void)stopCoreMotion {
    
    [_cmMgr stopDeviceMotionUpdates];
}

- (void)startUpdateBeacons {
    
    for (CLBeaconRegion *beaconRegion in _beaconRegions) {
        
        [_locationManager startRangingBeaconsInRegion:beaconRegion];
    }
    
    __weak IDRBaseLocationServer *weakSelf = self;
    
    _beaconsUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [weakSelf onUpdateBeacons];
    }];
    
    [_beaconsUpdateTimer fire];
    
    _beacons = [[NSMutableArray alloc] init];
}

- (void)onUpdateBeacons {
    
    @synchronized (_beacons) {
        
        if ([self.delegate respondsToSelector:@selector(didGetRangeBeacons:)]) {
            
            NSArray *array = [_beacons copy];
            
            if (array.count > 0) {
                
                NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                [self.delegate didGetRangeBeacons:str];
            }
        }
        
        [_beacons removeAllObjects];
    }
}

#pragma mark - 停止获取蓝牙信息
- (void)stopUpdateBeacons {
    
    for (CLBeaconRegion *beaconRegion in _beaconRegions) {
        
        [_locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
    
    [_beaconsUpdateTimer invalidate];
    
    _beaconsUpdateTimer = nil;
    
    [_beacons removeAllObjects];
}

#pragma mark - 蓝牙定位实时回调
-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region {
    
    if (!_isReceiveBeacons) {
        
        _isReceiveBeacons = YES;
    }
    
    id data = [[self class]getBeaconsJSON:beacons];
    
    if (data) {
        
        [_beacons addObjectsFromArray:data];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    _heading = newHeading;
}

#pragma mark - 定位权限变化判断
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            
            NSLog(@"定位服务未开启");
            
            _isLocationAvailable = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationOff" object:nil];
        }
            break;
        default:
        {
            NSLog(@"定位服务开启");
            
            _isLocationAvailable = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationOn" object:nil];
        }
            break;
    }
}

+ (NSArray*)getBeaconsJSON:(NSArray *)beacons
{
    @synchronized(beacons)
    {
        NSMutableArray * aBeacons = [NSMutableArray array];
        
        NSArray * temp = [beacons copy];
        
        for (CLBeacon * beacon in temp)
        {
            NSDictionary *data = [[self class] createBeaconsDict:beacon];
            
            if (data) {
                
                [aBeacons addObject:data];
            }
        }
        
        return aBeacons;
    }
}

//处理解析蓝牙数据
+ (NSDictionary*)createBeaconsDict:(CLBeacon*)beacon
{
    if (beacon.rssi == 0) {
        
        return nil;
    }
    
    NSString * major = [NSString stringWithFormat:@"%d",[beacon.major  intValue]];
    
    NSString * minor = [NSString stringWithFormat:@"%d",[beacon.minor intValue]];
    
    NSString * rss = [NSString stringWithFormat:@"%ld",(long)beacon.rssi];
    
    NSString * accuracy = [NSString stringWithFormat:@"%.2f",(float)beacon.accuracy];
    
    if (!major || !minor || !rss || !accuracy) {
        
        NSLog(@"error");
    }
    
    NSDictionary * beaconDict = [[NSDictionary alloc] initWithObjects:@[major,rss,minor,accuracy] forKeys:@[@"major",@"rssi",@"minor",@"accuracy"]];
    
    if (!beaconDict) {
        
        return nil;
    }
    
    return beaconDict;
}

- (void)dealloc {
    
    [self stop];
}

@end

//--------------------------------------------------------------------------------
NSString * RequestSensorPermission_js() {
    #define __wvjb_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__wvjb_js_func__(
;(function() {
        if (typeof(DeviceMotionEvent) !== 'undefined' && typeof(DeviceMotionEvent.requestPermission) === 'function') {
               DeviceMotionEvent.requestPermission().then(response => {
                   if (response == 'granted') {
                       window.addEventListener('devicemotion', (e) => { })
                   }
               }).catch(console.error)
           }

    
})();
    ); // END preprocessorJSCode

    #undef __wvjb_js_func__
    return preprocessorJSCode;
};


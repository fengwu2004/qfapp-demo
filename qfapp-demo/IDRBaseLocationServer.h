//
//  YFBeaconManager.h
//  YFMapKit
//
//  Created by Sincere on 16/1/20.
//  Copyright © 2016年 Sincere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CLHeading;

/*
 * 在开启定位前，检测周围是否有蓝牙
 */

/*
 * 当定位中出现无法获取蓝牙时开启的检测工具
 * 如果再次获取蓝牙，切换回动态定位状态
 */

@protocol IDRBaseLocationServerDelegate <NSObject>

/**
 *  返回ibeacon的数据
 *
 *  @param beacons beacon的数据
 */
@required - (void)didGetRangeBeacons:(NSString*)strbeacons;

/**
 *  返回设备欧拉角
 */
@optional - (void)didGetEuler:(double)x y:(double)y z:(double)z;

@end

//----------------------------------------------------------------------------------------
@interface IDRBaseLocationServer : NSObject

+ (instancetype)sharedInstance;

- (void)setBeaconUUID:(NSArray*)uuidStrings;

- (void)start;

- (void)stop;

/**
 *  开始获取蓝牙信息
 */

- (void)startUpdateBeacons;

/**
 *  停止获取蓝牙信息
 */
- (void)stopUpdateBeacons;

@property(nonatomic, weak) id<IDRBaseLocationServerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isLocationAvailable;

@end

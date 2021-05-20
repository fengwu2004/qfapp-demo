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
@optional - (void)didGetEuler:(double)yaw pitch:(double)pitch roll:(double)roll;

@end

//----------------------------------------------------------------------------------------
@interface IDRBaseLocationServer : NSObject

+ (instancetype)sharedInstance;

/**
 *  设置蓝牙beacon uuids, 定位之前需要设置
 */

- (void)setBeaconUUID:(NSArray*)uuidStrings;

/**
 *  开始定位
 */

- (void)start;

/**
 *  结束定位
 */

- (void)stop;

@property(nonatomic, weak) id<IDRBaseLocationServerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isLocationAvailable;

@end

//
//  EMAppStorePayDelegate.h
//  idrMap-demo
//
//  Created by li on 2021/9/8.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//
//  EMAppStorePay.h
//  MobileFixCar
//
//  Created by Wcting on 2018/4/11.
//  Copyright © 2018年 XXX有限公司. All rights reserved.
//

/*
 wct20180917 内购支付类，短视频e豆购买用到。
 */

@class EBAppStorePay;

@protocol EBAppStorePayDelegate <NSObject>;

@optional

/**
 wct20180418 内购支付成功回调

 @param appStorePay 当前类
 @param dicValue 返回值
 @param error 错误信息
 */
- (void)iapPay:(EBAppStorePay *)appStorePay responseAppStorePaySuccess:(NSDictionary *)dicValue error:(NSError*)error;


/**
 wct20180423 内购支付结果回调提示
 
 @param appStorePay 当前类
 @param dicValue 返回值
 @param error 错误信息
 */
- (void)iapPay:(EBAppStorePay *)appStorePay responseAppStorePayStatusshow:(NSDictionary *)dicValue error:(NSError*)error;

@end

@interface EBAppStorePay : NSObject

@property (nonatomic, weak)id<EBAppStorePayDelegate> delegate;


/**
  wct20180411 点击购买

 @param goodsID 商品id
 */
-(void)startBuyToAppStore:(NSString *)goodsID;

@end


@interface EBAppStorePayDelegate : NSObject

@end

NS_ASSUME_NONNULL_END

//
//  IdrMapView.h
//  idrMap-demo
//
//  Created by li on 2021/5/22.
//  Copyright © 2021 yellfun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IdrMapView : UIView

@property(nonatomic) BOOL enableAR;

- (id)initWithFrame:(CGRect)frame enableAR:(BOOL)enableAR;

@end

NS_ASSUME_NONNULL_END

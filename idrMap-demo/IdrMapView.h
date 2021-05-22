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

- (id)initWithFrame:(CGRect)frame enableAR:(BOOL)enableAR unitName:(NSString *)unitName;

@end

NS_ASSUME_NONNULL_END

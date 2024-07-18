//
//  SOSCircleProgressView.h
//  Onstar
//
//  Created by Onstar on 2019/1/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSCircleProgressView : UIView{
    CAShapeLayer * _trackLayer;
    UIBezierPath * _trackPath;
    CAShapeLayer * _progressLayer;
    UIBezierPath * _progressPath;
}
/// 底层圆的颜色
@property (nonatomic, strong) UIColor * trackColor;
/// 上层圆的颜色
@property (nonatomic, strong) UIColor * progressColor;
/// 进度 0~1 之间的数
@property (nonatomic, assign) float progress;
/// 两个圆的宽度
@property (nonatomic, assign) float progressWidth;
@end

NS_ASSUME_NONNULL_END

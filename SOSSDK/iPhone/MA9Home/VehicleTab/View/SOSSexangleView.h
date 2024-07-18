//
//  SOSSexangleView.h
//  Onstar
//
//  Created by Onstar on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSexangleView : UIView
@property(nonatomic,assign)CGFloat lineWidth;
@property(nonatomic,strong)UIColor * progressColor;

-(void)refreshProgess:(CGFloat)progress appointProgressColor:(nullable UIColor *)apColor;
-(void)startCircleAnimation;
-(void)stopCircleAnimation;
- (void)drawSexangleWithImageViewWidth:(CGFloat)width withLineWidth:(CGFloat)lineWidth withBackgroundStrokeColor:(UIColor *)color progressStrokeColor:(UIColor *)proColor;
@end

NS_ASSUME_NONNULL_END

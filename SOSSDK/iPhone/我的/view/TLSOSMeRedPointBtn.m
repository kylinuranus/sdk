//
//  TLSOSMeRedPointBtn.m
//  Onstar
//
//  Created by TaoLiang on 2017/10/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLSOSMeRedPointBtn.h"

@interface TLSOSMeRedPointBtn ()
@end

@implementation TLSOSMeRedPointBtn

- (void)setUnreadNum:(NSUInteger)unreadNum	{
    _unreadNum = unreadNum;
    [self setNeedsDisplay];

}

- (void)drawRect:(CGRect)rect{
    self.redPoint.hidden = !(_unreadNum > 0);
}


- (UIView *)redPoint{
    if (!_redPoint) {
        _redPoint = [UIView new];
        _redPoint.backgroundColor = [UIColor redColor];
        [self addSubview:_redPoint];
        [self adjustRedPointFrame];
    }    else if (_redPoint.width == 0)    {
        [self adjustRedPointFrame];
    }
    if (_showNum) {
        [self addUnreadNum:_redPoint];    //addByWQ
    }
    return _redPoint;
}

- (void)adjustRedPointFrame    {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            CGFloat radius = _radius > 0 ? _radius : 5;
            if (_showNum) {
                radius = 8;
            }
            _redPoint.layer.cornerRadius = radius;
            CGPoint rightTop = CGPointMake(subView.right, subView.top);
            _redPoint.frame = CGRectMake(rightTop.x - radius -5, rightTop.y - radius +5, 2 * radius, 2 * radius);
            if (_unreadNum > 99) {
                _redPoint.frame = CGRectMake(rightTop.x - radius, rightTop.y - radius, 2 * radius+9, 2 * radius);
            }
            
        }
    }
}

- (void)addUnreadNum:(UIView*)view
{
    [view removeAllSubviews];
    UILabel *lb = [[UILabel alloc] init];
    lb.text = [NSString stringWithFormat:@"%lu",(unsigned long)_unreadNum];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = [UIColor whiteColor];
    lb.font = [UIFont systemFontOfSize:10];
    if (_unreadNum > 99) {
        lb.text = @"99+";
    }
    [view addSubview:lb];
    
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY);
        if (_unreadNum > 99) {
            make.width.mas_equalTo(20);
        }else
        {
            make.width.mas_equalTo(16);
        }
        make.height.mas_equalTo(14);
    }];
}

@end

//
//  BaseAnnotationView.m
//  Onstar
//
//  Created by Coir on 16/8/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "BaseAnnotationView.h"
#import "SOSSearchResult.h"
#import "BaseAnnotation.h"
#import "CustomerInfo.h"

@interface BaseAnnotationView ()

@property (nonatomic, strong, readwrite) BaseCalloutView *calloutView;

@end

@implementation BaseAnnotationView

#define kCalloutWidth       180.0
#define kCalloutHeight      54.0

- (void)setSelected:(BOOL)selected animated:(BOOL)animated  {
    if (self.selected == selected)      return;
    
    if (selected)   {
        if (self.isLBSMapMode)     {
            self.calloutView = [[BaseCalloutView alloc] initWithFrame:CGRectMake(0, 0, 206, 54)];
            self.calloutView.isLBSMapMode = YES;
            self.calloutView.center = CGPointMake(15, -30);
            [self.calloutView configSelf];
            self.calloutView.type = self.type;
        }    else    {
            if (self.calloutView == nil)    {
                if (self.type == POI_TYPE_FootPrint_OverView || self.type == POI_TYPE_FootPrint_Detail)   {
                    
                    self.calloutView = [[BaseCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
                    self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x - ((self.type != POI_TYPE_FootPrint_Detail) ? 24 : 0), - CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
                    [self.calloutView configSelf];
                    //足迹概览模式,添加向右小箭头
                    self.calloutView.rightArrowImgView.hidden = (self.type != POI_TYPE_FootPrint_OverView);
                    self.calloutView.type = self.type;
                    self.calloutView.totalCount = self.cityCount;
                    
                }
            }
        }
        self.calloutView.nameStr = self.name;
        [self addSubview:self.calloutView];
    }   else    {
        [self.calloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}


// 解决 自定义气泡添加点击事件无效问题
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self.calloutView.rightButton convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.calloutView.rightButton.bounds, tempoint))		{
            view = self.calloutView.rightButton;
        }
    }
    return view;
}


- (void)configView:(NSString *)cityName footInfoCount:(NSInteger)footCount {
    self.cityLB.text = cityName;
    self.footmarkLB.text = [NSString stringWithFormat:@"%lu足迹",(long)footCount];
    [self addSubview:self.cityLB];
    [self addSubview:self.footmarkLB];
    [self addSubview:self.checkImageView];
}

- (UILabel *)footmarkLB      {
    if (!_footmarkLB) {
        _footmarkLB = [[UILabel alloc] initWithFrame:CGRectMake(0, self.cityLB.y + self.cityLB.height + 2, self.size.width, 10)];
        _footmarkLB.textColor = [UIColor whiteColor];
        _footmarkLB.font = [UIFont systemFontOfSize:12];
        _footmarkLB.textAlignment = NSTextAlignmentCenter;;
        _footmarkLB.adjustsFontSizeToFitWidth = YES;
    }
    return _footmarkLB;
}

- (UILabel *)cityLB     {
    if (!_cityLB) {
        _cityLB = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.height - 14) /2, self.size.width, 14)];
        _cityLB.textAlignment = NSTextAlignmentCenter;
        _cityLB.textColor = [UIColor whiteColor];
        _cityLB.font = [UIFont systemFontOfSize:12];
        _cityLB.adjustsFontSizeToFitWidth = YES;
    }
    return _cityLB;
}

- (UIImageView *)checkImageView     {
    if (!_checkImageView) {
        UIImage *image = [UIImage imageNamed:@"icon_check_in_done_white_idle"];
        _checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.size.width - image.size.width) / 2, self.cityLB.y - image.size.height - 2, image.size.width, image.size.height)];
        _checkImageView.image = image;
    }
    return _checkImageView;
}

@end

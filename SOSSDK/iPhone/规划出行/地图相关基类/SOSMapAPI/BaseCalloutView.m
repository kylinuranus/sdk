//
//  BaseCalloutView.m
//  Onstar
//
//  Created by Coir on 16/8/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "BaseCalloutView.h"

@implementation BaseCalloutView     {
    
    UILabel *titleLabel;
    
    UIView *bgView;
    
    UIImageView *backGroungImgView;
    
}

- (id)initWithFrame:(CGRect)frame   {
    self = [super initWithFrame:frame];
    if (self)   {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configSelf      {
    // 背景图片
    backGroungImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"弹窗框"]];
    [self addSubview:backGroungImgView];
    backGroungImgView.center = CGPointMake(self.width / 2, self.height / 2);
    
    bgView = [[UIView alloc] initWithFrame:self.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgView];
    
    // 添加标题
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width / 2, self.height * .85)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Title";
    [bgView addSubview:titleLabel];
    // 添加跳转Button
    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width * 2 / 5, self.height * .85)];
    [_rightButton setTitle:@"Button" forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [bgView addSubview:_rightButton];
    
    // 向右箭头图片
    _rightArrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LBS_icon_arrow_right_passion_blue_idle"]];
    _rightArrowImgView.centerY = _rightButton.centerY;
    _rightArrowImgView.right = bgView.width + 3;
    _rightArrowImgView.hidden = YES;
    [bgView addSubview:_rightArrowImgView];
}

- (void)setNameStr:(NSString *)nameStr      {
    _nameStr = nameStr;
    if (_type == POI_TYPE_FootPrint_OverView) {
        [_rightButton setTitle:nameStr forState:0];
        [_rightButton setTitleColor:colorFromRGB(73, 126, 220, 1) forState:0];
    }   else if (_type == POI_TYPE_FootPrint_Detail)    {
        titleLabel.minimumScaleFactor = 9. / 13;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 2;
        titleLabel.text = nameStr;
        titleLabel.textColor = [UIColor darkGrayColor];
    }	else if (self.isLBSMapMode)		{
        titleLabel.text =  nameStr;
        titleLabel.numberOfLines = 2;
        titleLabel.textColor = [UIColor darkGrayColor];
    }
}

- (void)setTotalCount:(NSNumber *)totalCount    {
    _totalCount = totalCount;
    if (_type == POI_TYPE_FootPrint_OverView) {
        titleLabel.text = [NSString stringWithFormat:@"%@条足迹", totalCount];
        titleLabel.textColor = [UIColor whiteColor];
    }   else if (_type == POI_TYPE_FootPrint_Detail)    {
        [_rightButton setTitle:@"删除" forState:0];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:0];
    }
}

- (void)setType:(POIType)type   {
    _type = type;
    if (type == POI_TYPE_FootPrint_OverView) {
        backGroungImgView.image = [UIImage imageNamed:@"足迹背景"];
        _rightButton.centerX = self.width * 3 / 4;
        titleLabel.left = 0;
    }   else if (type == POI_TYPE_FootPrint_Detail)    {
        backGroungImgView.image = [UIImage imageNamed:@"对话框"];
        titleLabel.left = self.width * .07;
        _rightButton.right = self.width;
    }	else	{
        backGroungImgView.image = [UIImage imageNamed:@"geofencingCalloutView"];
        titleLabel.frame = CGRectMake(0, 0, 206, 45);
        _rightButton.hidden = YES;
    }
}

@end

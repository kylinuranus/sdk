//
//  SOSTopNetworkTipView.m
//  Onstar
//
//  Created by onstar on 2019/1/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTopNetworkTipView.h"
#import "SOSReachability.h"
#import "SOSTopPromptView.h"

@interface SOSTopNetworkTipView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UIButton *closeBtn;

@end

#define KTIPTAG 9923
@implementation SOSTopNetworkTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [[UIColor colorWithHexString:@"#C50000"] colorWithAlphaComponent:0.9];
        _backgroundView.layer.cornerRadius = 4.f;
        [self addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self);
        }];
        _promptLabel = [UILabel new];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.font = [UIFont systemFontOfSize:11];
        _promptLabel.text = @"获取网络失败,请重新连接";
        [self addSubview:_promptLabel];
        [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self);
            make.left.equalTo(@10);
        }];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"Icon／34x34／trip_icon_position_del_34x34"] forState:UIControlStateNormal];
        [self addSubview:_closeBtn];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.and.right.equalTo(self);
            make.size.equalTo(@34);
            make.left.equalTo(_promptLabel.mas_right).offset(6);
        }];
        [SOSReachability SOSNetworkStatuswithSuccessBlock:^(NSInteger status) {
            //初始化Reachability时候AFNetworkReachabilityStatus=AFNetworkReachabilityStatusUnknown
            if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                [self dismiss];
            }
        }];
    }
    return self;
}



+ (BOOL)showing {
    
    return [SOS_ONSTAR_WINDOW viewWithTag:KTIPTAG]?YES:NO;
}

+ (void)show {
    
    if ([self showing]) {
        return;
    }
    SOSTopPromptView *topView = [SOS_ONSTAR_WINDOW viewWithTag:KTOPTAG];
    if (topView && topView.showing) {
        [topView dismiss];
    }
    if (SOS_ONSTAR_WINDOW) {
        SOSTopNetworkTipView *tipView = [SOSTopNetworkTipView new];
        tipView.tag = KTIPTAG;
        [SOS_ONSTAR_WINDOW addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(@(STATUSBAR_HEIGHT));
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.height.equalTo(@34);
        }];
    }
}

- (void)dismiss {
    [SOSTopNetworkTipView dismiss];
}

+ (void)dismiss {
    if (![self showing]) {
        return;
    }
    SOSTopNetworkTipView *tipView = [SOS_ONSTAR_WINDOW viewWithTag:KTIPTAG];
    if (tipView) {
        [UIView animateWithDuration:0.2 animations:^{
            tipView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            tipView.alpha = 0;
        } completion:^(BOOL finished) {
            [tipView removeFromSuperview];
            tipView.transform = CGAffineTransformIdentity;
            tipView.alpha = 1;
        }];
    }
   
}

@end

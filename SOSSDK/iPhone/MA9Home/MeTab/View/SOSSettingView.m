//
//  SOSSettingView.m
//  Onstar
//
//  Created by Onstar on 2018/11/22.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSSettingView.h"
#import "TLSOSMeRedPointBtn.h"

@interface SOSSettingView(){
    TLSOSMeRedPointBtn *notifyButton;
    UIButton *settingButton;
}

@property (strong, nonatomic) UIButton *overallScanButton;


@end
@implementation SOSSettingView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        if (!SOS_MYCHEVY_PRODUCT) {
            [self configView];
        }
    }
    return self;
}
- (void)layoutSubviews{
     [super layoutSubviews];
}
-(void)configView{
    
    settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"Icon_me_setup"] forState:UIControlStateNormal];
//    settingButton.redPoint.top = 0;
    [self addSubview:settingButton];
    [settingButton addTarget:self action:@selector(settingCenter) forControlEvents:UIControlEventTouchUpInside];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(0);
        make.right.equalTo(self).offset(0);
        make.bottom.equalTo(self).offset(0);
        make.width.equalTo(self.mas_height);
    }];
    
    notifyButton = [TLSOSMeRedPointBtn buttonWithType:UIButtonTypeCustom];
    [notifyButton setImage:[UIImage imageNamed:@"Icon_me_messagecenter"] forState:UIControlStateNormal];
//    [notifyButton setBackgroundColor:[UIColor blueColor]];
    notifyButton.showNum = YES;
    notifyButton.redPoint.top = 0;
    [self addSubview:notifyButton];
    [notifyButton addTarget:self action:@selector(notifyCenter) forControlEvents:UIControlEventTouchUpInside];
    [notifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(settingButton.mas_left).offset(0);
        make.height.equalTo(self);
        make.width.equalTo(self.mas_height);
        make.centerY.equalTo(self);
       
    }];
    notifyButton.showNum = YES;
//    [notifyButton setUnreadNum:1];
    
#ifndef SOSSDK_SDK
    _overallScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_overallScanButton setImage:[UIImage imageNamed:@"Icon／34x34／me_icon_set-up_34x34"] forState:UIControlStateNormal];
    [_overallScanButton addTarget:self action:@selector(onOverallScan) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_overallScanButton];
    [_overallScanButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(notifyButton.mas_left);
        make.left.top.height.equalTo(self);
        make.width.equalTo(self.mas_height);
    }];
#endif
    
}
-(void)updateMessageNumber{
//    notifyButton.showNum = YES;
    notifyButton.unreadNum = [MsgCenterManager shareInstance].msgNum;
}
- (CGSize)intrinsicContentSize{
    return CGSizeMake(180, 40);
}

- (void)settingCenter{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(SOSHomeMeTabProtocol)]) {
        [self.delegate clickSetting];
        [SOSDaapManager sendActionInfo:ME_SET];
    }

}

- (void)notifyCenter{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(SOSHomeMeTabProtocol)]) {
        [self.delegate clickNotification];
        [SOSDaapManager sendActionInfo:ME_MESSAGECENTER];
    }
   
}

- (void)onOverallScan {
    if ([_delegate respondsToSelector:@selector(onOverallScan)]) {
        [_delegate onOverallScan];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

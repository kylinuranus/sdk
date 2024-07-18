//
//  SOSMeTabHeaderUnloginView.m
//  Onstar
//
//  Created by Onstar on 2019/3/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTabHeaderUnloginView.h"
#import "UIImage+SOSSkin.h"

@interface SOSMeTabHeaderUnloginView(){
    UIImageView * backgroundImageView;
    UILabel * titleLabel;     //未登录 OR 服务天数提示
    UILabel * subTitleLabel;  //未登录提示 OR onstar套餐
}
@end
@implementation SOSMeTabHeaderUnloginView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:backgroundImageView];
        titleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        
        subTitleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:titleLabel];
        [self addSubview:subTitleLabel];
        
        backgroundImageView.image = [UIImage sossk_imageNamed:@"me_package_none_bg"];
        titleLabel.text = @"安吉星 · 您的爱车管家";
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        titleLabel.textColor = [UIColor whiteColor];
        
        subTitleLabel.text=@"应急救援 · 远程遥控 · 实时车况 · 车载WIFI";
        subTitleLabel.textColor = [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.meNonePackageFontColor"];
        subTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        
        self.loginButton = [[UIButton alloc] init];
        [self.loginButton setImage:[UIImage imageNamed:@"Btn_me_login"] forState:UIControlStateNormal];
        [self.loginButton addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        self.functionType = SOSMeFunctionLogin;

        [self addSubview:self.loginButton];
        
        //布局
        [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(12.0f);
            make.trailing.mas_equalTo(-12.0f);
        }];
        
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).mas_offset(34);
            make.centerX.equalTo(self);
        }];
        [subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->titleLabel.mas_bottom).mas_offset(14);
            make.centerX.equalTo(self);
        }];
        [self.loginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self->backgroundImageView.mas_bottom).mas_offset(-26);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}
-(void)functionClick:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(functionButtonWithType:)]) {
        [self.delegate performSelector:@selector(functionButtonWithType:)withObject:@(self.functionType)];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)inLoadingState{
    self.loginButton.hidden = YES;
}
-(void)unLoginState{
    if (self.loginButton.hidden) {
        self.loginButton.hidden = NO;
    }
    [self.loginButton setImage:[UIImage imageNamed:@"Btn_me_login"] forState:UIControlStateNormal];

}
-(void)visitorState{
    [self unLoginState];
    [self.loginButton setImage:[UIImage imageNamed:@"me_upgradesub_button"] forState:UIControlStateNormal];
    self.functionType = SOSMeFunctionUpgradeOwner;
}

@end

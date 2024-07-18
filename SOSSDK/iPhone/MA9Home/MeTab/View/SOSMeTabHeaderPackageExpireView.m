//
//  SOSMeTabHeaderPackageExpireView.m
//  Onstar
//
//  Created by Onstar on 2019/3/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTabHeaderPackageExpireView.h"
#import "UIImage+SOSSkin.h"

@interface SOSMeTabHeaderPackageExpireView(){
    UIImageView * backgroundImageView;
    UILabel * titleLabel;     //未登录 OR 服务天数提示
    UILabel * subTitleLabel;  //未登录提示 OR onstar套餐
}
@end
@implementation SOSMeTabHeaderPackageExpireView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width-24.0f, frame.size.height)];
        [self addSubview:backgroundImageView];
        titleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        
        subTitleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:titleLabel];
        [self addSubview:subTitleLabel];
        
        backgroundImageView.image = [UIImage sossk_imageNamed:@"me_package_none_bg"];
        titleLabel.text = @"安吉星 · 您的爱车管家";
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        titleLabel.textColor = [UIColor whiteColor];
        
        subTitleLabel.text=@"您的套餐已过期";
        subTitleLabel.textColor = [UIColor colorWithHexString:@" #6483C9"];
        subTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        
        self.renewalButton = [[UIButton alloc] init];
        [self.renewalButton setImage:[UIImage imageNamed:@"Btn_me_renewalonstar"] forState:UIControlStateNormal];
        [self.renewalButton addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.renewalButton];
        
        //布局
        [backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
        [self.renewalButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self->backgroundImageView.mas_bottom).mas_offset(-26);
            make.centerX.equalTo(self);
        }];
        self.functionType = SOSMeFunctionByOnstarPackage;

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

@end

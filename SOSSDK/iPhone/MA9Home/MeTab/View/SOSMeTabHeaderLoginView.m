//
//  SOSMeTabHeaderLoginView.m
//  Onstar
//
//  Created by Onstar on 2019/3/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTabHeaderLoginView.h"
#import "PackageUtil.h"
#import "SOSAvatarManager.h"
#import "SOSCardUtil.h"
#import "UIImage+SOSSkin.h"

@interface SOSMeTabHeaderLoginView(){
    UIImageView * onstarBadgeImageView;
    UILabel * titleLabel;//护航天数
    UILabel * subTitleLabel;//套餐剩余
    UILabel * datapackageTitleLabel;//4g
    
}
@property(nonatomic,strong)UIButton * functionButton;
@property(nonatomic,strong)UIImageView * backgroundImageView;
@property(nonatomic,strong)UIImageView * onstarVehicleImageView;
@end
@implementation SOSMeTabHeaderLoginView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width-24.0f, frame.size.height)];
        self.backgroundImageView.image = [UIImage sossk_imageNamed:@"me_package_bg"];
        [self addSubview:self.backgroundImageView];
        
        onstarBadgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_package_icon_onstarbadge"]];
        [self addSubview:onstarBadgeImageView];
        
        titleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        subTitleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:titleLabel];
        [self addSubview:subTitleLabel];
        subTitleLabel.userInteractionEnabled = YES;
        [subTitleLabel setTapActionWithBlock:^{
            [SOSCardUtil routerToOnstarPackage];
            [SOSDaapManager sendActionInfo:ME_SERVICEPACKAGE_CURRENTPACKAGETAB];
        }];
        
        //布局
        [self.backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(12.0f);
            make.trailing.mas_equalTo(-12.0f);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).mas_offset(24);
            make.trailing.mas_equalTo(self).mas_offset(-24.0f);
        }];
        [subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->titleLabel.mas_bottom).mas_offset(14);
            make.trailing.mas_equalTo(self).mas_offset(-24.0f);
        }];
        [onstarBadgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_offset(26);
            make.top.mas_equalTo(self.mas_top);
        }];
        
        [self titleLabelForLogin];
        [self subTitleLabelForOnstarPackageDefault];
        
        [self refreshUserPackage];
    }
    return self;
}
-(void)titleLabelForLogin{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"安吉星已为您护航--天"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
    [titleLabel setAttributedText:string];
    
}

-(void)refreshUserPackage{
    [PackageUtil getPackageServiceSuccess:^(SOSGetPackageServiceResponse *userfulDic) {
        
        if ([userfulDic.state isEqualToString:@"3"]) {
            if ([self.delegate respondsToSelector:@selector(loginViewPackageExpiredState)]) {
                [self.delegate performSelector:@selector(loginViewPackageExpiredState)];
            }
        }else{
            [self addVehicleDriveIntoAnimation];
            NSString * remainingDay =userfulDic.currRemainingDays;
            if (remainingDay) {
                [self subTitleLabelUpdateOnstarPackageRemainingDay:remainingDay];
            }
            BOOL isgen9 = [Util vehicleIsG9];
            if (!isgen9) {
                [self addLabelFor4G];
                [self datapackageLabelUpdateFlow:userfulDic.remainingBytes.currentRemainUsage remainUsageUnit:userfulDic.remainingBytes.currRemainUsageUnit];
            }
            if ([userfulDic.state isEqualToString:@"2"]) {
                [self functionButtonBuyDatapackage];
            }
            if ([userfulDic.state isEqualToString:@"1"]) {
                [self functionButtonBuyOnstarPackage];
            }
            //护航天数
            [self titleLabelUpdateEscortDays:userfulDic.escort];
        }
        
    } failed:^(NSString *responseStr, NSError *error) {
        
    }];
}

-(void)addVehicleDriveIntoAnimation{
    @weakify(self);
    [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeOther avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
        @strongify(self);
        if (self.superview) {
            if (!self.onstarVehicleImageView) {
                self.onstarVehicleImageView = [[UIImageView alloc] init];
                self.onstarVehicleImageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.onstarVehicleImageView setFrame:CGRectMake(-254, 92, 254, 120)];
                [self addSubview:self.onstarVehicleImageView];
                CABasicAnimation *animation = nil;
                animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
                [animation setFromValue:@(self.onstarVehicleImageView.centerX)];
                [animation setToValue:@(self.onstarVehicleImageView.centerX+self.onstarVehicleImageView.width)];
                //        [animation setDelegate:self];//代理回调
                [animation setDuration:1.0];
                [animation setRemovedOnCompletion:NO];//默认为YES,设置为NO时setFillMode有效
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [animation setFillMode:kCAFillModeBoth];
                [self.onstarVehicleImageView.layer addAnimation:animation forKey:@"baseanimation"];
                //            self.height = self.height+10.0f;
            }
            [self.onstarVehicleImageView setImage:avatar];
        }
        
    }];
}
-(void)removeVehicleDriveIntoAnimation{
    if (self.onstarVehicleImageView) {
        [self.onstarVehicleImageView removeFromSuperview];
        self.onstarVehicleImageView = nil;
        //         self.height = self.height - 10.0f;
    }
}
//////////////////////////////////////////////
-(void)attributedString:(NSMutableAttributedString *)ats addNumber:(NSString *)number{
    NSTextAttachment *imageAtta = [[NSTextAttachment alloc] init];
    imageAtta.bounds = CGRectMake(0, -5, 18, 40);
    UIImage * numImage = [UIImage imageNamed:[NSString stringWithFormat:@"me_icon_number_%@",number]];
    if (numImage) {
        imageAtta.image = numImage;
        NSAttributedString *attach = [NSAttributedString attributedStringWithAttachment:imageAtta];
        [ats insertAttributedString:attach atIndex:8];
    }
}
//更新护航天数
-(void)titleLabelUpdateEscortDays:(NSString *)days{
    if (days) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"安吉星已为您护航天"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
        [titleLabel setAttributedText:string];
        
        if (days.length >0) {
            for (NSInteger i = [days length]-1; i>= 0; i--) {
                //截取字符串中的每一个字符
                NSString *s = [days substringWithRange:NSMakeRange(i, 1)];
                [self attributedString:string addNumber:s];
            }
            [titleLabel setAttributedText:string];
            
        }else{
            [string insertString:@"_" atIndex:8];
        }
    }
    
}
//-(void)titleLabelForLogin{
//    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"安吉星已为您护航--天"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#9D8169"]}];
//    [titleLabel setAttributedText:string];
//    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).mas_offset(34);
//        make.trailing.mas_equalTo(self).mas_offset(-24.0f);
//    }];
//
//}
-(void)datapackageLabelUpdateFlow:(NSString *)flow remainUsageUnit:(NSString *)unit{
    if (!flow || !([flow integerValue] >0) ) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"车载Wi-Fi流量已用完"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#D37A10"]}];
        [datapackageTitleLabel setAttributedText:string];
    }else{
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"车载Wi-Fi流量剩余 "attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 13],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
        [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",flow,unit]attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}]];
        [datapackageTitleLabel setAttributedText:string];
    }
    
}
//更新天数
-(void)subTitleLabelUpdateOnstarPackageRemainingDay:(NSString *)day{
    NSMutableAttributedString *string;
    if (day.isNotBlank && day.integerValue > 30) {
        string  = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"安吉星当前套餐生效中"] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
    }else{
        string   = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前套餐剩余 "] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
        [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@天",day]attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}]];
    }
    
    
    [subTitleLabel setAttributedText:string];
}
//默认--天数
-(void)subTitleLabelForOnstarPackageDefault{
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"当前套餐剩余 "attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
    [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"--天"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}]];
    
    [subTitleLabel setAttributedText:string];
    [subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->titleLabel.mas_bottom).mas_offset(14);
        make.trailing.mas_equalTo(self).mas_offset(-24.0f);
    }];
}
-(void)addLabelFor4G{
    if (!datapackageTitleLabel) {
        datapackageTitleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        datapackageTitleLabel.userInteractionEnabled = YES;
        [datapackageTitleLabel setTapActionWithBlock:^{
            [SOSCardUtil routerTo4GPackage];
            [SOSDaapManager sendActionInfo:ME_DATAPACKAGE_CURRENTPACKAGETAB];
        }];
    }
    [self addSubview:datapackageTitleLabel];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"车载Wi-Fi流量剩余 "attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.mePackagePageFontColor"]}];
    [string appendString:@"--M"];
    [datapackageTitleLabel setAttributedText:string];
    [datapackageTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->subTitleLabel.mas_bottom).mas_offset(3.0f);
        make.trailing.mas_equalTo(self).mas_offset(-24.0f);
    }];
    //获取4g包信息
}
-(void)functionButtonBuyOnstarPackage{
    //    self.functionButton.hidden = NO;
    [self.functionButton setImage:[UIImage imageNamed:@"Btn_me_renew"] forState:UIControlStateNormal];
    self.functionType = SOSMeFunctionByOnstarPackage;
    [SOSDaapManager sendActionInfo:ME_PURCHASE_HOTSALE];
}
-(void)functionButtonBuyDatapackage{
    //    self.functionButton.hidden = NO;
    [self.functionButton setImage:[UIImage imageNamed:@"me_btn_buy_4g"] forState:UIControlStateNormal];
    self.functionType = SOSMeFunctionByDataPackage;
    [SOSDaapManager sendActionInfo:ME_PURCHASE_DATA];
    //    [self adjustButtonRight];
}
//-(void)functionButtonRenewalOnstar{
////    self.functionButton.hidden = NO;
//    [self.functionButton setImage:[UIImage imageNamed:@"Btn_me_renewalonstar"] forState:UIControlStateNormal];
//    functionType = SOSMeFunctionByOnstarPackage;
////    [self adjustButtonRight];
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(void)functionClick:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(functionButtonWithType:)]) {
        [self.delegate performSelector:@selector(functionButtonWithType:)withObject:@(self.functionType)];
    }
}
-(UIButton *)functionButton{
    if (!_functionButton) {
        _functionButton = [[UIButton alloc] init];
        [self.functionButton addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_functionButton];
        [self.functionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).mas_offset(-12);
            make.trailing.equalTo(self).mas_offset(-24.0f);
        }];
    }
    return _functionButton;
}
@end

//
//  SOSMeTabHeaderView.m
//  Onstar
//
//  Created by Onstar on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTabHeaderView.h"
#import "SOSGreetingManager.h"
#import "SOSAvatarManager.h"
#import "PackageUtil.h"
#import "SOSMeTabHeaderUnloginView.h"
#import "SOSMeTabHeaderLoginView.h"
#import "SOSMeTabHeaderPackageExpireView.h"

typedef NS_ENUM(NSInteger, SOSMeHeaderViewType) {
    SOSMeHeaderViewUnlogLogin,  //0
    SOSMeHeaderViewInLogin, //
    SOSMeHeaderViewLogin,  //
    SOSMeHeaderViewLoginExpire
};
@interface SOSMeTabHeaderView()<SOSMeTableHeaderViewProtol>{
//    UIImageView * backgroundImageView;
//    UILabel * titleLabel;     //未登录 OR 服务天数提示
//    UILabel * subTitleLabel;  //未登录提示 OR onstar套餐
//    UILabel * datapackageTitleLabel;//4g
//    SOSMeFunctionType functionType;
    SOSMeHeaderViewType headerViewType;
//    UIImageView * onstarBadgeImageView;
//    UIImageView * onstarVehicleImageView;
    
}
//@property(nonatomic,strong)UIButton * functionButton;
@property(nonatomic,weak)SOSMeTabHeaderUnloginView * unloginView;
@property(nonatomic,weak)SOSMeTabHeaderUnloginView * visitorView;
@property(nonatomic,weak)SOSMeTabHeaderLoginView   * loginView;
@property(nonatomic,weak)SOSMeTabHeaderPackageExpireView   * expireView;

@end
@implementation SOSMeTabHeaderView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width-24.0f, frame.size.height)];
//        [self addSubview:backgroundImageView];
//        titleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
//
//        subTitleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
//        [self addSubview:titleLabel];
//        [self addSubview:subTitleLabel];

//        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKEN) {
//            [self configLoadingState];
//        }
        if (!headerViewType) {
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                [self configLoginSuccessState];
            }else{
                [self configLoadingState];
            }
        }
       
    }
    return self;
}
//-(void)layoutSubviews{
//    [super layoutSubviews];
//}
///////////////////////////public method
-(void)configUnloginState{
    if (headerViewType == SOSMeHeaderViewLogin) {
        [self removeAllSubviews];
    }
    headerViewType = SOSMeHeaderViewUnlogLogin;
    [self.unloginView unLoginState];
    
}
-(void)configLoadingState{
    headerViewType = SOSMeHeaderViewInLogin;
    [self.unloginView inLoadingState];
}
-(void)configLoginSuccessState{
    
    if (headerViewType != SOSMeHeaderViewLogin) {
        [self removeAllSubviews];
    }
    headerViewType = SOSMeHeaderViewLogin;
    
    if ([SOSCheckRoleUtil isVisitor]) {
        [self loginVisitor];
    }else{

        if (_loginView) {
            _loginView = nil;
        }
           [self loginView];
    
    }
}
-(void)refreshPackageState{

    if (_loginView) {
        [_loginView refreshUserPackage];
    }
}

-(void)loginViewPackageExpiredState{
    if (headerViewType != SOSMeHeaderViewLoginExpire) {
        [self removeAllSubviews];
    }
    headerViewType = SOSMeHeaderViewLogin;
    
    [self expireView];
}
#pragma mark -----------
-(void)loginVisitor{
    [self.visitorView visitorState];
}

//depredate
-(void)functionButtonWithType:(NSNumber *)buttonType{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(SOSHomeMeTabProtocol)]) {
        switch (buttonType.integerValue) {
            case SOSMeFunctionLogin:
                [self.delegate clickLogin];
                break;
            case SOSMeFunctionUpgradeOwner:
                [self.delegate clickUpgrade];
                break;
            case SOSMeFunctionByOnstarPackage:
                [self.delegate clickPurchasePackage];
                break;
            case SOSMeFunctionByDataPackage:
                [self.delegate clickPurchaseDataPackage];
                break;
            default:
                break;
        }

    }
}

-(SOSMeTabHeaderUnloginView*)unloginView{
    if (!_unloginView) {
        SOSMeTabHeaderUnloginView * unlogin = [[SOSMeTabHeaderUnloginView alloc] init];
        unlogin.delegate = self;
        [self addSubview:unlogin];
        [unlogin mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(8.0f);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-12);
        }];
        _unloginView = unlogin;
    }
    return _unloginView;
}
-(SOSMeTabHeaderUnloginView*)visitorView{
    if (!_visitorView) {
        SOSMeTabHeaderUnloginView * visitorV = [[SOSMeTabHeaderUnloginView alloc] init];
        visitorV.delegate = self;
        [self addSubview:visitorV];
        [visitorV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(8.0f);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-12);
        }];
        _visitorView = visitorV;
    }
    return _visitorView;
}

-(SOSMeTabHeaderLoginView*)loginView{
    if (!_loginView) {
        SOSMeTabHeaderLoginView *login = [[SOSMeTabHeaderLoginView alloc] init];
        login.delegate = self;
        [self addSubview:login];
        [login mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(8.0f);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-12);
        }];
        _loginView = login;
    }
    return _loginView;
}
-(SOSMeTabHeaderPackageExpireView*)expireView{
    if (!_expireView) {
        SOSMeTabHeaderPackageExpireView * exp = [[SOSMeTabHeaderPackageExpireView alloc] init];
        exp.delegate = self;
        [self addSubview:exp];
        [exp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(8.0f);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-12);
        }];
        _expireView = exp;
    }
    return _expireView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

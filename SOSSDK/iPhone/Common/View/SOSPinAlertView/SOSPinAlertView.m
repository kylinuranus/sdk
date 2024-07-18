//
//  SOSPinAlertView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPinAlertView.h"
#import "SOSServicePwd.h"
#import "SOSPinContentView.h"
#import "SOSRemoteTool.h"


@interface SOSPinAlertView ()
//@property (assign, nonatomic) BOOL shouldShowHonkAndFlash;
//@property (strong, nonatomic) UIView *containerView;

//@property (weak, nonatomic) UIButton *confirmBtn;
@end

@implementation SOSPinAlertView

+ (instancetype)pinAlertView {
    
    return [[self alloc] init];
}

+ (void)pinAlertViewWithErrorMsg:(NSString *)errorMsg comPleteBlock:(void(^)(NSString *inputPwd, BOOL flashSelected, BOOL hornSelected))confirm {
    SOSPinContentView *testView = [SOSPinContentView viewFromXib];
    
    testView.pinType = SOSPinTypePassword;
    testView.errorMsg = errorMsg;
    
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"服务密码" message:nil customView:testView preferredStyle:SOSAlertControllerStyleAlert];
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleDefault handler:nil];
    [vc addActions:@[action]];
    @weakify(vc)
    testView.didCompleteInputBlock = ^(NSString * _Nonnull pinCode, SOSPinContentView * _Nonnull pinView) {
        @strongify(vc)
        [vc dismissViewControllerAnimated:YES completion:^{
            [SOSRemoteTool upgradeTokenWithInputPwd:pinCode Success:^{
                !confirm?:confirm(pinCode,NO,NO);
            } Failure:^(NSString *err) {
                [self pinAlertViewWithErrorMsg:err comPleteBlock:confirm];
            }];
        }];
    };
    [vc show];
}

- (void)setConfirm:(void (^)(NSString *, BOOL, BOOL))confirm {
    _confirm = confirm;
    [SOSPinAlertView pinAlertViewWithErrorMsg:nil comPleteBlock:confirm];
}


//+ (instancetype)pinAlertViewShouldShowHonkAndFlash:(BOOL)shouldShowHonkAndFlash {
//    SOSPinAlertView *alertView = [SOSPinAlertView new];
//    alertView.shouldShowHonkAndFlash = shouldShowHonkAndFlash;
//    return alertView;
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [self configUI];
//        ///..Genie Sun的神奇写法
//        _pinView.buttonOK = _confirmBtn;
//
//    }
//    return self;
//}
//
//- (void)setShouldShowHonkAndFlash:(BOOL)shouldShowHonkAndFlash{
//    _shouldShowHonkAndFlash = shouldShowHonkAndFlash;
//    _pinView.isHornFlash = _shouldShowHonkAndFlash;
//}
//
//- (void)setPhoneFuncId:(NSString *)phoneFuncId {
//    _phoneFuncId = phoneFuncId;
//    _pinView.functionID = phoneFuncId;
//}

- (void)show 	{
//    [self.alertController show];
//    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
//    __block BOOL shouldShow = YES;
//    [keyWindow.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:SOSPinAlertView.class]) {
//            shouldShow = NO;
//            *stop = YES;
//        }
//    }];
//    if (!shouldShow) {
//        return;
//    }
//    [keyWindow addSubview:self];
//    [self mas_makeConstraints:^(MASConstraintMaker *make){
//        make.edges.equalTo(keyWindow);
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.pinView.tf becomeFirstResponder];
//    });
}

//- (void)hide {
//    [self removeFromSuperview];
//}
//
//
//- (void)cancelBtnClicked:(id)sender {
//    if (_cancel) {
//        _cancel();
//    }
//    [self hide];
//}
//
//- (void)confirmBtnClicked:(id)sender {
//    if ([Util trimWhite:_pinView.tf].length < 6) {
//        _confirmBtn.enabled = NO;
//    }    else {
//        _confirmBtn.enabled = YES;
//        if (_confirm) {
//            _confirm([Util trimWhite:_pinView.tf], _pinView.isFlashSelected, _pinView.isHornSelected);
//        }
//    }
//    [self hide];
//}
//
//- (void)configUI {
//    UIView *maskView = [UIView new];
//    maskView.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:0.6f];
//    [self addSubview:maskView];
//    [maskView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.edges.equalTo(self);
//    }];
//
//    _containerView = [UIView new];
//    _containerView.backgroundColor = [UIColor whiteColor];
//    _containerView.layer.cornerRadius = 10.f;
//    _containerView.layer.masksToBounds = YES;
//    [self addSubview:_containerView];
//    [_containerView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.width.mas_equalTo(SCREEN_WIDTH - 105.f);
//        make.centerX.equalTo(self);
//        make.centerY.equalTo(self).offset(-40);
//    }];
//
//    UILabel *titleLabel = [UILabel new];
//    titleLabel.text = @"服务密码";
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.textColor = [UIColor colorWithHexString:@"3A3A51"];
//    titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:20.0f];
//    [_containerView addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.right.equalTo(_containerView);
//        make.top.equalTo(@10);
//        make.height.mas_equalTo(40);
//    }];
//
//    __weak __typeof(self)weakSelf = self;
//    _pinView = [SOSServicePwd viewFromXib];
//    _pinView.feedback = ^{
//        [weakSelf hide];
//
//        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:MA8_3_FEEDBACK_URL];
//        UINavigationController * homePresent =(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController].presentedViewController ;
//        if (homePresent) {
//            [homePresent pushViewController:vc animated:YES];
//        }else{
//            [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
//        }
//    };
//    [_containerView addSubview:_pinView];
//    [_pinView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.top.equalTo(titleLabel.mas_bottom);
//        make.left.right.equalTo(_containerView);
//    }];
//
//    UIView *line = [UIView new];
//    line.backgroundColor = [UIColor lightGrayColor];
//    [_containerView addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.right.equalTo(_containerView);
//        make.top.equalTo(_pinView.mas_bottom);
//        make.height.mas_equalTo(0.5);
//    }];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
//    cancelBtn.backgroundColor = [UIColor whiteColor];
//    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_containerView addSubview:cancelBtn];
//    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.right.equalTo(_containerView);
//        make.top.equalTo(line.mas_bottom);
//        make.height.mas_equalTo(54);
//    }];
//
//    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [confirmBtn setBackgroundColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
//    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//    [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    confirmBtn.enabled = NO;
//    [_containerView addSubview:confirmBtn];
//    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make){
//        make.top.equalTo(cancelBtn.mas_bottom);
//        make.left.right.equalTo(_containerView);
//        make.height.mas_equalTo(54);
//        make.bottom.equalTo(_containerView.mas_bottom);
//    }];
//    _confirmBtn = confirmBtn;
//
//
//}

@end

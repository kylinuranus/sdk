//
//  SOSGeoModifyMobileVC.m
//  Onstar
//
//  Created by Coir on 2019/7/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoModifyMobileVC.h"
#import "SOSGeoDataTool.h"
#import "SVIndefiniteAnimatedView.h"
@interface SOSGeoModifyMobileVC () <UITextFieldDelegate>{
    SVIndefiniteAnimatedView* _animatedView;
}

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *originGeoPhoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *imgCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *imgCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *SMSCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getSMSCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getSMSCodeButtonWidthGuide;

@property (nonatomic, copy) NSString *imgToken;

@property (nonatomic, copy) NSString *SMSToken;

@property (nonatomic, assign) int SMSTimerCount;
@property (nonatomic, strong) dispatch_source_t SMSTimer;

@end

@implementation SOSGeoModifyMobileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    [self configSelf];
    [self refreshImgCode];
}

- (void)configSelf	{
    [self.ensureButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [self.ensureButton setBackgroundColor:[UIColor colorWithHexString:@"C3CEEC"] forState:UIControlStateDisabled];
    
    [self.getSMSCodeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.getSMSCodeButton setBackgroundColor:[UIColor colorWithHexString:@"CFCFCF"] forState:UIControlStateSelected];
    [self.getSMSCodeButton setBackgroundColor:[UIColor colorWithHexString:@"CFCFCF"] forState:UIControlStateDisabled];
    
    self.imgCodeTextField.maxInputLength = 8;
    self.SMSCodeTextField.maxInputLength = 10;
    [self.phoneNumTextField setPhoneNumberFilter];
    __weak __typeof(self) weakSelf = self;
    [[self.phoneNumTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        [weakSelf refreshEnsureButtonState];
    }];
    [[self.imgCodeTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        [weakSelf refreshEnsureButtonState];
    }];
    [[self.SMSCodeTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        [weakSelf refreshEnsureButtonState];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    if (_isReplenishMobile) {
        self.title = @"绑定手机号";
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    }
}
//-(void)logout{
//    [self.navigationController popViewControllerAnimated:YES];
//    [[LoginManage sharedInstance] doLogout];
//
//}
- (void)back     {
    if (!_isReplenishMobile) {
        // 号码输入框不为空且与原本围栏电话不同
        if (self.phoneNumTextField.text.length && ![self.phoneNumTextField.text isEqualToString:self.geofence.getGeoMobile]) {
            [Util showAlertWithTitle:@"是否保存设置？" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex) {
                    //                [self saveGeofenceChange];
                }    else    {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } cancleButtonTitle:@"丢弃" otherButtonTitles:@"保存", nil];
        }    else    {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
         [self.navigationController popViewControllerAnimated:YES];
    }
    if (_backHandler) {
        _backHandler();
    }
}

- (void)configSMSButtonTitleWithText:(NSString *)title	{
    dispatch_async_on_main_queue(^{
        if (self.getSMSCodeButton.tag == 0)		self.getSMSCodeButtonWidthGuide.constant = 98.f;
        else									self.getSMSCodeButtonWidthGuide.constant = 122.f;
        
        [self.view layoutIfNeeded];
        self.getSMSCodeButton.titleLabel.text = title;
        [self.getSMSCodeButton setTitleForAllState:title];
    });
}

- (void)resetGetSMSButtonTimer		{
    self.SMSTimerCount = 60;
    self.getSMSCodeButton.tag = 100;
    [self configSMSButtonTitleWithText:@"60秒后重新获取"];
    if (self.SMSTimer)    dispatch_cancel(self.SMSTimer);
    __weak __typeof(self) weakSelf = self;
    self.SMSTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.SMSTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.SMSTimer, ^{
        if (weakSelf.SMSTimerCount > 0)		{
            weakSelf.SMSTimerCount --;
            weakSelf.getSMSCodeButton.enabled = NO;
            weakSelf.getSMSCodeButton.layer.borderWidth = 0;
            weakSelf.getSMSCodeButton.tag = 100;
            [weakSelf configSMSButtonTitleWithText:[NSString stringWithFormat:@"%@秒后重新获取", @(weakSelf.SMSTimerCount)]];
        }	else	{
            if (weakSelf.SMSTimer)    dispatch_cancel(weakSelf.SMSTimer);
            weakSelf.getSMSCodeButton.enabled = YES;
            weakSelf.getSMSCodeButton.layer.borderWidth = .5;
            weakSelf.getSMSCodeButton.tag = 0;
            [weakSelf configSMSButtonTitleWithText:@"重新发送"];
        }
    });
    //2.启动定时器
    dispatch_resume(self.SMSTimer);
}

- (void)refreshEnsureButtonState    {
    self.ensureButton.enabled = self.phoneNumTextField.text.length == 11 && self.imgCodeTextField.text.length && self.SMSCodeTextField.text.length;
}

- (void)setGeofence:(NNGeoFence *)geofence		{
    _geofence = [geofence copy];
    NSString *phoneStr = self.geofence.getGeoMobile;
    NSString *titleStr = @"";
    NSString *subTitle = @"";
    if (phoneStr.length == 0) {
        titleStr = @"接收提醒的手机号";
        subTitle = @"请输入手机号和验证码完成验证";
    }	else	{
        titleStr = @"修改手机号";
        subTitle = @"原手机号 ";
        phoneStr = [Util maskMobilePhone:phoneStr];
    }
    
    dispatch_async_on_main_queue(^{
        self.view.backgroundColor = self.view.backgroundColor;
        self.title = titleStr;
        self.subTitleLabel.text = subTitle;
        self.originGeoPhoneLabel.text = phoneStr;
    });
}
- (void)addLoadingCircle {
    if (!_animatedView) {
        _animatedView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _animatedView.strokeThickness = 2;
        _animatedView.strokeColor = UIColorHex(6896ED);
        _animatedView.radius = 8;
    }
    [self.imgCodeButton addSubview:_animatedView];
    [_animatedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.imgCodeButton);
        make.width.height.mas_equalTo(10);
    }];
}
- (void)removeLoadingCircle {
    if (_animatedView) {
        [_animatedView removeFromSuperview];
    }
}

/// 刷新图片验证码
- (IBAction)refreshImgCode {
    [self.imgCodeButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self addLoadingCircle];
    self.imgToken = nil;
    [SOSGeoDataTool getImgCodeForUrl:_isReplenishMobile?SOSReplenishMobile_GetImgCodeURL:SOSSmartDevice_GetImgCodeURL responseSuccess:^(UIImage *img, NSString *imgToken) {
        [self removeLoadingCircle];
        if (img) {
            [self.imgCodeButton setBackgroundImage:img forState:UIControlStateNormal];
            self.imgToken = imgToken;
        }	else	{
            [Util toastWithMessage:@"获取图片验证码失败"];
        }
    } responseFailure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [self removeLoadingCircle];
    }];
}

/// 获取短信验证码
- (IBAction)getSMSCode {
   
    NSString *originPhone = self.geofence.getGeoMobile;
    NSString *errMsg = nil;
    
    if (self.phoneNumTextField.text.length == 0)							errMsg = @"手机号不能为空";
    else if (!([Util isNumeber:self.phoneNumTextField.text] && self.phoneNumTextField.text.length == 11))	errMsg = @"手机号输入有误";
    else if ([self.phoneNumTextField.text isEqualToString:originPhone])		errMsg = @"新的手机号不能与旧手机号一样";
    else if (self.imgCodeTextField.text.length == 0)						errMsg = @"图形验证码不能为空";

    if (errMsg.length) {
        [Util showErrorHUDWithStatus:errMsg];
        return;
    }
    
    [SOSGeoDataTool getSMSCodeForUrl:_isReplenishMobile? SOSReplenishMobile_GetSMSCodeURL:SOSSmartDevice_GetSMSCodeURL withImgCode:self.imgCodeTextField.text imgToken:self.imgToken andPhoneNum:self.phoneNumTextField.text responseSuccess:^(NSString * _Nonnull SMSCode, NSString * _Nonnull SMSToken) {
        self.SMSToken = SMSToken;
        [self resetGetSMSButtonTimer];
        [Util toastWithVerifyCode:SMSCode];
        [Util showSuccessHUDWithStatus:@"验证码已发送"];
        dispatch_async_on_main_queue(^{
            [self.SMSCodeTextField becomeFirstResponder];
        });
    } responseFailure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
}

/// 保存按钮点击
- (IBAction)savePhoneNum 	{
    if (self.ensureButton.isEnabled == NO)		return;
    if ([self.phoneNumTextField.text isEqualToString:self.geofence.getGeoMobile]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_isReplenishMobile) {
        [self saveReplenishMobile];
    }else{
      [self saveGeofenceChange];
    }
}

- (void)saveGeofenceChange    {
    self.geofence.mobilePhone = self.phoneNumTextField.text;
    if (self.geofence.isLBSMode) {
        ((NNLBSGeoFence *)self.geofence).mobile = self.phoneNumTextField.text;
    }
    
    [SOSGeoDataTool verifySMSCodeWithSMSCode:self.SMSCodeTextField.text SMSToken:self.SMSToken Success:^(NSString *authToken) {
        if (self.geofence.isLBSMode) {
            ((NNLBSGeoFence *)self.geofence).mobile = self.phoneNumTextField.text;
            ((NNLBSGeoFence *)self.geofence).verifyFlagtoken = authToken;
        }
        // 
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Mobile), @"Geofence":[self.geofence copy], @"ModifyMobileToken": authToken}];
        [Util showSuccessHUDWithStatus:@"设置成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
}
-(void)saveReplenishMobile{
    [Util showLoadingView];
    [SOSGeoDataTool replenishVerifySMSCodeWithMobile:self.phoneNumTextField.text SMSCode:self.SMSCodeTextField.text Success:^(NSString * _Nonnull authToken) {
        [Util hideLoadView];
        [self replenishMobileSuccess];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NSDictionary *resDic = responseStr.mj_JSONObject;
//        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
//            //                NSString *code = resDic[@"errorCode"];
//            NSString *code = resDic[@"code"];
//            if ([code isEqualToString:@"E3426"]) {
//                 NSString *msg = resDic[@"description"];
//                if ([msg isKindOfClass:[NSString class]])     [Util showErrorHUDWithStatus:msg];
//                return ;
//            }
//            //            if ([msg isKindOfClass:[NSString class]])     [Util showErrorHUDWithStatus:msg];
//        }
        [Util hideLoadView];
        [self replenishMobileFail];
    }];
}
#pragma mark - Textfield Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField	{
    if (textField == self.phoneNumTextField) {
        [self.imgCodeTextField becomeFirstResponder];
    }	else if (textField == self.imgCodeTextField)	{
        [self.SMSCodeTextField becomeFirstResponder];
    }	else if (textField == self.SMSCodeTextField)	{
//        [self savePhoneNum];
    }
    
    return YES;
}

- (void)dealloc        {
    [Util dismissHUD];
    if (self.SMSTimer)    dispatch_cancel(self.SMSTimer);
    NSLog(@"replenishMobile dealloc");
}

#pragma mark - 补充手机号提交后弹框部分
//补充成功
- (void)replenishMobileSuccess        {
    
    [Util showAlertWithTitle:@"绑定成功" message:@"服务手机号绑定成功,如需修改请前往星用户信息修改" confirmBtn:@"知道了" completeBlock:^(NSInteger buttonIndex) {
        [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber = self.phoneNumTextField.text;
        [[LoginManage sharedInstance] saveUserBasicInfo:[CustomerInfo sharedInstance].userBasicInfo.mj_JSONString];
       
        [self.navigationController popViewControllerAnimated:YES];
        if (_completeHandler) {
           _completeHandler();
         }
    }];
}
//补充失败
- (void)replenishMobileFail        {
    //重新发送验证码  清空图形验证码和短验输入框 刷新图形验证码
    [self refreshImgCode];
    self.SMSTimerCount = -1;
    self.imgCodeTextField.text = @"";
    self.SMSCodeTextField.text = @"";
    
    if ([SOSCheckRoleUtil isVisitor]) {
        [Util showAlertWithTitle:@"绑定失败" message:@"请重新绑定服务手机号并确认当前通信环境是否通畅" completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                if (_completeHandler) {
                    _completeHandler();
                }
            }
        } cancleButtonTitle:@"稍后绑定" otherButtonTitles:@"立即重试",nil];
    }else{
        [Util showAlertWithTitle:@"绑定失败" message:@"请重新绑定服务手机号并确认当前通信环境是否通畅" confirmBtn:@"知道了" completeBlock:nil];
    }
    
}
@end

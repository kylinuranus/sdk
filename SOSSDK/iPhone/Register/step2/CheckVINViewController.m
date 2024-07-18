//
//  CheckVINViewController.m
//  Onstar
//
//  Created by Vicky on 13-12-5.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import "CheckVINViewController.h"
#import "SOSVisitorViewController.h"
#import "UnderLineLabel.h"
#import "Util.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"
#import "CustomerInfo.h"
#import "SOSNetworkOperation.h"
#import "LoadingView.h"
#import "VehicleInfoUtil.h"
#import "SOSUrlRequestStatusView.h"
#import "RegisterUtil.h"
#import "SOSCustomAlertView.h"
#import "VehicleEnrollViewController.h"
#import "RegisterMAViewController.h"
#import "CheckVINViewController.h"
#import "SOSOCRViewController.h"
#import "SOSRegisterAgreementView.h"
#import "SOSAgreementAlertView.h"
#import "SOSFlexibleAlertController.h"

@interface CheckVINViewController ()<SOSAlertViewDelegate>
{
    NSString *currentCaptchaId;
    //验证captchaId是否验证成功
    BOOL flag;
}
@property (weak, nonatomic) IBOutlet UIView *captchaViewBG;//验证码容器视图
@property (weak, nonatomic) IBOutlet UIImageView *captchaImageV;  // 验证码图片
@property (weak, nonatomic) IBOutlet UIButton *changeOneBtn; //换一张、刷新验证码
@property (weak, nonatomic) IBOutlet SOSRegisterAgreementView *agreementsView;//安吉星服务协议
@property (weak, nonatomic) IBOutlet UIView *registerViewBG; //注册按钮容器视图
@property (weak, nonatomic) IBOutlet UILabel *labelGetCheck;//注册
@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;//注册按钮;
@property (weak, nonatomic) IBOutlet UIView *nameInputView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *nameRequireTip;
@property (weak, nonatomic) IBOutlet UILabel *govidLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captachaTopConstrain;


@end

@implementation CheckVINViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"RegisterNewUser", nil);
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    
    [self initView];
    //获取图片验证码
    [self getImageCaptcha];
    info3User = NO;
}

#pragma mark - 初始化页面
- (void)initView
{
    _govidLabel.text = [_govidLabel.text stringByAppendingString:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid];
    //注册点击按钮
    _buttonRegister.enabled = NO;
    [_buttonRegister setBackgroundColor:[UIColor colorWithHexString:@"1762cb"] forState:UIControlStateNormal];
    [_buttonRegister setBackgroundColor:[UIColor Gray153] forState:UIControlStateDisabled];
    _buttonRegister.layer.cornerRadius = 3;
    _buttonRegister.layer.masksToBounds = YES;
    
    //换一张、刷新验证码
    _changeOneBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _changeOneBtn.layer.cornerRadius = 2.0;
    _changeOneBtn.layer.masksToBounds = YES;
    //    [_changeOneBtn setTitle:NSLocalizedString(@"changeOneCaptchaImage",nil) forState:UIControlStateNormal];
    //隐藏验证码容器视图
    _captchaViewBG.hidden = YES;
    
    _textfieldVIN.returnKeyType = UIReturnKeyDone;
    //输入车辆VIN/证件号码
    _textfieldVIN.adjustsFontSizeToFitWidth = YES;
    
    //输入开通安吉星服务时的车辆识别码（VIN)或证件号
//    _labelContent.text = NSLocalizedString(@"SB021-17_2", nil);
    
    //注册
//    _labelGetCheck.text = NSLocalizedString(@"RegisterNewUser", nil);
    
    
////    _labelContent.numberOfLines = 1;
//    _labelContent.adjustsFontSizeToFitWidth = YES;
    [_textfieldVIN setupScanButtonWithDelegate:self responseMethod:@selector(pushScanView)];
    _textfieldVIN.rightViewMode = UITextFieldViewModeAlways;
    
    @weakify(self);
    _agreementsView.checkState = ^(BOOL allSelected) {
        [self judgeShouldEnableNextButton];
    };
    _agreementsView.tapAgreement = ^(NSInteger line, NSInteger index) {
        @strongify(self);
        [self.view endEditing:YES];
        if (self.agreements.count < 4 && self.agreements.count > 0) {
            [Util toastWithMessage:@"获取协议内容错误"];
            return;
        }
        SOSAgreement *agreement = self.agreements[line * 2 + index];
        SOSAgreementAlertView *view = [[SOSAgreementAlertView alloc] initWithAlertViewStyle:SOSAgreementAlertViewStyleSignUp];
        view.agreements = @[agreement];
        [view show];
    };


}
- (void)judgeShouldEnableNextButton
{
    BOOL enable = NO;
    if (_textfieldVIN.text.length > 0) {
        enable = _agreementsView.isAllSelected;
    }else {
        enable = NO;
    }
    _buttonRegister.enabled = enable;
}

- (void)pushScanView
{
    [self.view endEditing:YES];
    [SOSDaapManager sendActionInfo:register_scan];
    SOSOCRViewController * myCameraVC = [[SOSOCRViewController alloc] init];
    SOSWeakSelf(weakSelf);
    myCameraVC.currentType = ScanVIN;
    [myCameraVC setScanBlock:^(SOSScanResult * result){
        if (result.resultText != nil) {
            weakSelf.buttonRegister.enabled = YES;
            weakSelf.textfieldVIN.text = result.resultText;
        }
    }];
    [self.navigationController pushViewController:myCameraVC animated:YES];
}

#pragma mark - view Cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    flag = NO;
    currentCaptchaId = nil;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if (!((SOSUrlRequestStatusView *)_textfieldVIN.rightView).clearButtonVisiable) {
//        [((SOSUrlRequestStatusView *)_textfieldVIN.rightView) showClearButton];
//    };
    //验证码限制输入长度
    if (textField == _captchaText) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString];
        if (textField.text.length >= 4)	textField.text = [textField.text substringToIndex:4];
        return NO;
    }
    NSMutableString *newValue = [_textfieldVIN.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if (range.location >= 25) return NO;
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
        if (textField == _firstNameField || textField == _lastNameField) {
            [_nameRequireTip setText:@""];
        }
        return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self judgeShouldEnableNextButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField     {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark -info3
- (void)searchIsInfo3User:(NSString *)userInput
{
    info3User = NO;
    
    [VehicleInfoUtil vehicleIsInfo3JudgeBygid:nil vehicleVin:vinID successHandler:^(ResponseInfo *resp)
     {
         if ([resp.code isEqualToString:@"E0000"] && resp.desc) {
             info3User = YES;
         }
         [self queryVehicleEnrollState];
         
     } failureHandler:^(NSString *responseStr, NNError *error) {
         [self queryVehicleEnrollState];

     }];
    
}
- (void)hideNameInputView
{
    _captachaTopConstrain.constant = _captachaTopConstrain.constant - 90.0;
    _nameInputView.hidden = YES;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 点击注册
- (IBAction)buttonRegisterClicked:(id)sender {
    
    [self.view endEditing:YES];
    if([[Util trim:_textfieldVIN ] length] ==0)
    {
        //不能为空
        _labelVINTip.text = NSLocalizedString(@"NullField", nil);
        return;
    }else{
        _labelVINTip.text = @"";
        vinID = [Util trim:_textfieldVIN ];//@"LSGGF53B7BH0119WE";
    }
    //        //[[SOSReportService shareInstance] recordActionWithFunctionID:Register_Registration];
    if (!self.captchaViewBG.hidden) {
        if (self.captchaText.text.length > 0) {
            //step 1 = 验证图片验证码
            [Util showLoadingView];
            [self getImageCaptchaValidate:currentCaptchaId captchaValue:self.captchaText.text];
        }else{
            self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImage", nil);
            self.errorCaptchaLB.textColor = [UIColor redColor];
        }
    }

}

#pragma mark - 8.0注册,首先查询是否enroll
- (void)queryVehicleEnrollState
{
    dispatch_async(dispatch_get_main_queue(),^(){
    RegisterEnrollDTO * regEnroll = [[RegisterEnrollDTO alloc] init];
    [regEnroll setVin:[vinID uppercaseString]];
    CaptchaDTO * capdto = [[CaptchaDTO alloc] init];
    [capdto setIsRequired:@"1"];
    [capdto setCaptchaId:currentCaptchaId];
    [capdto setCaptchaValue:self.captchaText.text];
    [regEnroll setCaptchaInfo:capdto];
    NSString *json = [regEnroll mj_JSONString];
    SOSWeakSelf(weakSelf);
    [RegisterUtil isCheckEnrollState:YES paragramString:json successHandler:^(NSString *responseStr) {
        [Util hideLoadView];
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        //返回E000，查询正常
        if ([SOSUtil isOperationResponseSuccess:responseDic]) {
                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerType = SOSRegisterVIN;
                    if ([SOSUtil isOperationResponseSuccess:responseDic]) {
                        //返回的是E0000，查询出正常结果
                        SOSEnrollInformation * enrollInfo = [SOSEnrollInformation mj_objectWithKeyValues:[responseDic objectForKey:@"enrollInfo"]];
                        //有enrollinfo
                        if (enrollInfo) {
                            dispatch_async_on_main_queue(^{
                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"您已有注册信息被保存过,\n是否需要继续上次注册?" cancelButtonTitle:@"否" otherButtonTitles:@[@"是"]];
                            [alert setButtonMode:SOSAlertButtonModelHorizontal];
                            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                if (buttonIndex ==0) {
                                    //不使用草稿
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].vin = vinID;
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeFresh;
                                    VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                    dispatch_async_on_main_queue(^{
                                        [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                    });
                                }
                                else
                                {
                                    //使用草稿
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =enrollInfo;
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                    
                                    VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                    //                                    mobVerify.currentRegisterType = SOSRegisterUserTypeExist;
                                    dispatch_async_on_main_queue(^{
                                        [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                    });
                                }
                            }];
                                [alert show];
                            });
                            
                        }
                        else
                        {
                            //没有enrollinfo
                            [SOSRegisterInformation sharedRegisterInfoSingleton].vin = vinID;
                            VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                            [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeFresh;
                            dispatch_async_on_main_queue(^{
                                [self.navigationController pushViewController:mobVerify animated:YES];
                            });
                        }
                    }
                    else
                    {
                        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
                    }
            
        }
        else
        {
            //返回服务端特定报错信息
            if ([SOSUtil isOperationResponseMAAndSubscriber:responseDic]) {
                //step2在GAA中有对应的subscriber，注册过MA
                dispatch_async_on_main_queue(^{
                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已注册过安吉星" detailText:@"您可以登录手机应用后,\n添加车辆" cancelButtonTitle:nil otherButtonTitles:@[@"登录"]];
                [alert setButtonMode:SOSAlertButtonModelHorizontal];
                alert.delegate = self;
                [alert show];
                });
            }
            else
            {
                if ([SOSUtil isOperationResponseEnrolledNoneMA:responseDic]) {
                    dispatch_async_on_main_queue(^{
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"该车已注册安吉星" detailText:@"您与该车不是绑定关系\n您提供的身份证与现有车辆不匹配，请重新修改证件号码或拨打客服电话" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    alert.phoneFunctionID = Register_2step_notification_carnotbound_call;
                    [alert setPageModel:SOSAlertViewModelCallPhoneOnlyPhone];
                    [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                    [alert setButtonMode:SOSAlertButtonModelHorizontal];
                    [alert setButtonClickHandle:^(NSInteger buttonIndex){
                        [SOSDaapManager sendActionInfo:Register_2step_notification_carnotbound_iknow];
                    }];
                        [alert show];
                    });
                }
                else
                {
                    if ([SOSUtil isOperationResponseRequestEnrolled:responseDic])
                    {
                        dispatch_async_on_main_queue(^{
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已提交过车辆注册请求" detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                        if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                            alert.phoneFunctionID = AddCar_submitted_call;
                        }else{
                            alert.phoneFunctionID = register_notification_submited_call;
                        }
                        [alert setPageModel:SOSAlertViewModelRegister];
                        [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                        [alert setButtonMode:SOSAlertButtonModelHorizontal];
                            [alert show];
                        });
                        [SOSDaapManager sendActionInfo:register_notification_submited];
                    }
                    else
                    {
                        dispatch_async_on_main_queue(^(){
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:[Util visibleErrorMessage:responseStr] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                            [alert show];
                        });
                    }
                    
                }
            }
        }
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        NSLog(@"===%@",responseStr);
        [Util hideLoadView];
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        //返回服务端特定报错信息
        if ([SOSUtil isOperationResponseMAAndSubscriber:responseDic]) {
            //step2在GAA中有对应的subscriber，注册过MA
            dispatch_async_on_main_queue(^{
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已注册过安吉星" detailText:@"您可以登录手机应用后,\n添加车辆" cancelButtonTitle:nil otherButtonTitles:@[@"登录"]];
            [alert setButtonMode:SOSAlertButtonModelHorizontal];
            alert.delegate = self;
                [alert show];
            });
        }
        else
        {
            /***已enroll未注册MA****/
            if ([SOSUtil isOperationResponseEnrolledNoneMA:responseDic]) {
                //如果vin已经enroll了，查询用户的email／mobile
                SOSEnrollInformation * enrollInfo = [SOSEnrollInformation mj_objectWithKeyValues:[responseDic objectForKey:@"enrollInfo"]];
                if (enrollInfo) {
                    if (enrollInfo.isMobileUnique && enrollInfo.isEmailUnique) {
                        //设置下一界面vin，email，mobile
                        [SOSRegisterInformation sharedRegisterInfoSingleton].email =enrollInfo.email;
                        [SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer =enrollInfo.mobile;
                        [SOSRegisterInformation sharedRegisterInfoSingleton].vin =vinID;
                        if (info3User) {
                            //                        [SOSRegisterInformation sharedRegisterInfoSingleton].firstName = _firstNameField.text;
                        }
                        RegisterMAViewController * mobVerify = [[RegisterMAViewController alloc] initWithNibName:@"RegisterMAViewController" bundle:nil];
                        mobVerify.isInfo3User  = info3User;
                        dispatch_async_on_main_queue(^{
                            [self.navigationController pushViewController:mobVerify animated:YES];
                        });
                    }
                    else
                    {
                        [Util toastWithMessage:@"手机或者邮箱不唯一!请联系安吉星!"];
                    }
                }
            }
            else
            {
                /**********/
                if ([SOSUtil isOperationResponseRequestEnrolled:responseDic])
                {
                    dispatch_async_on_main_queue(^{
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已提交过车辆注册请求" detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                        alert.phoneFunctionID = AddCar_submitted_call;
                    }else{
                        alert.phoneFunctionID = register_notification_submited_call;
                    }
                    [alert setPageModel:SOSAlertViewModelRegister];
                    [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                    [alert setButtonMode:SOSAlertButtonModelHorizontal];
                        [alert show];
                    });
                    [SOSDaapManager sendActionInfo:register_notification_submited];
                }
                else
                {
                    
                    if ([SOSUtil isOperationResponseAlreadyRegister:responseDic]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"该车已注册安吉星" detailText:@"您与该车不是绑定关系\n您提供的身份证与现有车辆不匹配,请重新修改证件号码或拨打客服电话" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                        alert.phoneFunctionID = Register_2step_notification_carnotbound_call;
                        [alert setPageModel:SOSAlertViewModelCallPhoneOnlyPhone];
                        [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                        [alert setButtonClickHandle:^(NSInteger buttonIndex){
                            [SOSDaapManager sendActionInfo:Register_2step_notification_carnotbound_iknow];
                        }];
                            [alert show];
                        });
                    }
                    else
                    {
                        //VIN 不存在
                        if ([SOSUtil isOperationResponseNonexistenceVIN:responseDic])
                        {
                            dispatch_async_on_main_queue(^(){
                                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"车辆不存在" detailText:@"请您输入正确的VIN号\n或拨打客服电话 400-820-1188" cancelButtonTitle:NSLocalizedString(@"Register_Sure", nil) otherButtonTitles:nil];
                                [alert setButtonClickHandle:^(NSInteger index){
                                    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                                        [SOSDaapManager sendActionInfo:AddCar_Notexist_Iknow];
                                    }else{
                                        [SOSDaapManager sendActionInfo:Register_2step_notification_Vinnotexsit_Iknow];
                                    }
                                }];
                                [alert show];
                            });
                        }
                        else
                        {
                            if ([SOSUtil isOperationResponseMAVINEnrolled:responseDic])
                            {
                                dispatch_async_on_main_queue(^(){
                                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"该车已注册安吉星" detailText:@"您与该车不是绑定关系\n您提供的身份证与现有车辆不匹配,请重新修改证件号码或拨打客服电话" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                                alert.phoneFunctionID = Register_2step_notification_carnotbound_call;
                                [alert setPageModel:SOSAlertViewModelCallPhoneOnlyPhone];
                                [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                                [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                    [SOSDaapManager sendActionInfo:Register_2step_notification_carnotbound_iknow];
                                }];
                                [alert show];
                                });
                            }
                            else
                            {
                                dispatch_async_on_main_queue(^(){
                                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:[Util visibleErrorMessage:responseStr] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                                    [alert show];
                                });
                            }
                            
                        }
                    }
                }
            }
        }
    }];
         });
}
#pragma mark - 注册接口
//- (void)sendToBackground
//{
//    _textfieldVIN.enabled = NO;
//    _buttonRegister.enabled = NO;
//    buttonCamera.enabled = NO;
//    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
//    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
//    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
//    if([[Util trim:_textfieldVIN] length]==17)
//    {
//        if(![Util isValidateVin:[Util trim:_textfieldVIN]])
//        {
//            [self popMessage:NSLocalizedString(@"SB021_MSG019", nil) withTitle:nil];
//            return;
//        }
//        [regRequest setVin:[vinID uppercaseString]];
//    }else{
//        [regRequest setGovernmentID:vinID];
//    }
//    [regRequest setCaptchaId:currentCaptchaId];
//    [regRequest setCaptchaValue:self.captchaText.text];
//    [regRequest setSendCodeSenario:kVerifyCodeSubscriberSenario];
//    if (info3User) {
//        [regRequest setFirstName:_firstNameField.text];//info3
//        [regRequest setLastName:_lastNameField.text];//info3
//    }
//    NSString *json = [regRequest mj_JSONString];
//    NSString *url = [BASE_URL stringByAppendingString:INFO3_REGISTER_CODE_GET];//info3 url change
//
//    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSLog(@"response:%@",responseStr);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _textfieldVIN.enabled = YES;
//            _buttonRegister.enabled = YES;
//            buttonCamera.enabled = YES;
//            [[LoadingView sharedInstance] stop];
//            @try {
//                NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//                NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
//                if ([[operation afOperation] response].statusCode == 200){
//                        mobile = response.mobilePhoneNumber;
//                        email = response.emailAddress;
//                        NSString *isMobileUnique =response.isMobileUnique;
//                        NSString *isEmailUnique = response.isEmailUnique;
//                        OwnerRegCodeViewController *reg =[[OwnerRegCodeViewController  alloc] initWithMobile:mobile Email:email andVin:vinID];
//                        //有手机
//                        if (mobile!= nil && isMobileUnique.boolValue)
//                        {
//                            reg.isMobileExist = YES;
//                            reg.currentMobile = mobile;
//                        }
//                        //有邮箱
//                        if(email != nil && isEmailUnique.boolValue)
//                        {
//                            reg.isEmailExist = YES;
//                            reg.currentEmail = email;
//                        }
//                    if (info3User) {
//                        reg.firstName = _firstNameField.text;
//                        reg.lastName = _lastNameField.text;
//                    }
//                        reg.isFromOwner = YES;
//                        reg.captchaID = currentCaptchaId;
//                        reg.captchaStr = self.captchaText.text;
//                        flag = YES;
//                        [self.navigationController pushViewController:reg animated:YES];
//                }
//            }
//            @catch (NSException * e) {
//                NSLog(@"exception jsonFormatError");
//            }
//        });
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self requestFailed:nil];
//            [[LoadingView sharedInstance] stop];
//            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
//
//        });
//    }];
//    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
//    [operation setHttpMethod:@"PUT"];
//    [operation start];
//}

- (void)requestFailed:(NSString *)request{
    _textfieldVIN.enabled = YES;
    [self judgeShouldEnableNextButton];
    buttonCamera.enabled = YES;
}

#pragma mark -Register Response
- (void)popMessage:(NSString *) message withTitle:(NSString *)title     {
    [_textfieldVIN resignFirstResponder];
    [Util showAlertWithTitle:title message:message completeBlock:nil];
}

#pragma mark - 图片验证码验证
- (void)getImageCaptchaValidate:(NSString *)captchaId captchaValue:(NSString *)captchaValue     {
    
    NSString *url = [BASE_URL stringByAppendingString:
                     [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_VALIDATE,captchaId,captchaValue]];// send verificati
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if ([responseDic[@"code"] isEqualToString:@"E0000"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImage", nil);
//                self.errorCaptchaLB.textColor = [UIColor lightGrayColor];
                //step 2 = 查询车辆是否enroll
                //step 1 查询车辆是否info3
                [self searchIsInfo3User:_textfieldVIN.text];
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImageError", nil);
            self.errorCaptchaLB.textColor = [UIColor redColor];
            [self requestFailed:nil];
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];
    
    [self clearErrorTip];
}

#pragma mark -  获取验证码
- (IBAction)changeOneAct:(id)sender {
    if (flag) {
        [self getImageCaptcha];
    }else{
        if (currentCaptchaId != nil) {
            [self getImageCaptchaGenerate_own:currentCaptchaId];
        }else{
            [self getImageCaptcha];
        }
    }
}

#pragma mark - 图片验证码 请求id
- (void)getImageCaptcha
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CODE_IMAGE_CAPTCHA];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if (responseDic[@"required"]) {
            if (responseDic[@"captchaId"]) {
                currentCaptchaId = responseDic[@"captchaId"];
                [self getImageCaptchaGenerate_own:responseDic[@"captchaId"]];
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertWithTitle:@"获取验证码失败" message:nil completeBlock:nil];
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];
    
}

#pragma mark - 图片验证码 generate
- (void)getImageCaptchaGenerate_own:(NSString *)captchaId     {
    NSString *url = [BASE_URL stringByAppendingString:
                     [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_GENERATE,captchaId]];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil needReturnSourceData:YES successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData* data = [NSData dataWithData:responseStr];
            UIImage *captchaImage = [UIImage imageWithData:data];
            self.captchaImageV.image = captchaImage;
            self.captchaImageV.layer.cornerRadius = 3.0;
            self.captchaImageV.layer.masksToBounds = YES;
            if (self.captchaViewBG.hidden) {
                self.captchaViewBG.hidden = NO;
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *captchaImage = [UIImage imageNamed:@"yanzhengmaFail"];
            self.captchaImageV.image = captchaImage;
            self.captchaImageV.layer.cornerRadius = 3.0;
            self.captchaImageV.layer.masksToBounds = YES;
            if (self.captchaViewBG.hidden) {
                self.captchaViewBG.hidden = NO;
            }
        });
    }];
    [operation setHttpMethod:@"GET"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation start];
    [self clearErrorTip];
}
-(void)clearErrorTip{
    if (self.errorCaptchaLB.text) {
        self.errorCaptchaLB.text = nil;
    }
}
#pragma mark - 非安吉星车主用户点击此注册
- (void)onstarClickUrl{
    [SOSDaapManager sendActionInfo:register_nononstaruser];

    SOSVisitorViewController *Visitor = [[SOSVisitorViewController alloc]initWithNibName:@"SOSVisitorViewController" bundle:nil];
    [self.navigationController pushViewController:Visitor animated:YES];
}
- (void)dealloc
{
    [[SOSRegisterInformation sharedRegisterInfoSingleton] destroyRegisterInfoSingleton];
}
@end

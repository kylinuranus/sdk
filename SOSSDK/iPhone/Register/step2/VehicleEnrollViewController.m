//
//  VehicleEnrollViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "VehicleEnrollViewController.h"
#import "ScanReceiptViewController.h"
#import "RegisterUtil.h"
#import "SOSRegisterTextField.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SOSRegisterInformation.h"
#import "SOSCustomAlertView.h"
#import "NSString+JWT.h"
#import "RegisterUtil.h"
@interface VehicleEnrollViewController ()<UITextFieldDelegate,SOSAlertViewDelegate>
{
    BOOL  isMobileUnique;
}
@property (weak, nonatomic) IBOutlet UIView *freshRegisterView;      //新注册用户显示
@property (weak, nonatomic) IBOutlet UIView *existingRegisterView;   //有草稿的注册用户显示
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *freshMobileVerifyField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *existMobileVerifyField;
@property (weak, nonatomic) IBOutlet UILabel *existMobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *secCodeTip;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UITextField *freshMobileField;
@property (weak, nonatomic) IBOutlet UIScrollView *keyboardScrollView;
@property (weak, nonatomic) IBOutlet UILabel *lb_auth_err01;
@property (weak, nonatomic) IBOutlet UILabel *lb_auth_err02;

@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@end

@implementation VehicleEnrollViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lb_auth_err01.hidden = YES;
    self.lb_auth_err02.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        self.title = NSLocalizedString(@"添加车辆", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"registeNavigateTitle", nil);
    }
       // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    [self initUI];
    isMobileUnique = YES;
}
- (void)initUI
{
    [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
    //根据是否注册手机应用显示验证码界面
    switch ([SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType) {
        case SOSRegisterUserTypeExist:
        {
            self.freshRegisterView.hidden = YES;
            self.secCodeTip.text = @"请输入验证码";
            self.vinLabel.text = [self.vinLabel.text stringByAppendingString:[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.vin.uppercaseString];
            [self.existMobileLabel setText:[self.existMobileLabel.text stringByAppendingString:NONil([[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.mobile stringInterceptionHide])]];
            [self.existMobileVerifyField setupVerifyCodeRightViewWithDelegate:self Method:@selector(willSendPhoneVerifyCode:)];
        }
            break;
        case SOSRegisterUserTypeFresh:
        {
            self.existingRegisterView.hidden = YES;
            self.secCodeTip.text = @"请输入手机号及验证码";
            self.vinLabel.text = [self.vinLabel.text stringByAppendingString:[SOSRegisterInformation sharedRegisterInfoSingleton].vin.uppercaseString];
            [self.freshMobileVerifyField setupVerifyCodeRightViewWithDelegate:self Method:@selector(willSendPhoneVerifyCode:)];
        }
            break;
            
        default:
            break;
    }
    //
}
#pragma mark - 发送验证码
- (void)willSendPhoneVerifyCode:(id)sender
{
    
    switch ([SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType) {
        case SOSRegisterUserTypeExist:
        {
            //已经保存过的手机号，直接发送
            [self didSendPhoneVerifyCode:sender];
        }
            break;
        case SOSRegisterUserTypeFresh:
        {
            //新的手机号，检测合法性
            if ([Util isValidatePhone:self.freshMobileField.text]) {
                [self didSendPhoneVerifyCode:sender];
            }
            else
            {
                //[Util toastWithMessage:@"手机号不合法"];
                SOSCustomAlertView *cusAlertView = [[SOSCustomAlertView alloc] initWithTitle:@"" detailText:@"手机号不合法" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                cusAlertView.backgroundModel = SOSAlertBackGroundModelStreak;
                //cusAlertView.pageModel = SOSAlertViewModelMirrorBindSuccess;
                cusAlertView.buttonClickHandle = ^(NSInteger clickIndex) {
                    if (clickIndex == 1) {
                    }
                };
                [cusAlertView show];
            }
        }
            break;
            
        default:
            break;
    }
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_step2mobile_getverifcode];
    }

}
- (void)didSendPhoneVerifyCode:(id)sender
{
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
        ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMobile];
        [regRequest setEmailAddress:@""];
        [regRequest setSendCodeSenario:kVerifyCodeVisitorSenario];
    switch ([SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType) {
        case SOSRegisterUserTypeExist:
        {
            [regRequest setMobilePhoneNumber:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer];
        }
            break;
        case SOSRegisterUserTypeFresh:
        {
            [regRequest setMobilePhoneNumber:_freshMobileField.text];
            _freshMobileField.userInteractionEnabled = NO;
        }
            break;
        default:
            break;
    }
    NSString *json = [regRequest mj_JSONString];
    [RegisterUtil sendVerifyCode:json successHandler:^(NNRegisterResponse * response) {
        dispatch_async(dispatch_get_main_queue(), ^{
           isMobileUnique = response.isMobileUnique.boolValue;
//           [Util toastWithVerifyCode:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",response.secCode]];
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];

    //倒计时
    UIButton * codeButton =(UIButton * )sender;
    __block NSInteger time = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(time <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [codeButton setTitle:@"重新发送" forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = YES;
            });
            
        }	else	{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [codeButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
    
}
#pragma mark - @protocal textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _existMobileVerifyField) {
        if (range.location==0 && range.length == 1) {
            [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
        }
        else
        {
            [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
        }
    }
    else
    {
        if (textField == _freshMobileVerifyField) {
            
            if (range.location==0 && range.length == 1) {
                [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
            }
            else
            {
                if ([Util isValidatePhone:self.freshMobileField.text]) {
                    [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
                }
                else
                {
                    [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
                }
            }
        }
    }
    
    return YES;
}
#pragma mar]k - 验证验证码
- (IBAction)nextStepScanReceipt:(id)sender {
    [self.view endEditing:YES];
    [SOSDaapManager sendActionInfo:register_2step_next];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //如果是添加车辆，使用phoneNumber注册，不需要验证mobile unique
        if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank || [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank) {
            isMobileUnique = YES;
        }
        else
        {
            //如果添加车辆操作的Visitor是使用email注册，依然要验证mobile unique
        }
    }
    else
    {
        
    }
    [self isMobileUniqueDispatcher];

}
- (void)isMobileUniqueDispatcher
{
    if (isMobileUnique) {
        NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
        [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
        [regRequest setEmailAddress:@""];
        NSString *secCode;
        switch ([SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType) {
            case SOSRegisterUserTypeExist:
            {
                secCode = [Util trim:self.existMobileVerifyField];
                [regRequest setMobilePhoneNumber:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer];
            }
                break;
            case SOSRegisterUserTypeFresh:
            {
                secCode = [Util trim:self.freshMobileVerifyField];
                [regRequest setMobilePhoneNumber:_freshMobileField.text];
            }
                break;
                
            default:
                break;
        }
        [regRequest setSecCode:secCode];
        [regRequest setSendCodeSenario:kVerifyCodeVisitorSenario];
        [Util showLoadingView];
        [RegisterUtil checkVerifyCode:[regRequest mj_JSONString] successHandler:^(NNError * resp)
         {
             dispatch_async_on_main_queue(^(){
                 [Util hideLoadView];
                 if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType == SOSRegisterUserTypeFresh) {
                     [SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer =[Util trim:self.freshMobileField];
                 }
                 ScanReceiptViewController * src = [[ScanReceiptViewController alloc] initWithNibName:@"ScanReceiptViewController" bundle:nil];
                 src.backRecordFunctionID = register_3step_back;
                 [self.navigationController pushViewController:src animated:YES];
                 
             });
             
         } failureHandler:^(NSString *responseStr, NSError *error) {
             [Util hideLoadView];
             [self authFail:responseStr];
         }];
    }
    else
    {
        
        //手机号已经注册
        SOSWeakSelf(weakSelf);
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已注册过安吉星" detailText:@"您可登录手机应用后添加车辆" cancelButtonTitle:@"登录" otherButtonTitles:nil];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger buttonIndex){
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }];
        dispatch_async_on_main_queue(^(){
            [alert show];
        });
    }
}

- (void)authFail:(NSString*)str
{
    NSDictionary *d = [Util dictionaryWithJsonString:str];
    if (![d[@"code"] isEqualToString:@"E0000"]) {
        self.lb_auth_err01.hidden = NO;
        self.lb_auth_err02.hidden = NO;
    }else{
        [Util showAlertWithTitle:nil message:str completeBlock:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

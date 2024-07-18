//
//  SOSVerifyMAMobileViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVerifyMAMobileViewController.h"
#import "RegisterUtil.h"
#import "SOSCustomAlertView.h"
#import "NSString+JWT.h"
@interface SOSVerifyMAMobileViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *verifyCodeField;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@end

@implementation SOSVerifyMAMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"手机验证";
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    self.vinLabel.text = [self.vinLabel.text stringByAppendingString:[_gaaMobile stringInterceptionHide]];
    [SOSUtil setButtonStateDisableWithButton:self.verifyButton];
    [self.verifyCodeField setupVerifyCodeRightViewWithDelegate:self Method:@selector(willSendPhoneVerifyCode:)];

}
- (void)willSendPhoneVerifyCode:(id)sender {
    [self.verifyCodeField resignFirstResponder];
    [self didSendPhoneVerifyCode:sender];
}

- (void)didSendPhoneVerifyCode:(id)sender
{
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMobile];
    [regRequest setEmailAddress:@""];
    [regRequest setSendCodeSenario:kVerifyCodeVisitorSenario];
    [regRequest setMobilePhoneNumber:_gaaMobile];
    NSString *json = [regRequest mj_JSONString];
    [RegisterUtil sendVerifyCode:json successHandler:^(NNRegisterResponse * response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//                [Util toastWithVerifyCode:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",response.secCode]];
//            });
    } failureHandler:^(NSString *responseStr, NSError *error) {
        if ([SOSUtil isOperationResponseAlreadyRegister:[Util dictionaryWithJsonString:responseStr]]) {
            //手机号已经注册
            SOSWeakSelf(weakSelf);
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"您已注册手机应用,\n请登录后添加车辆" cancelButtonTitle:@"取消" otherButtonTitles:@[@"登录"]];
            [alert setButtonMode:SOSAlertButtonModelHorizontal];
            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                if (buttonIndex == 1) {
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
            dispatch_async_on_main_queue(^(){
                [alert show];
            });
        }
        else
        {
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }
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
            
        }else{
            
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
- (IBAction)verifyCode:(id)sender
{
    [self.view endEditing:YES];
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [regRequest setEmailAddress:@""];
    NSString *secCode;
    secCode = [Util trim:self.verifyCodeField];
    [regRequest setMobilePhoneNumber:_gaaMobile];
    [regRequest setSecCode:secCode];
    [regRequest setSendCodeSenario:kVerifyCodeVisitorSenario];
    [Util showLoadingView];
    [RegisterUtil checkVerifyCode:[regRequest mj_JSONString] successHandler:^(NNError * resp)
     {
         [Util hideLoadView];
         dispatch_async_on_main_queue(^(){
             [self.navigationController popViewControllerAnimated:YES];
             if (_verifyBlock) {
                 _verifyBlock(YES);
             }
         });
         
     } failureHandler:^(NSString *responseStr, NSError *error) {
         [Util hideLoadView];
         [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
     }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string     {
    NSMutableString *newValue = [self.verifyCodeField.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if ([newValue length]== 0) {
        [SOSUtil setButtonStateDisableWithButton:self.verifyButton];
    }
    else {
        [SOSUtil setButtonStateEnableWithButton:self.verifyButton];
    }
    return YES;
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

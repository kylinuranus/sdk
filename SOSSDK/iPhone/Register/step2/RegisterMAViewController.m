//
//  RegisterMAViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "RegisterMAViewController.h"
#import "SOSRegisterTextField.h"
#import "RegisterUtil.h"
#import "SOSCustomAlertView.h"
#import "SOSRegisterInformation.h"
#import "NSString+JWT.h"

typedef NS_ENUM(NSInteger,SOSReceiveVerifyCodeType)
{
    SOSReceiveVerifyCodePhone,
    SOSReceiveVerifyCodeEmail,
};
@interface ContactWayModule : NSObject
@property(nonatomic,copy)NSString * metaData;

@property(nonatomic,assign)SOSReceiveVerifyCodeType wayReceive;
@end

@implementation ContactWayModule
@end

@interface RegisterMAViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SOSAlertViewDelegate>
{
    
    UITableView  * reservedList;
    UIView * reservedListbg;               //预留信息列表
    SOSReceiveVerifyCodeType receiveWay;  //验证码接受方式
    NSMutableArray * contactArray;
}
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *verifyCodeField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *mobileNumberField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorCaptchaLB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorLbHeightConstint;
@property(nonatomic,assign) NSInteger time;
@end



@implementation RegisterMAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    self.title = NSLocalizedString(@"registeNavigateTitle", nil);
    self.errorLbHeightConstint.constant = 0;
//    self.nextStepButton.enabled = NO;
//    [self.nextStepButton.layer setCornerRadius:5.0f];
    [self initMobileField];
    [self.verifyCodeField  setupVerifyCodeRightViewWithDelegate:self Method:@selector(willSendPhoneVerifyCode:)];
    [self.passwordField setupPasswordField];
}

//手机号敏感隐藏
- (NSString *)makeShowPhoneNumber		{
    return [@"预留手机号 " stringByAppendingString:[[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer stringInterceptionHide]];
}

//邮箱敏感隐藏
- (NSString *)makeShowEmail		{
    return [@"预留邮箱 " stringByAppendingString:[[SOSRegisterInformation sharedRegisterInfoSingleton].email stringEmailInterceptionHide]];
}

//设置显示预留信息(手机或者邮箱，优先手机)
- (void)initMobileField		{
    if (!contactArray ) {
        contactArray = [NSMutableArray array];
    }
    if (_isInfo3User) {
        [self addInfo3NameField];
    }

    if ([SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer.isNotBlank) {
        //有预留手机号
        ContactWayModule * cwm = [[ContactWayModule alloc] init];
        cwm.metaData  = [self makeShowPhoneNumber];
        cwm.wayReceive = SOSReceiveVerifyCodePhone;
        [self.mobileNumberField setText:cwm.metaData];
        receiveWay = SOSReceiveVerifyCodePhone;
        [contactArray addObject:cwm];
        if ([SOSRegisterInformation sharedRegisterInfoSingleton].email.isNotBlank) {
            //有预留邮箱
            ContactWayModule * cwm = [[ContactWayModule alloc] init];
            cwm.metaData  = [self makeShowEmail];
            cwm.wayReceive = SOSReceiveVerifyCodeEmail;
            [contactArray addObject:cwm];
        }
    }
    else
    {
        if ([SOSRegisterInformation sharedRegisterInfoSingleton].email.isNotBlank) {
            ContactWayModule * cwm = [[ContactWayModule alloc] init];
            cwm.metaData  = [self makeShowEmail];
            cwm.wayReceive = SOSReceiveVerifyCodeEmail;
            receiveWay = SOSReceiveVerifyCodeEmail;
            [self.mobileNumberField setText:cwm.metaData];
            [contactArray addObject:cwm];
        }
    }
    [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
    //设置下拉列表
    if (contactArray.count>1) {
        [self.mobileNumberField setupDropdownComboboxDelegate:self Method:@selector(showCombobox:)];
    }
}

//增加info3用户姓名字段
- (void)addInfo3NameField	{
    self.registerButtonTopConstraint.constant = 80.0f;
    self.info3NameBaseView.hidden = NO;
}

- (void)showCombobox:(id)sender		{
    [self.view endEditing:YES];
    if (!reservedListbg) {
         reservedListbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIView * overlay = [[UIView alloc] initWithFrame:reservedListbg.frame];
        overlay.backgroundColor = [UIColor lightGrayColor];
        overlay.alpha = 0.2f;
        [reservedListbg addSubview:overlay];
        
//        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCombobox)];
//        [reservedListbg addGestureRecognizer:tap];
        // 转换field到table坐标系以确定table位置
        CGRect bgp = [self.fieldBaseView convertRect:self.mobileNumberField.frame toView:reservedListbg];
        reservedList = [[UITableView alloc] initWithFrame:CGRectMake(bgp.origin.x, bgp.origin.y-20.0f, self.mobileNumberField.frame.size.width, self.mobileNumberField.frame.size.height *2) style:UITableViewStylePlain];
        reservedList.backgroundColor = [UIColor clearColor];
        reservedList.delegate = self;
        reservedList.dataSource = self;
        reservedList.scrollEnabled = NO;
        reservedList.separatorStyle = UITableViewCellSeparatorStyleNone;
//        UIView * x = [[UIView alloc] initWithFrame:CGRectMake(bgp.origin.x, bgp.origin.y-20.0f, self.mobileNumberField.frame.size.width, self.mobileNumberField.frame.size.height *2)];
//        x.backgroundColor = [UIColor redColor];
        [reservedListbg addSubview:reservedList];
    }
    [self.view addSubview:reservedListbg];

}

- (void)hideCombobox	{
    [reservedListbg removeFromSuperview];
}

- (void)willSendPhoneVerifyCode:(id)sender	{
    //新的手机号，检测合法性
    switch (receiveWay) {
        case SOSReceiveVerifyCodePhone:
        {
//            if ([Util isValidatePhone:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer])
//            {
                [self didSendPhoneVerifyCode:sender];
//            }
//                 else
//                 {
//                 [Util toastWithMessage:@"手机号不合法"];
//                 }
        }
            break;
        case SOSReceiveVerifyCodeEmail:
        {
//            if ([Util isValidateEmail:[SOSRegisterInformation sharedRegisterInfoSingleton].email])
//            {
                [self didSendPhoneVerifyCode:sender];
                
//            }
//            else
//            {
//                [Util toastWithMessage:@"邮箱不合法"];
//            }
        }
            break;
        default:
            break;
    }
}

//发送验证码后信息不可更改
- (void)disableInput	{
    [self.mobileNumberField clearRightView];
}

- (void)didSendPhoneVerifyCode:(id)sender	{
    [self disableInput];
    //发送验证码请求
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    if(receiveWay == SOSReceiveVerifyCodePhone)		{
        ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMobile];
        [regRequest setEmailAddress:@""];
        [regRequest setMobilePhoneNumber:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer];
        
        
    }   else   {
        ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMailAddress];
        [regRequest setEmailAddress:[SOSRegisterInformation sharedRegisterInfoSingleton].email];
        [regRequest setMobilePhoneNumber:@""];
        [regRequest setDestType:@"E"];
        
    }
    [regRequest setSendCodeSenario:kVerifyCodeSubscriberSenario];

    NSString *json = [regRequest mj_JSONString];
    [RegisterUtil sendVerifyCode:json successHandler:^(NNRegisterRequest * response) {
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    //倒计时
    UIButton * codeButton =(UIButton * )sender;
    self.time = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    @weakify(self)
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self)
        if(self.time <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [codeButton setTitle:@"重新发送" forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = self.time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [codeButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = NO;
            });
            self.time--;
        }
    });
    dispatch_resume(_timer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contactArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.mobileNumberField.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:12.0];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"59708A"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.textLabel setText:((ContactWayModule *)([contactArray objectAtIndex:indexPath.row])).metaData];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mobileNumberField.text = ((ContactWayModule *)([contactArray objectAtIndex:indexPath.row])).metaData;
    receiveWay = ((ContactWayModule *)([contactArray objectAtIndex:indexPath.row])).wayReceive;
    [self hideCombobox];
}

- (IBAction)continueNextStep:(id)sender {
    self.errorLbHeightConstint.constant = 0;
    [self.view endEditing:YES];
    [SOSDaapManager sendActionInfo:register_2step_next];
    if (![Util isValidatePassword:self.passwordField.text]) {
        [Util toastWithMessage:@"您的密码格式输入有误"];
    }else{
        NNRegisterRequest *regRequest ;
        if (_isInfo3User) {
            if (self.info3FirstName.text.isNotBlank && self.info3LastName.text.isNotBlank ) {
                regRequest = [[NNRegisterRequest alloc]init];
                [regRequest setFirstName:self.info3FirstName.text];
                [regRequest setLastName:self.info3LastName.text];
            }
            else
            {
                [Util toastWithMessage:@"必须输入姓和名!"];
                return;
            }
        }
        else
        {
            regRequest = [[NNRegisterRequest alloc]init];
        }
        [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
        
        if(receiveWay== SOSReceiveVerifyCodePhone)
        {
            ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMobile];
            [regRequest setEmailAddress:@""];
            [regRequest setMobilePhoneNumber:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer];
            
        }   else   {
            ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ValidateMailAddress];
            [regRequest setEmailAddress:[SOSRegisterInformation sharedRegisterInfoSingleton].email];
            [regRequest setMobilePhoneNumber:@""];
            [regRequest setDestType:@"E"];
        }
            if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerType == SOSRegisterGOVID) {
                [regRequest setGovernmentID:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid];
            }
            else
            {
                [regRequest setVin:[SOSRegisterInformation sharedRegisterInfoSingleton].vin];
            }

        [regRequest setPassWord:self.passwordField.text];
        [regRequest setSecCode:self.verifyCodeField.text];
        NSString *json = [regRequest mj_JSONString];
        [Util showLoadingView];
        [RegisterUtil registAsOwner:nil paragramString:json successHandler:^(SOSNetworkOperation *operation,NSString *responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                {
                    NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
                    NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
                    NSString *errorCode = response.code;
                    if (operation.statusCode == 200) {
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"恭喜您成功注册安吉星手机应用" detailText:NSLocalizedString(@"Register_Success_Prompt", nil) cancelButtonTitle:nil otherButtonTitles:@[@"登录"]];
                        [alert setButtonMode:SOSAlertButtonModelHorizontal];
                        [alert setButtonClickHandle:^(NSInteger clickIndex){
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            if (receiveWay == SOSReceiveVerifyCodePhone) {
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer forKey:NN_MASK_USERNAME];
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer forKey:NN_CURRENT_USERNAME];
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer forKey:NN_TEMP_USERNAME];
                                [defaults synchronize];
                            }
                            else
                            {
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].email forKey:NN_MASK_USERNAME];
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].email forKey:NN_CURRENT_USERNAME];
                                [defaults setObject:[SOSRegisterInformation sharedRegisterInfoSingleton].email forKey:NN_TEMP_USERNAME];
                                [defaults synchronize];
                            }
                            [SOSDaapManager sendActionInfo:onstarpersonalinfor_notification_phonenotmatch_reverify];
                        }];
                        alert.delegate = self;
                        [alert show];
                    }else{
                        [self resetSMSState];
                        if ([errorCode length]>= 1) {
                            NSString *errorMssage = NSLocalizedString(errorCode, nil);
                            NSLog(@"errorMssage is:%@", errorMssage);
                            [Util showAlertWithTitle:nil message:errorMssage completeBlock:nil];
                        }
                        else
                        {
                            
                        }
                    }
                    
                }
            });
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [self resetSMSState];
            id response = [responseStr toBasicObject];
            BOOL showErrorCodeLb = NO;
            if ([response isKindOfClass:[NSDictionary class]]) {
//                if ([response[@"code"] isEqualToString:@"E3324"] || [response[@"code"] isEqualToString:@"E3314"]) {
                if ([response[@"code"] isEqualToString:@"E3314"]) {
                    self.errorLbHeightConstint.constant = 30;
                    showErrorCodeLb = YES;
                }else if ([response[@"code"] isEqualToString:@"E3324"])
                {
                    showErrorCodeLb = NO;
                }
            }
            if (!showErrorCodeLb) {
                [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
            }

        }];
    }
    
}

- (void)resetSMSState {
    self.time = 0;
    self.verifyCodeField.text = @"";
}

#pragma mark - delegate
- (void)sosAlertView:(SOSCustomAlertView *)alertView didClickButtonAtIndex:(NSInteger )buttonIndex	{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField	{
    if (textField == self.mobileNumberField) {
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    
    if (range.location==0 && range.length == 1) {
        [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
    }
    else
    {
        if (textField == self.verifyCodeField) {
            if ([Util trim:self.passwordField].length >0) {
                [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
            }
        }
        else
        {
            if ([Util trim:self.verifyCodeField].length >0) {
                [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
            }
        }
    }
    return YES;
}

@end

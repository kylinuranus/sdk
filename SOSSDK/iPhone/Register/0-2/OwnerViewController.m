//
//  OwnerViewController.m
//  Onstar
//
//  Created by Vicky on 13-12-5.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import "OwnerViewController.h"
#import "SOSVisitorViewController.h"
#import "UnderLineLabel.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"
#import "VehicleInfoUtil.h"
#import "SOSUrlRequestStatusView.h"
#import "RegisterUtil.h"
#import "SOSCustomAlertView.h"
#import "VehicleEnrollViewController.h"
#import "RegisterMAViewController.h"
#import "CheckVINViewController.h"
#import "verifyGovidViewController.h"
#import "SOSCardUtil.h"
//test vc
#import "SubmitPersonalInfoViewController.h"
#import "SOSSelectDealerVC.h"
#import "ScanReceiptViewController.h"
#import "InputPinCodeView.h"
#import "SOSOCRViewController.h"
#import "AccountTypeTableViewController.h"
#import "NSString+JWT.h"
//#import "SOSVerifyMAMobileViewController.h"
//#import "MeSelectInsuranceViewController.h"
#import "SOSInsuranceViewController.h"
#import "SOSRegisterAgreementView.h"
#import "SOSAgreementAlertView.h"
#import "SOSAgreement.h"

@interface OwnerViewController ()<SOSAlertViewDelegate>
{
   __block NSString *currentCaptchaId;
    //验证captchaId是否验证成功
    UIView * inputBaseView;//info3补充姓名baseView
    BOOL isFromScan;
}
@property (weak, nonatomic) IBOutlet UIView *captchaViewBG;//验证码容器视图
@property (weak, nonatomic) IBOutlet UIImageView *captchaImageV;  // 验证码图片
@property (weak, nonatomic) IBOutlet UIButton *changeOneBtn; //换一张、刷新验证码

@property (weak, nonatomic) IBOutlet SOSRegisterAgreementView *agreementsView;

@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;//注册按钮;
@property (weak, nonatomic) IBOutlet UnderLineLabel *onsatrLabel;
@property (strong, nonatomic)  SOSRegisterTextField *firstNameField;
@property (strong, nonatomic)  SOSRegisterTextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *promptedLabel;  //扫描框上输入提示语
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *protocalTopConstraint; //协议文字距离验证码输入框距离

@property (strong, nonatomic) NSMutableArray<SOSAgreement *> *agreements;
@end

static CGFloat nameInputHeight = 50;

@implementation OwnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"RegisterNewUser", nil);
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    //currentCaptchaId = nil;
    //非安吉星车主用户点击此注册
    //    _onsatrLabel.shouldUnderline = YES;
    _onsatrLabel.lineWidth = 1.0;
    [_onsatrLabel setText:NSLocalizedString(@"Not_Onstar_Subscriber", nil) andFrame:_onsatrLabel.bounds];
    [_onsatrLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onstarClickUrl)]];
    //注册点击按钮
    _buttonRegister.enabled = NO;
    [_buttonRegister setBackgroundColor:[UIColor colorWithHexString:@"1762cb"] forState:UIControlStateNormal];
    [_buttonRegister setBackgroundColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
    _buttonRegister.layer.cornerRadius = 3;
    _buttonRegister.layer.masksToBounds = YES;
    
    //换一张、刷新验证码
    _changeOneBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _changeOneBtn.layer.cornerRadius = 2.0;
    _changeOneBtn.layer.masksToBounds = YES;
    
    //隐藏验证码容器视图
    _captchaViewBG.hidden = YES;
    
    [self initPageForiPhone];
    
    //获取图片验证码
    [self getImageCaptcha];
    
    [_textfieldVIN setupScanButtonWithDelegate:self responseMethod:@selector(pushScanView)];
    _textfieldVIN.rightViewMode = UITextFieldViewModeAlways;
    __weak __typeof(self)weakSelf = self;
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [weakSelf judgeShouldEnableNextButton];
    }];
    
    info3User = NO;
    
    self.currentRegisterType = SOSRegisterVIN;
    
    _agreements = @[].mutableCopy;
    NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS), agreementName(SGM_TC), agreementName(SGM_PS)];
    [self requestAgreements:types];
    _agreementsView.checkState = ^(BOOL allSelected) {
        [weakSelf judgeShouldEnableNextButton];
    };
    _agreementsView.tapAgreement = ^(NSInteger line, NSInteger index) {
        [weakSelf.view endEditing:YES];
        if ((weakSelf.agreements.count < types.count && weakSelf.agreements.count > 0) || (weakSelf.agreements.count == 0)) {
            [Util toastWithMessage:@"获取协议内容错误"];
            return;
        }
        SOSAgreement *agreement = weakSelf.agreements[line * 2 + index];
        SOSAgreementAlertView *view = [[SOSAgreementAlertView alloc] initWithAlertViewStyle:SOSAgreementAlertViewStyleSignUp];
        view.agreements = @[agreement];
        [view show];
    };

}


/**
 获取协议

 @param types 协议s
 */
- (void)requestAgreements:(NSArray<NSString *> *)types {
    [SOSAgreement requestAgreementsWithTypes:types success:^(NSDictionary *response) {
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                
                NSLog(@"response=%@",response[obj]);
                if(response[obj]!=[NSNull null]){
                    
                    SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                    [_agreements addObject:model];
                }
          
            }
        }];
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"获取协议内容失败"];
    }];
}

/**
 进入扫描界面
 */
- (void)pushScanView
{
    [self.view endEditing:YES];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay != SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:register_scan];
    }
    else
    {
        [SOSDaapManager sendActionInfo:AddCar_VIN_Camera];
    }
    if (self.vinCodeOnly) {
        //如果是单独扫描vin
        SOSOCRViewController * myCameraVC = [[SOSOCRViewController alloc] init];
        SOSWeakSelf(weakSelf);
        myCameraVC.backRecordFunctionID = AddCar_Camera_back;
        myCameraVC.currentType = ScanVIN;
        [myCameraVC setScanBlock:^(SOSScanResult * result){
            if (result.resultText != nil) {
                isFromScan = YES;
                weakSelf.textfieldVIN.text = result.resultText;
                [weakSelf judgeShouldEnableNextButton];
            }
        }];
        [self.navigationController pushViewController:myCameraVC animated:YES];
    }
    else
    {
        SOSOCRViewController * myCameraVC = [[SOSOCRViewController alloc] init];
        SOSWeakSelf(weakSelf);
        myCameraVC.scanIDCardFront = YES;
        myCameraVC.backFunctionID = register_scanVIN_ID_back;
        [myCameraVC setScanBlock:^(SOSScanResult * result){
            if (result.resultText != nil) {
                isFromScan = YES;  // willAppear中不重置currentCaptchaId，避免扫身份证后验证码总提示失败
//                weakSelf.buttonRegister.enabled = YES;
                weakSelf.textfieldVIN.text = result.resultText;
                [weakSelf judgeShouldEnableNextButton];
            }
        }];
        [self.navigationController pushViewController:myCameraVC animated:YES];
    }
}
//visitor添加车辆设置界面状态
- (void)visitorAddVehicleConfigView
{
    [Util showLoadingView];
    NNGAAEmailPhoneRequest * req = [[NNGAAEmailPhoneRequest alloc] init];
    req.emailAddress = [CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress;
    req.mobilePhoneNumber = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
    //查询visitor是否存在gaa,如果不存在gaa，则只能输入vin
    [RegisterUtil queryIsGAAMobileAndEmail:req successHandler:^(NSString *responseStr) {
        [Util hideLoadView];
        if (![SOSUtil isOperationResponseDescSuccess:[Util dictionaryWithJsonString:responseStr]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self viewVINOnly];
            }
                           );
        }
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util toastWithMessage:responseStr];
    }];
}
//仅允许输入VIN
- (void)viewVINOnly {
    self.vinCodeOnly = YES;
    self.promptedLabel.text = NSLocalizedString(@"Upgrade_Subscriber_Prompt", nil);
    self.textfieldVIN.placeholder = NSLocalizedString(@"Please_Input_VIN", nil);
}

#pragma mark - 初始化页面
- (void)initPageForiPhone
{
    //添加车辆修正界面显示内容
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle ) {
        self.onsatrLabel.hidden = YES;
        self.title = @"添加车辆";
        if ([SOSCheckRoleUtil isVisitor]) {
            //如果是visitor升级车主，首先检查visitor是否已经存在gaa
            [self visitorAddVehicleConfigView];
        }
        else
        {  //如果是subscriber／driver／proxy添加车辆，界面只接受vin输入
            [self viewVINOnly];
        }
        self.backRecordFunctionID = AddCar_back;
    }
    else{
        self.backRecordFunctionID = register_1step_back;
    }
    _textfieldVIN.returnKeyType = UIReturnKeyDone;
    _textfieldVIN.adjustsFontSizeToFitWidth = YES;
    //输入开通安吉星服务时的车辆识别码（VIN)或证件号
    _labelContent.text = NSLocalizedString(@"SB021-17_2", nil);
    //注册
    [_buttonRegister setTitle:NSLocalizedString(@"Next_Step", nil) forState:0];
    _labelContent.numberOfLines = 1;
    _labelContent.adjustsFontSizeToFitWidth = YES;
}

#pragma mark - 取消键盘
- (void)cancelBackKeyboard:(id)sender     {
    [self.view endEditing:YES];
}

#pragma mark - view Cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!isFromScan) {      // 身份证或者vin码扫描界面回退，不重置currentCaptchaId，避免扫身份证后验证码总提示失败
        currentCaptchaId = nil;
    }
    isFromScan = NO;   //重置
}


#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //验证码限制输入长度
    if (textField == _captchaText) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString];
        if (textField.text.length >= 4)	textField.text = [textField.text substringToIndex:4];
        return NO;
    }
    NSMutableString *newValue = [_textfieldVIN.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
//    [self judgeShouldEnableNextButton];

    if (range.location >= 30) return NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textfieldVIN) {
        if ([Util trim:textField].length >0) {
            [self searchIsInfo3User:textField.text];
        }
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self judgeShouldEnableNextButton];
//    _buttonRegister.enabled = NO;
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
    NSString * vin;
    NSString * gid;
    vinID = [Util trim:_textfieldVIN ];//@"LSGGF53B7BH0119WE";
    
    if ([vinID isValidateRegisterIdentification]) {
        //如果是身份证／vin
        if ([vinID isValidateRegisterVINOrIDCard]) {
            if ([vinID isValidateVIN]) {
                //如果是vin
                self.currentRegisterType = SOSRegisterVIN;
            }	else	{
                if (self.vinCodeOnly) {
                    return;
                }	else	{
                    self.currentRegisterType = SOSRegisterGOVID;
                }
            }
        }	else	{
            //如果是其他证件号，(港澳台等)
            self.currentRegisterType = SOSRegisterGOVID;
        }
    }
    if (self.currentRegisterType == SOSRegisterVIN) 	vin = vinID;
    else												gid = vinID;
    [VehicleInfoUtil vehicleIsInfo3JudgeBygid:gid vehicleVin:vin successHandler:^(ResponseInfo *resp)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([resp.code isEqualToString:@"E0000"] && resp.desc) {
                 info3User = YES;
                 //如果是visitor升级车主，并且是info3车或者证件号，同时不是CMS注册的用户,则需让用户补充姓名
                 if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle &&[SOSCheckRoleUtil isVisitor] && ![[CustomerInfo sharedInstance] isCMSRegisterUser])
                 {
                     [self insertNameInputField];
                 }
             }
             else
             {
                 [self hiddeNameInputField];
             }
             
         });
     } failureHandler:^(NSString *responseStr, NNError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self hiddeNameInputField];
         });
     }];
    
}

#pragma mark -visitor添加info3车辆补充用户姓名UI
/**
 增加visitor添加info3车辆补充用户姓名界面
 */
- (void)insertNameInputField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!inputBaseView) {
            inputBaseView = [[UIView alloc] init];
            //        inputBaseView.backgroundColor = [UIColor redColor];
            [self.view addSubview:inputBaseView];
            [inputBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.captchaViewBG.mas_bottom).offset(0);
                make.height.equalTo(@(nameInputHeight));
                make.leading.equalTo(self.view.mas_leading).offset(40);
                make.trailing.equalTo(self.view.mas_trailing).offset(-40);
            }];
            
            UILabel * firstNameTitle = [SOSUtil onstarLabelWithFrame:CGRectZero fontSize:16.0f];
            [firstNameTitle setText:@"姓:"];
            [inputBaseView addSubview:firstNameTitle];
            [firstNameTitle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(inputBaseView.mas_leading).offset(0);
                make.centerY.equalTo(inputBaseView.mas_centerY);
                make.width.equalTo(@30);
                make.height.equalTo(@30);
            }];
            
            self.firstNameField = [[SOSRegisterTextField alloc] initWithFrame:CGRectZero];
            self.firstNameField.layer.masksToBounds = YES;
            self.firstNameField.layer.cornerRadius = 4;
            self.firstNameField.backgroundColor = [UIColor whiteColor];
            [self.firstNameField setPlaceholder:@"姓氏"];
            
            [inputBaseView addSubview:self.firstNameField];
            [self.firstNameField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(firstNameTitle.mas_right).offset(0);
                make.centerY.equalTo(inputBaseView.mas_centerY);
                make.height.equalTo(@30);
                make.right.equalTo(inputBaseView.mas_centerX).offset(0);
            }];
            
            UILabel * lastNameTitle = [SOSUtil onstarLabelWithFrame:CGRectZero fontSize:16.0f];
            [lastNameTitle setText:@"名:"];
            [inputBaseView addSubview:lastNameTitle];
            [lastNameTitle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(inputBaseView.mas_centerX).offset(0);
                make.width.equalTo(@30);
                make.height.equalTo(@30);
                make.centerY.equalTo(inputBaseView.mas_centerY);
            }];
            
            self.lastNameField = [[SOSRegisterTextField alloc] initWithFrame:CGRectZero];
            self.lastNameField.backgroundColor = [UIColor whiteColor];
            self.lastNameField.layer.masksToBounds = YES;
            self.lastNameField.layer.cornerRadius = 4;
            [inputBaseView addSubview:self.lastNameField];
            [self.lastNameField setPlaceholder:@"名字"];
            [self.lastNameField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastNameTitle.mas_right).offset(0);
                make.centerY.equalTo(inputBaseView.mas_centerY);
                make.height.equalTo(@30);
                make.trailing.equalTo(inputBaseView.mas_trailing);
            }];
            
            self.protocalTopConstraint.constant =  self.protocalTopConstraint.constant + nameInputHeight;
        }
    });
}
- (void)hiddeNameInputField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (inputBaseView) {
            [inputBaseView removeFromSuperview];
            inputBaseView = nil;
            self.protocalTopConstraint.constant =  self.protocalTopConstraint.constant - nameInputHeight;
        }
    });
    
}
- (void)queryVINorGovid
{
    //step 2 = 查询车辆是否enroll
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //如果是升级车主或者添加车辆,首先检查车辆enroll状态
        [self queryVisitorState];
    }
    else
    {
        //如果是注册enroll
        [self queryVehicleEnrollState];
    }
}


#pragma mark - 点击注册
- (IBAction)buttonRegisterClicked:(id)sender {
    [self.view endEditing:YES];
    if (inputBaseView != nil) {
        if (![self.firstNameField.text isNotBlank] ||![self.lastNameField.text isNotBlank] ) {
            [Util toastWithMessage:@"请输入姓名"];
            return;
        }
    }
    if([[Util trim:_textfieldVIN ] length] ==0)
    {
        //不能为空
        _labelVINTip.text = NSLocalizedString(@"NullField", nil);
        return;
    }else{
        _labelVINTip.text = @"";
        vinID = [Util trim:_textfieldVIN ];//@"LSGGF53B7BH0119WE";
        //如果是合法证件号
        if ([vinID isValidateRegisterIdentification]) {
            //如果是身份证／vin
            if ([vinID isValidateRegisterVINOrIDCard]) {
                if ([vinID isValidateVIN]) {
                    //如果是vin
                    self.currentRegisterType = SOSRegisterVIN;
                }
                else
                {
                //defectid 20342
                //最终TL决定: 前端去掉判断条件，或者提示改成跟后端一样的话术，但建议前端去掉判断条件
//                    ________________________________________
                    
                    if (self.vinCodeOnly) {
                        //[Util toastWithMessage:@"您输入的证件号码/VIN已注册，请使用您注册时的账号进行登入。"];
                        [self shouldInputVin];

                        return;
                    }
                    else
                    {
                        self.currentRegisterType = SOSRegisterGOVID;
                    }
                }
                if (!self.captchaViewBG.hidden) {
                    if (self.captchaText.text.length > 0) {
                        //step 0 = 验证图片验证码
                        [Util showLoadingView];
                        [self getImageCaptchaValidate:currentCaptchaId captchaValue:self.captchaText.text];
                    }else{
                        self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImage", nil);
                        self.errorCaptchaLB.textColor = [UIColor redColor];
                    }
                }
            }
            else
            {
                if (self.vinCodeOnly) {
                    //[Util toastWithMessage:@"您输入的证件号码/VIN已注册，请使用您注册时的账号进行登入。"];
                    [self shouldInputVin];
                    return;
                }else{
                    //如果是其他证件号，(港澳台等)
                    self.currentRegisterType = SOSRegisterGOVID;
                    if (!self.captchaViewBG.hidden) {
                        if (self.captchaText.text.length > 0) {
                            //step 0 = 验证图片验证码
                            [Util showLoadingView];
                            self.isOtherGovid = YES;
                            [self getImageCaptchaValidate:currentCaptchaId captchaValue:self.captchaText.text];
                        }else{
                            self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImage", nil);
                            self.errorCaptchaLB.textColor = [UIColor redColor];
                        }
                    }
                }
                
            }
        }
        else
        {
            [Util toastWithMessage:@"可支持6~25位数字、字母或汉字，但不支持特殊字符"];
        }
    }
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_Camera_submit];
    }
    else
    {
        [SOSDaapManager sendActionInfo:register_1step_next];
    }
}
-(void)shouldInputVin{
    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"车辆不存在" detailText:NSLocalizedString(@"Register_Inexist_VIN", nil) cancelButtonTitle:NSLocalizedString(@"Register_Sure", nil) otherButtonTitles:nil];
    [alert setButtonClickHandle:^(NSInteger index){
        [SOSDaapManager sendActionInfo:AddCar_Notexist_Iknow];
    }];
    [alert show];
}
#pragma mark - 8.0升级车主及添加车辆，首先查询Visitor与输入VIN／govid关系
- (void)queryVisitorState
{
    NNVehicleAddRequest * VisitorQuery = [[NNVehicleAddRequest alloc] init];
    switch (self.currentRegisterType) {
        case SOSRegisterVIN:
        {
            [VisitorQuery setVin:[vinID uppercaseString]];
        }
            break;
        case SOSRegisterGOVID:
        {
            [VisitorQuery setGovernmentID:vinID];
        }
            break;
        default:
            break;
    }
    [VisitorQuery setIdpUserID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    [VisitorQuery setSubscriberID:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];
    [VisitorQuery setAccountNumber:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    if (inputBaseView != nil) {
        [VisitorQuery setFirstName:self.firstNameField.text];//info3
        [VisitorQuery setLastName:self.lastNameField.text];//info3
    }
    [VisitorQuery setMobilePhoneNumber:[CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber];
    [VisitorQuery setEmailAddress:[CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress];
    [VisitorQuery setCaptchaId:currentCaptchaId];
    [VisitorQuery setCaptchaValue:self.captchaText.text];
    NSString *json = [VisitorQuery mj_JSONString];
    [RegisterUtil checkVisitorWithVINOrGovidState:json successHandler:^(NSString *responseStr) {
        NSDictionary * dic =[Util dictionaryWithJsonString:responseStr];
        if ([SOSUtil isOperationResponseDescSuccess:dic]) {
            //然后查询vin状态
            [self queryVehicleEnrollState];
        }else
        {
            [Util hideLoadView];
            NSArray * showAlertArr = [SOSUtil visitorAddVehicleResponse:dic];
            if (showAlertArr) {
                dispatch_async_on_main_queue(^{
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:showAlertArr[1] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    [alert setButtonClickHandle:^(NSInteger buttonIndex){
                        if ([showAlertArr[2] isEqualToString:@"E3139"] || [showAlertArr[2] isEqualToString:@"E3141"])
                        {
                            //升级车主成功,
                            [SOSDaapManager sendActionInfo:AddCar_Success_Iknow];
                            [[LoginManage sharedInstance] doLogout];
                            [self.navigationController  popToRootViewControllerAnimated:YES];
                        }
                    }];
                    [alert setButtonMode:SOSAlertButtonModelVertical];
                    alert.delegate = self;
                    [alert show];
                });
            }
            else
            {
                dispatch_async_on_main_queue(^{
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:responseStr cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    [alert setButtonClickHandle:nil];
                    [alert setButtonMode:SOSAlertButtonModelVertical];
                    alert.delegate = self;
                    [alert setButtonClickHandle:^(NSInteger clickIndex){
                        [SOSDaapManager sendActionInfo:AddCar_Fail_Iknow];
                    }];
                    [alert show];
                });
            }
            
        }
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        
        [self handleFailResponse:responseStr];
    }];
}

/**
 不同报错话术的处理
 @param failRes
 */
- (void)handleFailResponse:(NSString *)failRes
{
    NSDictionary * responseDic = [Util dictionaryWithJsonString:failRes];
    NSArray * showAlertArr = [SOSUtil visitorAddVehicleResponse:responseDic];
    if (showAlertArr != nil) {
        //关联了多个subscriber
        if ([showAlertArr[2] isEqualToString:@"E3104"]) {
            dispatch_async_on_main_queue(^{
                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:showAlertArr[1] cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"]];
                [alert setButtonClickHandle:^(NSInteger buttonIndex){
                    if (buttonIndex == 1) {
                        [SOSDaapManager sendActionInfo:AddCar_step1multiowner_continue];
                        verifyGovidViewController * verify = [[verifyGovidViewController alloc] initWithNibName:@"verifyGovidViewController" bundle:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:verify animated:YES];
                        });
                    }else{
                        [SOSDaapManager sendActionInfo:AddCar_step1multiowner_cancel];
                    }
                }];
                [alert setButtonMode:SOSAlertButtonModelVertical];
                alert.delegate = self;
                [alert show];
            });
        }
        else
        {
            //已注册用户与该车无绑定关系,致电客服
            if ([showAlertArr[2] isEqualToString:@"E3135"]) {
                dispatch_async_on_main_queue(^{
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    [alert setPageModel:SOSAlertViewModelRegisterFail];
                    [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                    [alert setButtonMode:SOSAlertButtonModelHorizontal];
                    [alert setPhoneFunctionID:AddCar_Fail_call];
                    [alert show];
                });
            }
            else
            {
                //车辆未enroll但有Draft
                if ([showAlertArr[2] isEqualToString:@"E3131"])
                {
                    dispatch_async_on_main_queue(^{
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                        [alert setPageModel:SOSAlertViewModelRegister];
                        [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                        [alert setButtonMode:SOSAlertButtonModelHorizontal];
                        [alert show];
                    });
                }
                else
                {
                    dispatch_async_on_main_queue(^{
                        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:showAlertArr[1] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                        [alert setButtonMode:SOSAlertButtonModelVertical];
                        alert.delegate = self;
                        [alert show];
                    });
                }
            }
        }
    }
    else
    {
        dispatch_async_on_main_queue(^{
            
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"添加失败" detailText:[Util visibleErrorMessage:failRes] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert setButtonMode:SOSAlertButtonModelHorizontal];
            alert.delegate = self;
            [alert show];
        });
    }
}
#pragma mark - 8.0注册,首先查询是否enroll
- (void)queryVehicleEnrollState
{
    RegisterEnrollDTO * regEnroll = [[RegisterEnrollDTO alloc] init];
    switch (self.currentRegisterType) {
        case SOSRegisterVIN:
        {
            [regEnroll setVin:[vinID uppercaseString]];
        }
            break;
        case SOSRegisterGOVID:
        {
            [regEnroll setGovid:[vinID uppercaseString]];
        }
            break;
        default:
            break;
    }
    CaptchaDTO * capdto = [[CaptchaDTO alloc] init];
    [capdto setIsRequired:@"1"];
    [capdto setCaptchaId:currentCaptchaId];
    [capdto setCaptchaValue:self.captchaText.text];
    [regEnroll setCaptchaInfo:capdto];
    NSString *json = [regEnroll mj_JSONString];
    //VIN和govid请求不同接口
    SOSWeakSelf(weakSelf);
    [RegisterUtil isCheckEnrollState:(self.currentRegisterType == SOSRegisterVIN)?YES:NO paragramString:json successHandler:^(NSString *responseStr) {
        [Util hideLoadView];
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        //返回E000，查询正常
        if ([SOSUtil isOperationResponseSuccess:responseDic]) {
            switch (self.currentRegisterType) {
                    //***********************step1如果输入的是govid
                case SOSRegisterGOVID:
                {
                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerType = SOSRegisterGOVID;
                    //hassubscriber
                    NNCheckAccountObject * checkAccount = [NNCheckAccountObject mj_objectWithKeyValues:responseDic];
                    if (checkAccount) {
                        if (!checkAccount.hasSubscriber) {
                            //step2如果用户不存在系统
                            //-2.1并且输入的证件号是身份证,继续注册
                            if (!self.isOtherGovid) {
                                [self pushCheckVinWithSubscriber:NO];
                            }
                            //-2.2否则，如果是其他证件号，则提示拨打电话
                            else
                            {
                                [SOSUtil showCustomAlertWithTitle:@"提示" message:@"证件号不存在，请您尝试输入注册时的证件号码或拨打客服电话400-820-1188" completeBlock:nil];
                            }
                        }
                        else
                        {
                            //step2如果用户存在gaa但没注册MA，进入注册MA界面
                            dispatch_async_on_main_queue(^{
                                [SOSRegisterInformation sharedRegisterInfoSingleton].subscriber =[NNSubscriber mj_objectWithKeyValues:[responseDic objectForKey:@"subscriberInfo"]];
                                RegisterMAViewController * mobVerify = [[RegisterMAViewController alloc] initWithNibName:@"RegisterMAViewController" bundle:nil];
                                [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid =vinID;

                                mobVerify.isInfo3User = info3User;
                                mobVerify.backRecordFunctionID = register_2step_back;
                                [self.navigationController pushViewController:mobVerify animated:YES];
                            });
                        }
                    }
                    else
                    {
                        [self pushCheckVinWithSubscriber:NO];
                    }
                    
                }
                    break;
                    //*********************step1如果输入的是vin
                case SOSRegisterVIN:
                {
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
                                    {
                                        /**********************不使用草稿*******************/
                                        if (buttonIndex ==0) {
                                            if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle && [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank) {
                                                //如果是添加车辆，并且用户有idm手机号，默认发送到这个手机号，不管vin是否有草稿
                                                SOSEnrollInformation *mockInfo = [[SOSEnrollInformation alloc] init];
                                                mockInfo.mobile = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
                                                mockInfo.vin = [vinID uppercaseString];
                                                [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =
                                                mockInfo;
                                                [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                                VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                                dispatch_async_on_main_queue(^{
                                                    [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                                });
                                                [SOSDaapManager sendActionInfo:AddCar_step2mobile_pauselastprogress];
                                            }
                                            else
                                            {
                                                if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle && [CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone.isNotBlank) {
                                                    //如果是添加车辆，并且用户有gaa手机号，默认发送到这个手机号，不管vin是否有草稿
                                                    SOSEnrollInformation *mockInfo = [[SOSEnrollInformation alloc] init];
                                                    mockInfo.mobile = [CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone;
                                                    mockInfo.vin = [vinID uppercaseString];
                                                    [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =
                                                    mockInfo;
                                                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                                    VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                                    dispatch_async_on_main_queue(^{
                                                        [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                                    });
                                                    [SOSDaapManager sendActionInfo:AddCar_step2mobile_pauselastprogress];
                                                }
                                                else
                                                {
                                                    [SOSRegisterInformation sharedRegisterInfoSingleton].vin = [vinID uppercaseString];
                                                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeFresh;
                                                    VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                                    dispatch_async_on_main_queue(^{
                                                        [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                                    });
                                                    [SOSDaapManager sendActionInfo:register_notification_stopcontinueregister];
                                                }
                                                
                                            }
                                            
                                        }
                                        else
                                        {
                                            /**********************使用草稿*******************/
                                            if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank) {
                                                enrollInfo.mobile = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
                                            };
                                            [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =enrollInfo;
                                            
                                            [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                            
                                            VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                            dispatch_async_on_main_queue(^{
                                                [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                            });
                                            if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                                                [SOSDaapManager sendActionInfo:AddCar_step2mobile_continuelastprogress];
                                            }else{
                                                [SOSDaapManager sendActionInfo:register_notification_continueregister];
                                            }
                                        }
                                    }
                                    
                                }];
                                [alert show];
                            });
                            
                        }
                        else
                        {
                            //没有enrollinfo
                            if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                                //进行添加车辆操作,如果Visitor使用手机号注册ma，将手机号携带过去，如果使用email，下一界面显示手机号输入框
                                if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank) {
                                    SOSEnrollInformation * mockEnrollInfo = [[SOSEnrollInformation alloc] init];
                                    mockEnrollInfo.vin = [vinID uppercaseString];
                                    mockEnrollInfo.mobile = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =mockEnrollInfo;
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                    VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                    dispatch_async_on_main_queue(^{
                                        [self.navigationController pushViewController:mobVerify animated:YES];
                                    });
                                    
                                }
                                else
                                {
                                    if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone.isNotBlank) {
                                        //如果是添加车辆，并且用户有gaa手机号，默认发送到这个手机号，不管vin是否有草稿
                                        SOSEnrollInformation *mockInfo = [[SOSEnrollInformation alloc] init];
                                        mockInfo.mobile = [CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone;
                                        mockInfo.vin = [vinID uppercaseString];
                                        [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo =
                                        mockInfo;
                                        [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeExist;
                                        VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                        dispatch_async_on_main_queue(^{
                                            [weakSelf.navigationController pushViewController:mobVerify animated:YES];
                                        });
                                        
                                    }
                                    else
                                    {
                                        [SOSRegisterInformation sharedRegisterInfoSingleton].vin = [vinID uppercaseString];
                                        [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeFresh;
                                        VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                        dispatch_async_on_main_queue(^{
                                            [self.navigationController pushViewController:mobVerify animated:YES];
                                        });
                                    }
                                    
                                }
                            }
                            else
                            {
                                [SOSRegisterInformation sharedRegisterInfoSingleton].vin = [vinID uppercaseString];
                                VehicleEnrollViewController * mobVerify = [[VehicleEnrollViewController alloc] initWithNibName:@"VehicleEnrollViewController" bundle:nil];
                                [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType = SOSRegisterUserTypeFresh;
                                mobVerify.backRecordFunctionID=register_2step_back;
                                dispatch_async_on_main_queue(^{
                                    [self.navigationController pushViewController:mobVerify animated:YES];
                                });
                            }
                        }
                    }
                    else
                    {
                        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
                    }
                    
                }
                    break;
                default:
                    break;
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
                    //如果vin已经enroll了，查询用户的email／mobile
                    SOSEnrollInformation * enrollInfo = [SOSEnrollInformation mj_objectWithKeyValues:[responseDic objectForKey:@"enrollInfo"]];
                    if (enrollInfo) {
                        //设置下一界面vin，email，mobile
                        [SOSRegisterInformation sharedRegisterInfoSingleton].email =NONil(enrollInfo.email);
                        [SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer =NONil(enrollInfo.mobile);
                        [SOSRegisterInformation sharedRegisterInfoSingleton].vin =[vinID uppercaseString];
                        
                        RegisterMAViewController * mobVerify = [[RegisterMAViewController alloc] initWithNibName:@"RegisterMAViewController" bundle:nil];
                        mobVerify.isInfo3User = info3User;
                        dispatch_async_on_main_queue(^{
                            [self.navigationController pushViewController:mobVerify animated:YES];
                        });
                    }
                }
                else
                {
                    if ([SOSUtil isOperationResponseRequestEnrolled:responseDic])
                    {
                        dispatch_async_on_main_queue(^{
                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已提交过车辆注册请求" detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                            alert.buttonClickHandle = ^(NSInteger clickIndex) {
                                [SOSDaapManager sendActionInfo:AddCar_submitted_Iknow];
                            };
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
        self.isOtherGovid = NO;
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        NSLog(@"===%@",responseStr);
        self.isOtherGovid = NO;
        [Util hideLoadView];
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if (responseDic != nil) {
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
                            [SOSRegisterInformation sharedRegisterInfoSingleton].vin =[vinID uppercaseString];
                            
                            RegisterMAViewController * mobVerify = [[RegisterMAViewController alloc] initWithNibName:@"RegisterMAViewController" bundle:nil];
                            mobVerify.isInfo3User = info3User;
                            mobVerify.backRecordFunctionID = register_2step_back;
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
                        
                        if ([SOSUtil isOperationResponseNonexistenceVIN:responseDic])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"车辆不存在" detailText:NSLocalizedString(@"Register_Inexist_VIN", nil) cancelButtonTitle:NSLocalizedString(@"Register_Sure", nil) otherButtonTitles:nil];
                                [alert setButtonClickHandle:^(NSInteger index){
                                    [SOSDaapManager sendActionInfo:AddCar_Notexist_Iknow];
                                }];
                                [alert show];
                                
                            });
                        }
                        else
                        {
                            if ([SOSUtil isOperationResponseAlreadyRegister:responseDic]){
                                if (self.currentRegisterType == SOSRegisterGOVID) {
                                    {
                                        //手机号已经注册
                                        SOSWeakSelf(weakSelf);
                                        dispatch_async_on_main_queue(^(){
                                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"您已注册过安吉星" detailText:@"您可登录手机应用后添加车辆" cancelButtonTitle:@"登录" otherButtonTitles:nil];
                                            [alert setButtonMode:SOSAlertButtonModelHorizontal];
                                            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                                                [LoginManage sharedInstance].Oncompletion = ^(BOOL com){
                                                    if (com) {
                                                        dispatch_async_on_main_queue(^(){
                                                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"未检测到车辆" detailText:@"您当前还没有绑定车辆，\n您可以通过添加车辆功能添加车辆以便于您使用安吉星的全部服务" cancelButtonTitle:@"暂不添加" otherButtonTitles:@[@"添加车辆"]];
                                                            [alert setButtonMode:SOSAlertButtonModelVertical];
                                                            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                                                if (buttonIndex == 1) {
                                                                    [SOSCardUtil routerToUpgradeSubscriber];
                                                                    [SOSDaapManager sendActionInfo:logininfo_novehicle_add];
                                                                }
                                                                else
                                                                {
                                                                    //取消添加操作
                                                                    [SOSDaapManager sendActionInfo:logininfo_novehicle_canceladd];
                                                                }
                                                            }];
                                                            [alert show];
                                                        });
                                                    }
                                                    
                                                };
                                            }];
                                            [alert show];
                                        });
                                    }
                                }
                                else{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SOSUtil showOnstarAlertWithTitle:@"提示" message:[Util visibleErrorMessage:responseStr] alertModel:SOSAlertViewModelContent completeBlock:^(NSInteger buttonIndex) {
                                            if (buttonIndex == 1) {
                                                [SOSCardUtil routerToForegtPassWord:self];
                                            }
                                            else{
                                            }
                                        } cancleButtonTitle:@"知道了" otherButtonTitles:@[@"立即修改密码"]];
                                    });
                                }
                            }
                            else {
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
}
//检查govid未使用后进入vin输入界面
- (void)pushCheckVinWithSubscriber:(BOOL)hasSub
{
    [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid = vinID;
    CheckVINViewController * checkVin = [[CheckVINViewController alloc] initWithNibName:@"CheckVINViewController" bundle:nil];
    checkVin.govidHaveSubscriber = hasSub;
    checkVin.agreements = self.agreements;
    checkVin.backRecordFunctionID = register_2step_back;
    dispatch_async_on_main_queue(^{
        [self.navigationController pushViewController:checkVin animated:YES];
    });
}

- (void)requestFailed:(NSString *)request{
    _textfieldVIN.enabled = YES;
    [self judgeShouldEnableNextButton];
    buttonCamera.enabled = YES;
}

#pragma mark -Register Response
- (void)popMessage:(NSString *) message withTitle:(NSString *)title     {
    [_textfieldVIN resignFirstResponder];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OkButtonTitle", nil) style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:ac0];
    [ac show];
    
}

#pragma mark - 图片验证码验证
- (void)getImageCaptchaValidate:(NSString *)captchaId captchaValue:(NSString *)captchaValue     {
    if (captchaId) {
        
        NSString *url = [BASE_URL stringByAppendingString:
                         [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_VALIDATE,captchaId,captchaValue]];// send verificati
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSLog(@"response:%@",responseStr);
            NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
            if ([responseDic[@"code"] isEqualToString:@"E0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                self.errorCaptchaLB.text = @"";
                    //                self.errorCaptchaLB.textColor = [UIColor lightGrayColor];
                    //step 1 查询车辆是否info3
                    [self queryVINorGovid];
                });
            }
            if (self.errorCaptchaLB.text) {
                self.errorCaptchaLB.text = nil;
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self captchaErrorTip];
                [self requestFailed:nil];
            });
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
        [operation setHttpMethod:@"GET"];
        [operation start];
    }else{
        [Util hideLoadView];
        [self captchaErrorTip];
        [self requestFailed:nil];
        
    }
}
-(void)captchaErrorTip{
    self.errorCaptchaLB.text = NSLocalizedString(@"inPutCaptchaImageError", nil);
    self.errorCaptchaLB.textColor = [UIColor redColor];
}
#pragma mark -  获取验证码
- (IBAction)changeOneAct:(id)sender {
    
    [self getImageCaptcha];
//    if (![self.errorCaptchaLB.text isEqualToString:@""]) {
//        self.errorCaptchaLB.text = @"";
//    }
}

#pragma mark - 图片验证码 请求id
- (void)getImageCaptcha		{
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CODE_IMAGE_CAPTCHA];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if (responseDic[@"required"]) {
            if (responseDic[@"captchaId"]) {
                self->currentCaptchaId = responseDic[@"captchaId"];
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
    if (self.errorCaptchaLB.text) {
        self.errorCaptchaLB.text = nil;
    }
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
}

#pragma mark - 判断是否enable下一步按钮
- (void)judgeShouldEnableNextButton {
    BOOL enable = NO;
    if (_textfieldVIN.text.length > 0) {
        enable = _agreementsView.isAllSelected;
    }else {
        enable = NO;
    }
    _buttonRegister.enabled = enable;
}

#pragma mark - 非安吉星车主用户点击此注册
- (void)onstarClickUrl{
    
    
    [SOSDaapManager sendActionInfo:register_nononstaruser];
    SOSVisitorViewController *Visitor = [[SOSVisitorViewController alloc]initWithNibName:@"SOSVisitorViewController" bundle:nil];
    [self.navigationController pushViewController:Visitor animated:YES];
}

- (void)dealloc {
    [[SOSRegisterInformation sharedRegisterInfoSingleton] destroyRegisterInfoSingleton];
}
@end

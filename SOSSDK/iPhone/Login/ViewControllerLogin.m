//
//  ViewControllerLogin.m
//  Onstar
//
//  Created by Alfred Jin on 1/10/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "ViewControllerLogin.h"
#import "Util.h"
#import "AppPreferences.h"
#import "CustomerInfo.h"

#import "OwnerViewController.h"
#import "LoadingView.h"
//#import "LoginTableViewCell.h"
#import "LoginInsertTableViewCell.h"
#import <Security/Security.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "SOSKeyChainManager.h"
#import "SOSBiometricsManager.h"
#import "SOSCardUtil.h"
#import "SOSFlexibleAlertController.h"
#import "SOSPhoneBindController.h"
//test
#import "SOSBangcleKBTextField.h"

//
#define FIELD_USERNAME_TAG	1011
#define FIELD_PASSWORD_TAG	1012

#define showFingerBtn       1
#define IDMSTATUS @"idmStatus"

@interface ViewControllerLogin()<UITextFieldDelegate>     {
    CGRect frameNaviBar;
    /*
     2013-01-05 王健功修改
     添加isRegisterClicked监控是否是进行注册操作
     */
    BOOL isRegisterClicked;
    
    //用户的数组
    //    NSMutableArray *userNameArray;
    //    UIView *customAccessoryView;
    //    SOSBangcleKBTextField *passwordTf;
    //    UITextField *userNameTf;
    //    NSMutableArray *userNameArray;
    //    UIView *customAccessoryView;
    SOSBangcleKBTextField *passwordTf;
    SOSRegisterTextField *userNameTf;
    NSString *tempStr;
}
@property (weak, nonatomic) IBOutlet UIButton *registerGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgetConstrain;

///从访客注册页面传入的已注册手机号
@property (copy, nonatomic) NSString *fillCellphoneNum;

@end

@implementation ViewControllerLogin
{
    BOOL isIMDLogin;     //YES：置空账号密码 NO：按照原来逻辑
    NSString *tempUname;
    NSString *maskedUname;
    NSString *uName;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIDMStatus];
    self.title = @"登录";
    //    _forgetConstrain.constant = 10;
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backToPreview)];
    self.navigationItem.leftBarButtonItem =left;
    
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    CGRect forgetFrame = buttonForget.frame;
    forgetFrame.origin.y -= 70;
    buttonForget.frame = forgetFrame;
    [buttonLogin setTitle:NSLocalizedString(@"loginInfoNavigateTitle", nil) forState:0];
    [buttonForget setTitle:NSLocalizedString(@"forgetPwd", nil) forState:0];
    [buttonRegister setTitle:NSLocalizedString(@"registeNavigateTitle", nil) forState:0];
    
    [buttonLogin setBackgroundColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:self.registerGuide.currentAttributedTitle];
    //注册指南增加下划线
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [str length])];
    [self.registerGuide setAttributedTitle:str forState:UIControlStateNormal];
    //修改登录时候Loading样式,由于这个VC居然没有登录状态回调,只能监控LloginState状态显示\隐藏Toast并控制userInteractionEnabled
    __weak __typeof(self)weakSelf = self;
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON || state.integerValue == LOGIN_STATE_LOADINGTOKENSUCCESS) {
                [Util dismissHUD];
                weakSelf.view.userInteractionEnabled = YES;
            }
        });
      
    }];
    [self initTextField];
}

-(void)initTextField{
    if (!userNameTf) {
        userNameTf  = [[SOSRegisterTextField alloc] init];
        [userNameTf setTextColor:[SOSUtil onstarTextFontColor]];
        userNameTf.secureTextEntry = NO;
        [userNameTf addNormalBorderStyle];
        [userNameTf setClearButtonMode:UITextFieldViewModeWhileEditing];
        userNameTf.attributedPlaceholder =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"loginUser", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"C7CFD8"]}];
        userNameTf.returnKeyType = UIReturnKeyNext;
        userNameTf.tag = FIELD_USERNAME_TAG;
        userNameTf.delegate = self;
        if (userNameTf.text.length > 0) {
            fingerBtn.enabled = YES;
            fingerBtn.layer.borderColor = [UIColor colorWithHexString:@"107FE0"].CGColor;
        }else{
            [self fingerBtnDisable];
        }
        [self.loginField addSubview:userNameTf];
        [userNameTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(40);
            make.trailing.mas_equalTo(-40);
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self.loginField);
            make.height.mas_equalTo(44);
        }];
    }
    if (!passwordTf) {
        passwordTf  = [[SOSBangcleKBTextField alloc] init];
        [passwordTf setupPasswordField];
        [passwordTf setTextColor:[SOSUtil onstarTextFontColor]];
        [passwordTf addNormalBorderStyle];
        passwordTf.secureTextEntry = YES;
        //        passwordTf.btnPopAnimation=YES;
        //        passwordTf.keyboardTypeKB=BangcleKeyboardViewTypeLetter;
        passwordTf.attributedPlaceholder =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"loginPwd", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                                                                                                                      NSForegroundColorAttributeName:[UIColor colorWithHexString:@"C7CFD8"]}];
        
        passwordTf.returnKeyType = UIReturnKeyGo;
        passwordTf.tag = FIELD_PASSWORD_TAG;
        passwordTf.delegate = self;
        
        [self.loginField addSubview:passwordTf];
        [passwordTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(40);
            make.trailing.mas_equalTo(-40);
            make.height.mas_equalTo(44);
            make.top.mas_equalTo(userNameTf.mas_bottom).mas_offset(20.0);
        }];
    }
    
}
- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    tempUname =[defaults objectForKey:NN_TEMP_USERNAME];
    uName = [defaults objectForKey:NN_CURRENT_USERNAME];
    maskedUname = [defaults objectForKey:NN_MASK_USERNAME];
    NSLog(@"tempUname is:%@", tempUname);
    NSLog(@"uName is:%@", uName);
    NSLog(@"maskedUname is:%@", maskedUname);
    if (([tempUname isEqualToString:uName]) && ([maskedUname length] > 0))		tempStr = maskedUname;
    else																		tempStr = tempUname;
    userNameTf.text = isIMDLogin ? @"" : tempStr;
    if (userNameTf.text.isNotBlank) {
        fingerBtn.enabled = YES;
        fingerBtn.layer.borderColor = [UIColor colorWithHexString:@"107FE0"].CGColor;
    }else{
        [self fingerBtnDisable];
    }
    buttonLogin.enabled = userNameTf.text.isNotBlank && passwordTf.text.isNotBlank;
    
    if (_fillCellphoneNum.length > 0) {
        userNameTf.text = _fillCellphoneNum;
        _fillCellphoneNum = nil;
    }
    
}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    
    [[RACSignal merge:@[passwordTf.rac_textSignal, RACObserve(passwordTf, text)]] subscribeNext:^(NSString* text){
        buttonLogin.enabled = userNameTf.text.length && passwordTf.text.length;
    }];
    [userNameTf.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        buttonLogin.enabled = userNameTf.text.length && passwordTf.text.length;
    }];
    
#ifdef DEBUG
    [passwordTf setText:isIMDLogin ? @"" : @"Admin123"];
#else
    [passwordTf setText:@""];
#endif
#ifdef showFingerBtn
    
    if (![SOSBiometricsManager isSupportBiometrics]) {
        //不支持
        fingerBtn.hidden = YES;
    }else{
        fingerBtn.hidden = YES;
        
        if (userNameTf.text.length > 0) {
            if (uName.length > 0 && uName && ([uName isEqualToString:userNameTf.text] || [maskedUname isEqualToString:userNameTf.text] || [[uName uppercaseString] isEqualToString:[userNameTf.text uppercaseString]] || [[maskedUname uppercaseString] isEqualToString:[userNameTf.text uppercaseString]])) {
                BOOL ownerFor = [SOSKeyChainManager readUserWithOwner:uName];
                if (ownerFor) {
                    [self fingerLogin:nil];
                }
            }
        }
    }
#else
    if (objc_getAssociatedObject(self, _cmd)) return;
    else objc_setAssociatedObject(self, _cmd, @"CONFIG", OBJC_ASSOCIATION_RETAIN);
    
    fingerBtn.hidden = YES;
    
    CGRect forgetFrame = buttonForget.frame;
    buttonForget.frame = forgetFrame;
#endif
    
}

- (void)viewWillDisappear:(BOOL)animated	{
    [super viewWillDisappear:animated];
    [self CancelBackKeyboard:nil];
    if (self.navigationController.topViewController == self) {
        [Util dismissHUD];
    }
    if (![LoginManage sharedInstance].loginSuccessActionActivity) {
        [LoginManage sharedInstance].loginSuccessAction = nil;
    }
}

- (void)backToPreview	{
    //[[SOSReportService shareInstance] recordActionWithFunctionID:loginregister_Close];
    [LoginManage sharedInstance].loginResult = LOGIN_RESULT_CANCEL;
    [self CancelBackKeyboard:nil];
    [[LoginManage sharedInstance] dismissLoginNavAnimated:YES];
}

-(void)checkIDMStatus
{
    if (UserDefaults_Get_Bool(IDMSTATUS)) {     //idm账号合并后跳登陆需要置空账号密码
        isIMDLogin = YES;
    }else
    {
        isIMDLogin = NO;
    }
    UserDefaults_Set_Bool(NO, IDMSTATUS);
}

- (IBAction)buttonLoginClicked:(id)sender {
    //[[SOSReportService shareInstance] recordActionWithFunctionID:Login];
    [passwordTf resignFirstResponder];
    [userNameTf resignFirstResponder];
    if (forceUpgrade) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"upgradeMandatory", @"") completeBlock:^(NSInteger buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLInAPPStore]];
        }];
    }
    
    BOOL checkInput = [self checkUserInput];
    if (!checkInput) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *maskedUname = [defaults objectForKey:NN_MASK_USERNAME];
    NSString *uName = [defaults objectForKey:NN_CURRENT_USERNAME];
    
    if ([maskedUname isEqualToString:userNameTf.text])
    {
        [defaults setObject:uName forKey:NN_TEMP_USERNAME];
    }
    else
    {
        [defaults setObject:userNameTf.text forKey:NN_TEMP_USERNAME];
    }
    [defaults synchronize];
    
    [self CancelBackKeyboard:nil];
    [Util showHUD];
    self.view.userInteractionEnabled = NO;
    //            [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    
    double delayInSeconds = 1.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username =  [defaults objectForKey:NN_TEMP_USERNAME];
        [[LoginManage sharedInstance] loginFromViewController:self withUserName:username password:passwordTf.text stateWatcher:nil];
    });
    
}

/**
 注册按钮点击
 
 @param sender
 */
- (IBAction)buttonRegisterClicked:(id)sender {
    [SOSDaapManager sendActionInfo:Register];
    
    isRegisterClicked = YES;
    OwnerViewController *ownerVC= [[OwnerViewController alloc]initWithNibName:@"OwnerViewController" bundle:nil];
    [SOSRegisterInformation sharedRegisterInfoSingleton].registerWay = SOSRegisterWayNormalRegister;
    [self.navigationController pushViewController:ownerVC animated:YES];
}

- (void)CancelBackKeyboard:(id)sender {
    if (passwordTf.isFirstResponder) {
        [passwordTf resignFirstResponder];
    }
    if (userNameTf.isFirstResponder) {
        [userNameTf resignFirstResponder];
    }
}

- (BOOL)checkUserInput {
    if ([[userNameTf.text stringByTrim] length] < 6) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"usernameIsNull", @"") completeBlock:nil];
        return NO;
    }
    else if ([[passwordTf.text stringByTrim] length] < 1) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"passwordIsNull", @"") completeBlock:nil];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField     {	
    if (FIELD_USERNAME_TAG == textField.tag)
    {
        [passwordTf becomeFirstResponder];
    }
    else if (FIELD_PASSWORD_TAG == textField.tag)
    {
        [self buttonLoginClicked:nil];
    }return YES;
}

- (IBAction)forgetPwClick:(id)sender {
    [SOSCardUtil routerToForegtPassWord:self];
}

- (IBAction)fingerLogin:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uName = [defaults objectForKey:NN_CURRENT_USERNAME];
    //同一个账号不是第一次登录
    if (uName.length > 0 && uName && ([uName isEqualToString:userNameTf.text] || [maskedUname isEqualToString:userNameTf.text] || [[uName uppercaseString] isEqualToString:[userNameTf.text uppercaseString]] || [[maskedUname uppercaseString] isEqualToString:[userNameTf.text uppercaseString]])) {
        //此账号是否开启了指纹登录
        NSString *idpidstr = [SOSKeyChainManager readidpid:uName];
        BOOL openFLg = [[SOSKeyChainManager readFingerPrint:idpidstr] boolValue];
        if (openFLg) {
            //开启
            //验证指纹密码
            LAContext *context = [[LAContext alloc] init];
            context.localizedFallbackTitle = @"输入密码";
            
            NSError *authError = nil;
            
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
                BOOL isSupportFaceId = [SOSBiometricsManager isSupportFaceId];
                NSString *myLocalizedReasonString = isSupportFaceId?@"请使用账号密码进行登录操作":@"请验证已有指纹（Touch ID）";
                
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                        localizedReason:myLocalizedReasonString
                                  reply:^(BOOL success, NSError *error) {
                                      if (success) {
                                          NSLog(@"Touch ID is available.");
                                          //[[SOSReportService shareInstance] recordActionWithFunctionID:FingurePrintLogin_password];
                                          dispatch_async(dispatch_get_main_queue(),^{
                                              [Util showHUD];
                                              self.view.userInteractionEnabled = NO;
                                              //                                              [[LoadingView sharedInstance] startIn:self.view];
                                              [[LoginManage sharedInstance] loginFromViewController:self withUserName:uName password:[SOSKeyChainManager readPassword:uName] stateWatcher:nil];
                                          });
                                          
                                      } else {
                                          switch (error.code) {
                                              case LAErrorUserCancel:
                                              {
                                                  //用户在Touch ID对话框中点击了取消按钮：
                                                  NSLog(@"Authentication Cancelled: 用户取消");
                                                  
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                      if ([passwordTf canBecomeFirstResponder]) {
                                                          [passwordTf becomeFirstResponder];
                                                      }
                                                      
                                                  });
                                              }
                                                  break;
                                              case LAErrorAuthenticationFailed: {
                                                  NSString *imageName = isSupportFaceId ? @"faceID" : @"touchID";
                                                  NSString *title = isSupportFaceId ? @"面容验证失败" : @"指纹验证失败";
                                                  SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:imageName] title:title message:@"请使用密码登录" customView:nil preferredStyle:SOSAlertControllerStyleAlert];
                                                  SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:nil];
                                                  [ac addActions:@[action]];
                                                  [ac show];
                                                  
                                              }
                                                  break;
                                              case LAErrorPasscodeNotSet:
                                                  //认证不能开始,因为此台设备没有设置密码.
                                                  NSLog(@"你尚未设置手机解锁密码，请在设置>touch ID与密码中设置");
                                                  break;
                                              case LAErrorSystemCancel:
                                                  //认证被系统取消了(例如其他的应用程序到前台了)
                                                  NSLog(@"System cancelled authentication:认证被系统取消了");
                                                  break;
                                              case LAErrorUserFallback:
                                              {
                                                  //认证被取消,因为用户点击了 fallback 按钮(输入密码).
                                                  NSLog(@"You chosed to try password: 用户点击了 fallback 按钮");
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                      if ([passwordTf canBecomeFirstResponder]) {
                                                          [passwordTf becomeFirstResponder];
                                                      }
                                                      
                                                  });
                                              }
                                                  break;
                                              default:
                                                  NSLog(@"You cannot access to private content!");
                                                  break;
                                          }
                                      }
                                  }];
            }else if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"密码解锁" reply:^(BOOL success, NSError * _Nullable error){
                    
                }];
            }else{
                //开启指纹密码失败
                [Util showAlertWithTitle:nil message:@"您暂未设置指纹密码，请登录后到“我的”“个人中心”里设置使用指纹密码。" completeBlock:nil];
            }
        }else{
            //未开启
            if (sender != nil) {
                [Util showAlertWithTitle:nil message:@"您的指纹密码已关闭，请登录后到“我的”“个人中心”里设置使用指纹密码。" completeBlock:nil];
            }
        }
    }else{
        //第一次登录 用户名为空状态下 用户名错误
        if (sender != nil) {
            [Util showAlertWithTitle:nil message:@"您的用户名填写错误" completeBlock:nil];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string	{
    if (string.length > 0) {
        fingerBtn.enabled = YES;
        fingerBtn.layer.borderColor = [UIColor colorWithHexString:@"107FE0"].CGColor;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField	{
    
    [self setTextFieldBorderHight:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField	{
    [self setTextFieldBorderNormal:textField];
}

- (void)setTextFieldBorderHight:(UITextField *)textField	{
    textField.layer.borderColor = [UIColor colorWithHexString:@"1D81DD"].CGColor;
}

- (void)setTextFieldBorderNormal:(UITextField *)textField	{
    textField.layer.borderColor = [UIColor colorWithHexString:@"C7CFD8"].CGColor;
}

/**
 注册指南
 @param
 */
- (IBAction)goRegisterGuide:(id)sender {
    
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:Register_Guide_URL];
    [SOSDaapManager sendActionInfo:enrollment_enrollmentmanual];
    vc.backRecordFunctionID = enrollmentmanual_back;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self fingerBtnDisable];
    return YES;
}

- (void)fingerBtnDisable {
    fingerBtn.enabled = NO;
    fingerBtn.layer.borderColor = [SOSUtil onstarButtonDisableColor].CGColor;
    [fingerBtn setTitleColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
}

- (void)dealloc {
    NSLog(@"LoginView Dealloc===============");
}

- (void)fillCellphoneNumber:(NSString *)cellphoneNumber {
    _fillCellphoneNum = cellphoneNumber;
}
@end

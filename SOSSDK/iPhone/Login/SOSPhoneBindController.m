//
//  SOSPhoneBindController.m
//  Onstar
//
//  Created by WQ on 2019/4/1.
//  Copyright © 2019年 Shanghai Onstar. All rights reserved.
//

#import "SOSPhoneBindController.h"
#import "RegisterUtil.h"
#define kCountNum 59
#define IDMSTATUS @"idmStatus"


@interface SOSPhoneBindController ()

@property (weak, nonatomic) IBOutlet UITextField *tf_phone;
@property (weak, nonatomic) IBOutlet UITextField *tf_code;
@property (weak, nonatomic) IBOutlet UIButton *btn_auth;
@property (weak, nonatomic) IBOutlet UIButton *btn_bind;

@end

@implementation SOSPhoneBindController
{
    NSInteger count;
    NSString *phoneCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    count = kCountNum;
    self.title = @"绑定服务手机号";
    // Do any additional setup after loading the view from its nib.
    
}


-(void)getAuth:(NSString*)phoneNum
{
    
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkSendVerificationCodeURL, phoneNum];
    [Util showHUDWithStatus:nil];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        NSDictionary *resultDic = [responseStr mj_JSONObject];
        NSString *s = [NSString stringWithFormat:@"短信验证码为: %@",resultDic[@"data"][@"result"]];
        phoneCode = resultDic[@"data"][@"result"];
        [Util toastWithMessage:s];
        NSLog(@"resultDic is %@",resultDic);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        NSDictionary *errorDic = [responseStr mj_JSONObject];
        [Util toastWithMessage:errorDic[@"errorMessage"]];
        NSLog(@"resultDic is %@",errorDic);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}


-(void)codeAuth:(NSString*)code
{
    NSString *url = [BASE_URL stringByAppendingString:IDM_VERIFICATION_CODE];
    NSDictionary *d = @{@"receiver":self.tf_phone.text,@"secCode":code,@"destType":@"S"};
    NSString *s = [Util jsonFromDict:d];
//    [Util showHUDWithStatus:nil];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"resultDic is %@",responseStr);
        [self codeAuthSuccess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
//        NSDictionary *errorDic = [responseStr mj_JSONObject];
        [Util showErrorHUDWithStatus:[Util visibleErrorMessage:responseStr]];
//        NSLog(@"resultDic is %@",errorDic);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}


-(void)codeAuthSuccess:(NSString*)str
{
    [Util dismissHUD];
    NSDictionary *d = [Util dictionaryWithJsonString:str];
    if ([d[@"code"] isEqualToString:@"E0000"]) {
        [self bindPhone:d[@"secToken"]];
    }
}


-(void)bindPhone:(NSString*)token
{
    NSString *url = [BASE_URL stringByAppendingString:IDM_ACCOUNT_BIND];
    NSDictionary *d = @{@"secToken":token,@"email":[CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress};
    NSString *s = [Util jsonFromDict:d];
    [Util showHUDWithStatus:@"正在加载"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [self bindPhoneSuccess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        NSDictionary *d = [responseStr mj_JSONObject];
        [self bindFailed:d];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}



-(void)bindPhoneSuccess:(NSString*)responseStr
{
    [Util dismissHUD];
    NSDictionary *d = [responseStr mj_JSONObject];
    if ([d[@"code"] isEqualToString:@"E0000"]) {
        if ([d[@"mergeToken"] length] > 0) {    //有token，表示需合并
            [Util showAlertWithTitle:@"账号合并" message:@"您的手机号已注册，是否与邮箱账号合并？合并后请使用手机号登陆安吉星。" completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self toMerge:d[@"mergeToken"]];
                }else
                {
                    //[self.navigationController popViewControllerAnimated:YES];
                }
            } cancleButtonTitle:@"不合并" otherButtonTitles:@"立即合并",nil];
        }else
        {
            [Util showSuccessHUDWithStatus:d[@"description"]];
            if (_overBlock) {
                _overBlock(self.tf_phone.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else
    {
        [Util toastWithMessage:d[@"description"]];
    }
}

-(void)bindFailed:(NSDictionary *)d
{
    
    [Util toastWithMessage:d[@"description"]];
    if ([d[@"code"] isEqualToString:@"E5007"]) {
        [Util showAlertWithTitle:@"手机号已被使用" message:@"该手机号已被其他用户绑定为服务手机号，请使用其他号码进行绑定" completeBlock:^(NSInteger buttonIndex) {
        } cancleButtonTitle:@"知道了"otherButtonTitles:nil];
    }else
    {
        [Util toastWithMessage:d[@"description"]];
    }
}


-(void)toMerge:(NSString*)token
{
    NSString *url = [BASE_URL stringByAppendingString:IDM_ACCOUNT_MERGE];
    NSDictionary *d = @{@"mergeToken":token,@"email":[CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress};
    NSString *s = [Util jsonFromDict:d];
    [Util showHUDWithStatus:nil];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"resultDic is %@",responseStr);
        [self mergeSuccess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        NSDictionary *errorDic = [responseStr mj_JSONObject];
        [Util showAlertWithTitle:@"绑定失败" message:@"服务手机号绑定失败，请重新绑定或稍后再试." completeBlock:^(NSInteger buttonIndex) {
        } cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
        NSLog(@"resultDic is %@",errorDic);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}


-(void)mergeSuccess:(NSString *)responseStr
{
    [Util dismissHUD];
    NSDictionary *d = [responseStr mj_JSONObject];
    if ([d[@"code"] isEqualToString:@"E0000"]) {
        [Util showAlertWithTitle:@"绑定成功" message:@"服务手机号绑定成功，您需要使用手机号重新登陆安吉星" completeBlock:^(NSInteger buttonIndex) {
            [self.navigationController  popToRootViewControllerAnimated:YES];
            [[LoginManage sharedInstance] doLogout];
            UserDefaults_Set_Bool(YES,IDMSTATUS);
            if (_needRelogin) {
                _needRelogin();
            }
        } cancleButtonTitle:nil otherButtonTitles:@"重新登陆",nil];
    }
}
- (void)countDown
{
    //NSLog(@"current %@",[NSThread currentThread]);
    count--;
    if (count <= 0) {
        self.btn_auth.enabled = YES;
        [self.btn_auth setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.btn_auth setTitleColor:[UIColor skyBlue] forState:UIControlStateNormal];
        self.btn_auth.layer.borderColor = [UIColor skyBlue].CGColor;
        self.btn_auth.backgroundColor = [UIColor clearColor];   
        count = kCountNum;
    }else
    {
        self.btn_auth.enabled = NO;
        self.btn_auth.backgroundColor = [UIColor Gray185];
        self.btn_auth.layer.borderColor = [UIColor Gray185].CGColor;
        NSString *str = [NSString stringWithFormat:@"%lds后重新获取",(long)count];
        [self.btn_auth setTitle:str forState:UIControlStateNormal];
        [self.btn_auth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btn_auth.titleLabel.textColor = [UIColor whiteColor];
        [self performSelector:@selector(countDown) withObject:nil afterDelay:1];
    }
}


-(void)checkUnique
{
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [regRequest setMobilePhoneNumber:self.tf_phone.text];
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CHECK_UNIQUE];
    NSString *json = [regRequest mj_JSONString];
    [Util showHUDWithStatus:@"正在加载"];
    [RegisterUtil registAsVisitor:url paragramString:json successHandler:^(NNRegisterResponse *regRes) {
        NSLog(@"regRes is %@",regRes);
        [self codeAuth:self.tf_code.text];
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        [Util showAlertWithTitle:@"手机号已被使用" message:@"该手机号已被其他用户绑定为服务手机号，请使用其他号码进行绑定" completeBlock:^(NSInteger buttonIndex) {
            } cancleButtonTitle:@"知道了"otherButtonTitles:nil];
    }];
}


-(BOOL)checkPhoneValidate
{
    if (self.tf_phone.text.length > 0) {
        if (self.tf_phone.text.length == 11) {
            return YES;
        }else
        {
            [Util showErrorHUDWithStatus:@"请使用有效的手机号"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [Util dismissHUD];
            });
            return NO;
        }
    }else
    {
        [Util showErrorHUDWithStatus:@"手机号不能为空"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Util dismissHUD];
        });
        return NO;
    }
}


- (IBAction)authOnPress:(UIButton *)sender {
    if ([self checkPhoneValidate]) {
        count++;
        [self countDown];
        [self getAuth:self.tf_phone.text];
    }
}

- (IBAction)bindOnPress:(UIButton *)sender {
    
    
    [self checkPhoneValidate];
    if ([self checkPhoneValidate]) {
        [self checkUnique];
    }
}



@end

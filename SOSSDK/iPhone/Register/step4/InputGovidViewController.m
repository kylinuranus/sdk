//
//  InputGovidViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "InputGovidViewController.h"
#import "SOSRegisterTextField.h"
#import "RegisterUtil.h"
#import "NSString+JWT.h"
#import "SOSCustomAlertView.h"
@interface InputGovidViewController ()
{
    NSString *currentCaptchaId;
    //验证captchaId是否验证成功
    NSString *currentGovid;
}
@property (weak, nonatomic) IBOutlet UILabel *tobeChangedGovidLabel;
@property (weak, nonatomic) IBOutlet UIView *captchaViewBG;//验证码容器视图
@property (weak, nonatomic) IBOutlet UIImageView *captchaImageV;  // 验证码图片
@property (weak, nonatomic) IBOutlet UIButton *changeOneBtn; //换一张、刷新验证码
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *govidField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *verifyCodeField;
@property (weak, nonatomic) IBOutlet UIButton *confirmChangeGovid;

@end

@implementation InputGovidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[SOSUtil onstarLightGray]];
    if (self.changeGovid) {
        self.title = @"更改证件号码";
    }
    else
    {
        self.title = @"输入证件号码";
    }
    [self.govidField addTextInputPredicate];
    if (self.isUseForAddVehicle) {
        self.title = @"身份证信息验证";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        [self.confirmChangeGovid setTitle:@"验证" forState:UIControlStateNormal];
    }
    [self initView];
}
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initView
{
    self.tobeChangedGovidLabel.hidden = self.changeGovid == nil;
    if (!self.tobeChangedGovidLabel.hidden) {
        self.tobeChangedGovidLabel.text = [self.tobeChangedGovidLabel.text stringByAppendingString:[self.changeGovid govidStringInterceptionHide]];
    }
    [self getImageCaptcha];
    [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];

}
#pragma mark -  获取验证码
- (IBAction)changeOneAct:(id)sender {
    [self getImageCaptcha];
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
           
        });
    }];
    [operation setHttpMethod:@"GET"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation start];
}
- (IBAction)confirm:(id)sender {
    [self.view endEditing:YES];
    currentGovid = [Util trim:self.govidField];
    if (currentGovid.length > 1) {
        currentGovid = currentGovid.uppercaseString;
        [self getImageCaptchaValidate:currentCaptchaId captchaValue:self.verifyCodeField.text];
    }
    else
    {
        [Util toastWithMessage:@"请输入正确证件号!"];
    }
}
#pragma mark - 获取govid信息
- (void)queryGovidInfo
{
    SOSRegisterCheckRequestWrapper * reg = [[SOSRegisterCheckRequestWrapper alloc] init];
    reg.enrollInfo = [[SOSRegisterCheckRequest alloc] init];
    reg.enrollInfo.vin = [SOSRegisterInformation sharedRegisterInfoSingleton].vin;
    reg.enrollInfo.inputGovid = currentGovid;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //添加车辆操作，需要确定用户是Visitor升级车主还是subscriber添加车辆,如果是subscriber添加车辆，则后端服务不会验证身份证是否被占用
        if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId != nil) {
            reg.enrollInfo.scanIssue = @"subscriber";
        }
        else
        {
            reg.enrollInfo.scanIssue = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        }
    }
    SOSWeakSelf(weakSelf);
    //请求查询govid对应subscriber接口并不能取得全部信息，所以调用新接口获取
    [RegisterUtil checkNewGovidInfo:[reg mj_JSONString] successHandler:^(NSString *responseStr) {
        [Util hideLoadView];
        SOSRegisterCheckResponseWrapper * userInfo =[SOSRegisterCheckResponseWrapper mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        /****step 1 如果用户信息存在*****/
        if (userInfo.enrollInfo) {
            if (weakSelf.fillBlock) {
                weakSelf.fillBlock(currentGovid, userInfo.enrollInfo,nil);
            }
        }
        else
        {
            weakSelf.fillBlock(currentGovid, nil,nil);
        }
        dispatch_async_on_main_queue(^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        weakSelf.fillBlock(currentGovid, nil,responseStr);
        dispatch_async_on_main_queue(^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}
#pragma mark - 验证图片验证码
- (void)getImageCaptchaValidate:(NSString *)captchaId captchaValue:(NSString *)captchaValue
{
    [Util showLoadingView];
    NSString *url = [BASE_URL stringByAppendingString:
                     [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_VALIDATE,captchaId,captchaValue]];// send verificati
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if ([responseDic[@"code"] isEqualToString:@"E0000"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isUseForAddVehicle) {
                    
                }
                else
                {
                    //查询govid
                    [self queryGovidInfo];
                }
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        self.captchaErrorLabel.text = NSLocalizedString(@"inPutCaptchaImageError", nil);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}


#pragma mark - textField
- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    if (textField == _verifyCodeField) {
        if (self.captchaErrorLabel.text.isNotBlank) {
            self.captchaErrorLabel.text = nil;
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _govidField) {
        if (range.location==0 && range.length == 1) {
            [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];
        }
        else
        {
            if (_verifyCodeField.text.length >1) {
                [SOSUtil setButtonStateEnableWithButton:self.confirmChangeGovid];
            }
            else
            {
                [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];
            }
        }
    }
    else
    {
        if (textField == _verifyCodeField) {
            if (range.location==0 && range.length == 1) {
                [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];
            }
            else
            {
                if (_govidField.text.length >1) {
                    [SOSUtil setButtonStateEnableWithButton:self.confirmChangeGovid];
                }
                else
                {
                    [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];
                }
            }
        }
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

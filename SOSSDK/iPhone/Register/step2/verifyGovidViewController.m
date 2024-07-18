//
//  InputGovidViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "verifyGovidViewController.h"
#import "SOSRegisterTextField.h"
#import "RegisterUtil.h"
#import "SOSCustomAlertView.h"
#import "SOSOCRViewController.h"
@interface verifyGovidViewController ()
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

@implementation verifyGovidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[SOSUtil onstarLightGray]];
    self.title = @"身份证信息验证";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    [self.confirmChangeGovid setTitle:@"验证" forState:UIControlStateNormal];
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
        self.tobeChangedGovidLabel.text = [self.tobeChangedGovidLabel.text stringByAppendingString:self.changeGovid];
    }
    [self getImageCaptcha];
    [SOSUtil setButtonStateDisableWithButton:self.confirmChangeGovid];
    [self.govidField setupScanButtonWithDelegate:self responseMethod:@selector(pushScanView)];
}
/**
 进入扫描界面
 */
- (void)pushScanView
{
//    SOSWeakSelf(weakSelf);
//    SOSOCRViewController * idOcr = [[SOSOCRViewController alloc] init];
//    idOcr.currentType = ScanIDCard;
//    idOcr.scanIDCardFront = YES;
////    idOcr.backFunctionID = register_scanVIN_ID_back;
//    [idOcr setScanBlock:^(SOSScanResult * result){
//        if (result.resultText != nil) {
//            weakSelf.govidField.text = result.resultText;
//        }
//    }];
//    [self.navigationController pushViewController:idOcr animated:YES];
    
    
    @weakify(self);
    SOSOCRViewController * idOcr = [[SOSOCRViewController alloc] init];
    idOcr.currentType = ScanIDCard;
    idOcr.scanIDCardFront = YES;
    [idOcr setScanBlock:^(SOSScanResult * result){
        @strongify(self);
       self.govidField.text = result.resultText;
    }];
    [self.navigationController pushViewController:idOcr animated:YES];
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
    [SOSDaapManager sendActionInfo:AddCar_step1multiowner_Idverify];
    if (currentGovid.length > 1) {
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
    NNVehicleAddRequest * VisitorQuery = [[NNVehicleAddRequest alloc] init];
    
    [VisitorQuery setGovernmentID:[_govidField.text stringByTrim]];
    [VisitorQuery setIdpUserID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    [VisitorQuery setCaptchaId:currentCaptchaId];
    [VisitorQuery setCaptchaValue:self.verifyCodeField.text];
    NSString *json = [VisitorQuery mj_JSONString];
    [RegisterUtil checkVisitorWithVINOrGovidState:json successHandler:^(NSString *responseStr) {
         [Util hideLoadView];
        NSDictionary * dic =[Util dictionaryWithJsonString:responseStr];
            NSArray * showAlertArr = [SOSUtil visitorAddVehicleResponse:dic];
            if (showAlertArr) {
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:showAlertArr[1] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                    [alert setButtonClickHandle:^(NSInteger buttonIndex){
                        if ([showAlertArr[2] isEqualToString:@"E3139"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //升级车主成功,
                                [[LoginManage sharedInstance] doLogout];
                                [self.navigationController  popToRootViewControllerAnimated:YES];
                            });
                        }
                    }];
                    [alert setButtonMode:SOSAlertButtonModelVertical];
                dispatch_async_on_main_queue(^{
                    [alert show];
                });
            }
            else
            {
                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:responseStr cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alert setButtonClickHandle:nil];
                [alert setButtonMode:SOSAlertButtonModelVertical];
                dispatch_async_on_main_queue(^{
                    [alert show];
                });
            }
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [self handleFailResponse:responseStr];
    }];
}
- (void)handleFailResponse:(NSString *)responseStr
{
    NSDictionary * responseDic = [Util dictionaryWithJsonString:responseStr];
    NSArray * showAlertArr = [SOSUtil visitorAddVehicleResponse:responseDic];
    if (showAlertArr != nil) {
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:showAlertArr[0] detailText:showAlertArr[1] cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert setButtonClickHandle:^(NSInteger buttonIndex){
            }];
            [alert setButtonMode:SOSAlertButtonModelVertical];
            dispatch_async_on_main_queue(^{
                [alert show];
            });
    }
    else
    {
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:responseStr cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert setButtonClickHandle:^(NSInteger buttonIndex){
        }];
        [alert setButtonMode:SOSAlertButtonModelVertical];
        dispatch_async_on_main_queue(^{
            [alert show];
        });
    }
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
                    //查询govid
                    [self queryGovidInfo];
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util toastWithMessage:NSLocalizedString(@"inPutCaptchaImageError", nil)];
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}


#pragma mark - textField
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

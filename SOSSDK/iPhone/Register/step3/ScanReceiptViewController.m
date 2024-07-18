//
//  ScanReceiptViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/19.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "ScanReceiptViewController.h"
#import "SOSImagePickerManager.h"
#import "SOSRegisterInformation.h"
#import "SOSCustomAlertView.h"
#import "RegisterUtil.h"
#import "SOSScanIDCardViewController.h"
#import "SOSOCRViewController.h"
#import "SOSReceiptInformViewController.h"
#import "LoadingView.h"
@interface UIImageSelectButton :UIButton

/**
 识别图片的completeBlock
 */
typedef void (^recongBlock)(SOSScanResult * result);

@property(nonatomic,assign)BOOL isValidateImage;
@property(nonatomic,strong)UIImageView * buttonBorderView; //显示是否是合法照片
@property(nonatomic,strong)CALayer *     maskLayer; //灰色背景
@property(nonatomic,strong)UILabel *     titlePrompt; //标题
@property(nonatomic,strong)UILabel *     recongPrompt; //识别的文字
@property(nonatomic,strong)NSString *    recongInfo; //识别出的信息

- (void)setImageLegalBorderWithTitle:(NSString *)title recongValue:(NSString *)value;
- (void)startRecongImageWithCompleteBlock:(recongBlock)recBlock;
@end

@implementation UIImageSelectButton

/**
 合法的边框
 @param title 显示的标题
 @param value 识别出图片中的身份证号之类的值
 */
- (void)setImageLegalBorderWithTitle:(NSString *)title recongValue:(NSString *)value
{
    
    [self clearState];
    if (!self.buttonBorderView) {
        self.maskLayer = [[CALayer alloc] init];
        self.maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        [self.maskLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.maskLayer.opacity = 0.5f;
        [self.layer addSublayer:self.maskLayer];
        
        self.titlePrompt = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 80) /2 , 30, 80, 20)];
        self.titlePrompt.font = [UIFont fontWithName:@"PingFang SC" size:12.0f];
        [self.titlePrompt setTextColor:[UIColor whiteColor]];
        [self.titlePrompt setText:title];
        [self addSubview:self.titlePrompt];
        
        self.recongPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0 , 45, self.frame.size.width, 20)];
        self.recongPrompt.font = [UIFont systemFontOfSize:14.0f];
        [self.recongPrompt setTextColor:[UIColor whiteColor]];
        [self.recongPrompt setText:value];
        [self.recongPrompt setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.recongPrompt];

        self.buttonBorderView = [[UIImageView alloc] initWithFrame: CGRectMake(-2.8, -2.8, self.frame.size.width+5.6, self.frame.size.height+5.6)];
        [self addSubview:self.buttonBorderView];
        [self.buttonBorderView setImage:[UIImage imageNamed:@"btn_upload_success"]];
    }
    self.isValidateImage = YES;
}
//非法的边框
- (void)setImageIllLegalBorder
{
    [self clearState];
    if (!self.buttonBorderView) {
        self.buttonBorderView = [[UIImageView alloc] initWithFrame: CGRectMake(-2.8, -2.8, self.frame.size.width+5.6, self.frame.size.height+5.6)];
        [self addSubview:self.buttonBorderView];
    }
    [self.buttonBorderView setImage:[UIImage imageNamed:@"btn_upload_fail"]];
    self.isValidateImage = NO;

}
- (void)startRecongImageWithCompleteBlock:(recongBlock)recBlock
{
    SOSScanResult * res = [[SOSScanResult alloc] init];
    res.resultImg = self.imageView.image;
    res.resultText = @"ssdsdf";
    self.isValidateImage = YES;
    recBlock(res);
}
- (void)clearState
{
    
    if (self.buttonBorderView.superview) {
        [self.buttonBorderView removeFromSuperview];
    }
    self.buttonBorderView = nil;
    if (self.titlePrompt.superview) {
        [self.titlePrompt removeFromSuperview];
    }
    self.titlePrompt = nil;
    if (self.recongPrompt.superview) {
        [self.recongPrompt removeFromSuperview];
    }
    self.recongPrompt = nil;
    if (self.maskLayer.superlayer) {
        [self.maskLayer removeFromSuperlayer];
    }
    self.maskLayer = nil;
}
@end

@interface ScanReceiptViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property (weak, nonatomic) IBOutlet UIImageSelectButton *scanIDCardFrontButton;//扫描身份证正面
@property (weak, nonatomic) IBOutlet UIImageSelectButton *scanIDCardBackButton; //扫描身份证反面
@property (weak, nonatomic) IBOutlet UIImageSelectButton *scanReceiptButton;    //扫描购车发票
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;

@property (copy, nonatomic) NSString *scanFullNameValue;
@property (copy, nonatomic) NSString *scanGenderValue;
@property (copy, nonatomic) NSString *scanAddressValue;

//TODO - 扫描软件未确定前给予输入框输入身份证号等
@property (copy, nonatomic)  NSString *IDcardField;
@property (copy, nonatomic)  NSString *IDExpiredField;
@property (copy, nonatomic)  NSString *VINField;
@property (assign, nonatomic) NSInteger  validateMetaNumber;

@end

@implementation ScanReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.validateMetaNumber = 0;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        self.title = NSLocalizedString(@"添加车辆", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"registeNavigateTitle", nil);
    }
    [self.view setBackgroundColor:[SOSUtil onstarLightGray]];
    [self initObser];
    [self initView];
   

}
- (void)initObser
{
    @weakify(self);
    [RACObserve(self, validateMetaNumber) subscribeNext:^(id x) {
        @strongify(self)
        if (self.validateMetaNumber ==3) {
            [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
        }
        else
        {
            [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
        }
    }];
}
- (void)initView
{
    [SOSUtil setButtonStateDisableWithButton:self.nextStepButton];
    [self.scanReceiptButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.scanIDCardBackButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.scanIDCardFrontButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo && [SOSRegisterInformation sharedRegisterInfoSingleton].registerUserType == SOSRegisterUserTypeExist) {
        //有草稿
        [self loadDraftImage];
    }
    
    self.vinLabel.text = [self.vinLabel.text stringByAppendingString:NONil([SOSRegisterInformation sharedRegisterInfoSingleton].vin).uppercaseString];
}
- (void)loadDraftImage
{
    @weakify(self);
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgGovFrontUrl) {
        [self.scanIDCardFrontButton sd_setImageWithURL:[NSURL URLWithString:[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgGovFrontUrl] forState:0  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (!error) {
                [self.scanIDCardFrontButton setImageLegalBorderWithTitle:@"身份证号码:" recongValue: [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.inputGovid];
            }
            else
            {
                [self.scanIDCardFrontButton setImageIllLegalBorder];
            }
            self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
        }];
    }
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgGovBackUrl) {
        [self.scanIDCardBackButton sd_setImageWithURL:[NSURL URLWithString:[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgGovBackUrl] forState:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (!error) {
                [self.scanIDCardBackButton setImageLegalBorderWithTitle:@"身份证有效期:" recongValue:[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.scanGovExpireDate];
            }
            else
            {
                [self.scanIDCardBackButton setImageIllLegalBorder];
            }
            self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
        }];
    }
    if([SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgVehicleInvoiceUrl) {
        [self.scanReceiptButton sd_setImageWithURL:[NSURL URLWithString:[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.imgVehicleInvoiceUrl] forState:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (!error) {
                [self.scanReceiptButton setImageLegalBorderWithTitle:nil recongValue: nil];
            }
            else
            {
                [self.scanReceiptButton setImageIllLegalBorder];
            }
            self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
        }];

    }
    if ( self.validateMetaNumber == 3) {
        [SOSUtil setButtonStateEnableWithButton:self.nextStepButton];
    }
    self.IDcardField = [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.inputGovid;
    self.IDExpiredField =[SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.scanGovExpireDate;
    self.VINField = [SOSRegisterInformation sharedRegisterInfoSingleton].enrollInfo.vin;
    
}
#pragma mark - image转base64编码字符串
- (NSData *)generateGovFrontImageStr
{
    NSData *imageData = [Util zipImageDataLessthan1MB:self.scanIDCardFrontButton.imageView.image];//UIImageJPEGRepresentation(self.scanIDCardFrontButton.imageView.image, 0.1f);
     return  imageData;
}
- (NSData *)generateGovBackImageStr
{
    NSData *imageData = [Util zipImageDataLessthan1MB:self.scanIDCardBackButton.imageView.image];//UIImageJPEGRepresentation(self.scanIDCardBackButton.imageView.image, 0.1f);
    return  imageData;
}
- (NSData *)generateGovReceiptImageStr
{
    NSData *imageData = [Util zipImageDataLessthan1MB:self.scanReceiptButton.imageView.image];//UIImageJPEGRepresentation(self.scanReceiptButton.imageView.image, 0.1f);
    return  imageData;
}
- (IBAction)nextStepToCompletePersonalInfo:(id)sender
{
    [self.view endEditing:YES];
    [[LoadingView sharedInstance] startIn:self.view];
    NSArray * photoArray = @[@{@"name":@"govFrontFile",@"data":[self generateGovFrontImageStr]},@{@"name":@"govBackFile",@"data":[self generateGovBackImageStr]},@{@"name":@"vehicleInvoiceFile",@"data":[self generateGovReceiptImageStr]}];
    SOSWeakSelf(weakSelf);
    [RegisterUtil uploadSubscriberPhotos:photoArray successHandler:^(NSString *responseStr) {
        SOSRegisterCheckReceiptResponse * response = [SOSRegisterCheckReceiptResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        [Util hideLoadView];
        if (response) {
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    {
                        
                        if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle && [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId.isNotBlank) {
                            //如果是subscriber添加车辆，则提示“在当前账户下添加车辆需保持证件号一致，若需用其他证件绑定车辆，请重新注册，感谢您的配合”
                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"在当前账户下添加车辆需保持证件号一致，若需用其他证件绑定车辆，请重新注册，感谢您的配合" cancelButtonTitle:@"好的" otherButtonTitles:nil];
                            [alert setButtonMode:SOSAlertButtonModelHorizontal];
                            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                //使用当前身份证
                                SubmitPersonalInfoViewController * sub = [[SubmitPersonalInfoViewController alloc] initWithNibName:@"SubmitPersonalInfoViewController" bundle:nil];
                                sub.queryUserInfoPara =[self generateDraftInfo:response];
                                [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid = self.IDcardField;
                                //                        sub.checkedUserInfo = userInfo.enrollInfo;
                                [weakSelf.navigationController pushViewController:sub animated:YES];
                                
                            }];
                            [alert show];
                        }
                        else
                        {
                            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"是否使用当前的身份证信息 \n注册安吉星服务" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"]];
                            [alert setButtonMode:SOSAlertButtonModelHorizontal];
                            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                                if (buttonIndex == 0) {
                                    //不使用当前身份证
                                    SubmitPersonalInfoViewController * sub = [[SubmitPersonalInfoViewController alloc] initWithNibName:@"SubmitPersonalInfoViewController" bundle:nil];
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid = nil;
                                    sub.backRecordFunctionID = register_4step_personalinfo_back;
                                    [sub setSubmitUserDraftPara:[self generateDraftInfo:response]];
                                    [weakSelf.navigationController pushViewController:sub animated:YES];
                                    [SOSDaapManager sendActionInfo:register_3step_notification_cancelID];
                                }
                                else
                                {
                                    //使用当前身份证
                                    SubmitPersonalInfoViewController * sub = [[SubmitPersonalInfoViewController alloc] initWithNibName:@"SubmitPersonalInfoViewController" bundle:nil];
                                    sub.queryUserInfoPara =[self generateDraftInfo:response];
                                    SOSRegisterScanIDCardInfoWrapper * scanResult = [[SOSRegisterScanIDCardInfoWrapper alloc] init];
                                    scanResult.firstNameValue = weakSelf.scanFullNameValue;
                                    scanResult.genderValue = weakSelf.scanGenderValue;
                                    scanResult.addressValue = weakSelf.scanAddressValue;
                                    sub.scanInfo = scanResult;
                                    sub.backRecordFunctionID = register_4step_personalinfo_back;
                                    [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid = self.IDcardField;
                                    [weakSelf.navigationController pushViewController:sub animated:YES];
                                    [SOSDaapManager sendActionInfo:register_3step_notification_confirmID];
                                    
                                }
                            }];
                            [alert show];
                        }
                    }
                });
            }
        }
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:NSLocalizedString(@"Upload_failed", nil) message:responseStr completeBlock:nil];
    }];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_step3mobile_nextstep];
        
    }else{
        [SOSDaapManager sendActionInfo:register_3step_next];
    }
}

- (SOSRegisterCheckRequestWrapper *)generateDraftInfo:(SOSRegisterCheckReceiptResponse *)response
{
    SOSRegisterCheckRequestWrapper * reg = [[SOSRegisterCheckRequestWrapper alloc] init];
    reg.enrollInfo = [[SOSRegisterCheckRequest alloc] init];
    reg.enrollInfo.vin = [SOSRegisterInformation sharedRegisterInfoSingleton].vin;
    reg.enrollInfo.mobile = [SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer;
    reg.enrollInfo.inputGovid = self.IDcardField;
    reg.enrollInfo.scanGovid = self.IDcardField;
    reg.enrollInfo.scanGovExpireDate = self.IDExpiredField;
    reg.enrollInfo.imgGovFrontUrl = response.govFrontUrl;
    reg.enrollInfo.imgGovBackUrl = response.govBackUrl;
    reg.enrollInfo.imgVehicleInvoiceUrl = response.vehicleInvoiceUrl;
    reg.enrollInfo.subscriberId = response.subscriberId;
//    reg.enrollInfo.vin = response.vin;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //添加车辆操作，需要确定用户是Visitor升级车主还是subscriber添加车辆,如果是subscriber添加车辆，则后端服务不会验证身份证是否被占用
        if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId != nil) {
            reg.enrollInfo.scanIssue = @"subscriber";
            //根据9.1上线前UAT测试提出问题修改19.05.22
            if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.governmentId.isNotBlank) {
                reg.enrollInfo.inputGovid =[CustomerInfo sharedInstance].userBasicInfo.subscriber.governmentId;
                reg.enrollInfo.scanGovid = [CustomerInfo sharedInstance].userBasicInfo.subscriber.governmentId;
            }
           
        }
        else
        {
            reg.enrollInfo.scanIssue = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        }
    }
    return reg;
}
- (IBAction)checkPicture:(id)sender
{
    //给出提示页面
    SOSReceiptInformViewController * recInform = [[SOSReceiptInformViewController alloc] initWithNibName:@"SOSReceiptInformViewController" bundle:nil];
//    SOSWeakSelf(weakSelf);
     @weakify(self);
    [recInform setContinueCompleteCallBack:^(){
        SOSImagePickerManager * imp =[[SOSImagePickerManager alloc] init];
        [imp setSelectBlock:^(UIImage * selectImage){
            @strongify(self);
            [(UIImageSelectButton *)sender setImage:selectImage forState:UIControlStateNormal];
            [(UIImageSelectButton *)sender setImageLegalBorderWithTitle:nil recongValue:nil];
            self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
        }];
        [imp invokeImagePicker:self];
    }];
    [self.navigationController pushViewController:recInform animated:YES];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_step3mobile_scaninvoice];
        
    }else{
        [SOSDaapManager sendActionInfo:register_3step_invoice];
    }

}
- (IBAction)checkIDCardFront:(id)sender
{
    @weakify(self);
    SOSOCRViewController * idOcr = [[SOSOCRViewController alloc] init];
    idOcr.currentType = ScanIDCard;
    idOcr.scanIDCardFront = YES;
    __block id senderB = sender;
    [idOcr setScanBlock:^(SOSScanResult * result){
        @strongify(self);
        [(UIImageSelectButton *)senderB setImage:result.resultImg forState:UIControlStateNormal];
        if (result.resultText != nil && result.resultText.isNotBlank) {
            [(UIImageSelectButton *)senderB setImageLegalBorderWithTitle:@"身份证号码:" recongValue:result.resultText];
            self.IDcardField = result.resultText;
            self.scanFullNameValue = result.fullNameText;
            self.scanGenderValue = result.genderText;
            self.scanAddressValue = result.addressText;
        }
        else
        {
            [(UIImageSelectButton *)senderB setImageIllLegalBorder];
            [SOSDaapManager sendActionInfo:register_3step_notification_Idexpired_rescan];
        }
        self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
    }];
    [self.navigationController pushViewController:idOcr animated:YES];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_step3mobile_scanIDfrount];

    }else{
        [SOSDaapManager sendActionInfo:register_3step_ID];
    }

}
- (IBAction)checkIDCardBack:(id)sender
{
    
    @weakify(self);
    SOSOCRViewController * idOcr = [[SOSOCRViewController alloc] init];
    idOcr.currentType = ScanIDCard;
    idOcr.scanIDCardFront = NO;
    __block id senderB = sender;
    [idOcr setScanBlock:^(SOSScanResult * result){
        @strongify(self);
        [(UIImageSelectButton *)senderB setImage:result.resultImg forState:UIControlStateNormal];
        if (result.resultText != nil && result.resultText.isNotBlank) {
            [(UIImageSelectButton *)senderB setImageLegalBorderWithTitle:@"身份证有效期:" recongValue:result.resultText];
            self.IDExpiredField = result.resultText;
        }
        else
        {
            [(UIImageSelectButton *)senderB setImageIllLegalBorder];
            
        }
        self.validateMetaNumber = self.scanIDCardFrontButton.isValidateImage + self.scanIDCardBackButton.isValidateImage+self.scanReceiptButton.isValidateImage;
    }];
    [self.navigationController pushViewController:idOcr animated:YES];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [SOSDaapManager sendActionInfo:AddCar_step3mobile_scanIDback];
        
    }else{
        [SOSDaapManager sendActionInfo:register_3step_Idback];
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

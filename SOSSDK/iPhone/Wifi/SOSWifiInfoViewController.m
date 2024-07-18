//
//  SOSWifiInfoViewController.m
//  Onstar
//
//  Created by Onstar on 2020/3/9.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSWifiInfoViewController.h"
#import "ServiceController.h"
#import "LoadingView.h"
#import "SOSRemoteTool.h"
#import "SOSCardUtil.h"
@interface SOSWifiInfoViewController ()<UITextFieldDelegate>{
    UIView *ssidView;
    UIView *pdView;
    UILabel *label1;
    UITextField * ssidField;
    UITextField * pdField;
    //promopt
    UILabel * normalTipL;
    UILabel * SSIDTipL;
    UILabel * PDTipL;
    //
    UIButton * saveButton;
    UIImageView *wifiIcon;
    BOOL pdfieldTextSec;
    UIButton * pdTextSecButton;
}


//@property(nonatomic ,assign)BOOL isvalidateSSID;
//@property(nonatomic ,assign)BOOL isvalidatePD;

@end

@implementation SOSWifiInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    //    @weakify(self)
    //    RAC(saveButton,enabled) = [RACSignal combineLatest:@[ssidField.rac_textSignal,pdField.rac_textSignal] reduce:^(NSString*ssidStr,NSString*pdStr){
    //        @strongify(self)
    //            return @(NO);
    //    }];
    [self getWIFIInfo];
}
- (void)goTo4GPackage:(id)sender{
    [SOSCardUtil routerTo4GPackage];
}
#pragma mark -UI
-(void)configUI{
    self.title = @"车载Wi-Fi";
    BOOL isowner = [SOSCheckRoleUtil isOwner];
    //ssid
    ssidView = [[UIView alloc] init];
    ssidView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:ssidView];
    [ssidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(55);
    }];
    
    label1 = [[UILabel alloc] init];
    [label1 setFont:[UIFont systemFontOfSize:15]];
    [label1 setTextColor:[UIColor colorWithHexString:@"#28292F"]];
    [label1 setText:@"名     称"];
    label1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(ssidView).mas_offset(32);
        make.centerY.mas_equalTo(ssidView);
        make.width.mas_equalTo(55);
    }];
    
    ssidField = [[UITextField alloc] init];
    ssidField.delegate = self;
    [ssidField setTextColor:[UIColor colorWithHexString:@"#828389"]];
    [ssidView addSubview:ssidField];
    [ssidField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(label1.mas_right).mas_offset(21);
        make.right.mas_equalTo(ssidView).mas_offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(ssidView);
    }];
    UIButton *clearB = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    [clearB setImage:[UIImage imageNamed:@"soswifi_edit_clear"] forState:UIControlStateNormal];
    [clearB addTarget:self action:@selector(clearSSID) forControlEvents:UIControlEventTouchUpInside];
    ssidField.rightView = clearB;
    ssidField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    if (!SSIDTipL) {
        SSIDTipL = [[UILabel alloc] init];
        [SSIDTipL setFont:[UIFont systemFontOfSize:12]];
        [SSIDTipL setTextColor:[UIColor colorWithHexString:@"#828389"]];
        [SSIDTipL setText:isowner?@"*名称需要6-18个字符，仅支持大小写字母，数字":nil];
        [self.view addSubview:SSIDTipL];
        [SSIDTipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ssidView.mas_bottom).mas_offset(6);
            make.leading.mas_equalTo(15);
        }];
    }
    
    //pd
    pdView = [[UIView alloc] init];
    pdView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:pdView];
    [pdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSIDTipL.mas_bottom).mas_offset(isowner?17:4);
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(55);
    }];
    UILabel *label2 = [[UILabel alloc] init];
    [label2 setText:@"密     码"];
    [label2 setFont:[UIFont systemFontOfSize:15]];
    [label2 setTextColor:[UIColor colorWithHexString:@"#28292F"]];
    label2.textAlignment = NSTextAlignmentLeft;
    [pdView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(pdView).mas_offset(32);
        make.centerY.mas_equalTo(pdView);
        make.width.mas_equalTo(55);
    }];
    
    pdField = [[UITextField alloc] init];
    pdField.delegate = self;
    pdField.secureTextEntry = YES;
    pdfieldTextSec = YES;
    [pdField setTextColor:[UIColor colorWithHexString:@"#828389"]];
    [pdView addSubview:pdField];
    [pdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(label2.mas_right).mas_offset(21);
        make.right.mas_equalTo(pdView).mas_offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(pdView);
    }];
    pdTextSecButton = [[UIButton alloc] init];
    [pdTextSecButton setImage:[UIImage imageNamed:@"sos_eye_close"] forState:UIControlStateNormal];
    [pdTextSecButton setImage:[UIImage imageNamed:@"sos_eye_open"] forState:UIControlStateSelected];
    [pdView addSubview:pdTextSecButton];
    [pdTextSecButton addTarget:self action:@selector(showPlainText:) forControlEvents:UIControlEventTouchUpInside];
    pdField.rightView = pdTextSecButton;
    pdField.rightViewMode = UITextFieldViewModeAlways;
    
    if (!PDTipL) {
        PDTipL = [[UILabel alloc] init];
        [PDTipL setFont:[UIFont systemFontOfSize:12]];
        [PDTipL setTextColor:[UIColor colorWithHexString:@"#828389"]];
        [PDTipL setText:isowner?@"*密码需要8-14个字符，仅支持大小写字母和数字":nil];
        [self.view addSubview:PDTipL];
        [PDTipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(pdView.mas_bottom).mas_offset(6);
            make.leading.mas_equalTo(15);
        }];
    }
    //connect tip
    normalTipL = [[UILabel alloc] init];
    normalTipL.numberOfLines = 0;
       NSMutableDictionary *textDict = [NSMutableDictionary dictionary];
       textDict[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#828389"];
       textDict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    
    //段落样式
       NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
       //行间距
       paraStyle.lineSpacing = 5.0;
       //首行文本缩进
       //使用
       //文本段落样式
       textDict[NSParagraphStyleAttributeName] = paraStyle;
     normalTipL.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:textDict];
    [normalTipL setLineBreakMode:(NSLineBreakByWordWrapping)];
    
    [self.view addSubview:normalTipL];
    [normalTipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(45);
        make.top.mas_equalTo(PDTipL.mas_bottom).mas_offset(isowner?30:16);
        make.trailing.mas_equalTo(-30);
    }];
    
    if (isowner) {
        saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setNSButtonStyle];
        [saveButton addTarget:self action:@selector(buttonSaveTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:saveButton];
        [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(93);
            make.trailing.mas_equalTo(-93);
            make.bottom.mas_equalTo(self.view).mas_offset(-16);
            make.height.mas_equalTo(37);
        }];
        saveButton.enabled = NO;
        
    }else{
        ssidField.userInteractionEnabled = NO;
        pdField.userInteractionEnabled = NO;
    }
    
    if ([CustomerInfo sharedInstance].currentVehicle.gen10) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
              [btn setTitle:@"流量查询" forState:UIControlStateNormal];
              [btn sizeToFit];
              [btn addTarget:self action:@selector(goTo4GPackage:) forControlEvents:UIControlEventTouchUpInside];
              self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}
//-(void)saveButtonState{
//    if (isvalidateSSID&&isvalidatePD) {
//        saveButton.enabled = YES;
//    }else{
//        saveButton.enabled = NO;
//    }
//}

-(void)clearSSID{
    [ssidField setText:nil];
}
-(void)clearPD{
    [pdField setText:nil];
}
-(void)showPlainText:(UIButton *)sender{
    [sender setSelected:!sender.selected];
   pdfieldTextSec = pdField.secureTextEntry = !pdField.secureTextEntry;
}

-(void)layoutViewForInfoVehicle{
    UILabel * flag = [[UILabel alloc] init];
    [flag setTextColor:[UIColor colorWithHexString:@"#828389"]];
    flag.adjustsFontSizeToFitWidth = YES;
    [flag setText:[self infoSSIDPrefix]];
    [ssidView addSubview:flag];
    [flag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(label1.mas_right).mas_offset(21);
        make.centerY.mas_equalTo(ssidView);
        make.width.mas_equalTo(100);
    }];
    [ssidField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(flag.mas_right).mas_offset(0);
        make.right.mas_equalTo(ssidView).mas_offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(ssidView);
    }];
}

- (void)shouldNavBackAndShowErrorAlert    {
    [Util showAlertWithTitle:nil message:@"车载Wi-Fi设置暂不可用，如有需要可至车内车载娱乐系统端做设置。" completeBlock:^(NSInteger buttonIndex) {
        [[LoadingView sharedInstance] stop];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
-(void)ssidTipNormal{
    [SSIDTipL setTextColor:[UIColor colorWithHexString:@"#828389"]];
    if ([self infoSSIDHasPrefix]) {
        [SSIDTipL setText:@"*名称需要6-14个字符，仅支持大小写字母和数字"];
    }else{
        [SSIDTipL setText:@"*名称需要6-18个字符，仅支持大小写字母和数字"];
    }
}
-(void)ssidTipError{
    SSIDTipL.text = @"输入内容不符合要求";
    SSIDTipL.textColor = [UIColor colorWithHexString:@"#C50000"];
    saveButton.enabled = NO;
}
-(void)pdTipNormal{
    [PDTipL setTextColor:[UIColor colorWithHexString:@"#828389"]];
    [PDTipL setText:@"*密码需要8-14个字符，仅支持大小写字母和数字"];
    
}
-(void)pdTipError{
    PDTipL.text = @"输入内容不符合要求";
    PDTipL.textColor = [UIColor colorWithHexString:@"#C50000"];
    saveButton.enabled = NO;
}
-(void)pdfieldEditingState{
       UIButton *clearB = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
       [clearB setImage:[UIImage imageNamed:@"soswifi_edit_clear"] forState:UIControlStateNormal];
       [clearB addTarget:self action:@selector(clearPD) forControlEvents:UIControlEventTouchUpInside];
       pdField.rightView = clearB;
       ssidField.rightViewMode = UITextFieldViewModeWhileEditing;
}
-(void)pdfieldNormalState{
       
       pdField.rightView = pdTextSecButton;
}
#pragma mark -network
-(void)getWIFIInfo{
    if (![[ServiceController sharedInstance] tryPerformRequest:GET_HOTSPOT_INFO_REQUEST StartTime:[NSDate date]]) {
        return;
    }
    [[LoadingView sharedInstance] startIn:self.view];
    ServiceController * service = [ServiceController sharedInstance];
    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
    [[ServiceController sharedInstance] updatePerformVehicleService];
    @weakify(self);
    [service startFunctionWithName:GET_HOTSPOT_INFO_REQUEST startSuccess:^(id result) {
        
    } startFail:^(id result) {
        [Util hideLoadView];
        @strongify(self);
        [self shouldNavBackAndShowErrorAlert];
        
    } askSuccess:^(id result) {
        [Util hideLoadView];
        [Util alertUserEvluateApp];
        @strongify(self);
        [self handleInfoResult:result];
        
    } askFail:^(id result) {
        @strongify(self);
        [Util hideLoadView];
        [self shouldNavBackAndShowErrorAlert];
        
    }];
}

-(void)setWifiInfo{
    ServiceController * service = [ServiceController sharedInstance];
    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
    
    service.ssid = [Util trimWhite:ssidField];
    service.passphrase = [Util trimWhite:pdField];
    
    [[LoadingView sharedInstance] startIn:self.view];
    @weakify(self);
    [service startFunctionWithName:SET_HOTSPOT_INFO_REQUEST startSuccess:^(id result) {
        
    } startFail:^(id result) {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:@"操作失败" message:[NSString stringWithFormat:@"车载热点信息更新失败\n请稍候重新尝试操作"] completeBlock:nil];
        
        
    } askSuccess:^(id result) {
        @strongify(self);
        [[LoadingView sharedInstance] stop];
        [Util alertUserEvluateApp];
        if ([self infoSSIDHasPrefix]) {
            [CustomerInfo sharedInstance].wifi_SSID = [[[CustomerInfo sharedInstance].wifi_SSID substringToIndex:10] stringByAppendingString:[Util trimWhite:ssidField]];
        }else{
            [CustomerInfo sharedInstance].wifi_SSID = [Util trimWhite:ssidField];
        }
        [CustomerInfo sharedInstance].wifi_pwd = [Util trimWhite:pdField];
        [self updateTip];
        
        [Util showSuccessHUDWithStatus:@"车载Wi-Fi修改成功"];
        
    } askFail:^(id result) {
        [[LoadingView sharedInstance] stop];
        [Util showErrorHUDWithStatus:@"车载Wi-Fi修改失败"];
    }];
    
}
- (void)handleInfoResult:(NSDictionary *)dic{
    if (dic) {
        NSString *ssid,*password;
        ssid = [[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"ssid"];
        password= [[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"passphrase"];
        if (ssid==nil) {
            ssid = [[[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"hotspotInfo"]objectForKey:@"ssid"];
        }
        if (password ==nil) {
            password = [[[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"hotspotInfo"]objectForKey:@"passphrase"];
        }
        [CustomerInfo sharedInstance].wifi_SSID = NNil(ssid);
        [CustomerInfo sharedInstance].wifi_pwd = NNil(password);
        if ([self infoSSIDHasPrefix]) {
            [self layoutViewForInfoVehicle];
            self -> ssidField.text =  [[CustomerInfo sharedInstance].wifi_SSID substringFromIndex:10];
        }else{
            self -> ssidField.text =  [CustomerInfo sharedInstance].wifi_SSID;
        }
        self -> pdField.text =  [CustomerInfo sharedInstance].wifi_pwd;
        if ([[CustomerInfo sharedInstance].wifi_SSID isNotBlank]) {
            [self updateTip];
            if (!wifiIcon) {
                wifiIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon／22x22／icon_wifi_def_22x22"]];
                [self.view addSubview:wifiIcon];
                [wifiIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(22, 22));
                    make.top.mas_equalTo(normalTipL);
                    make.right.mas_equalTo(normalTipL.mas_left).mas_offset(-8);
                }];
            }
        }
    }else{
        [self shouldNavBackAndShowErrorAlert];
    }
}
-(void)updateTip{
    NSMutableDictionary *textDict = [NSMutableDictionary dictionary];
          textDict[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#828389"];
          textDict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
       
       //段落样式
          NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
          //行间距
          paraStyle.lineSpacing = 5.0;
          //首行文本缩进
          //使用
          //文本段落样式
          textDict[NSParagraphStyleAttributeName] = paraStyle;
        normalTipL.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"通过无线局域网在车内连接车载Wi-Fi\n1. 从您的手机或其他设备的无线局域网设置中选取“%@”\n2. 按照连接提示输入密码",[CustomerInfo sharedInstance].wifi_SSID] attributes:textDict];
}
//save changed wifi
-(void)buttonSaveTapped{
    BOOL isvalidateSSID = YES;
       BOOL isvalidatePD = YES;
    if ([self infoSSIDHasPrefix]) {
        if (![Util isValidateInfo3SSID:ssidField.text]) {
            [self ssidTipError];
            isvalidateSSID = NO;
//            [ssidField becomeFirstResponder];
        }
        
    }else{
        if (![Util isValidateSSID:ssidField.text]) {
            [self ssidTipError];
            isvalidateSSID = NO;
//            [ssidField becomeFirstResponder];
                }
    }
    if (![Util isvalidateSSIDPassword:pdField.text]) {
        [self pdTipError];
        isvalidatePD = NO;
//        [pdField becomeFirstResponder];
    }
    
    if (isvalidateSSID && isvalidatePD) {
        @weakify(self);
           [[SOSRemoteTool sharedInstance] checkPINCodeSuccess:^{
               @strongify(self);
               [self setWifiInfo];
           }];
    }else{
        
    }
    //check changed value
}

#pragma mark -UITextfield

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == ssidField) {
        [self ssidTipNormal];
    }else{
        [self pdTipNormal];
        if (textField.isSecureTextEntry) {
            textField.secureTextEntry = NO;
        }
        [self pdfieldEditingState];
    }
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([Util trim: textField].isNotBlank) {
        saveButton.enabled = YES;
    }else{
        saveButton.enabled = NO;
    }
    if (textField == pdField) {
        [textField setSecureTextEntry:pdfieldTextSec];
        [self pdfieldNormalState];
    }
    return YES;
}

//info3 vehicle wifi has prefix 'DIRECT'
-(BOOL)infoSSIDHasPrefix
{
    return [CustomerInfo sharedInstance].currentVehicle.info3 && [[CustomerInfo sharedInstance].wifi_SSID.uppercaseString hasPrefix:@"DIRECT"];
}
-(NSString *)infoSSIDPrefix{
    return  [[CustomerInfo sharedInstance].wifi_SSID substringToIndex:10];
}

@end

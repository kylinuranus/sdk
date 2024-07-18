//
//  UserCarInfoVC.m
//  Onstar
//  车牌号VC
//  Created by Coir on 15/10/30.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//

#import "UserCarInfoVC.h"
#import "CustomerInfo.h"
#import "CarNumInputView.h"
#import "RequestDataObject.h"
#import "PurchaseModel.h"

@interface UserCarInfoVC () <UITextFieldDelegate, CarNumInputViewDelegate>  {
    __weak IBOutlet UIView *safeBottomView;
    __weak IBOutlet UILabel *infoLabel;//车牌号、发动机号标题
    //    __weak IBOutlet UILabel *resultInfoLabel;//显示车牌号、发动机号
    __weak IBOutlet UITextField *inputTextField;//输入框
    __weak IBOutlet NSLayoutConstraint *inputTextFieldLeading;
    __weak IBOutlet UIButton *carNumButton;//车牌号按钮
    __weak IBOutlet UILabel *errorInfoLabel;//错误提示信息
    __weak IBOutlet UIButton *ensureButton;//修改、确定按钮
    
    NSString *engineNumString;//发动机号
    NSString *lisenceNumString;//车牌
    CarNumInputView *carNumInputView;
}
@end

@implementation UserCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.view.backgroundColor = SOSUtil.onstarLightGray;
    inputTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ISIPAD ? 30 : 15, 30)];
    inputTextField.leftViewMode = UITextFieldViewModeAlways;
    inputTextField.layer.cornerRadius = 4;
    inputTextField.layer.masksToBounds = YES;
    
    carNumInputView = [[CarNumInputView alloc] init];
    carNumInputView.delegate = self;
    carNumInputView.top = SCREEN_HEIGHT;
    [self.view addSubview:carNumInputView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lisenceNumString = UserDefaults_Get_Object(@"CarInfoTypeLicenseNum");
    engineNumString = UserDefaults_Get_Object(@"CarInfoTypeEngineNum");
    lisenceNumString = lisenceNumString.uppercaseString;
    engineNumString = engineNumString.uppercaseString;
    
    [self refreshState];
    if (self.carInfoType == CarInfoTypeLicenseNum) {
        self.title = @"设置车牌号";//NSLocalizedString(@"Plate_Number", nil);
    }   else if (self.carInfoType == CarInfoTypeEngineNum)  {
        self.title = @"设置发动机号";//NSLocalizedString(@"Engine_Number", nil);
    }
}

- (void)refreshState    {
    if (self.carInfoType == CarInfoTypeLicenseNum) {
        carNumButton.left = infoLabel.right + 5;
        inputTextField.left = carNumButton.right;
        if (lisenceNumString.length > 2) {
            [carNumButton setTitleForNormalState:[lisenceNumString substringToIndex:1]];
            inputTextField.text = [lisenceNumString substringFromIndex:1];
        }
        inputTextField.width = SCREEN_WIDTH - 30 - inputTextField.left;
        [ensureButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        inputTextField.placeholder = @"如:D37382";
        infoLabel.text = @"车 牌 号";  //@"车牌号：";
        [infoLabel sizeToFit];
        infoLabel.height = 30;
        //        }
    }   else if (self.carInfoType == CarInfoTypeEngineNum)  {
       
        carNumButton.hidden = YES;
        inputTextFieldLeading.constant = - 50.;
        infoLabel.text = NSLocalizedString(@"Engine_Number", nil);
        [infoLabel sizeToFit];
        infoLabel.height = 30;
        //            resultInfoLabel.left = infoLabel.right + 10;
        inputTextField.left = infoLabel.right;
        inputTextField.text = engineNumString;
        inputTextField.width = SCREEN_WIDTH - 30 - inputTextField.left;
        [ensureButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        inputTextField.placeholder = @"如:D3278761";
        //        }
    }
}

#pragma mark - 修改、保存点击
- (IBAction)ensure:(UIButton *)sender {
    [inputTextField resignFirstResponder];
    NSString *utf8Str = [carNumButton.titleLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* tempStr = [utf8Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //保存
    //    if ([sender.titleLabel.text isEqual:NSLocalizedString(@"Save", nil)]) {
    inputTextField.text = [Util trim:inputTextField];
    BOOL isCorrectNum = NO;
    if (self.carInfoType == CarInfoTypeLicenseNum) {
        isCorrectNum = [Util isCorrectLicenseNum:[carNumButton.titleLabel.text stringByAppendingString:inputTextField.text]];
    }else{
        isCorrectNum = [Util isCorrectEngineNum:inputTextField.text];
    }
    
    if (!isCorrectNum) {
        if (inputTextField.text.length)    {
            errorInfoLabel.text = [(self.carInfoType == CarInfoTypeEngineNum ? NSLocalizedString(@"engine", nil) : NSLocalizedString(@"license_plate", nil)) stringByAppendingString:NSLocalizedString(@"error_please_re-enter", nil)];
            errorInfoLabel.hidden = NO;
            return;
        }
    }else{
        errorInfoLabel.hidden = YES;
    }
    
    if (self.carInfoType == CarInfoTypeLicenseNum) {
        [SOSDaapManager sendActionInfo:PlateNo_save];
        if (inputTextField.text.length) {
            lisenceNumString = [tempStr stringByAppendingString:inputTextField.text.uppercaseString];
        }   else    {
            lisenceNumString = @"";
        }
        
        NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
        [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
        [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [request setLicensePlate:lisenceNumString];
        [self updateCarInfo:[request mj_JSONString] compCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitle:NSLocalizedString(@"modify", nil) forState:UIControlStateNormal];
                //                    inputTextField.hidden = YES;
                //                    resultInfoLabel.hidden = NO;
                //                    resultInfoLabel.text = inputTextField.text.uppercaseString;
                [self endEditCarNum];
                //            carNumButton.hidden = YES;
                infoLabel.text = NSLocalizedString(@"Plate_Number", nil);
            });
            UserDefaults_Set_Object(lisenceNumString, @"CarInfoTypeLicenseNum");
            [self performSelectorOnMainThread:@selector(navBack:) withObject:nil waitUntilDone:NO];
            [Util showSuccessHUDWithStatus:@"设置成功"];
        }];
    }else if (self.carInfoType == CarInfoTypeEngineNum)  {
        [SOSDaapManager sendActionInfo:EngineNo_save];
        engineNumString = inputTextField.text.uppercaseString;
        
        NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
        [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
        [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [request setEngineNumber:engineNumString];
        [self updateCarInfo:[request mj_JSONString] compCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //                    inputTextField.hidden = YES;
                //                    resultInfoLabel.hidden = NO;
                [sender setTitle:NSLocalizedString(@"modify", nil) forState:UIControlStateNormal];
                //                    resultInfoLabel.text = inputTextField.text.uppercaseString;
                inputTextField.placeholder = @"如：D3278761";
                infoLabel.text = NSLocalizedString(@"Engine_Number", nil);
            });
            UserDefaults_Set_Object(engineNumString, @"CarInfoTypeEngineNum");
            [self performSelectorOnMainThread:@selector(navBack:) withObject:nil waitUntilDone:NO];
        }];
    }
    
}

#pragma mark - 导航栏返回
- (IBAction)navBack:(UIButton *)sender {
    if (self.carInfoType == CarInfoTypeLicenseNum) {
        [SOSDaapManager sendActionInfo:PlateNo_back];
    }else {
        [SOSDaapManager sendActionInfo:EngineNo_back];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 更新保险日期
- (void)updateCarInfo:(NSString *)json compCallback:(void (^)(void))compCallback
{
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        
        [Util showLoadingView];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                !compCallback ? : compCallback();
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            [Util showAlertWithTitle:nil message:dic[@"description"] completeBlock:nil];
            [Util hideLoadView];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
    }else{
        
        [Util showAlertWithTitle:nil message:@"无法修改,获取车辆信息错误" completeBlock:nil];
    }
   
}

- (IBAction)changeCarNum:(UIButton *)sender{
    [self.view endEditing:YES];
    [self beginEditCarNum];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self endEditCarNum];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length == 0) {
        textField.text = [textField.text stringByAppendingString:[string uppercaseString]];
        if(self.carInfoType != CarInfoTypeEngineNum && textField.text.length>7)
        {
            textField.text = [textField.text substringToIndex:7];
        }
        return NO;
    }
    return YES;
}

- (void)beginEditCarNum{
    [UIView animateWithDuration:.3 animations:^{
        carNumInputView.bottom = safeBottomView.bottom;
        [carNumInputView setSelect:carNumButton.titleLabel.text];
    }];
}

- (void)endEditCarNum{
    [UIView animateWithDuration:.3 animations:^{
        carNumInputView.top = self.view.bottom;
    }];
}

#pragma mark - CarNumInputView Delegate
- (void)outputStrChanged:(NSString *)output{
    [SOSDaapManager sendActionInfo:PlateNo_province];
    carNumButton.titleLabel.text = output;
    [carNumButton setTitle:output forState:UIControlStateNormal];
}

- (void)finishInput{
    [self endEditCarNum];
}

#pragma mark - 车牌号接口
+ (void)getVehicleBasicInfoSuccess:(nullable void (^)(BOOL success))block;
{
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [NSString stringWithFormat:(@"%@" VEHICLE_INFO_URL), BASE_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        
        SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSLog(@"车牌号 responseStr %@",responseStr);
            NSError *error = nil;
            NSDictionary *vehicleDic =[Util dictionaryWithJsonString:responseStr];
            NSLog(@"车牌号  %@",vehicleDic);
            if (!error)
            {
                if(vehicleDic!=nil){
                    NSString *engineNumber = vehicleDic[@"engineNumber"];
                    NSString *licensePlate = vehicleDic[@"licensePlate"];
                    UserDefaults_Set_Object(licensePlate, @"CarInfoTypeLicenseNum");
                    UserDefaults_Set_Object(engineNumber, @"CarInfoTypeEngineNum");
                }
            }else{
                NSLog(@"http error");
            }
            if (block) {
                block(YES);
            }
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSLog(@"车牌号失败  %ld %@ %@ ",(long)statusCode,responseStr,error);
            if (block) {
                block(NO);
            }
        }];
        [sosOperation setHttpMethod:@"GET"];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation start];
        
    }else{
        
        if (block) {
            block(NO);
        }
    }
    
}

 

@end

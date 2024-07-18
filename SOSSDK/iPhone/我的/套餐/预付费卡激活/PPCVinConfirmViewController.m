//
//  PPCVinConfirmViewController.m
//  Onstar
//
//  Created by Joshua on 6/10/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PPCVinConfirmViewController.h"
#import "SOSPrepaidCardVC.h"
#import "PurchaseModel.h"
#import "LoadingView.h"

@interface PPCVinConfirmViewController ()

@end

@implementation PPCVinConfirmViewController     {

    __weak IBOutlet UIButton *nextBtn;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"车辆识别";
    self.backRecordFunctionID = Activeforothers_Activpage_back;
    
    [_vinNumber setSuppressibleKeyboard];
    [_phoneNumber setSuppressibleKeyboard];
    nextBtn.layer.cornerRadius = 3;
    nextBtn.layer.masksToBounds = YES;
    nextBtn.backgroundColor = [UIColor colorWithHexString:@"0e5fce"];
    _vinNumber.delegate = self;
    _phoneNumber.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([PurchaseModel getUserType] == UserTypeAnonymous) {
        self.phoneView.hidden = NO;
    } else {
        self.phoneView.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated     {
    [super viewWillDisappear:animated];
    [[PurchaseProxy sharedInstance] removeListener:self];
}

- (IBAction)backToPreviousView:(id)sender     {
    if ([[self.navigationController viewControllers] count] <= 1) {
        [PurchaseModel purgeSharedInstance];
        [PurchaseProxy purgeSharedInstance];
//        [self dismissModalViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
    _vinNumber.text = [_vinNumber.text uppercaseString];
    if (textField == _vinNumber) {
        [self validateVin];
    } else if (textField == _phoneNumber) {
        [self validatePhone];
    }
}

- (BOOL)validateVin     {
    NSString *retStr = nil;
    NSString *vin = [_vinNumber text];
    if ([vin length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else if (![Util isValidateVin:vin]) {
        retStr = NSLocalizedString(@"SB027_MSG003", nil);
    }
    _vinEmptyLabel.text = retStr;
    return [retStr length] == 0;
}

- (BOOL)validatePhone     {
    if (_phoneView.hidden) {
        return YES;
    }
    
    NSString *retStr = nil;
    NSString *phone = [_phoneNumber text];
    if ([phone length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else if (![Util isValidatePhone:phone]) {
        retStr = NSLocalizedString(@"SB027_MSG012", nil);
    }
    _phoneEmptyLabel.text = retStr;
    return [retStr length] == 0;
}

- (BOOL)validateInput     {
    return [self validateVin] && [self validatePhone];
}

- (IBAction)nextButtonPressed:(id)sender     {
    [self.view endEditing:YES];
    if ([self validateInput]) {
        [SOSDaapManager sendActionInfo:Activeforothers_Next];
        [[LoadingView sharedInstance] startIn:self.view];
        [[PurchaseProxy sharedInstance] addListener:self];
        [[PurchaseProxy sharedInstance] getAccountInfoByVin:_vinNumber.text];
    } else
        return;
}

- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[PurchaseProxy sharedInstance] removeListener:self];
    [[LoadingView sharedInstance] stop];
    
    NNExtendedSubscriber *response = [[PurchaseModel sharedInstance] getAccountInfoResponse];
    if (success && response && [[response make] length] > 0) {
        
        SOSPrepaidCardVC *vc = [SOSPrepaidCardVC new];
        vc.backDaapFunctionID = Prepaidcard_Activpage_back;
        vc.isFromVinConfirmation = YES;
        NNVehicle *vehicle = [[NNVehicle alloc] init];
        vehicle.vin = _vinNumber.text;
        vehicle.makeDesc = [response make];
        vehicle.modelDesc = [response model];
        [[PurchaseModel sharedInstance] setPpcVehicle:vehicle];
        
        [[PurchaseModel sharedInstance] setPpcPhone:_phoneNumber.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    } else {
        [Util showAlertWithTitle:nil message:object completeBlock:nil];
    }
}

// 获得焦点
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (_vinNumber==textField) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Activeforothers_VIN];
    }
    return YES;
}


@end

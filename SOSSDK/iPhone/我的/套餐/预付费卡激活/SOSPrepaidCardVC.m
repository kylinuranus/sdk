//
//  SOSPrepaidCardVC.m
//  Onstar
//
//  Created by Coir on 28/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPrepaidCardVC.h"
#import "PPCActivateViewController.h"
#import "PurchaseModel.h"
#import "PurchaseProxy.h"
#import "CustomerInfo.h"
#import "PPCHistoryViewController.h"
#import "LoadingView.h"
#import "UIImageView+WebCache.h"
#import "PPCVinConfirmViewController.h"
#import "AccountInfoUtil.h"
#import "NSString+jwt.h"

@interface SOSPrepaidCardVC ()  <ProxyListener, UITextFieldDelegate>   {
    UIButton *characterD;
    
    __weak IBOutlet UIButton *activateBtn;
    __weak IBOutlet UIButton *activeForOtherBtn;
    __weak IBOutlet UILabel *phoneLB;
    __weak IBOutlet UILabel *firstNameLB;
    __weak IBOutlet UILabel *lastNameLB;
}
@end

@implementation SOSPrepaidCardVC

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"预付费卡激活";
    __weak __typeof(self) weakSelf = self;
    
    [self setRightBarButtonItemWithTitle:@"订单记录" AndActionBlock:^(id item) {
        [SOSDaapManager sendActionInfo:Prepaidcard_Record];
        PPCHistoryViewController *vc = [[UIStoryboard storyboardWithName:[Util getStoryBoard] bundle:nil] instantiateViewControllerWithIdentifier:@"PPCHistoryViewController"];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    [activateBtn setTitle:@"立刻激活" forState:UIControlStateNormal];
    [_cardNumber setSuppressibleKeyboard];
    [_cardPassword setSuppressibleKeyboard];
    _cardNumber.delegate = self;
    _cardPassword.delegate = self;
    _cardPassword.text = @"";
    self.name.text = @"";
    
    if (self.isFromVinConfirmation) {
        self.backRecordFunctionID = Activeforothers_Activpage_back;
    }    else    {
        NNVehicle *vehicle = [[NNVehicle alloc] init];
        vehicle.vin = [[CustomerInfo sharedInstance] userBasicInfo].currentSuite.vehicle.vin;
        vehicle.make = [[[CustomerInfo sharedInstance] currentVehicle] make];
        vehicle.model = [[CustomerInfo sharedInstance] currentVehicle].model;
        vehicle.modelDesc = [[CustomerInfo sharedInstance] currentVehicle].modelDesc;
        vehicle.makeDesc = [[[CustomerInfo sharedInstance] currentVehicle] makeDesc];
        [[PurchaseModel sharedInstance] setPpcVehicle:vehicle];
        self.backRecordFunctionID = Prepaidcard_back;
    }
    [self getSubscriberInfo];
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    
    if (self.isFromVinConfirmation) {
        activeForOtherBtn.hidden = YES;
    }
    [self updateUI];
    self.cardNumber.text = @"";
    self.cardPassword.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // come from vin confirmation, no need change vehicle and buy for others
    if (!self.isFromVinConfirmation && [PurchaseModel getUserType] == UserTypeSubScriber) {
        self.constantView.hidden = YES;
        self.clickableView.hidden = NO;
        self.myMakeModel.text = [[[PurchaseModel sharedInstance] ppcVehicle] makeModel];
        self.myVin.text = [[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin stringInterceptionHide];
        firstNameLB.text = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        firstNameLB.hidden = YES;
        
        NSString *lastName = [CustomerInfo sharedInstance].userBasicInfo.idmUser.lastName;
        lastNameLB.text = [NSString stringWithFormat:@"%@ 先生/女士", lastName];
        phoneLB.text = [([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.length ? [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber : [CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress) stringInterceptionHide];
    } 	else 	{
        self.constantView.hidden = NO;
        self.clickableView.hidden = YES;

    }
}

- (void)updateUI     {
    NNExtendedSubscriber *response = [[PurchaseModel sharedInstance] getAccountInfoResponse];
    self.makeModel.text = [NSString stringWithFormat:@"%@", [[[PurchaseModel sharedInstance] ppcVehicle] makeModel]];
    self.vin.text = [[[[PurchaseModel sharedInstance] ppcVehicle] vin] stringInterceptionHide];
    self.name.text = [NSString stringWithFormat:@"%@ 先生/女士", response.lastName];
    
    NSString *contactMethod = nil;
    if ([CustomerInfo sharedInstance].changePhoneNo.length > 8) {
        contactMethod = [[CustomerInfo sharedInstance].changePhoneNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    } else if ([CustomerInfo sharedInstance].changeEmailNo.length > 0) {
        contactMethod = [Util maskEmailWithStar:[CustomerInfo sharedInstance].changeEmailNo];
    }
    self.contactMethod.text = contactMethod;
}

- (void)updatePPCPhone:(NSString *)phone     {
    [[PurchaseModel sharedInstance] setPpcPhone:phone];
}

- (void)viewWillDisappear:(BOOL)animated     {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self hideCharacterD:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification     {
    // NSNotification中的 userInfo字典中包含键盘的位置和大小等信息
    NSDictionary *userInfo = [notification userInfo];
    // UIKeyboardAnimationDurationUserInfoKey 对应键盘弹出的动画时间
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // UIKeyboardAnimationCurveUserInfoKey 对应键盘弹出的动画类型
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    //数字彩,数字键盘添加“D”按钮
    if (characterD){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];//设置添加按钮的动画时间
        [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];//设置添加按钮的动画类型
        
        //设置自定制按钮的添加位置(这里为数字键盘添加“D”按钮)
        NSLog(@"%@", NSStringFromCGRect(characterD.frame));
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if (screenHeight - characterD.frame.origin.y < FLT_MIN) {
            characterD.transform=CGAffineTransformTranslate(characterD.transform, 0, -53);
        }
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification     {
    // NSNotification中的 userInfo字典中包含键盘的位置和大小等信息
    [self hideCharacterD:notification];
}

- (void)hideCharacterD:(NSNotification *)notification     {
    NSDictionary *userInfo = [notification userInfo];
    // UIKeyboardAnimationDurationUserInfoKey 对应键盘收起的动画时间
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (characterD.superview)
    {
        [UIView animateWithDuration:animationDuration animations:^{
            //动画内容，将自定制按钮移回初始位置
            characterD.transform=CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            //动画结束后移除自定制的按钮
            [characterD removeFromSuperview];
            characterD = nil;
        }];
    } else {
        [characterD removeFromSuperview];
        characterD = nil;
    }
}

//初始化，数字键盘“D”按钮
- (void)configSpecialCharacterInKeyBoardButton{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    //初始化
    if (characterD == nil)
    {
        characterD = [UIButton buttonWithType:UIButtonTypeCustom];
        [characterD.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [characterD setTitle:@"D" forState:UIControlStateNormal];
        [characterD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        characterD.frame = CGRectMake(0, screenHeight, 106, 53);
        
        characterD.adjustsImageWhenHighlighted = NO;
        [characterD addTarget:self action:@selector(inputCharacterD) forControlEvents:UIControlEventTouchUpInside];
    }
    //每次必须从新设定“D”按钮的初始化坐标位置
    characterD.frame = CGRectMake(0, screenHeight, 106, 53);
    
    //由于ios8下，键盘所在的window视图还没有初始化完成，调用在下一次 runloop 下获得键盘所在的window视图
    [self performSelector:@selector(addDoneButton) withObject:nil afterDelay:0.0f];
    
}

- (void)inputCharacterD     {
    NSString *strCardNum = [self.cardNumber text];
    if (![strCardNum hasPrefix:@"D"]) {
        strCardNum = [NSString stringWithFormat:@"D%@", strCardNum];
        self.cardNumber.text = strCardNum;
    }
}

- (void)addDoneButton{
    //获得键盘所在的window视图
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [tempWindow addSubview:characterD];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField     {
    if (textField == self.cardNumber) {
        //        if (!ISIPAD) {
        //            [self configSpecialCharacterInKeyBoardButton];
        //        }
        
    }
    CGFloat textFieldBottomY = self.scrollView.frame.origin.y + textField.frame.origin.y + textField.frame.size.height;
    CGFloat keyboardTopY = self.view.frame.size.height - 250;
    if (textFieldBottomY > keyboardTopY) {
        [self.scrollView setContentOffset:CGPointMake(0, textFieldBottomY - keyboardTopY + 20) animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
    if (textField == self.cardNumber) {
        [self hideCharacterD:nil];
    }
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    if (textField == _cardNumber) {
        [self validateCardNum];
    } else if (textField == _cardPassword) {
        [self validatePassWord];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string     {
    NSString *expectStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _cardNumber) {
        if ([expectStr length] > 10) {
            return NO;
        }
    } else if (textField == _cardPassword) {
        if ([expectStr length] > 12) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateCardNum     {
    NSString *retStr = nil;
    NSString *card = [_cardNumber text];
    if ([card length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else {
        NSString *regex = @"^[D\\d]{10}$";
        NSPredicate *cardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![cardPredicate evaluateWithObject:card]) {
            retStr = NSLocalizedString(@"SB027_MSG001", nil);
        }
        
        if (![CustomerInfo sharedInstance].currentVehicle.wifiSupported && !self.isFromVinConfirmation) {
            NSString *regex = @"^D[\\d]{9}$";
            NSPredicate *cardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if ([cardPredicate evaluateWithObject:card]) {
                retStr = NSLocalizedString(@"SB027_MSG022", nil);
            }
        }
    }
    _cardEmptyLabel.hidden = !retStr.length;
    _cardEmptyLabel.text = retStr;
    return [retStr length] == 0;
}

- (BOOL)validatePassWord     {
    NSString *retStr = nil;
    NSString *pass = [_cardPassword text];
    if ([pass length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    }
    _passEmptyLabel.hidden = !retStr.length;
    _passEmptyLabel.text = retStr;
    return [retStr length] == 0;
}

- (IBAction)nextButtonPressed:(id)sender     {
    [self.view endEditing:YES];
    if (![self validateCardNum] || ![self validatePassWord]) {
        return;
    }
    if (self.isFromVinConfirmation) {
        [SOSDaapManager sendActionInfo:Prepaidcard_Activpage_confirm];
    }    else    {
        [SOSDaapManager sendActionInfo:Prepaidcard_Activenow];
    }
    [[PurchaseModel sharedInstance] setPpcCardNo:_cardNumber.text];
    [[PurchaseModel sharedInstance] setPpcCardPasswd:_cardPassword.text];
    [[LoadingView sharedInstance] startIn:self.view];
    [[PurchaseProxy sharedInstance] addListener:self];
    [[PurchaseProxy sharedInstance] validatePPC:self.isFromVinConfirmation];
}

- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[LoadingView sharedInstance] stop];
    [[PurchaseProxy sharedInstance] removeListener:self];
    NNActivatePPCResponse *response = [[PurchaseModel sharedInstance] validateResponse];
    if (success && [[response status] isEqualToString:@"VALID"]) {
        PPCActivateViewController *vc = [[UIStoryboard storyboardWithName:[Util getStoryBoard] bundle:nil] instantiateViewControllerWithIdentifier:@"PPCActivateViewController"];
        if (self.isFromVinConfirmation) {
            vc.activeType = ActivatePPCForOthers;
        } else {
            vc.activeType = ActivatePPCForMyself;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController pushViewController:vc animated:YES];
        });
        
    } else {
        [Util showAlertWithTitle:nil message:object completeBlock:nil];
    }
}

#pragma mark 为他人激活
- (IBAction)activeForOthers:(id)sender     {
    //    预付费卡激活页_为他人激活_输入VIN点下一步
    [SOSDaapManager sendActionInfo:Prepaidcard_Activeforothers];
    PPCVinConfirmViewController *vc = [[UIStoryboard storyboardWithName:[Util getStoryBoard] bundle:nil] instantiateViewControllerWithIdentifier:@"PPCVinConfirmViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 手机号
- (void)getSubscriberInfo     {
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    [AccountInfoUtil getAccountInfo:YES Success:^(NNExtendedSubscriber *subscriber) {
        [Util hideLoadView];
        [CustomerInfo sharedInstance].changePhoneNo = subscriber.mobile;
        [CustomerInfo sharedInstance].changeEmailNo = subscriber.email;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    } Failed:^{
        [Util hideLoadView];
    }];
}

// 获得焦点
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _cardNumber) {
        _cardEmptyLabel.hidden = YES;
    }   else if (textField == _cardPassword)    {
        _passEmptyLabel.hidden = YES;
    }
    return YES;
}

@end

//
//  SOSUtil.m
//  Onstar
//
//  Created by lizhipan on 17/3/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSUtil.h"
//#import "BuyOnStarPackageVC.h"
#import "NSString+JWT.h"
#import "SOSLoginDbService.h"
#import "SOSLoginUserDbService.h"
#import "SOSCardUtil.h"
#import "SOSCustomAlertView.h"
@implementation SOSUtil
NSString * const kDefault_Account_Avatar = @"avatar";

//+ (BOOL)shouldShowVerifyPersonInfo		{
//
//    BOOL isRightLoginState = [SOSUtil isRightLoginStateForNoticeVerifyPersionInfo];
//    if (isRightLoginState == NO)		return NO;
//    //增加实名认证入口
//    NSDictionary *dic = UserDefaults_Get_Object(KShouldNoticeVerifyPersionInfo);
//    NSNumber *shouldNotice = dic[[[CustomerInfo sharedInstance].userBasicInfo.idpUserId md5String]];
//    shouldNotice = shouldNotice == nil ? @(YES) : shouldNotice;
//    return shouldNotice.boolValue;
//}

//+ (BOOL)isRightLoginStateForNoticeVerifyPersionInfo		{
//    BOOL isRightLoginState = [LoginManage sharedInstance].loginState >= LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || [LoginManage sharedInstance].loginState < LOGIN_STATE_LOADINGUSERBASICINFOFAIL;
//    if (!isRightLoginState)        return NO;
//    if (![SOSCheckRoleUtil isOwner])    return NO;
//    if ([CustomerInfo sharedInstance].currentVehicle.gen9) 		return NO;
//    return YES;
//}


+ (SOSWebViewController *)generateBannerClickController:(NNBanner *)banner        {
    NNDispatcherReq *req = [[NNDispatcherReq alloc]init];
//    [req setUrl:banner.url];
    [req setDispatchFrom:@"BANNER"];
    [req setDispatchKey:[NSString stringWithFormat:@"%@",banner.bannerID]];
    [req setPartner_id:banner.partnerId];
    [req setContentType:banner.contentType];
    [req setMethod:banner.httpMethod];
    [req setAttributeData:banner.attributeData];
    [req setParamsData:banner.paramData];
    [req setLongitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude)];
    [req setLatitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude)];
    SOSWebViewController *web = [[SOSWebViewController alloc]initWithDispatcher:req];
//    web.closeSafeArea = YES;
    web.hideShareFlg = !banner.canSharing;
    web.shareUrl = banner.url;
    web.tempShareUrl = banner.url;
    web.shareImg = banner.thumbnailsUrl;
    web.titleStr = banner.title;
    web.isH5Title = banner.isH5Title.integerValue;
    return web;
}

+ (CustomNavigationController*)bannerClickShowController:(NNBanner *)banner
{
//    [[SOSReportService shareInstance] recordEventWithFunctionID:banner.functionId type:TypeEnumToString(Click) objectType:TypeEnumToString(Banner) objectID:[NSString stringWithFormat:@"%@",banner.bannerID] operation:@"" result:@"" extra:nil];
    //tap
    NSString *title = banner.title;
    NSString *contenturl = banner.contentUrl?banner.contentUrl:banner.url;
    NSString *content = banner.content;
    NSString *clickUrl = banner.clickMonitoringUrl;
    NSString *isScaling = banner.isScaling;
    NSString *isH5TitleStr = banner.isH5Title;
    NSString *data =  banner.paramData;
    if(data.length>0){
        contenturl =  [contenturl stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"&data=",data]];
    }
    int isH5Title = [isH5TitleStr isEqualToString:@"1"]?1:-1;
    if (clickUrl) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:clickUrl params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                NSLog(@"秒针点击URL [%@]", clickUrl);
            }
                                                                    failureBlock:nil];
            [operation start];
        });
    }
    NSInteger scaling = ([isScaling integerValue] == 1) ? 1 : -1;
    NSString * showType = banner.showType;
    UIViewController *rootVC = nil;
    switch (showType.integerValue) {
        //加载html字符串
        case 1:	{
            SOSWebViewController *vc = [[SOSWebViewController alloc]initWithTitle:title withUrl:contenturl withBannerType:scaling isH5Title:isH5Title];
            vc.HTMLString =content;
            vc.shouldDismiss = YES;
            rootVC = vc;
            break;
        }
        //兼容老后台
        case 2:	{
            //webview加载
            SOSWebViewController *vc = [[SOSWebViewController alloc]initWithTitle:title withUrl:contenturl withBannerType:scaling isH5Title:isH5Title];
            vc.shouldDismiss = YES;
            rootVC = vc;
            break;
        }
        case 3:
            rootVC = [self generateBannerClickController:banner];
            break;
        //Safari打开
        case 4:	{
            NSURL * safariurl = [NSURL URLWithString:contenturl];
            [[UIApplication sharedApplication] openURL:safariurl];
            break;
        }
        default:
            break;
    }
    if (rootVC) {
        CustomNavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:rootVC];
        return navi;
    }
    return nil;
}

+ (void)presentLoginFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:fromVC andTobePushViewCtr:toVC completion:^(BOOL finished) { }];
}

+ (void)callPhoneNumber:(NSString *)phoneNumber    {
    if (!phoneNumber.length) {
        [Util toastWithMessage:@"无号码"];
        return;
    }
    NSArray *phoneArray = [phoneNumber componentsSeparatedByString:@";"];
    if (phoneArray.count)   phoneNumber = phoneArray[0];
    if (phoneNumber) {
        if (SystemVersion >= 10.2) {
            NSString * url = [NSString stringWithFormat:@"tel:%@", phoneNumber];
            BOOL supportCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
            if (!supportCall)   {
                [Util showAlertWithTitle:NSLocalizedString(@"ContactNotSupport", nil) message:nil completeBlock:nil];
            }   else    {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }   else    {
            [Util showAlertWithTitle:phoneNumber message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    NSString * url = [NSString stringWithFormat:@"tel:%@", phoneNumber];
                    BOOL supportCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
                    if (!supportCall) {
                        [Util showAlertWithTitle:NSLocalizedString(@"ContactNotSupport", nil) message:nil completeBlock:nil];
                    }else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                }
            } cancleButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"callOnstar",nil), nil];
        }
    }
}
+ (void)callDearPhoneNumber:(NSString *)phoneNumber    {
     if (![phoneNumber isValidateTel]) {
             return;
         }
         SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:[NSString stringWithFormat:@"拨打经销商？\n%@",phoneNumber] detailText:nil cancelButtonTitle:@"拨打" otherButtonTitles:@[@"取消"]];
         alert.pageModel = SOSAlertViewModelCallPhone_Icon;
         alert.backgroundModel = SOSAlertBackGroundModelWhite;
         alert.buttonClickHandle = ^(NSInteger clickIndex) {
             if (clickIndex == 0) {
                 NSString *string = [NSString stringWithFormat:@"tel:%@", phoneNumber];
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
             }
         };
         [alert show];
}
+ (void)callBuyDataPackageController {
    [SOSCardUtil routerTo4GPackage];
}

+ (void)callBuyOnstarPackageController {
    [SOSCardUtil routerToOnstarPackage];
}

#pragma mark - 注册部分返回特定code报文判断
+ (BOOL)isOperationResponseSuccess:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E0000"]) {
        return YES;
    }	else	{
        return NO;
    }
}

+ (BOOL)isOperationResponseDescSuccess:(NSDictionary *)resDic        {
    if ([resDic[@"description"] respondsToSelector:@selector(boolValue)]) {
        return [resDic[@"description"] boolValue];
    }
    return NO;
}

//GAA中有对应的subscriber，且注册过MA
+ (BOOL)isOperationResponseMAAndSubscriber:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3106"]) {
        return YES;
    }	else	{
        return NO;
    }
}

// mobile/govid/vin已经注册过MA
+ (BOOL)isOperationResponseAlreadyRegister:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3304"]) {
        return YES;
    }	else	{
        return NO;
    }
}

//VIN已经enroll过,但没注册过MA
+ (BOOL)isOperationResponseEnrolledNoneMA:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3130"]) {
        return YES;
    }	else	{
        return NO;
    }
}

//VIN不存在
+ (BOOL)isOperationResponseNonexistenceVIN:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3107"]) {
        return YES;
    }	else	{
        return NO;
    }
}

//VIN已经enroll过,且注册过MA (车辆有多个subscriber)
+ (BOOL)isOperationResponseMAVINEnrolled:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3104"]) {
        return YES;
    }	else	{
        return NO;
    }
}

//车俩已Enroll用户与该车关联
+ (NSArray *)visitorAddVehicleResponse:(NSDictionary *)resDic        {
    if ([resDic[@"code"] isEqualToString:@"E3137"]) {
        return @[@"该车已开通安吉星服务",@"您已有的安吉星车辆已添加到您账户下",@"E3137"];
    }
    //车辆已注册安吉星用户和该车无绑定关系
    if ([resDic[@"code"] isEqualToString:@"E3135"]) {
        return @[@"车辆添加失败",@"该车已注册安吉星\n您与该车不是绑定关系\n您提供的身份证与现有车辆不匹配\n请重新修修改证件号码或拨打客服电话",@"E3135"];
    }
    //如果通过vin号查询到多个subscriber会直接报错给客户端提示 MSG_E3104
    if ([resDic[@"code"] isEqualToString:@"E3104"]) {
        return @[@"提示",@"您的车辆存在多种身份，\n请输入证件号进行升级。",@"E3104"];
    }
    //车辆未Enroll，但有MA有效Enroll请求，submitted/expired
    if ([resDic[@"code"] isEqualToString:@"E3131"]) {
        return @[@"您已提交过车辆注册请求",NSLocalizedString(@"Register_Success_Wait", nil),@"E3131"] ;
    }
    if ([resDic[@"code"] isEqualToString:@"E3107"]) {
        [SOSDaapManager sendActionInfo:regsiter_notification_vinnotexist];
        return @[@"车辆不存在",@"请您输入正确的VIN号或拨打客服电话\n400-820-1188",@"E3107"];
    }
    //govid 添加车辆失败，无法验证用户信息
    if ([resDic[@"code"] isEqualToString:@"E3136"]) {
        return @[@"提示",@"无法验证您的身份",@"E3136"];
    }
    //visitor通过 govid 添加车辆成功
    if ([resDic[@"code"] isEqualToString:@"E3139"]) {
        return @[@"恭喜您",@"您已升级成功成为安吉星车主",@"E3139"];
    }
    //visitor 通过vin添加成功
    if ([resDic[@"code"] isEqualToString:@"E3141"]) {
        return @[@"该车已开通安吉星服务",@"您已有的安吉星车辆已添加到您账户下",@"E3141"];
    }
    //govid不存在gsp
    if ([resDic[@"code"] isEqualToString:@"E1005"]) {
        return @[@"添加失败",resDic[@"description"],@"E1005"] ;
    }
    //govid存在gsp
    if ([resDic[@"code"] isEqualToString:@"E3322"]) {
        return @[@"提示",resDic[@"description"],@"E3322"] ;
    }
    //govid存在gsp
    if ([resDic[@"code"] isEqualToString:@"E3304"]) {
        return @[@"提示",resDic[@"description"],@"E3304"] ;
    }
    
    return nil;
}

//添加车辆visitor输入govid绑定车辆成功
+ (BOOL)isOperationResponseUpgradeSuccess:(NSDictionary *)resDic		{
    if ([resDic[@"code"] isEqualToString:@"E3139"]) {
        return YES;
    }	else	{
        return NO;
    }
}

//已经提交过enroll请求
+ (BOOL)isOperationResponseRequestEnrolled:(NSDictionary *)resDic	{
    if ([resDic[@"code"] isEqualToString:@"E3131"]) {
        return YES;
    }	else	{
        return NO;
    }
}

+ (NSArray *)vehicleSupportCommandArray	{
    NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchVehicleCommands:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    if (reslutStr.length > 0 && reslutStr) {
        NNSupportedCommands *supportedCommands = [NNSupportedCommands mj_objectWithKeyValues:reslutStr];
        NNCommands *commands = supportedCommands.commands;
        NSMutableArray * commandArr = [NSMutableArray array];
        for (NNCommand *command in commands.command) {
            [commandArr addObject:command.name];
        }
        return commandArr ;
        
    }	else	{
        return nil;
    }
}

+ (NSString *)checkPINResponseCode:(NSString *)resStr	{
    NSDictionary *resDic = [Util dictionaryWithJsonString:resStr];
    NSString *errorCode = nil;
    errorCode =[resDic objectForKey:@"description"];
    
    if ([errorCode isEqualToString:@"true"]) {
        //成功
        errorCode = @"0";
    }	else	{
        if ([errorCode isEqualToString:@"L7_304"]) {
            errorCode = @"L7_304";//最多输错10次
        }	else if ([errorCode isEqualToString:@"L7_305"]){
            errorCode = @"L7_305";//输错10次被锁
        }	else	{
            if ([resStr myContainsString:@"lock"]) {
                errorCode = @"L7_305";
            }	else	{
                errorCode = resStr;//call IG failed
            }
        }
    }
    
    return errorCode;
}
#pragma mark - end
#pragma mark - 用户角色对应客户端显示
+ (NSString *)roleZHcn:(NSString *)roleen	{
    if([[roleen lowercaseString] isEqualToString:ROLE_OWNER])	{
        return @"车主";
    }	else	{
        if([[roleen lowercaseString] isEqualToString:ROLE_DRIVER])	{
            return @"司机";
        }	else	{
            if([[roleen lowercaseString] isEqualToString:ROLE_PROXY])	{
                return @"代理";
            }	else	{
                if([[roleen lowercaseString] isEqualToString:ROLE_VISITOR])	{
                    return @"访客";
                }	else	{
                    return @"未知角色";
                }
            }
        }
    }
}

+ (NSString *)brandToMSP:(NSString *)br_emip	{

    if (br_emip) {
        return br_emip;
    }	else	{
        return @"ALL";
    }
}

+ (void)recordAccountConfirmNewTCPS:(NSString *)account		{
    //本地记录 - 等待BA确认,本地记录需要tcps版本号
    NSDictionary * tcpsConfirm = [NSDictionary dictionaryWithObjectsAndKeys:account,@"account",[NSNumber numberWithBool:YES],kPreference_Confirm_TCPS, nil];
    UserDefaults_Set_Object(tcpsConfirm, kPreference_Confirm_TCPS);
}

+ (void)showCustomAlertWithTitle:(NSString *)title_ message:(NSString *)message_ completeBlock:(CompleteBlock)complete_		{
    if ([[NSThread currentThread] isMainThread]) {
//        [Util showAlertWithTitle:title_ message:message_ completeBlock:complete_];
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:title_ detailText:message_ cancelButtonTitle:nil otherButtonTitles:@[@"知道了"]];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:complete_];
        [alert show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:title_ detailText:message_ cancelButtonTitle:nil otherButtonTitles:@[@"知道了"]];
            [alert setButtonMode:SOSAlertButtonModelHorizontal];
            [alert setButtonClickHandle:complete_];
            [alert show];
        });
    }
}
+ (void)showCustomAlertWithTitle:(NSString *)title_ message:(NSString *)message_ cancleButtonTitle:(NSString *)cancleTitle_ otherButtonTitles:(NSArray *)titleArray_ completeBlock:(CompleteBlock)complete_        {
    dispatch_async(dispatch_get_main_queue(), ^{
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:title_ detailText:message_ cancelButtonTitle:cancleTitle_ otherButtonTitles:titleArray_];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:complete_];
        [alert show];
    });
}
+ (BOOL)queryAccountAreadyConfirmTCPS:(NSString *)account	{
    if ([UserDefaults_Get_Object(kPreference_Confirm_TCPS) respondsToSelector:@selector(count)]) {
        return  [[UserDefaults_Get_Object(kPreference_Confirm_TCPS) objectForKey:@"account"] isEqualToString:account] &&[[UserDefaults_Get_Object(kPreference_Confirm_TCPS) objectForKey:kPreference_Confirm_TCPS] boolValue];
    }	 else	{
        return NO;
    }
    
}

#pragma mark - end

+ (UIColor *)onstarLightViewControllerTitleColor	{
    return [UIColor colorWithHexString:@"4E4E5F"];
}

///APP默认的背景色。谨慎改动
+ (UIColor *)onstarLightGray	{
    return [UIColor colorWithHexString:@"#F3F5FE"];
}

+ (UIColor *)onstarButtonDisableColor	{
    return  [UIColor colorWithHexString:@"C4C4C9"];
}

+ (UIColor *)onstarButtonEnableColor	{
    return  [UIColor colorWithHexString:@"107FE0"];
}

+ (UIColor *)onstarTextFontColor	{
    return  [UIColor colorWithHexString:@"59708A"];
}
/*
  MA 9.0 颜色
 */
+ (UIColor *)onstarBlackColor    {
    return  [UIColor colorWithHexString:@"#4E5059"];
}

+ (UIColor *)defaultLabelBlack {
    return [UIColor colorWithHexString:@"#28292F"];
}

+ (UIColor *)defaultSubLabelBlack {
    return [UIColor colorWithHexString:@"#828389"];
}

+ (UIColor *)defaultLabelLightBlue {
    return [UIColor colorWithHexString:@"#6896ED"];
}

+ (int)getUserLevelWithDonationIntegral:(NSString*)donationIntegralStr    {
    int donationIntegral = donationIntegralStr.intValue;
    if (donationIntegral < 200)                                     return 0;
    else if (donationIntegral >= 200 && donationIntegral < 600)        return 1;
    else if (donationIntegral >= 600 && donationIntegral < 1000)    return 2;
    else if (donationIntegral >= 1000)                                return 3;
    
    return 0;
}

+ (UIImage *)brandImageWithBrandStr:(NSString *)str {
    if ([str.lowercaseString isEqualToString:@"buick"]) {
        return [UIImage imageNamed:@"brand_BUICK"];
    }else if ([str.lowercaseString isEqualToString:@"cadi"]) {
        return [UIImage imageNamed:@"brand_cadillac"];
    }else if ([str.lowercaseString isEqualToString:@"chevy"]) {
        return [UIImage imageNamed:@"brand_CHEVROLET"];
    }
    return nil;

}

+ (void)clearLoginUserRecord
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:NN_MASK_USERNAME];
    [defaults setObject:@"" forKey:NN_CURRENT_USERNAME];
    [defaults setObject:@"" forKey:NN_TEMP_USERNAME];
    [defaults synchronize];
}
#pragma mark - SOSAlert Stytle
+ (void)showOnstarAlertWithTitle:(NSString *)title_ message:(NSString *)message_ alertModel:(NSInteger)alertModel_ completeBlock:(CompleteBlock)complete_ cancleButtonTitle:(NSString *)canceltitle_ otherButtonTitles:(NSArray *)otherTitles_
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:title_ detailText:message_ cancelButtonTitle:canceltitle_ otherButtonTitles:otherTitles_];
        alert.pageModel = alertModel_;//SOSAlertViewModelCallPhone;
        alert.buttonMode = SOSAlertButtonModelVertical;
        alert.backgroundModel = SOSAlertBackGroundModelWhite;
        alert.buttonClickHandle = complete_;
        [alert show];
    });
}
+ (SOSLoginUserDefaultVehicleVO *)getProfileObjFromDatabase {
    NSString *cachedProfileString = [[SOSLoginUserDbService sharedInstance] searchUserIdToken:[LoginManage sharedInstance].idToken];
    SOSLoginUserDefaultVehicleVO *profile = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:cachedProfileString]];
    return profile;
}

+ (void)saveProfileObjToDatabase:(SOSLoginUserDefaultVehicleVO *)profile {
    NSString *newProfileString = [profile mj_JSONString];
    [[SOSLoginUserDbService sharedInstance] updateUserIdToken:[LoginManage sharedInstance].idToken reposeString:newProfileString];
}
#pragma mark -AES128
/**
 *  加密
 *
 *  @param string 需要加密的string
 *
 *  @return 加密后的字符串
 */
+ (NSString *)AES128EncryptString:(NSString *)string{
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //加密
    NSData *aesData = [data AES128EncryptWithKey:AES128KEY iv:AES128IV];
    aesData = [aesData base64EncodedDataWithOptions:0];
    NSString *encodeStr = [[NSString alloc] initWithData:aesData encoding:NSUTF8StringEncoding];
    return  encodeStr;
}

/**
 *  解密
 *
 *  @param string 加密的字符串
 *
 *  @return 解密后的内容
 */
+ (NSString *)AES128DecryptString:(NSString *)string{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *aesData = [data AES128DecryptWithKey:AES128KEY iv:AES128IV];
    return [[NSString alloc] initWithData:aesData encoding:NSUTF8StringEncoding];
}

#pragma mark - 设置下一步按钮状态
+ (void)setButtonStateDisableWithButton:(UIButton *)button	{
    if (button.enabled) {
        button.enabled = NO;
        [button setBackgroundColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
    }
}
+ (void)setButtonStateDisableWithButton:(UIButton *)button withColor:(UIColor *)apColor   {
    if (button.enabled) {
        button.enabled = NO;
//        [button setBackgroundColor:apColor forState:UIControlStateDisabled];
//        button.layer.cornerRadius = 3;
//        button.layer.masksToBounds = YES;
    }
}

+ (void)setButtonStateEnableWithButton:(UIButton *)button	{
    if (!button.enabled) {
        button.enabled = YES;
        [button setBackgroundColor:[SOSUtil onstarButtonEnableColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
    }
}
+ (UILabel *)onstarLabelWithFrame:(CGRect )rect fontSize:(CGFloat)fontSize;
{
    UILabel * label = [[UILabel alloc] initWithFrame:rect];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextColor:[self onstarTextFontColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    return label;
}
@end

@implementation SOSClientAcronymTransverter
@end

@implementation SOSClientAcronymTransverterCollection

+ (NSDictionary *)objectClassInArray	{
    return @{ @"transArr" : @"SOSClientAcronymTransverter" };
}
@end

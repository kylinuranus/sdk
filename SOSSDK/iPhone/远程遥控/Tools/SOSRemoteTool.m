//
//  SOSRemoteTool.m
//  Onstar
//
//  Created by Coir on 2018/4/16.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "PoiHistory.h"
#import "SOSAudioBox.h"
#import "RegisterUtil.h"
#import "SOSTripModule.h"
#import "BaseSearchOBJ.h"
#import "SOSCardUtil.h"
#import "SOSRemoteTool.h"
#import "ChooseFingerView.h"
#import "SOSPinContentView.h"
#import "SOSDonateDataTool.h"
#import "ServiceController.h"
#import "SOSKeyChainManager.h"
#import "SOSBiometricsManager.h"
#import "HornFlashFingerView.h"
#import "SOSRegisterInformation.h"
#import "ViewControllerFingerprintpw.h"
#import "SOSFlexibleAlertController.h"
#import "SOSHVACSettingVC.h"
#import "FootPrintDataOBJ.h"

/// 消息类型
typedef NS_ENUM(NSUInteger, SOSRemoteToolMessageType)   {
    /// 请求指令
    SOSRemoteToolMessageType_RequestCommend = 1,
    /// 预操作弹框消息
    SOSRemoteToolMessageType_PreAction_AlertMessage,
    /// 操作成功消息提示音文件名
    SOSRemoteToolMessageType_PreAction_AlertSound_FileName,
    /// 操作完成弹框消息
    SOSRemoteToolMessageType_Operation_Result_Message,
    /// 对应服务包功能名
    SOSRemoteToolMessageType_Avaliable_Function_Name,
    /// 对应 DAAP ID
    SOSRemoteToolMessageType_DAAP_ID
    
};

@interface SOSRemoteTool ()	<GeoDelegate, ErrorDelegate>

@property (nonatomic, strong) BaseSearchOBJ *searchObj;
@property (nonatomic, copy) NSMutableDictionary *tempCarLocationDic;
@property (nonatomic, assign) BOOL isLBSPOI;
@property (nonatomic, copy) NSString * operatePOI;

@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation SOSRemoteTool
    
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SOSRemoteTool *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super alloc] init];
        [instance addObserver];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始值
        _lastOperationType = SOSRemoteOperationType_VOID;
    }
    return self;
}
    
#pragma mark - 全局Toast通知操作结果
- (void)addObserver		{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        // 远程遥控界面隐藏toast通知
        if ([[SOS_APP_DELEGATE fetchMainNavigationController].topViewController respondsToSelector:@selector(hideGlobleVehicleOperationToast)])		return;
        NSDictionary *notiDic = noti.userInfo;
        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
        NSString *message = notiDic[@"message"];
        if (notiDic[@"OperationType"]) {
            switch (resultState) {
                case RemoteControlStatus_OperateFail:	{
                    // 车辆位置操作单独处理
                    if (operationType == SOSRemoteOperationType_VehicleLocation)     	{
                        if (![[SOS_APP_DELEGATE fetchMainNavigationController].topViewController respondsToSelector:@selector(showVehicleLocation:)]) 	{
                            // 只在一级界面 车辆/On键/生活/我 4个页面弹窗提示，用户可以选择查看/取消。二级界面不提示
                            if (SOS_APP_DELEGATE.fetchMainNavigationController.viewControllers.count > 1)        {
                                [[SOSTripModule getMainTripVC] setVehicleLocationResultBlockWhenArrear:^{
                                    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:message message:nil customView:nil preferredStyle:SOSAlertControllerStyleAlert];
                                    NSString *titleStr;
                                    titleStr = @"知道了";
                                    SOSAlertAction *action = [SOSAlertAction actionWithTitle:titleStr style:SOSAlertActionStyleDefault handler:nil];
                                    [vc addActions:@[action]];
                                    
                                    [vc show];
                                }];
                            }
                        }
                        return;
                    }
                    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:message message:nil customView:nil preferredStyle:SOSAlertControllerStyleAlert];
                    NSString *titleStr ;//= @"好的";
                    //                    if (operationType == SOSRemoteOperationType_VehicleLocation || [SOSRemoteTool isSendPOIOperation:operationType]) {
                    titleStr = @"知道了";
                    //                    }
                    SOSAlertAction *action = [SOSAlertAction actionWithTitle:titleStr style:SOSAlertActionStyleDefault handler:nil];
                    [vc addActions:@[action]];
                    
                    [vc show];
                }
                break;
                case RemoteControlStatus_OperateSuccess:
                // 车辆位置操作单独处理
                if (operationType == SOSRemoteOperationType_VehicleLocation)     return;
                //                    [Util toastWithMessage:message];
                [Util showSuccessHUDWithStatus:message subStatus:nil];
                break;
                default:
                break;
            }
        }
    }];
}
    
#pragma mark - 下发 POI 数据处理
- (void)sendToCarWithOperationType:(SOSRemoteOperationType)type AndPOI:(SOSPOI *)poi	{
    if (![SOSRemoteTool isSendPOIOperation:type])		return;
    [SOSRemoteTool sharedInstance].isLBSPOI = (poi.sosPoiType == POI_TYPE_LBS);
    SOSRemoteOperationType realType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:NO AndShouldFlash:NO];
    NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
    poiDic[@"sourceData"] = poi.mj_JSONString;
    if (realType == SOSRemoteOperationType_SendPOI_TBT) {
        poiDic[@"desLatitude"] = NONil(poi.latitude);
        poiDic[@"desLongitude"] = NONil(poi.longitude);
        poiDic[@"street"] = NONil(poi.address);
        poiDic[@"city"] = NONil(poi.city);
        poiDic[@"countryName"] = @"China";
        if (poi.address.length) 	poiDic[@"destinationType"] = @"ST_ADDR";
        else						poiDic[@"destinationType"] = @"CITY_CENTER";
    }	else	{
        poiDic[@"destination_name"] = NONil(poi.name);
        poiDic[@"destination_phoneNumber"] = NONil(poi.tel);
        poiDic[@"destination_address_street"] = NONil(poi.address);
        poiDic[@"destination_address_city"] = NONil(poi.city);
        poiDic[@"destination_address_state"] = @"China";
        poiDic[@"destination_address_zipCode"] = NONil(poi.code);
        poiDic[@"destination_location_longitude"] = NONil(poi.longitude);
        poiDic[@"destination_location_latitude"] = NONil(poi.latitude);
    }
    
    [[SOSRemoteTool sharedInstance] checkAuthWithOperationType:realType Parameters:poiDic.mj_JSONString Success:^(SOSRemoteOperationType type, NSString *parameter) {
        [SOSRemoteTool sharedInstance].parameter = parameter;
        [SOSRemoteTool showPreActionAlertWithOperationType:type];
    } Failure:nil];
}

/// 通过 Vin 号下发到车
- (void)sendToCarWithOperationType:(SOSRemoteOperationType)type  Vin:(NSString *)vin AndPOI:(SOSPOI *)poi    {
    if (![SOSRemoteTool isSendPOIOperation:type])        return;
    [SOSRemoteTool sharedInstance].isLBSPOI = (poi.sosPoiType == POI_TYPE_LBS);
    SOSRemoteOperationType realType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:NO AndShouldFlash:NO];
    NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
    poiDic[@"sourceData"] = poi.mj_JSONString;
    if (realType == SOSRemoteOperationType_SendPOI_TBT) {
        poiDic[@"desLatitude"] = NONil(poi.latitude);
        poiDic[@"desLongitude"] = NONil(poi.longitude);
        poiDic[@"street"] = NONil(poi.address);
        poiDic[@"city"] = NONil(poi.city);
        poiDic[@"countryName"] = @"China";
        if (poi.address.length)     poiDic[@"destinationType"] = @"ST_ADDR";
        else                        poiDic[@"destinationType"] = @"CITY_CENTER";
    }    else    {
        poiDic[@"destination_name"] = NONil(poi.name);
        poiDic[@"destination_phoneNumber"] = NONil(poi.tel);
        poiDic[@"destination_address_street"] = NONil(poi.address);
        poiDic[@"destination_address_city"] = NONil(poi.city);
        poiDic[@"destination_address_state"] = @"China";
        poiDic[@"destination_address_zipCode"] = NONil(poi.code);
        poiDic[@"destination_location_longitude"] = NONil(poi.longitude);
        poiDic[@"destination_location_latitude"] = NONil(poi.latitude);
    }
    [SOSRemoteTool sharedInstance].parameter = poiDic.mj_JSONString;
    [self startServiceWithOperationType:realType Vin:vin];
}

+ (void)startHVACSetting	{
    if ([[ServiceController sharedInstance] canPerformRequest:nil]) {
        [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS];
        SOSHVACSettingVC *vc = [SOSHVACSettingVC new];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [[SOS_APP_DELEGATE fetchMainNavigationController].topViewController
         presentViewController:vc animated:NO completion:nil];
    }
}
#pragma mark - 下发前用户权限检查
- (void)startOperationWithOperationType:(SOSRemoteOperationType)type	{
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }

    if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin) {
        [self promptUserIsDefaultPin];
    }else{
        [[SOSRemoteTool sharedInstance] checkAuthWithOperationType:type Parameters:nil Success:^(SOSRemoteOperationType type, NSString *parameter) {
            [SOSRemoteTool sharedInstance].parameter = parameter;
            [SOSRemoteTool showPreActionAlertWithOperationType:type];
        } Failure:nil];
    }
    
}
    
- (void)startOperationWithOperationType:(SOSRemoteOperationType)type WithParameters:(NSString *)parameter		{
    if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin) {
        [self promptUserIsDefaultPin];
    }else{
        [[SOSRemoteTool sharedInstance] checkAuthWithOperationType:type Parameters:parameter Success:^(SOSRemoteOperationType type, NSString *parameter) {
            [SOSRemoteTool sharedInstance].parameter = parameter;
            [SOSRemoteTool showPreActionAlertWithOperationType:type];
        } Failure:nil];
    }
}
-(void)promptUserIsDefaultPin{
    [Util showAlertWithTitle:@"未设置车辆控制密码" message:@"检测到您尚未设置车辆控制密码，为了保障车辆安全，请设置车辆控制密码后使用该功能" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [SOSCardUtil routerToPinModificationDirectWay:^{
                
            }];
        }
    } cancleButtonTitle:@"暂不使用" otherButtonTitles:@"立即设置",nil];
}

- (void)checkAuthWithOperationType:(SOSRemoteOperationType)type Parameters:(NSString *)parameter Success:(void (^)(SOSRemoteOperationType type, NSString *parameter))success Failure:(void (^)(void))failure    {
    UIViewController *vc = [SOS_APP_DELEGATE fetchMainNavigationController].topViewController;
    // 检测登录
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:vc andTobePushViewCtr:nil completion:^(BOOL finished)	{
        if (finished)    {
            //排除访客
            if ( ![SOSCheckRoleUtil checkVisitorInPage:vc])			return;
            
            // 车辆定位排除 司机代理
            if (type == SOSRemoteOperationType_VehicleLocation) 	{
                if (![SOSCheckRoleUtil checkDriverProxyInPage:vc])	return;
                if (![CustomerInfo sharedInstance].userBasicInfo.preference.vehiclePreference.fmvOpt) {
                    [Util showAlertWithTitle:@"提示" message:@"该功能已经关闭，如需开启请拨打400-820-1188按3号键或者在车内按蓝色按钮联系技术支持小组为您处理。" completeBlock:nil];
                    return;
                }
            }
            //检测是否重复操作
            if (![[ServiceController sharedInstance] canPerformRequest:[SOSRemoteTool getRemoteRequestStringWithOperationType:type]]) 	return;
            
            // 用户是司机/代理, 且不是下发 POI 操作
            if ([SOSCheckRoleUtil isDriverOrProxy] && ![SOSRemoteTool isSendPOIOperation:type]) {
                //司机代理远程操作之前查询权限
                [Util showHUD];
                [OthersUtil queryCarsharingStatusSuccessHandler:^(SOSRemoteControlShareUser *res) {
                    [CustomerInfo sharedInstance].carSharingFlag = res.authorizeStatus;
                    // 具备远程操作权限
                    if (res && res.authorizeStatus) {
                        if (![[CustomerInfo sharedInstance].vehicleServicePrivilege hasVehicleServiceAviliable]) {
                            //重新刷新availableFuncs
                            [OthersUtil loadVehiclePrivilegeSuccessHandler:^(SOSNetworkOperation *operation, NSString *response) {
                                [Util dismissHUD];
                                SOSVehicleAndPackageEntitlement * entitlement = [SOSVehicleAndPackageEntitlement mj_objectWithKeyValues:[Util dictionaryWithJsonString:response]];
                                
                                if (entitlement) 	[[CustomerInfo sharedInstance] updateServiceEntitlement:entitlement];
                                
                                if (![SOSRemoteTool checkPackageServiceInPage:vc WithType:type])    return;
                                if (success)	success(type, parameter);
                                
                            } failureHandler:^(NSInteger statusCode,NSString *responseStr, NNError *error) {
                                [Util dismissHUD];
                                if (success)    success(type, parameter);
                            }];
                        }	else	{
                            [Util dismissHUD];
                            if (![SOSRemoteTool checkPackageServiceInPage:vc WithType:type])    return;
                            if (success)    success(type, parameter);
                        }
                        
                    }    else    {
                        [Util dismissHUD];
                        //没有远程操作权限
                        [Util showAlertWithTitle:@"车主未授权，请联系车主" message:nil confirmBtn:@"知道了" completeBlock:nil];
                    }
                } failureHandler:^(NSString *responseStr, NNError *error) {
                    [Util dismissHUD];
                    [Util showAlertWithTitle:nil message:responseStr completeBlock:NULL];
                }];
            }    else    {
                // 车主鉴权
                if (![SOSRemoteTool checkPackageServiceInPage:vc WithType:type])    return;
                if (success)    success(type, parameter);
            }
        }
    }];
}
    
#pragma mark - 弹出预操作警告提示
+ (void)showPreActionAlertWithOperationType:(SOSRemoteOperationType)type	{
    // 车辆定位, 下发 POI 不需要预操作提示
    if (type == SOSRemoteOperationType_VehicleLocation) {
        [SOSRemoteTool ensureActionWithOperationType:type];
        return;
        // 下发 POI 不需要权限鉴定和预操作提示
    }    else if ([SOSRemoteTool isSendPOIOperation:type])    {
        [[SOSRemoteTool sharedInstance] startServiceWithOperationType:type withResponse:YES];
        return;
    }
    // 确认操作 xx ?
    [Util showAlertWithTitle:nil message:[SOSRemoteTool getPreActionAlertMessageWithOperationType:type] completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [self ensureActionWithOperationType:type];
        }
    } cancleButtonTitle:NSLocalizedString(@"remoteOperationTipsCancel", @"") otherButtonTitles:@"知道了", nil];
}
    
+ (void)ensureActionWithOperationType:(SOSRemoteOperationType)type		{
    // 需要鉴定权限   闪灯鸣笛需要每次鉴定权限
    if ([[LoginManage sharedInstance] needVerifyPin] || [self isHornAndFlashMode:type])    {
        
        BOOL isSupportBiometrics = [SOSBiometricsManager isSupportBiometrics];
        BOOL isUserOpenBiometriesAuthentication = [SOSBiometricsManager isUserOpenBiometriesAuthentication];
        
        //验证指纹密码
        if (isSupportBiometrics && isUserOpenBiometriesAuthentication && [[LoginManage sharedInstance] pinCode]) {
            // 闪灯鸣笛
            if ([SOSRemoteTool isHornAndFlashMode:type])    {
                //进入闪灯鸣笛指纹页面,需要用户确认闪灯鸣笛详情
                SOSPinContentView *testView = [SOSPinContentView viewFromXib];
                testView.pinType = SOSPinTypeFaceHonkAndFlash;
                testView.flashSelected = (type == SOSRemoteOperationType_Light || type ==SOSRemoteOperationType_LightAndHorn);
                testView.hornSelected  = (type == SOSRemoteOperationType_Horn || type ==SOSRemoteOperationType_LightAndHorn);
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:[SOSBiometricsManager isSupportFaceId] ? @"面容 ID 验证" : @"指纹验证" message:nil customView:testView preferredStyle:SOSAlertControllerStyleAlert];
                
                SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
                    if (testView.flashSelected) {
                        [SOSDaapManager sendActionInfo:MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL15];
                    }
                    SOSRemoteOperationType resultType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:testView.hornSelected AndShouldFlash:testView.flashSelected];
                    [SOSRemoteTool verifyUserBiometricsWithOperationType:resultType];
                }];
                SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                [vc addActions:@[action2,action1]];
                [vc show];
                
            }    else    {
                // 其他车辆操作,直接验证指纹
                [SOSRemoteTool verifyUserBiometricsWithOperationType:type];
            }
        }    else {
            //判断是否需要提示用户设置指纹，如果需要，则中断此处逻辑。
            if ([self remindOpenBiometricsWithOperationType:type])		return;
        }
    }    else    {
        // 不需要鉴定权限
        [[SOSRemoteTool sharedInstance] startServiceWithOperationType:type withResponse:YES];
    }
}
    
#pragma mark - 更新 Token, PIN 网络校验
+ (void)upgradeTokenWithInputPwd:(NSString *)pwd Success:(void (^)(void))success Failure:(void (^)(NSString *))failure	{
    dispatch_async_on_main_queue(^{
        [Util showHUDWithStatus:nil];
    });
    
    NSString *inputPwd = pwd.length ? pwd : [LoginManage sharedInstance].pinCode;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *verifyPinResult = [[LoginManage sharedInstance] upgradeToken:inputPwd];
        dispatch_async_on_main_queue(^(){
            [Util dismissHUD];
            NSString *alertMessage = nil;
            if (verifyPinResult.length != 1)    {
                alertMessage = [Util visibleErrorMessage:verifyPinResult];
                verifyPinResult = @"9";
            }
            switch (verifyPinResult.intValue) {
                case SOSVerifyPinResultCode_Success:
                if (success)    success();
                return;
                case SOSVerifyPinResultCode_Fail:
                alertMessage = NSLocalizedString(@"L7_304", @"");
                break;
                case SOSVerifyPinResultCode_Lock:
                alertMessage = NSLocalizedString(@"L7_305", @"");
                break;
                default:
                break;
            }
            if (alertMessage) {
                if (verifyPinResult.intValue == SOSVerifyPinResultCode_Lock) {
                    [Util showAlertWithTitle:nil message:alertMessage completeBlock:nil];
                }else {
                    if (failure)    failure(alertMessage);
                }
            }
        });
        
    });
}
    
#pragma mark - 校验用户 PIN
    //登录前验证pin码，不涉及车辆操作
- (void)checkPINCodeWithIdpid:(NSString *)idpid Success:(void (^)(void))success     {
    [SOSRemoteTool showPINViewWithOperationType:SOSRemoteOperationType_LockCar message:nil Success:^(SOSFlexibleAlertController *vc, NSString *pinCode, SOSPinContentView *pinView) {
        [Util showLoadingView];
        SOSRegisterCheckPINRequest * pinRequest = [[SOSRegisterCheckPINRequest alloc] init];
        pinRequest.accountID = idpid;
        //        pinRequest.pin = pinCode;
        pinRequest.pin = [SOSUtil AES128EncryptString:pinCode];
        
        [RegisterUtil checkPIN:[pinRequest mj_JSONString] successHandler:^(NSString *responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseStr isEqualToString:@"0"]) {
                    if (success)    success();
                }    else {
                    [SOSUtil showCustomAlertWithTitle:@"提示" message:[Util visibleErrorMessage:responseStr] completeBlock:nil];
                }
            });
        } failureHandler:^(NSString *responseStr) {
            [Util hideLoadView];
            dispatch_async_on_main_queue(^(){
                [SOSUtil showCustomAlertWithTitle:@"提示" message:[Util visibleErrorMessage:responseStr] completeBlock:nil];
            });
        }];
    }];
}
    
    //弹出PIN验证页面(登录后)，验证pin码但不做车辆操作，比如enroll验证pin
- (void)checkPINCodeSuccess:(void (^)(void))success	{
    if ([[LoginManage sharedInstance] needVerifyPin]) {
        // 此处 Type 主要用于检验是不是闪灯鸣笛操作
        [SOSRemoteTool showPINViewWithOperationType:SOSRemoteOperationType_ValidatePin message:nil Success:^(SOSFlexibleAlertController *vc, NSString *pinCode, SOSPinContentView *pinView) {
            // 更新 Token , PIN 网络校验
            [SOSRemoteTool upgradeTokenWithInputPwd:pinCode Success:success Failure:^(NSString * err) {
                [SOSRemoteTool showPINViewWithOperationType:SOSRemoteOperationType_ValidatePin message:err Success:^(SOSFlexibleAlertController *vc, NSString *pinCode, SOSPinContentView *pinView) {
                    // 更新 Token , PIN 网络校验
                    [SOSRemoteTool upgradeTokenWithInputPwd:pinCode Success:^{
                        success();
                        
                    } Failure:^(NSString *err){
                        //                        SOSRemoteOperationType resultType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:pinView.hornSelected AndShouldFlash:pinView.flashSelected];
                        //                    [SOSRemoteTool checkPINCodeWithOperationType:SOSRemoteOperationType_ValidatePin message:err];
                        [self checkPINCodeSuccess:success];
                    }];
                    
                }];
                //            [SOSRemoteTool checkPINCodeWithOperationType:SOSRemoteOperationType_ValidatePin message:err];
            }];
        }];
    }    else    {
        if (success)     success();
    }
}
    
+ (void)showPINViewWithOperationType:(SOSRemoteOperationType)type message:(NSString *)errMsg Success:(void (^)(SOSFlexibleAlertController *vc, NSString *pinCode, SOSPinContentView *pinView))success		{
    BOOL isHornAndFlashMode = [SOSRemoteTool isHornAndFlashMode:type];
    SOSPinContentView *testView = [SOSPinContentView viewFromXib];
    if (isHornAndFlashMode) {
        testView.pinType = SOSPinTypePasswordHonkAndFlash;
        
        testView.flashSelected = (type == SOSRemoteOperationType_Light || type ==SOSRemoteOperationType_LightAndHorn);
        testView.hornSelected  = (type == SOSRemoteOperationType_Horn || type ==SOSRemoteOperationType_LightAndHorn);
    }else {
        testView.pinType = SOSPinTypePassword;
    }
    testView.errorMsg = errMsg;
    
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"服务密码" message:nil customView:testView preferredStyle:SOSAlertControllerStyleAlert];
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleDefault handler:nil];
    [vc addActions:@[action]];
    [vc show];
    @weakify(vc)
    // PIN 本地校验
    testView.didCompleteInputBlock = ^(NSString * _Nonnull pinCode, SOSPinContentView * _Nonnull pinView) {
        @strongify(vc)
        [vc dismissViewControllerAnimated:YES completion:^{
            NSString *pinCodeEx = @"[A-Za-z0-9.-]{1,}";
            NSPredicate *pinCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinCodeEx];
            if ([pinCodeTest evaluateWithObject:pinCode] != YES)    {
                [Util showAlertWithTitle:nil message:@"安吉星密码不能为空，且只能为字母或数字。" completeBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex) {
                        [SOSRemoteTool showPINViewWithOperationType:type message:errMsg Success:success];
                    }
                }];
                return;
            }
            if (success)     success(vc, pinCode, pinView);
        }];
        
    };
}
    
+ (void)checkPINCodeWithOperationType:(SOSRemoteOperationType)type message:(NSString *)errMsg	{
    [self showPINViewWithOperationType:type message:errMsg Success:^(SOSFlexibleAlertController *vc, NSString *pinCode, SOSPinContentView *pinView) {
        // 更新 Token , PIN 网络校验
        [SOSRemoteTool upgradeTokenWithInputPwd:pinCode Success:^{
            if (type != SOSRemoteOperationType_ValidatePin) {
                // PIN 校验成功, 执行车辆操作
                SOSRemoteOperationType resultType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:pinView.hornSelected AndShouldFlash:pinView.flashSelected];
                [[SOSRemoteTool sharedInstance] startServiceWithOperationType:resultType withResponse:YES];
            }
            
        } Failure:^(NSString *err){
            SOSRemoteOperationType resultType = [SOSRemoteTool getRightTypeWithType:type ShouldHorn:pinView.hornSelected AndShouldFlash:pinView.flashSelected];
            [SOSRemoteTool checkPINCodeWithOperationType:resultType message:err];
        }];
        
    }];
}
    
#pragma mark - 验证用户指纹
+ (void)verifyUserBiometricsWithOperationType:(SOSRemoteOperationType)type	{
    [SOSBiometricsManager showBiometricsWithSuccessBlock:^{
        [self upgradeTokenWithInputPwd:nil Success:^{
            // PIN 校验成功, 执行车辆操作
            [[SOSRemoteTool sharedInstance] startServiceWithOperationType:type withResponse:YES];
        } Failure:^(NSString *err) {
            [SOSRemoteTool checkPINCodeWithOperationType:type message:nil];
        }];
    } errorBlock:^(NSError *error) {
        switch (error.code) {
            //用户在Touch ID对话框中点击了取消按钮：
            case LAErrorUserCancel:
            NSLog(@"Authentication Cancelled: 用户取消");
            //是否放弃本次操作
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"RM_makeSure", @"") completeBlock:^(NSInteger buttonIndex) {
                if (!buttonIndex)     [SOSRemoteTool checkPINCodeWithOperationType:type message:nil];
            } cancleButtonTitle:NSLocalizedString(@"RM_input_PIN", @"") otherButtonTitles:NSLocalizedString(@"RM_OK", @""), nil];
            
            break;
            
            case LAErrorAuthenticationFailed:
            //是否重试
            //                [Util showAlertWithTitle:nil message:NSLocalizedString(@"FingerprintVerifyFailedTryAgain", @"") completeBlock:^(NSInteger buttonIndex) {
            //                    if (!buttonIndex)
            [SOSRemoteTool checkPINCodeWithOperationType:type message:nil];
            //                } cancleButtonTitle:NSLocalizedString(@"upgradeOKButton", @"") otherButtonTitles:nil];
            
            break;
            default:
            break;
        }
    }];
}
    
#pragma mark - 提示用户设置指纹
+ (BOOL)remindOpenBiometricsWithOperationType:(SOSRemoteOperationType)type    {
    return [SOSBiometricsManager shouldRemindUserOpenBiometricsAlert:^{
        
        [Util showAlertWithTitle:[SOSBiometricsManager isSupportFaceId] ? @"启用面容 ID" : @"启用指纹 ID" message:@"可用于登录及代替服务密码执行车辆服务" completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                UIStoryboard *fingerPwStoryboard = [UIStoryboard storyboardWithName:[Util getPersonalcenterStoryBoard] bundle:nil];
                ViewControllerFingerprintpw *fingerPrint = [fingerPwStoryboard instantiateViewControllerWithIdentifier:@"ViewControllerFingerprintpw"];
                UINavigationController *navVC = [SOS_APP_DELEGATE fetchMainNavigationController];
                UIViewController *presentedVC = navVC.topViewController.presentedViewController;
                if (presentedVC) {
                    [presentedVC dismissViewControllerAnimated:YES completion:^{
                        [navVC pushViewController:fingerPrint animated:YES];
                    }];
                }    else    {
                    [navVC pushViewController:fingerPrint animated:YES];
                }
            }
        } cancleButtonTitle:@"取消" otherButtonTitles:@"去启用", nil];
        
    } inputPinCode:^{
        [SOSRemoteTool checkPINCodeWithOperationType:type message:nil];
    }];
}
    
    // 发送打开空调命令时,需先进行 远程启动
- (void)preHandleHVACCommands:(BOOL)cancelHvac Vin:(NSString *)vin	{
    SOSRemoteOperationType type = cancelHvac ? SOSRemoteOperationType_RemoteStartCancel : SOSRemoteOperationType_RemoteStart;
    NSString *requestName = [SOSRemoteTool getRemoteRequestStringWithOperationType:type];
    // 操作加锁
    [[ServiceController sharedInstance] updatePerformVehicleService];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_InitSuccess ErrorCode:@"HVAC"];
        [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:requestName userInfo:@{@"state":@(RemoteControlStatus_InitSuccess), @"OperationType" : @(cancelHvac?SOSRemoteOperationType_CloseHVAC:type) , @"message": message, @"HVAC":@(YES)}];
    });
    NSString *recordFunctionID = [SOSRemoteTool getDaapIDMessageWithType:type];
    
    [[ServiceController sharedInstance] startFunctionWithName:requestName startSuccess:^(id result) {
        NSString *resultStr = (NSString *)result;
        if ([resultStr isEqualToString:@"Start success"]) {
            NSLog(@"start success*\n*");
            [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_InitSuccess AndCode:nil  Vin:vin];
        }
    } startFail:^(id result) {
        [SOSRemoteTool handleErrorResultWithType:type AndErrorCode:result hvac:YES Vin:vin];
        NSLog(@"start failed*\n*");
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:NO funcId:recordFunctionID];
        }
    } askSuccess:^(id result) {
        NSString *message = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_OperateSuccess ErrorCode:@"HVAC"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:requestName userInfo:@{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : @(type), @"message": message, @"HVAC":@(YES)}];
        });
        [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_OperateSuccess AndCode:nil Vin:vin];
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:YES funcId:recordFunctionID];
        }
        if (!cancelHvac) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sendRequestWithOperationType:SOSRemoteOperationType_OpenHVAC Vin:vin];
            });
        }
        
    } askFail:^(id result) {
        [SOSRemoteTool handleErrorResultWithType:type AndErrorCode:result hvac:YES Vin:vin];
        NSLog(@"polling failed*\n*");
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:NO funcId:recordFunctionID];
        }
    }];
}
    
#pragma mark - 发送车辆控制指令
- (void)startServiceWithOperationType:(SOSRemoteOperationType)type withResponse:(BOOL)needResponse     {
    NSString *recordFunctionID = [SOSRemoteTool getDaapIDMessageWithType:type];
    if (recordFunctionID) {
        _startTime = [[NSDate date] timeIntervalSince1970];
    }
    _lastOperationType = type;
    if (type == SOSRemoteOperationType_OpenHVAC)    {
        [self preHandleHVACCommands:NO Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }    else if (type == SOSRemoteOperationType_CloseHVAC)    {
        self.parameter = nil;
        [self preHandleHVACCommands:YES Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        //        [self sendRequestWithOperationType:SOSRemoteOperationType_RemoteStartCancel];
    }    else    {
        [self sendRequestWithOperationType:type Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }
}

- (void)startServiceWithOperationType:(SOSRemoteOperationType)type Vin:(NSString *)vin	{
    NSString *recordFunctionID = [SOSRemoteTool getDaapIDMessageWithType:type];
    if (recordFunctionID) {
        _startTime = [[NSDate date] timeIntervalSince1970];
    }
    _lastOperationType = type;
    if (type == SOSRemoteOperationType_OpenHVAC)	{
        [self preHandleHVACCommands:NO Vin:vin];
    }	else if (type == SOSRemoteOperationType_CloseHVAC)    {
        self.parameter = nil;
        [self preHandleHVACCommands:YES Vin:vin];
    }	else	{
        [self sendRequestWithOperationType:type Vin:vin];
    }
}
    
- (void)sendRequestWithOperationType:(SOSRemoteOperationType)type Vin:(NSString *)vin		{
    NSString *requestName = [SOSRemoteTool getRemoteRequestStringWithOperationType:type];
    ServiceController * service = [ServiceController sharedInstance];
    service.vin = vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;// 闪灯鸣笛 处理
    if ([SOSRemoteTool isHornAndFlashMode:type]) {
        if (type == SOSRemoteOperationType_LightAndHorn)     {
            service.alertType = ALERT_ALL;
        }    else if(type == SOSRemoteOperationType_Horn)    {
            service.alertType = ALERT_HORN;
        }    else if(type == SOSRemoteOperationType_Light)    {
            service.alertType = ALERT_LIGHT;
        }
    }
    // 操作加锁
    [[ServiceController sharedInstance] updatePerformVehicleService];
    _operationStastus = RemoteControlStatus_InitSuccess;
    NSString *message = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_InitSuccess ErrorCode:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:requestName userInfo:@{@"state":@(RemoteControlStatus_InitSuccess), @"OperationType" : @(type) , @"message": message}];
    
//#warning 拦截车况请求，需要调试车辆操作UI、动画的时候使用
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [SOSRemoteTool handleErrorResultWithType:type AndErrorCode:@"123" Vin:vin];
//               NSLog(@"polling failed*\n*");
//        _operationStastus = RemoteControlStatus_OperateFail;
//        [ServiceController.sharedInstance cleanUpVehicleSevices];
//
//    });
//    return;
    // 积分公益增加积分
    [SOSDonateDataTool modifyUserDonateInfoWithActionType:[SOSDonateDataTool getDonateOperationTypeWithRemoteOperationType:type] Success:nil Failure:nil];
    
    BOOL isSendingLBSPOI = NO;
    if ([SOSRemoteTool isSendPOIOperation:type]) {
        isSendingLBSPOI = [SOSRemoteTool sharedInstance].isLBSPOI;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:self.parameter.mj_JSONObject];
        NSString *sourcePoiData = parameters[@"sourceData"];
        self.operatePOI = sourcePoiData;
        [[SOSPoiHistoryDataBase sharedInstance] insert:[SOSPOI mj_objectWithKeyValues:sourcePoiData.mj_JSONObject]];
        [parameters removeObjectForKey:@"sourceData"];
        [service setValuesForKeysWithDictionary:parameters];
        self.parameter = nil;
    }

    NSString *recordFunctionID = [SOSRemoteTool getDaapIDMessageWithType:type];
    [[ServiceController sharedInstance] startFunctionWithName:requestName Parameters:self.parameter Vin:vin startSuccess:^(id result) {
        NSString *resultStr = (NSString *)result;
        if ([resultStr isEqualToString:@"Start success"]) {
            NSLog(@"start success*\n*");
            _operationStastus = RemoteControlStatus_InitSuccess;
            [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_InitSuccess AndCode:nil Vin:vin];
        }
    } startFail:^(id result) {
        [SOSRemoteTool handleErrorResultWithType:type AndErrorCode:result Vin:vin];
        _operationStastus = RemoteControlStatus_OperateFail;
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:NO funcId:recordFunctionID];
        }
        
        NSLog(@"start failed*\n*");
    } askSuccess:^(id result) {
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:YES funcId:recordFunctionID];
        }
        if (type == SOSRemoteOperationType_SendPOI_ODD || type == SOSRemoteOperationType_SendPOI_TBT )        {
            [self uploadFootPrintWithType:type];
        }
        if (type == SOSRemoteOperationType_VehicleLocation)		{
            [self handleVehicleLocationResult:result];
        }	else	{
            NSString *message = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_OperateSuccess ErrorCode:nil];
            dispatch_async_on_main_queue(^{
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : @(type), @"message": message}];
                // LBS 点发送成功后要求有特殊的提示页面
                if (isSendingLBSPOI)     userInfo[@"isSendingLBSPOI"] = @(YES);
                [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:requestName userInfo:userInfo];
            });
            [Util alertUserEvluateApp];
            [SOSRemoteTool playSoundAlertWithType:type];
            [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_OperateSuccess AndCode:nil Vin:vin];
            _operationStastus = RemoteControlStatus_OperateSuccess;
        }
        
        
    } askFail:^(id result) {
        [SOSRemoteTool handleErrorResultWithType:type AndErrorCode:result Vin:vin];
        NSLog(@"polling failed*\n*");
        if (recordFunctionID) {
            [SOSDaapManager sendSysLayout:_startTime endTime:[[NSDate date] timeIntervalSince1970] maxUploadTime:180 loadStatus:NO funcId:recordFunctionID];
        }
        _operationStastus = [result isEqualToString:NETWORK_TIMEOUT] ? RemoteControlStatus_OperateTimeout : RemoteControlStatus_OperateFail;
    } resultSuccess:nil resultFail:nil];
}
-(void)uploadFootPrintWithType:(SOSRemoteOperationType)type{
    if (self.operatePOI) {
        SOSPOI * opPoi = [SOSPOI mj_objectWithKeyValues:self.operatePOI];
        NSDictionary * ftDic = @{@"poiId":NONil(opPoi.pguid),@"printTime":[Util SOS_stringDate],@"longitude":opPoi.longitude,@"latitude":opPoi.latitude,@"poiName":NONil(opPoi.name),@"poiAddress":NONil(opPoi.address),@"source":type ==SOSRemoteOperationType_SendPOI_ODD?@"ODD":@"TBT"};
        [FootPrintDataOBJ uploadFootPrintByDic:ftDic];
        self.operatePOI = nil;
    }
}
#pragma mark - 车辆位置结果处理
- (SOSPOI *)loadSavedVehicleLocation    {
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady] == NO)       return nil;
    if (![SOSCheckRoleUtil isOwner])											return nil;
    NSString *key = [NSString stringWithFormat:@"%@%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin, K_CAR_LOCATION_STAR];
    NSString *poiStr = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!poiStr.length)        return nil;
    SOSPOI *poi = [SOSPOI mj_objectWithKeyValues:[poiStr mj_JSONObject]];
    [CustomerInfo sharedInstance].carLocationPoi = poi;
    return poi;
}
    
- (void)handleVehicleLocationResult:(NSDictionary *)result        {
    if ([result isKindOfClass:[NSDictionary class]] && result.count) {
        NSDictionary *commandResponse = result[@"commandResponse"];
        if ([commandResponse isKindOfClass:[NSDictionary class]] && commandResponse.count) {
            NSDictionary *body = commandResponse[@"body"];
            if ([body isKindOfClass:[NSDictionary class]] && body.count) {
                NSDictionary *location = body[@"location"];
                if ([location isKindOfClass:[NSDictionary class]] && location.count) {
                    NSString *latitude = location[@"lat"];
                    NSString *longitude = location[@"long"];
                    if (latitude.length || longitude.length) {
                        CLLocation *vehicleLocation = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                        //经纬度无效
                        if (!CLLocationCoordinate2DIsValid(vehicleLocation.coordinate)) {
                            [SOSRemoteTool handleErrorResultWithType:SOSRemoteOperationType_VehicleLocation AndErrorCode:NETWORK_TIMEOUT Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
                            _operationStastus = RemoteControlStatus_OperateTimeout;
                            return;
                        }    else    {
                            self.tempCarLocationDic = [NSMutableDictionary dictionaryWithDictionary:@{@"VEHICLE_LOCATION": vehicleLocation}];
                            //逆地理编码
                            self.searchObj = [BaseSearchOBJ new];
                            self.searchObj.geoDelegate = self;
                            [self.searchObj reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:latitude.floatValue longitude:longitude.floatValue]];
                        }
                    }    else    {
                        //经纬度为空
                        [SOSRemoteTool handleErrorResultWithType:SOSRemoteOperationType_VehicleLocation AndErrorCode:NETWORK_TIMEOUT Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
                        _operationStastus = RemoteControlStatus_OperateTimeout;
                        return;
                    }
                }
            }
        }
    }
}
    
    // Search ReGeo Delegate
- (void)reverseGeocodingResults:(NSArray *)results	{
    if (results.count) {
        SOSPOI *carPOI = [results[0] copy];
        carPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
        CLLocation *location = self.tempCarLocationDic[@"VEHICLE_LOCATION"];
        carPOI.x = @(location.coordinate.longitude).stringValue;
        carPOI.y = @(location.coordinate.latitude).stringValue;
        carPOI.operationDateStrValue = [[NSDate date] stringWithISOFormat];
        carPOI.operationTime = [[NSDate date] stringWithFormat:@"MM月dd日HH:mm"];
        [CustomerInfo sharedInstance].carLocationPoi = carPOI;
        
        NSString *carlocationString = [carPOI mj_JSONString];
        NSString *key = [NSString stringWithFormat:@"%@%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin, K_CAR_LOCATION_STAR];
        [[NSUserDefaults standardUserDefaults] setObject:carlocationString forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async_on_main_queue(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:@"vehicleLocation" userInfo:@{@"state": @(RemoteControlStatus_OperateSuccess), @"OperationType" : @(SOSRemoteOperationType_VehicleLocation), @"message": @"获取车辆位置成功。", @"CarPOIInfo": carPOI.mj_keyValues}];
            //判断是当前页面是否是地图页面,用来显示车辆位置
            [self showVehicleLocationOnMap:carPOI.mj_keyValues];
        });
        [Util alertUserEvluateApp];
        [SOSRemoteTool playSoundAlertWithType:SOSRemoteOperationType_VehicleLocation];
        _operationStastus = RemoteControlStatus_OperateSuccess;
        
    }	else	{
        // 逆地理编码失败
        [SOSRemoteTool handleErrorResultWithType:SOSRemoteOperationType_VehicleLocation AndErrorCode:NETWORK_TIMEOUT Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        _operationStastus = RemoteControlStatus_OperateTimeout;
    }
}
    
- (void)baseSearch:(id)searchOption Error:(NSString *)errCode	{
    // 逆地理编码失败
    [SOSRemoteTool handleErrorResultWithType:SOSRemoteOperationType_VehicleLocation AndErrorCode:NETWORK_TIMEOUT Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    _operationStastus = RemoteControlStatus_OperateTimeout;
    
}
    
- (void)showVehicleLocationOnMap:(NSDictionary *)vehicleLocation     {
    UIViewController *vc = [SOS_APP_DELEGATE fetchMainNavigationController].topViewController;
    if ([vc respondsToSelector:@selector(showVehicleLocation:)]) {
        if ([vc valueForKey:@"shouldShowVehicleLocation"]) {
            BOOL shouldDelay = NO;
            [vc performSelector:@selector(showVehicleLocation:) withObject:vehicleLocation afterDelay:shouldDelay];
            return;
        }
    }
    // 只在一级界面 车辆/On键/生活/我 4个页面弹窗提示，用户可以选择查看/取消。二级界面不提示
    if (SOS_APP_DELEGATE.fetchMainNavigationController.viewControllers.count > 1)		{
        [[SOSTripModule getMainTripVC] setVehicleLocationResultBlockWhenArrear:^{
            [[SOSTripModule getMainTripVC] showVehicleLocation:nil];
        }];
        return;
    }
    
    // 单独处理
    [Util showAlertWithTitle:nil message:@"车辆位置获取成功" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [self performSelectorOnMainThread:@selector(showVehicleLocationInNewView:) withObject:vehicleLocation waitUntilDone:NO];
        }
    } cancleButtonTitle:@"知道了" otherButtonTitles:@"立即查看", nil];
}
    
- (void)showVehicleLocationInNewView:(NSDictionary *)vehicleLocation     {
    [SOS_APP_DELEGATE.fetchMainNavigationController popToRootViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int index = 1;
        #ifdef SOSSDK_SDK
            index = 2;
        #endif
        [((UITabBarController *)SOS_APP_DELEGATE.fetchRootViewController) setSelectedIndex:index];
        [SOS_APP_DELEGATE.fetchMainNavigationController.topViewController performSelector:@selector(showVehicleLocation:) withObject:vehicleLocation afterDelay:.3];
    });
}
    
#pragma mark - 处理请求回调
+ (void)handleErrorResultWithType:(SOSRemoteOperationType)type AndErrorCode:(NSString *)code Vin:(NSString *)vin  {
    [self handleErrorResultWithType:type AndErrorCode:code hvac:NO Vin:vin];
}
    
+ (void)handleErrorResultWithType:(SOSRemoteOperationType)type AndErrorCode:(NSString *)code hvac:(BOOL)hvac Vin:(NSString *)vin		{
    NSString *msg = @"";
    NSString *HVAC = hvac ? @"HVAC" : nil;
    if ([code isEqualToString:NETWORK_TIMEOUT]) 		{
        [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_OperateTimeout AndCode:nil Vin:vin];
        msg = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_OperateTimeout ErrorCode:HVAC];
        
    }	else if ([code isEqualToString:BACKEND_ERROR])	{
        [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_OperateFail AndCode:code Vin:vin];
        msg = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_OperateFail ErrorCode:HVAC];
    }	else 											{
        [SOSRemoteTool cacheLatestResultWithType:type Staus:RemoteControlStatus_OperateFail AndCode:code Vin:vin];
        msg = [SOSRemoteTool getActionResultMessageWithType:type AndStaus:RemoteControlStatus_OperateFail ErrorCode:HVAC];
    }
    
    //1.离开App,以本地通知方式通知用户
    //2.用户在当前页，页面话术改变
    //3.不在当前页，状态栏通知
    
    NSString *requestName = [SOSRemoteTool getRemoteRequestStringWithOperationType:type];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SOS_VEHICLE_OPERATE_NOTIFICATION object:requestName userInfo:@{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : @(type), @"message": msg,@"HVAC":@(hvac)}];
    });
}
    
// 缓存上次操作结果,用于远程遥控页面显示
+ (void)cacheLatestResultWithType:(SOSRemoteOperationType)type Staus:(RemoteControlStatus)status AndCode:(NSString *)code Vin:(NSString *)vin		{
    if (type == SOSRemoteOperationType_VehicleLocation || [SOSRemoteTool isSendPOIOperation:type])		return;
    NSString *operationCommendStr = [SOSRemoteTool getRemoteRequestStringWithOperationType:type];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[CustomerInfo sharedInstance].userBasicInfo.idpUserId forKey:REMOTE_COMMAND_IDPID];
    [userDefault setObject:@(type) forKey:Remote_Operation_Type];
    [userDefault setObject:vin forKey:REMOTE_COMMAND_VIN];
    [userDefault setObject:operationCommendStr forKey:REMOTE_COMMAND_TYPE];
    [userDefault setObject:[NSString stringWithFormat:@"%d",status]  forKey:REMOTE_COMMAND_STATUS];
    [userDefault setObject:NONil(code) forKey:REMOTE_COMMAND_CODE];
    [userDefault setObject:[NSDate date] forKey:REMOTE_COMMAND_DATE];
    [userDefault setObject:[LoginManage sharedInstance].accessToken forKey:REMOTE_COMMAND_ACT];
    [userDefault synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showLatestRemoteType" object:nil];
    });
}
    
    /// 根据操作类型播放对应操作完成音频文件
+ (void)playSoundAlertWithType:(SOSRemoteOperationType)type    {
    NSString *soundFileName = [SOSRemoteTool getAlertSoundFileNameWithOperationType:type];
    
    if (type == SOSRemoteOperationType_VehicleLocation) 	[Util playAlertSound];
    else	[SOSAudioBox playAlertSoundWithAudioFileName:soundFileName];
}
    
#pragma mark - 数据加工 & 处理
/// type 转换为 操作成功 对应 音频文件 String
+ (NSString *)getAlertSoundFileNameWithOperationType:(SOSRemoteOperationType)type	{
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_PreAction_AlertSound_FileName AndStaus:RemoteControlStatus_Void ErrorCode:nil];
}
    
/// type 转换为 预操作提示话术 String
+ (NSString *)getPreActionAlertMessageWithOperationType:(SOSRemoteOperationType)type		{
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_PreAction_AlertMessage AndStaus:RemoteControlStatus_Void ErrorCode:nil];
}
    
/// type 转换为 远程操作 Command 对应 String
+ (NSString *)getRemoteRequestStringWithOperationType:(SOSRemoteOperationType)type	{
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_RequestCommend AndStaus:RemoteControlStatus_Void ErrorCode:nil];
}

/// type 转换为 DAAP ID
+ (NSString *)getDaapIDMessageWithType:(SOSRemoteOperationType)type     {
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_DAAP_ID AndStaus:RemoteControlStatus_Void ErrorCode:nil];
}
    
/// type 转换为 操作结果话术 String
+ (NSString *)getActionResultMessageWithType:(SOSRemoteOperationType)type AndStaus:(RemoteControlStatus)status ErrorCode:(NSString *)errorCode	{
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_Operation_Result_Message AndStaus:status ErrorCode:errorCode];
}
    
/// type 转换为 Avaliable Function 对应 Name String
+ (NSString *)getAvaliableFunctionNameWithType:(SOSRemoteOperationType)type	{
    if ([self isSendPOIOperation:type]) {
        type = [self getRightTypeWithType:type ShouldHorn:NO AndShouldFlash:NO];
    }
    return [SOSRemoteTool getMessageWithOperationType:type MessageType:SOSRemoteToolMessageType_Avaliable_Function_Name AndStaus:RemoteControlStatus_Void ErrorCode:nil];
}
    
+ (NSString *)getMessageWithOperationType:(SOSRemoteOperationType)type MessageType:(SOSRemoteToolMessageType)messageType AndStaus:(RemoteControlStatus)status ErrorCode:(NSString *)errorCode	{
    NSString *messageStr = @"";
    NSString *requestStr = nil;
    NSString *soundFileName = nil;
    NSString *avaliableFunctionName = nil;
    NSString *daapID = nil;
    // 8.3 版本 取消错误码显示
    //    errorCode = nil;
    BOOL havc = [errorCode isEqualToString:@"HVAC"];
    NSString *actionResultMessage = NSLocalizedString(BACKEND_ERROR, @"");
    switch (type) {
        // 上锁
        case SOSRemoteOperationType_LockCar:
            messageStr = @"此操作将锁上所有的车门，注意人身及车辆安全";
            requestStr = LOCK_DOOR_REQUEST;
            soundFileName = @"door";
            avaliableFunctionName = @"unLock";
            daapID = Remotecontrol_lock_OpTime;
            if (status != RemoteControlStatus_Void)	{
                NSArray *messageArray = @[@"正在为您执行车门上锁操作...",
                                          @"车门已上锁",
                                          @"车门上锁失败, 请重试。",
                                          @"车门上锁超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 解锁
        case SOSRemoteOperationType_UnLockCar:
            messageStr = @"此操作将解锁所有的车门，注意人身及车辆安全";
            requestStr = UNLOCK_DOOR_REQUEST;
            soundFileName = @"door";
            avaliableFunctionName = @"unLock";
            daapID = Remotecontrol_unlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行车门解锁操作...",
                                          @"车门已解锁",
                                          @"车门解锁失败, 请重试。",
                                          @"车门解锁超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 远程启动
        case SOSRemoteOperationType_RemoteStart:
            messageStr = @"请确保车钥匙远离车辆30米以上，车辆熄火，挂P档，四扇车门关闭并且正常上锁。";
            requestStr = REMOTE_START_REQUEST;
            soundFileName = @"remoteStart";
            avaliableFunctionName = @"remoteStart";
            daapID = Remotecontrol_StartEngine_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行远程启动操作...",
                                          @"车辆已启动",
                                          havc?@"车辆启动失败，空调无法启动，请稍后重试":@"车辆启动失败, 请重试。",
                                          havc?@"车辆启动失败，空调无法启动，请稍后重试":@"车辆启动失败, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 取消启动
        case SOSRemoteOperationType_RemoteStartCancel:
            messageStr = @"此操作仅适用于您上一次启动车辆的方式为安吉星远程启动";
            requestStr = REMOTE_STOP_REQUEST;
            soundFileName = @"remoteCancel";
            avaliableFunctionName = @"remoteStart";
            daapID = Remotecontrol_CancelStartEngine_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行取消启动操作...",
                                          @"启动已取消",
                                          @"取消启动失败, 请重试。",
                                          @"取消启动超时, 请稍后重试。"];
                if (havc) {
                    messageArray = @[@"正在为您执行关闭空调操作...",
                                     @"空调设置成功",
                                     @"空调设置失败, 请重试。",
                                     @"空调设置超时, 请稍后重试。"];
                }
                
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 闪灯
        case SOSRemoteOperationType_Light:
            messageStr = @"请确保车辆档位置于P档，闪灯将持续30秒后自动关闭";
            requestStr = VEHICLE_ALERT_FLASHLIGHTS_REQUEST;
            soundFileName = @"whistle";
            avaliableFunctionName = @"vehicleAlert";
            daapID = Remotecontrol_lighthorn_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行闪灯操作...",
                                          @"闪灯操作成功",
                                          @"闪灯操作失败, 请重试。",
                                          @"闪灯操作超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 鸣笛
        case SOSRemoteOperationType_Horn:
            messageStr = @"请确保车辆档位置于P档，鸣笛将持续30秒后自动关闭";
            requestStr = VEHICLE_ALERT_HORN_REQUEST;
            soundFileName = @"whistle";
            avaliableFunctionName = @"vehicleAlert";
            daapID = Remotecontrol_lighthorn_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行鸣笛操作...",
                                          @"鸣笛操作成功",
                                          @"鸣笛操作失败, 请重试。",
                                          @"鸣笛操作超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 闪灯鸣笛
        case SOSRemoteOperationType_LightAndHorn:
            messageStr = @"请确保车辆档位置于P档，闪灯鸣笛将持续30秒后自动关闭";
            requestStr = VEHICLE_ALERT_REQUEST;
            soundFileName = @"whistle";
            avaliableFunctionName = @"vehicleAlert";
            daapID = Remotecontrol_lighthorn_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行闪灯鸣笛操作...",
                                          @"闪灯鸣笛操作成功",
                                          @"闪灯鸣笛操作失败, 请重试。",
                                          @"闪灯鸣笛操作超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 打开天窗
        case SOSRemoteOperationType_OpenRoofWindow:
            messageStr = @"继续此操作将为您打开天窗，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"openSunroof";
            soundFileName = @"";
            avaliableFunctionName = @"sunroofControl";
            daapID = Remotecontrol_sunroofunlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行打开天窗操作...",
                                          @"天窗已开启",
                                          @"天窗开启失败, 请重试。",
                                          @"天窗开启超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 关闭天窗
        case SOSRemoteOperationType_CloseRoofWindow:
            messageStr = @"继续此操作将为您关闭天窗，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"closeSunroof";
            soundFileName = @"";
            avaliableFunctionName = @"sunroofControl";
            daapID = Remotecontrol_sunrooflock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行关闭天窗操作...",
                                          @"天窗已关闭",
                                          @"天窗关闭失败, 请重试。",
                                          @"天窗关闭超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 打开车窗
        case SOSRemoteOperationType_OpenWindow:
            messageStr = @"继续此操作将为您打开所有车窗，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"openWindows";
            soundFileName = @"";
            avaliableFunctionName = @"windowsControl";
            daapID = Remotecontrol_windowsunlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行打开车窗操作...",
                                          @"车窗已开启",
                                          @"车窗开启失败, 请重试。",
                                          @"车窗开启超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 关闭车窗
        case SOSRemoteOperationType_CloseWindow:
            messageStr = @"继续此操作将为您关闭所有车窗，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"closeWindows";
            soundFileName = @"";
            avaliableFunctionName = @"windowsControl";
            daapID = Remotecontrol_windowslock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行关闭车窗操作...",
                                          @"车窗已关闭",
                                          @"车窗关闭失败, 请重试。",
                                          @"车窗关闭超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 打开后备箱
        case SOSRemoteOperationType_OpenTrunk:
            messageStr = @"继续此操作将为您打开后备箱，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"openTrunk";
            soundFileName = @"";
            avaliableFunctionName = @"trunkOpen";
            daapID = Remotecontrol_trunkunlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行打开后备箱操作...",
                                          @"后备箱已开启",
                                          @"后备箱开启失败, 请重试。",
                                          @"后备箱开启超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // My21
        case SOSRemoteOperationType_UnlockTrunk:
            messageStr = @"继续此操作将为您解锁后备箱，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"unlockTrunk";
            soundFileName = @"";
            avaliableFunctionName = @"trunkLockUnlock";
//            daapID = Remotecontrol_trunkunlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行解锁后备箱操作...",
                                          @"后备箱已解锁",
                                          @"后备箱解锁失败, 请重试。",
                                          @"后备箱解锁超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        case SOSRemoteOperationType_LockTrunk:
            messageStr = @"继续此操作将为您上锁后备箱，请您注意人身及车辆安全，以免造成不必要的损失。";
            requestStr = @"lockTrunk";
            soundFileName = @"";
            avaliableFunctionName = @"trunkLockUnlock";
            //        daapID = Remotecontrol_trunkunlock_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行上锁后备箱操作...",
                                          @"后备箱已上锁",
                                          @"后备箱上锁失败, 请重试。",
                                          @"后备箱上锁超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
        break;
        // 打开空调
        case SOSRemoteOperationType_OpenHVAC:
            messageStr = @"继续此操作将为您启动车辆并打开车内空调，同时将按照您调节的设置进行车内空调调节，在操作前请您确保车钥匙远离车辆30米以上，车辆处于熄火状态，挂P挡，所有车门关闭并且正常上锁，请确认后执行。";
            requestStr = @"setHvacSettings";
            soundFileName = @"";
            avaliableFunctionName = @"remoteHVAC";
            daapID = Remotecontrol_hvacsettings_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行打开空调操作...",
                                          @"空调设置成功",
                                          @"空调设置失败, 请重试。",
                                          @"空调设置超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 关闭空调
        case SOSRemoteOperationType_CloseHVAC:
            messageStr = @"此操作将关闭车内空调，并取消远程启动，此操作仅适用于您上一次启动车辆的方式为安吉星远程启动。";
            requestStr = @"setHvacSettings";
            soundFileName = @"";
            avaliableFunctionName = @"remoteHVAC";
            daapID = Remotecontrol_CancelStartEngine_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"正在为您执行关闭空调操作...",
                                          @"空调设置成功",
                                          @"空调设置失败, 请重试。",
                                          @"空调设置超时, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 车辆定位
        case SOSRemoteOperationType_VehicleLocation:
            messageStr = @"";
            requestStr = @"vehicleLocation";
            soundFileName = @"";
            avaliableFunctionName = @"vehicleLocation";
            daapID = Trip_Veh_GetLocation_Loadtime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"",
                                          @"获取车辆位置成功。",
                                          @"获取车辆位置失败, 请稍后重试。",
                                          @"获取车辆位置失败, 请稍后重试。"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 下发 TBT
        case SOSRemoteOperationType_SendPOI_TBT:
            messageStr = @"";
            requestStr = @"SendToTBTRequest";
            soundFileName = @"";
            avaliableFunctionName = @"tbt";
            daapID = Remotecontrol_TBT_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"路线正在下发，请耐心等待1-3分钟。",
                                          @"路线成功下发至车机",
                                          @"路线下发失败, 请重试",
                                          @"路线下发失败, 请重试"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        // 下发 ODD
        case SOSRemoteOperationType_SendPOI_ODD:
            messageStr = @"";
            requestStr = @"SendToNAVRequest";
            soundFileName = @"";
            avaliableFunctionName = @"odd";
            daapID = Remotecontrol_ODD_OpTime;
            if (status != RemoteControlStatus_Void)    {
                NSArray *messageArray = @[@"目的地正在下发，请耐心等待1-3分钟。",
                                          @"目的地成功下发至车机",
                                          @"目的地下发失败, 请重试",
                                          @"目的地下发失败, 请重试"];
                actionResultMessage = messageArray[status - 1];
            }
            break;
        default:
            break;
    }
    
    switch (messageType) {
        case SOSRemoteToolMessageType_PreAction_AlertMessage:
            return messageStr;
        case SOSRemoteToolMessageType_RequestCommend:
            return requestStr;
        case SOSRemoteToolMessageType_PreAction_AlertSound_FileName:
            return soundFileName;
        case SOSRemoteToolMessageType_Operation_Result_Message:
            return actionResultMessage;
        case SOSRemoteToolMessageType_Avaliable_Function_Name:
            return avaliableFunctionName;
        case SOSRemoteToolMessageType_DAAP_ID:
            return daapID;
        default:
            break;
    }
    return requestStr;
}
    
+ (BOOL)isHornAndFlashMode:(SOSRemoteOperationType)type	{
    BOOL value = type == SOSRemoteOperationType_LightAndHorn || type == SOSRemoteOperationType_Light || type == SOSRemoteOperationType_Horn;
    return value;
}
    
+ (BOOL)isSendPOIOperation:(SOSRemoteOperationType)type    {
    BOOL value = type == SOSRemoteOperationType_SendPOI_TBT || type == SOSRemoteOperationType_SendPOI_ODD || type == SOSRemoteOperationType_SendPOI_Auto;
    return value;
}
    
+ (SOSRemoteOperationType)getRightTypeWithType:(SOSRemoteOperationType)sourceType ShouldHorn:(BOOL)horn AndShouldFlash:(BOOL)flash		{
    if ([SOSRemoteTool isHornAndFlashMode:sourceType]) {
        if (horn && flash)            return SOSRemoteOperationType_LightAndHorn;
        else if (horn && !flash)    return SOSRemoteOperationType_Horn;
        else if (!horn && flash)    return SOSRemoteOperationType_Light;
        // 输入错误
        else                        return sourceType;
    }	else if (sourceType == SOSRemoteOperationType_SendPOI_Auto)		{
        if ([Util vehicleIsIcm])         {
            return SOSRemoteOperationType_SendPOI_ODD;
        }	else    {
            SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
            if (vehicle.sendToNAVSupport && vehicle.sendToTBTSupported) {
                BOOL userPreferODD = [[NSUserDefaults standardUserDefaults] boolForKey:IS_SENDING_ODD_First_REQUEST];
                if (userPreferODD)		return SOSRemoteOperationType_SendPOI_ODD;
                else            		return SOSRemoteOperationType_SendPOI_TBT;
            }    else if (vehicle.sendToNAVSupport)			{
                return SOSRemoteOperationType_SendPOI_ODD;
            }    else if (vehicle.sendToTBTSupported) 		{
                return SOSRemoteOperationType_SendPOI_TBT;
            }    else	{
                [Util toastWithMessage:@"不支持相关操作"];
            }
        }
    }
    return sourceType;
}
    
    
/// 检查包是否有效
+ (BOOL)checkPackageServiceInPage:(UIViewController *)selfVc WithType:(SOSRemoteOperationType)type	{
    //检查是否optin, 车辆定位以及下发 POI 不需要检测 optin
    if(![CustomerInfo sharedInstance].remote_control_optin_status && (type != SOSRemoteOperationType_VehicleLocation) && ![SOSRemoteTool isSendPOIOperation:type])	{
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"remoteControlOptIn", @"") completeBlock:nil];
        return NO;
    }
    if([SOSCheckRoleUtil checkPackageExpired:selfVc])	{
        return NO;
    }
    if (![SOSCheckRoleUtil checkPackageServiceAvailable:[SOSRemoteTool getAvaliableFunctionNameWithType:type]]) {
        return NO;
    }
    return YES;
}
    
+ (AppleWatchOperationResultStatus)watch_checkPackageWithType:(SOSRemoteOperationType)type {
    //检查是否optin, 车辆定位以及下发 POI 不需要检测 optin
    if(![CustomerInfo sharedInstance].remote_control_optin_status && (type != SOSRemoteOperationType_VehicleLocation) && ![SOSRemoteTool isSendPOIOperation:type])    {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"remoteControlOptIn", @"") completeBlock:nil];
        return AppleWatchPackageServiceNotAvailable;
    }
    if([SOSCheckRoleUtil checkPackageExpired:nil])    {
        return AppleWatchPackageServiceExpired;
    }
    if (![SOSCheckRoleUtil checkPackageServiceAvailable:[SOSRemoteTool getAvaliableFunctionNameWithType:type]]) {
        return AppleWatchPackageServiceNotAvailable;
    }
    return AppleWatchPackageServiceAvailable;
}

@end

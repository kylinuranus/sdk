//
//  SOSHomeAndCompanyTool.m
//  Onstar
//
//  Created by Coir on 16/3/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSHomeAndCompanyTool.h"
#import "CarOperationWaitingVC.h"
//#import "CollectionToolsOBJ.h"
#import "ServiceController.h"
#import "SOSCheckRoleUtil.h"
#import "NavigateSearchVC.h"
#import "SOSRemoteTool.h"
#import "SOSTripPOIVC.h"


@interface SOSHomeAndCompanyTool () {
//    SetHomeAddress_PageType page_Type;
//    __weak UIViewController *fromVC;
}

@property (nonatomic, assign) BOOL needShowWaiting;
@property (nonatomic, assign) BOOL needShowToast;

@end


@implementation SOSHomeAndCompanyTool


+ (SOSHomeAndCompanyTool *)sharedInstance    {
    static SOSHomeAndCompanyTool *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        [sharedOBJ addObserver];
    });
    return sharedOBJ;
}

- (void)addObserver  	{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
        //    @{@"state":@(RemoteControlStatus), @"OperationType" : @(SOSRemoteOperationType) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if ([SOSRemoteTool isSendPOIOperation:operationType]) {
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            switch (state) {
                case RemoteControlStatus_InitSuccess:
                    if  (self.needShowToast)	[Util toastWithMessage:userInfo[@"message"]];
                    break;
                case RemoteControlStatus_OperateSuccess:
                    
                    break;
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    
                    break;
                default:
                    break;
            }
        }
    }];
}

+ (SelectPointOperation)simpleTypeWithType:(SelectPointOperation)type	{
    switch (type) {
        case OperationType_Set_Home:
        case OperationType_Set_Home_Send_POI:
            return OperationType_Set_Home;
        case OperationType_Set_Company:
        case OperationType_Set_Company_Send_POI:
            return OperationType_Set_Company;
        default:
            return OperationType_Void;
    }
}

/// 设定家/公司地址完成后,保存信息并返回
+ (void)setHomeOrCompanyThenBackFromVC:(UIViewController *)fromVC WithPOI:(SOSPOI *)poi OperationType:(SelectPointOperation)operationType 	{
    [Util showHUD];
    [SOSHomeAndCompanyTool setHomeOrCompanyWithPOI:poi OperationType:operationType successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        dispatch_async_on_main_queue(^{
            switch (operationType) {
                case OperationType_Set_Home:
                case OperationType_Set_Company:
                    [fromVC dismissViewControllerAnimated:YES completion:nil];
                    break;
                case OperationType_Set_Home_Send_POI:
                case OperationType_Set_Company_Send_POI:
                    [SOSHomeAndCompanyTool alertSendPOIWithOperationType:operationType];
                    break;
                default:
                    break;
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
    }];
}

/// 保存家/公司地址(网络操作)
+ (void)setHomeOrCompanyWithPOI:(SOSPOI *)poi  OperationType:(SelectPointOperation)operationType successBlock:(SOSSuccessBlock)successBlock failureBlock:(SOSFailureBlock)failureBlock   {
//    NSString *url = [BASE_URL stringByAppendingFormat:HOME_POI_SET,[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSString *url = [BASE_URL stringByAppendingString:HOME_POI_SET];
    SelectPointOperation tempType = [self simpleTypeWithType:operationType];
    if (tempType == OperationType_Void)		return;
    SOSPOI *userPoi = [CustomerInfo sharedInstance].currentPositionPoi;
    
    NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
    poiDic[@"idpID"]            = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    poiDic[@"fuid"]             = poi.pguid;
    poiDic[@"poiName"]          = poi.name;
    poiDic[@"cityCode"]         = poi.city;
    poiDic[@"provience"]        = poi.province;
    poiDic[@"poiAddress"]       = poi.address;
    poiDic[@"poiNickname"]      = poi.nickName.length ? poi.nickName : poi.name;
    poiDic[@"poiCatetory"]      = poi.type;
    poiDic[@"customCatetory"]   = tempType == OperationType_Set_Home ? @"1" : @"2";    // "1"-家,"2"-公司
    poiDic[@"poiPhoneNumber"]   = poi.tel.length ? poi.tel : @"";
    poiDic[@"favoriteDestinationID"] = @(0);
    poiDic[@"poiCoordinate"]    = @{@"longitude": @(poi.longitude.floatValue),
                                    @"latitude": @(poi.latitude.floatValue)};
    poiDic[@"mobileCoordinate"] = @{@"longitude": @(userPoi.longitude.floatValue),
                                    @"latitude": @(userPoi.latitude.floatValue)};
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:[poiDic toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSDictionary *resDic = [responseStr mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                if ([code isEqualToString:@"E0000"]) {
                    NSDictionary *dataDic = resDic[@"data"];
                    if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
                        poi.destinationID = dataDic[@"favoriteDestinationID"];
                    }
                    // 保存结果
                    if (tempType == OperationType_Set_Home)		[CustomerInfo sharedInstance].homePoi = poi;
                    else                                       	[CustomerInfo sharedInstance].companyPoi = poi;
                    [[NSNotificationCenter defaultCenter] postNotificationName:KHomeAndCompanyChangedNotification object:nil];
                    if (successBlock)   successBlock(operation, responseStr);
                    [Util showSuccessHUDWithStatus:@"位置设定成功"];
                    return;
                }
            }
        }
        if (failureBlock)   failureBlock(operation.statusCode, responseStr, nil);
        [Util showErrorHUDWithStatus:@"信息保存失败!"];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failureBlock)   failureBlock(statusCode, responseStr, error);
        [Util showErrorHUDWithStatus:@"信息保存失败!"];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];
}

/// 提示用户 设置成功,是否现在发送到车
+ (void)alertSendPOIWithOperationType:(SelectPointOperation)operationType	{
    [Util showAlertWithTitle:nil message:@"设置成功,是否现在发送到车?" completeBlock:^(NSInteger buttonIndex) {
        dispatch_async_on_main_queue(^{
            UIViewController *topVC = [SOS_APP_DELEGATE fetchMainNavigationController].viewControllers.firstObject;
                if (buttonIndex) {
                    __block BOOL isSendHome = ([self simpleTypeWithType:operationType] == OperationType_Set_Home);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIViewController *topVC = [SOS_APP_DELEGATE fetchMainNavigationController].viewControllers.firstObject;
                        if (isSendHome)     [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:topVC WithType:pageTypeEasyBackHome];
                        else                [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:topVC WithType:pageTypeEasyBackCompany];
                    });
            }
            [topVC dismissViewControllerAnimated:YES completion:nil];
        });
    } cancleButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
}

- (void)EasyGoHomeFromVC:(UIViewController *)vc WithType:(SetHomeAddress_PageType)pageType  {
    [self EasyGoHomeFromVC:vc WithType:pageType needShowWaitingVC:YES needShowToast:NO];
}

- (void)EasyGoHomeFromVC:(UIViewController *)vc WithType:(SetHomeAddress_PageType)pageType needShowWaitingVC:(BOOL)needShowVC needShowToast:(BOOL)needToast   {
    [self checkAuthAndExitsWithType:pageType FromVC:vc Success:^(SOSPOI *resultPOI) {
        if (resultPOI) {        //直接发送
            self.needShowWaiting = needShowVC;
            self.needShowToast = needToast;
            if (needShowVC) {
                [[SOSRemoteTool sharedInstance] checkAuthWithOperationType:SOSRemoteOperationType_SendPOI_Auto Parameters:nil Success:^(SOSRemoteOperationType type, NSString *parameter) {
                    [[SOS_APP_DELEGATE fetchMainNavigationController].topViewController presentViewController:[CarOperationWaitingVC initWithPoi:resultPOI Type:OrderTypeAuto FromVC:nil] animated:YES completion:nil];
                } Failure:nil];
            }    else    {
                [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_Auto AndPOI:resultPOI];
            }
        }   else    {
            [SOSDaapManager sendActionInfo:pageType == pageTypeHome ? Trip_GoWhere_NotSet_Home_Set : Trip_GoWhere_NotSet_Office_Set];
            [Util showAlertWithTitle:@"地点未设置，现在去设置吗？" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1)     {
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_SET];
                    [self jumpToSetHomeAddressPageWithType:pageType];
                }    else    {
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_NO];
                    [SOSDaapManager sendActionInfo:pageType == pageTypeHome ? Trip_GoWhere_NotSet_Home_Cancel : Trip_GoWhere_NotSet_Office_Cancel];
                }
            } cancleButtonTitle:@"不了" otherButtonTitles:@"去设置", nil];
        }
    } Failure:^{ }];
}

- (void)checkAuthAndExitsWithType:(SetHomeAddress_PageType)pageType FromVC:(UIViewController *)vc Success:(void (^)(SOSPOI *resultPOI))success Failure:(void (^)(void))failBlock	{
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
        if (![SOSCheckRoleUtil checkVisitorInPage:vc] || [SOSCheckRoleUtil checkPackageExpired:vc])     {
            if (failBlock)    failBlock();
            return;
        }
        SOSPOI *finalPOI = [self getSavedHomeAndCompanyPOIWithType:pageType];
        if (success) 	success(finalPOI);
    }	else	{
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:vc withLoginDependence:[[LoginManage sharedInstance] isLoadingMainInterfaceReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            if (finished) {
                if (![SOSCheckRoleUtil checkVisitorInPage:vc] || [SOSCheckRoleUtil checkPackageExpired:vc])     {
                    if (failBlock)    failBlock();
                    return;
                }
                SOSPOI *finalPOI = [self getSavedHomeAndCompanyPOIWithType:pageType];
                if (success)     success(finalPOI);
            }
        }];
    }
}

- (SOSPOI *)getSavedHomeAndCompanyPOIWithType:(SetHomeAddress_PageType)pageType		{
    SOSPOI *homePoi = [CustomerInfo sharedInstance].homePoi;
    SOSPOI *companyPoi = [CustomerInfo sharedInstance].companyPoi;
    SOSPOI *finalPOI = (pageType == pageTypeEasyBackHome) ? homePoi : companyPoi;
    return finalPOI;
}

- (void)jumpToSetHomeAddressPageWithType:(SetHomeAddress_PageType)pageType     {
    //未设定过家和公司地址
    NavigateSearchVC *searchVC = [NavigateSearchVC new];
    if (pageType == pageTypeCompany) {
        searchVC.operationType = OperationType_Set_Company;
    }	else if (pageType == pageTypeHome)	{
        searchVC.operationType = OperationType_Set_Home;
    }	else	{
        searchVC.operationType = pageType == pageTypeEasyBackHome ? OperationType_Set_Home_Send_POI : OperationType_Set_Company_Send_POI;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SOS_APP_DELEGATE fetchMainNavigationController].topViewController presentViewController:nav animated:YES completion:nil];;
    });
}

@end

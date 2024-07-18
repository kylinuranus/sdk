//
//  SOSNavigateTool.m
//  Onstar
//
//  Created by Coir on 27/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOilMapVC.h"
#import "SOSTripPOIVC.h"
#import "SOSTripModule.h"
#import "SOSRemoteTool.h"
#import "SOSGeoDataTool.h"
#import "SOSOilDataTool.h"
#import "SOSUserLocation.h"
#import "SOSNavigateTool.h"
#import "SOSAMapSearchTool.h"

#import "SOSFlexibleAlertController.h"
#import "SOSGeoModifyMobileVC.h"

@implementation SOSNavigateTool

/// 显示路况,并跳转地图页面
+ (void)showTraffic:(BOOL)show  {
    dispatch_async_on_main_queue(^{
        SOSTripHomeVC *vc = [SOSTripModule getMainTripVC];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [vc showTraffic:@(YES)];
        });
        [SOS_APP_DELEGATE fetchRootViewController].selectedIndex = 1;
    });
}

/// 跳转附近加油站, CenterPOI 预处理
+ (void)showAroundOilStationWithCenterPOI:(SOSPOI *)poi FromVC:(UIViewController *)fromVC	{
    SOSPOI *centerPOI = poi;
    
    if (centerPOI == nil)	{
        centerPOI = [CustomerInfo sharedInstance].currentPositionPoi;
        if (centerPOI == nil) {
            // 无缓存定位点, 请求用户定位,只需要经纬度
            [Util showHUD];
            [[SOSUserLocation sharedInstance] getLocationWithoutReGeoSuccess:^(CLLocationCoordinate2D coordinate) {
                SOSPOI *poi = [SOSPOI new];
                poi.sosPoiType = POI_TYPE_CURRENT_LOCATION;
                poi.latitude = @(coordinate.latitude).stringValue;
                poi.longitude = @(coordinate.longitude).stringValue;
                poi.operationDateStrValue = [[NSDate date] stringWithISOFormat];
                [self requestStationListAndJumpWithPOI:poi FromVC:fromVC];
            } Failure:^(NSError *error) {
                [Util dismissHUD];
                [Util toastWithMessage:@"获取当前定位失败,请稍后重试"];
            }];
        }	else	{
            // 使用缓存中当前定位点
            [Util showHUD];
            [self requestStationListAndJumpWithPOI:centerPOI FromVC:fromVC];
        }
    }	else	{
        // 使用传入 POI
        [Util showHUD];
        [self requestStationListAndJumpWithPOI:centerPOI FromVC:fromVC];
    }
}

/// 请求加油站列表
+ (void)requestStationListAndJumpWithPOI:(SOSPOI *)centerPOI FromVC:(UIViewController *)fromVC	{
    __block BOOL shouldEnterNextPage = NO;
    SOSOilMapVC *oilListMapVC = [[SOSOilMapVC alloc] initWithPOI:centerPOI];
    if ([fromVC isKindOfClass:NSClassFromString(@"SOSLifeTabViewController")] || [fromVC isKindOfClass:NSClassFromString(@"SOSLifeWebViewController")])		{
        oilListMapVC.isFromLifePage = YES;
        [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance];
    }	else	{
        [SOSDaapManager sendActionInfo:Trip_WisdomOil];
    }
    oilListMapVC.isFromAroundSearch = [fromVC isKindOfClass:NSClassFromString(@"SOSAroundSearchVC")];
    // 已登录
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        // 优惠加油入口
        if (oilListMapVC.isFromLifePage) {
            shouldEnterNextPage = YES;
            // 无手机号
            if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.length == 0) {
                [Util showAlertWithTitle:@"绑定手机号" message:@"设置服务手机号，享受优惠加油提供的优惠价格" completeBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex) {
                        SOSGeoModifyMobileVC *vc = [SOSGeoModifyMobileVC new];
                        vc.isReplenishMobile = YES;
                        vc.completeHandler = ^{	};
                        [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
                    }
                } cancleButtonTitle:@"放弃优惠" otherButtonTitles:@"确定", nil];
                return;
            // 有手机号
            }	else	{
                [SOSOilDataTool requestOilInfoListSuccess:^(NSArray<SOSOilInfoObj *> * _Nonnull oilInfoList) {
                    NSString *defaultOilName = nil;
                    for (SOSOilInfoObj *oilInfo in oilInfoList) {
                        if (oilInfo.defaultShow) {
                            defaultOilName = oilInfo.oilName;
                            break;
                        }
                    }
                    oilListMapVC.oilInfoList = oilInfoList;
                    [SOSOilDataTool requestOilStationListWithCenterPOI:centerPOI GasType:nil OilName:defaultOilName AndSortColumn:nil Success:^(NSArray<SOSOilStation *> * _Nonnull stationList) {
                        oilListMapVC.stationList = stationList;
                        if (shouldEnterNextPage)        {
                            [Util dismissHUD];
                            dispatch_async_on_main_queue(^{
                                oilListMapVC.mapType = MapTypeOil;
                                [fromVC.navigationController pushViewController:oilListMapVC animated:YES];
                            });
                        }    else                        shouldEnterNextPage = YES;
                    } Failure:^{
                        if (shouldEnterNextPage)    [Util dismissHUD];
                        else                        shouldEnterNextPage = YES;
                    }];
                } Failure:^{
                    [Util toastWithMessage:@"获取油号信息失败"];
                    if (shouldEnterNextPage)    [Util dismissHUD];
                    else                        shouldEnterNextPage = YES;
                }];
            }
            return;
        // 附近加油站入口
        }	else	{
            shouldEnterNextPage = YES;
        }
    // 未登录
    }	else	{
        shouldEnterNextPage = YES;
    }
    [[SOSAMapSearchTool sharedInstance] aroungSearchWithKeyWords:@"加油站" CenterPOI:centerPOI PageNum:0 Success:^(NSArray<SOSPOI *> * _Nonnull poiArray) {
        oilListMapVC.poiArray = poiArray;
        if (shouldEnterNextPage)        {
            [Util dismissHUD];
            dispatch_async_on_main_queue(^{
                oilListMapVC.mapType = MapTypeOil;
                [fromVC.navigationController pushViewController:oilListMapVC animated:YES];
            });
        }    else                        shouldEnterNextPage = YES;
    } Failure:^{
        if (shouldEnterNextPage)    [Util dismissHUD];
        else                        shouldEnterNextPage = YES;
    }];
}

/// 跳转电子围栏页面
+ (void)showGeoPageFromVC:(UIViewController *)fromVC     {
    UIViewController *tempVC = fromVC;
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        tempVC = ((UINavigationController *)fromVC).topViewController;
    }
    [SOS_APP_DELEGATE hideMainLeftMenu];
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:fromVC andTobePushViewCtr:nil completion:^(BOOL finished) {
        if (finished) {
            // 访客
            if ([SOSCheckRoleUtil isVisitor]) {
                [Util showAlertWithTitle:nil message:NSLocalizedString(@"SB00001_MSG002", nil) completeBlock:nil];
                return;
            }
            if ([SOSCheckRoleUtil isDriverOrProxy]) {
                // 司机或者代理
                [Util showAlertWithTitle:@"车主未授权，请联系车主" message:nil confirmBtn:@"知道了" completeBlock:nil];
                return;
            }
            BOOL yearIs2010 = [[[CustomerInfo sharedInstance] currentVehicle].year isEqualToString:K_CADILLAC_YEAR];
            BOOL modelEN = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc isEqualToString:K_CADILLAC_MODEL_EN];
            BOOL modelCN = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc isEqualToString:K_CADILLAC_MODEL_CN];
            
            // Gen 8
            if (yearIs2010 || modelEN || modelCN) {
                [Util showAlertWithTitle:nil message:@"该车型不支持电子围栏功能" completeBlock:nil];
                return;
            }
            if ([SOSCheckRoleUtil checkPackageExpired:tempVC])	return;
            
            if (![SOSCheckRoleUtil checkPackageServiceAvailable:PP_GeoFence]) 	return;
            
            [Util showHUD];
            [SOSGeoDataTool getGeoFencingSuccessHandler:^(NSArray *fences) {
                [Util dismissHUD];
                if ([fences count]> 0) {
                    NNGeoFence *geo = fences.firstObject;
                    geo.isLBSMode = NO;
                    SOSGeoMapVC *geoVC = [[SOSGeoMapVC alloc] initWithGeoFence:geo];
                    [tempVC.navigationController pushViewController:geoVC animated:YES];
                }   else    {
                    SOSTripNoGeoView *noGeoView = [SOSTripNoGeoView viewFromXib];
                    [noGeoView showInView:fromVC.view];
                }
            } failureHandler:^(NSString *responseStr, NSError *error) {
                [Util dismissHUD];
                NSString *errStr = @"获取围栏信息失败";
                NSDictionary *errorDic = [Util dictionaryWithJsonString:responseStr];
                if ([errorDic isKindOfClass:[NSDictionary class]] && errorDic.allKeys.count) {
                    NSString *code = errorDic[@"code"];
                    if (code.length) {
                        errStr = errorDic[@"description"];
                    }
                }
                [Util toastWithMessage:errStr];
            }];
        }
    }];
}

//+ (void)showSmartHomeFromVC:(__kindof UIViewController *)fromVC {
//    #ifndef SOSSDK_SDK
//    [Util showHUD];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    NSString *url = [NSString stringWithFormat:(@"%@" smartHomeMachineList), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//    
//    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        
//        NSDictionary *dict = [Util dictionaryWithJsonString:responseStr];
//        [Util dismissHUD];
//        @try {
//            NNGetSmartHomedeviceList *smartHomeList = [NNGetSmartHomedeviceList mj_objectWithKeyValues:dict];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                 {
//                    if (smartHomeList.devices.count > 0) {
//                        TriggerViewController *triggerVc = [[TriggerViewController alloc] initWithNibName:@"TriggerViewController" bundle:nil];
//                        triggerVc.flag = YES;
//                        [fromVC.navigationController pushViewController:triggerVc animated:YES];
//                    }else {
//                        AddDeviceViewController *VC = [[AddDeviceViewController alloc] initWithNibName:@"AddDeviceViewController" bundle:nil];
//                        [fromVC.navigationController pushViewController:VC animated:YES];
//
//                    }
//                }
//            });
//        } @catch (NSException *exception) {
//            NSLog(@"XMLEXCEPTION %@",exception);
//        }
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        dispatch_async_on_main_queue(^{
//            [Util dismissHUD];
//            [Util toastWithMessage:@"获取家电列表失败，请重试！"];
//        });
//    }];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation start];
//#endif
//}

+ (void)sendToCarAutoWithPOI:(SOSPOI *)poi	{
    [self sendToCarAutoWithPOI:poi TBTDaapFuncID:nil AndODDDaapFuncID:nil CancelDaapFuncID:nil];
}

+ (void)sendToCarAutoWithPOI:(SOSPOI *)poi TBTDaapFuncID:(NSString *)tbtID AndODDDaapFuncID:(NSString *)oddID CancelDaapFuncID:(NSString *)cancelID		{
    if (![[LoginManage sharedInstance] isLoadingMainInterfaceReady])    {
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:SOS_APP_DELEGATE.fetchMainNavigationController.topViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingMainInterfaceReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {    }];
        return;
    }
    if ([Util vehicleIsIcm]) {
        if (oddID) [SOSDaapManager sendActionInfo:oddID];
        [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_ODD AndPOI:poi];
        return;
    }
    //排除访客
    if ( ![SOSCheckRoleUtil checkVisitorInPage:nil])            return;
    SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
    if (vehicle.sendToNAVSupport && vehicle.sendToTBTSupported) {
        SOSFlexibleAlertController *actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
        SOSAlertAction *oddAction = [SOSAlertAction actionWithTitle:@"车载导航" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
            if (oddID) [SOSDaapManager sendActionInfo:oddID];
            [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_ODD AndPOI:poi];
        }];
        SOSAlertAction *tbtAction = [SOSAlertAction actionWithTitle:@"音控领航" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
            if (tbtID) 	[SOSDaapManager sendActionInfo:tbtID];
            [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_TBT AndPOI:poi];
        }];
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
            if (cancelID)	[SOSDaapManager sendActionInfo:cancelID];
        }];
        [actionSheet addActions:@[oddAction, tbtAction, cancelAction]];
        [actionSheet show];
    }    else if (vehicle.sendToNAVSupport)        {
        [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_ODD AndPOI:poi];
    }    else    {
        if (vehicle.sendToTBTSupported) {
            [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_TBT AndPOI:poi];
        }	else	{
            [Util toastWithMessage:@"不支持相关操作"];
        }
    }
}

@end

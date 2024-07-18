//
//  SOStarJourneyUtil.m
//  Onstar
//
//  Created by lmd on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCardUtil.h"
#import "SOSLBSHeader.h"
#import "NavigateSearchVC.h"
#import "SOSOnstarPackageVC.h"
#import "SOSGreetingManager.h"
#import "SOSCustomAlertView.h"
#import "SOSVehicleInfoViewController.h"
#import "SOSVehicleConditionViewController.h"
#import "OwnerViewController.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "SOSDonateDataTool.h"
#import "SOSBuyPackageVC.h"
#import "CustomerInfo.h"
#import "SOSCarAssessmentView.h"
#import "RegisterUtil.h"
#import "SOSGreetingCache.h"
#import "SOSAgreement.h"
#import "PackageUtil.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "SOSBleNetwork.h"
#import "SOSBleOwnerSharePageViewController.h"
#import "SOSBleUserCarListViewController.h"
#import "SOSBleUserCarOperationViewController.h"
#import "SOSBleUserReceiveShareViewController.h"
#import <BlePatacSDK/DBManager.h>
#import "SOSBleUtil.h"
#endif
#import "AppDelegate_iPhone.h"


#import "SOSReservationDealersViewController.h"
#import "SOSAgreementAlertView.h"

#import "SOSSettingViewController.h"

#import "MeManualViewController.h"
#import "MeAboutUsViewController.h"
#import "SOSMyDonateVC.h"
#import "SOSTripPOIVC.h"
#import "ServiceController.h"
//#import "ViewControllerWifiOwner.h"
#import "SOSWifiInfoViewController.h"

#import "SOSOperationHistoryViewController.h"
#import "ChargeModeViewController.h"
#ifndef SOSSDK_SDK
#import "SOSSmartHomeEntranceViewController.h"
#import "SOSMirrorManager.h"
#import "SOSMirrorListController.h"
#import "SOSDefaultMirrorController.h"
#import "SOSOnstarLinkDataTool.h"
#import "SOSOnstarLinkSDKTool.h"
#import "SOSCloudVideoListVC.h"

#endif
#import "SOSDealerTool.h"

#import "SOSNavigateTool.h"
#import "SOSVehicleReportViewController.h"
#import "SOSTermsViewController.h"

#import "SOSHomeTabBarCotroller.h"

#import "SOSTripHomeVC.h"
#import "SOSNotifyController.h"
#import "SOSTripChargeVC.h"
#import "SOSEditQAPinViewController.h"
#import "SOSNStytleEditInfoViewController.h"
#import "SOSMileAgeInsuranceStatementVC.h"
#import "SOSThirdPartyWebVC.h"
//#ifdef SOSSDK_SDK
//#import <flutter_boost/FlutterBoostPlugin.h>
//#import <flutter_boost/FlutterBoost.h>
//#else
//#import "FlutterBoostPlugin.h"
//#import "FlutterBoost.h"
//#endif

@implementation SOSCardUtil

static SOSCardUtil *cardUtil = nil;
+ (instancetype)shareInstance     {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (cardUtil == nil) {
            cardUtil = [[self alloc] init];
        }
    });
    return cardUtil;
}


//获取爱车评估信息 ///msp/api/v3/user/evaluate/carconditionreport
//+ (void)getCarReport:(NNCarconditionReportReq *)req Success:(void (^)(NNCarReportResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_CarReport];
//    url = [self getUrlStringWithUrl:url dic:req.mj_JSONObject];
//    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//        NNCarReportResp *response = [NNCarReportResp mj_objectWithKeyValues:dic];
//        dispatch_async_on_main_queue(^{
//            if (completion && operation.statusCode == 200) {
//                completion(response);
//            }
//        });
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        dispatch_async_on_main_queue(^{
//            if (failCompletion) {
//                failCompletion(responseStr,error);
//            }
//        });
//    }];
//    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [operation setHttpMethod:@"GET"];
//    [operation start];
//}

+ (void)getCarCashBookReport:(NSString  *)vin Success:(void (^)(NNVehicleCashResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@", BASE_URL, VEHICLE_CASHBOOK_API,vin];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNVehicleCashResp *response = [NNVehicleCashResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
//            if (completion && operation.afOperation.response.statusCode == 200) {
                completion(response);
//            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

//获取综合油耗排名
+ (void)getOilRank:(NNRankReq *)req Success:(void (^)(NNOilRankResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    /*
    //找缓存 比对时间
    NSDictionary *cache = [[SOSGreetingCache shareInstance] getCardDataByCardName:soskFuelConsumeCardData idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
    //1.命中 回调返回
    if (cache) {
        NNOilRankResp *response = [NNOilRankResp mj_objectWithKeyValues:cache];
        if (completion) {
            completion(response);
        }
        return;
    }
     */
    //2.未命中 清空并继续请求
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_OilRank];
    url = [self getUrlStringWithUrl:url dic:req.mj_JSONObject];
    
    url = [url stringByAppendingFormat:@"&subscriberId=%@&vin=%@",NONil([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId),NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin)];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNOilRankResp *response = [NNOilRankResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                [[SOSGreetingCache shareInstance] cacheCardData:responseStr withCardName:soskFuelConsumeCardData idpid:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
                completion(response);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
    [SOSDaapManager sendActionInfo:Startrip_refreshfuelconsumption];

}

//获取综合能耗排名
+ (void)getEnergyRank:(NNRankReq *)req Success:(void (^)(NNEngrgyRankResp *urlRequest))completion Failed: (void(^)(NSString *responseStr, NSError *error))failCompletion
{
    /*
    //找缓存 比对时间
    NSDictionary *cache = [[SOSGreetingCache shareInstance] getCardDataByCardName:soskEnergeConsumeCardData idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
    //1.命中 回调返回
    if (cache) {
        NNEngrgyRankResp *response = [NNEngrgyRankResp mj_objectWithKeyValues:cache];
        if (completion) {
            completion(response);
        }
        return;
    }
     */
    //2.未命中 清空并继续请求
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_EnergyRank];
    url = [self getUrlStringWithUrl:url dic:req.mj_JSONObject];
    url = [url stringByAppendingFormat:@"&subscriberId=%@&vin=%@",[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNEngrgyRankResp *response = [NNEngrgyRankResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                [[SOSGreetingCache shareInstance] cacheCardData:responseStr withCardName:soskEnergeConsumeCardData idpid:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
                completion(response);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
    [SOSDaapManager sendActionInfo:Startrip_refreshEnergyconsumption];

}

//获取驾驶行为评分
+ (void)getDrivingScore:(NNCarconditionReportReq *)req Success:(void (^)(NNDrivingScoreResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    /*
    //找缓存 比对时间
    NSDictionary *cache = [[SOSGreetingCache shareInstance] getCardDataByCardName:soskDrivingScoreCardData idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
    //1.命中 回调返回
    if (cache) {
        NNDrivingScoreResp *response = [NNDrivingScoreResp mj_objectWithKeyValues:cache];
        if (completion) {
            completion(response);
        }
        return;
    }
     */
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_DrivingScore];
    url = [self getUrlStringWithUrl:url dic:req.mj_JSONObject];
    url = [url stringByAppendingFormat:@"&vin=%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNDrivingScoreResp *response = [NNDrivingScoreResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                [[SOSGreetingCache shareInstance] cacheCardData:responseStr withCardName:soskDrivingScoreCardData idpid:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
                completion(response);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
    [SOSDaapManager sendActionInfo:Startrip_refreshsmartdriver];
}

// 获取近期行程
+ (void)getTrailDataSuccess:(void (^)(SOSTrailResp *response))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion		{
//    NSDictionary *cache = [[SOSGreetingCache shareInstance] getCardDataByCardName:soskTrailCardData idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
//    //1.命中 回调返回
//    if (cache) {
//        SOSTrailResp *response = [SOSTrailResp mj_objectWithKeyValues:cache];
//        if (completion) {
//            completion(response);
//        }
//        return;
//    }
    NSString *url = [NSString stringWithFormat:@"%@%@?role=%@", BASE_URL, URL_RecentTrailData, [SOSCheckRoleUtil getCurrentRole]];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSTrailResp *response = [SOSTrailResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
//                [[SOSGreetingCache shareInstance] cacheCardData:responseStr withCardName:soskTrailCardData idpid:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
                completion(response);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

//星享之旅
- (void)singleGetStatTravelSuccess:(void (^)(NNStarTravelResp *urlRequest))completion
                            Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion {
    if (self.starResp) {
        if (completion) {
            completion(self.starResp);
        }
        if (![self.starResp isKindOfClass:[NSNumber class]]) {
            //请求成功过不用请求了
            return;
        }
    }
    self.starResp = @YES;
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_StarTravel];
    NSDictionary *d = @{@"idpUserID":NONil([CustomerInfo sharedInstance].userBasicInfo.idpUserId),
                       @"subscriberID":NONil([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId),
                        @"vin":NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin)};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            NNStarTravelResp *response = [NNStarTravelResp mj_objectWithKeyValues:dic];
            if (operation.statusCode == 200) {
                self.starResp = response;
                if (completion) {
                    completion(response);
                }
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            self.starResp = @NO;
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
    
}

+ (void)getStatTravelSuccess:(void (^)(NNStarTravelResp *urlRequest))completion
                      Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    [[SOSCardUtil shareInstance] singleGetStatTravelSuccess:completion Failed:failCompletion];
}


+ (void)getUBIInfoSuccess:(void (^)(NSDictionary *result))completion
                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    //找缓存 比对时间
    NSDictionary *cache = [[SOSGreetingCache shareInstance] getCardDataByCardName:soskUBICardData idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
    //1.命中 回调返回
    if (cache) {
        if (completion) {
            completion(cache);
        }
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_ShowUBI];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                [[SOSGreetingCache shareInstance] cacheCardData:responseStr withCardName:soskUBICardData idpid:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
                completion(dic);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}




+ (NSString *)getUrlStringWithUrl:(NSString *)url dic:(NSDictionary *)dic {
    if (dic == nil) {
        return url;
    }
    NSString *prams = [self getPramsStringWithJsonDic:dic];
    NSString *newUrl = [NSString stringWithFormat:@"%@?%@", url, prams];
    return newUrl;
}

+ (NSString *)getPramsStringWithJsonDic:(NSDictionary *)dic {
    NSMutableArray *pairs = [NSMutableArray new];
    for (NSString *key in dic.allKeys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",key, dic[key]]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    return query;
}

#pragma mark router
+ (void)routerToRemoteControl {
    [self routerToRemoteControl:nil];
//    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
//    [SOSCardUtil routerToRemoteControl:nil];
}

+ (void)routerToRemoteControl:(id)fromvc {
    
    if ([SOS_APP_DELEGATE fetchRootViewController].selectedViewController.presentedViewController) {
        [[SOS_APP_DELEGATE fetchRootViewController].selectedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO] ;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[SOS_APP_DELEGATE fetchRootViewController] cyl_popSelectTabBarChildViewControllerAtIndex:2];
        [SOS_APP_DELEGATE fetchRootViewController].selectedIndex = 2;
//    });
    
}
+ (void)routerToVehicleLocationInMap	{
    int index = 1;
    #ifdef SOSSDK_SDK
    index = 2;
    #endif
    dispatch_async_on_main_queue(^{
        [(UITabBarController *)[SOS_APP_DELEGATE fetchRootViewController] setSelectedIndex:index];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CustomNavigationController * tripNav = (CustomNavigationController *)[(UITabBarController *)[SOS_APP_DELEGATE fetchRootViewController] selectedViewController];
        SOSTripHomeVC *vc = [tripNav.viewControllers objectAtIndex:0];
        [vc showVehicleLocation:nil];
    });
}

/**
 跳转升级车主
 */
+ (void)routerToUpgradeSubscriber {
    
    OwnerViewController * scanVIN = [[OwnerViewController alloc] initWithNibName:@"OwnerViewController" bundle:nil];
    [SOSRegisterInformation sharedRegisterInfoSingleton].registerWay = SOSRegisterWayAddVehicle;
    [((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]) pushViewController:scanVIN animated:YES];
    
}
+ (void)routerToVehicleCondition {

//        [self checkAuth:YES checkLogin:YES complete:^{
//            //todosdk type:1 带navgationBar
//            [FlutterBoostPlugin open:@"vehicle://vehicle_condition_page" urlParams:@{@"type":[NSNumber numberWithInt:1]} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
//
//                } completion:^(BOOL f) {
//                    NSLog(@"加菜完成");
//                }];
//            }];
    SOSVehicleConditionViewController *vc = [[SOSVehicleConditionViewController alloc] initWithNibName:@"SOSVehicleConditionViewController" bundle:nil];
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];

}
+ (void)routerToVehicleDetectionReport{
//    if (SOS_APP_DELEGATE.isgsp) {
        SOSVehicleReportViewController *report = [[SOSVehicleReportViewController alloc] init];
        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
        [self routerToVc:report checkAuth:YES checkLogin:YES];

//    }else{
//        SOSOldVehicleReportViewController *report = [[SOSOldVehicleReportViewController alloc] init];
//        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
//        [self routerToVc:report checkAuth:YES checkLogin:YES];
//
//    }
}
+ (void)routerToRecentJourney	{
    if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])     return;
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:SOS_APP_DELEGATE.fetchMainNavigationController.topViewController withLoginDependence:[LoginManage sharedInstance].isLoadingUserBasicInfoReady showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            [Util showHUD];
            [SOSCardUtil getTrailDataSuccess:^(SOSTrailResp *response) {
                [Util dismissHUD];
                NSString *url = response.linkUrl;
                SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
                webVC.fd_prefersNavigationBarHidden = YES;
                [self routerToVc:webVC checkAuth:YES checkLogin:YES];
            } Failed:^(NSString *responseStr, NSError *error) {
                [Util dismissHUD];
                [Util toastWithMessage:@"数据异常,请稍后重试"];
            }];
        }
    }];
}
+ (void)routerToWifiSetting {
    [Util showHUD];
    [PackageUtil getPackageServiceSuccess:^(SOSGetPackageServiceResponse *userfulDic) {
        [Util dismissHUD];
        NSString * remainingDay = userfulDic.remainingBytes.currentRemainUsage;
        // 还有剩余流量
        if (remainingDay.length && remainingDay.intValue > 0) {
            if ([[ServiceController sharedInstance] canPerformRequest:GET_HOTSPOT_INFO_REQUEST]) {
//                ViewControllerWifiOwner *wait = [[ViewControllerWifiOwner alloc]initWithNibName:@"ViewControllerWifiOwner" bundle:nil];
              SOSWifiInfoViewController *wait = [[SOSWifiInfoViewController alloc]init];

                [self routerToVc:wait checkAuth:YES checkLogin:YES];
            }
        // 无剩余流量
        }    else    {
            [Util toastWithMessage:@"车载Wi-Fi流量已用完，请购买流量包之后进行设置"];
        }
    } failed:^(NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        if ([[ServiceController sharedInstance] canPerformRequest:GET_HOTSPOT_INFO_REQUEST]) {
//            ViewControllerWifiOwner *wait = [[ViewControllerWifiOwner alloc]initWithNibName:@"ViewControllerWifiOwner" bundle:nil];
            SOSWifiInfoViewController *wait = [[SOSWifiInfoViewController alloc]init];
            [self routerToVc:wait checkAuth:YES checkLogin:YES];
        }
    }];
    
}
+ (void)routerToChargeMode {
    if (![[ServiceController sharedInstance] canPerformRequest:GET_CHARGE_PROFILE_REQUEST]) {
        NSLog(@"stop PerformRequest");
        return;
    }else{
        ChargeModeViewController *chargeMode = [[ChargeModeViewController alloc]initWithNibName:@"ChargeModeViewController" bundle:nil];
        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
        [self routerToVc:chargeMode checkAuth:YES checkLogin:YES];
    }
}

+ (void)routerToOnstarReflect {
#ifndef SOSSDK_SDK
    SOSSmartHomeEntranceViewController* pushedCon = [[SOSSmartHomeEntranceViewController alloc] init];
    AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[delegate fetchMainNavigationController] andTobePushViewCtr:nil completion:^(BOOL finished){
        if(finished){
            [[delegate fetchMainNavigationController] pushViewController:pushedCon animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (![[SOSOnstarLinkSDKTool sharedInstance] isOnstarLinkRunning])     [SOSDaapManager sendActionInfo:Onstarlink_quickbutton];
                [[SOSOnstarLinkDataTool sharedInstance] enterOnstarLink];
            });
        }
    }];
#endif
}

+ (void)routerToFlueStation {
    [SOSNavigateTool showAroundOilStationWithCenterPOI:nil FromVC:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController];
}

+ (void)routerToDealerRev {
    [SOSDealerTool jumpToDealerListMapVCFromVC:nil WithPOI:nil isFromTripPage:NO];
    return;
    
    SOSReservationDealersViewController *reservationVc = [[SOSReservationDealersViewController alloc] initWithNibName:@"SOSReservationDealersViewController" bundle:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        reservationVc.selectedIndex = 1;
    });
    [self routerToVc:reservationVc checkAuth:YES checkLogin:YES];

}

+ (void)routerToBackMirror {
#ifndef SOSSDK_SDK
    @weakify(self)
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]  showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            [[SOSMirrorManager shareInstance] getDeviceList:^(NSInteger messageNum, id model) {
                @strongify(self)
                if (messageNum>0) {
                    SOSMirrorListController *vc = [[SOSMirrorListController alloc] init];
                    vc.isShow = NO;         //没有提示
                    vc.isSuccess = NO;
                    [self routerToVc:vc checkAuth:NO checkLogin:YES];
                }else {
                    SOSDefaultMirrorController *vc = [[SOSDefaultMirrorController alloc] init];
                    [self routerToVc:vc checkAuth:NO checkLogin:YES];
                }
            }];
        }
    }];
#endif
}

+ (void)routerToOperationHistory {
    
       SOSOperationHistoryViewController *hisVc = [[SOSOperationHistoryViewController alloc] initWithNibName:@"SOSOperationHistoryViewController" bundle:nil];
        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
        [self routerToVc:hisVc checkAuth:YES checkLogin:YES];
}

+ (void)routerToVehicleConditionFromPresentVC:(UINavigationController *)fromVC isPresentType:(BOOL)isPresent {
    SOSVehicleConditionViewController *vc = [[SOSVehicleConditionViewController alloc] initWithNibName:@"SOSVehicleConditionViewController" bundle:nil];
    [vc addLeftBarButtonItem];
    if (isPresent) {
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [fromVC presentViewController:nav animated:YES completion:^{

        }];
    }	else	{
        [fromVC pushViewController:vc animated:YES];
    }
}

+ (void)routerToH5Url:(NSString *)url {
    if (!url) {
        return;
    }
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
    [self routerToVc:vc];
}


/// 弹出bbwc教育页面
+ (void)routerToBBwcWithType:(NSString *)type {
    
    if (type.isNotBlank) {
        //加载bbwc教育页面
        [self realRouterToBBWCWithType:type];
        return;
    }
  
    [Util showLoadingView];
    SOSBBWCSubmitWrapper * scr = [[SOSBBWCSubmitWrapper alloc] init];
    //    scr.bbwcDone = false;
    [RegisterUtil submitBBWCInfoOrOnstarInfo:NO withEnrollInfo:[scr mj_JSONString] successHandler:^(NSString *responseStr) {
        NNBBWCResponse * resp = [NNBBWCResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resp && resp.vehicleType)
            {
                [Util hideLoadView];
                //加载bbwc教育页面
                [self realRouterToBBWCWithType:resp.vehicleType];
                
            }
            else
            {
                [Util hideLoadView];
                [KEY_WINDOW.rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
        });
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}

+ (void)realRouterToBBWCWithType:(NSString *)type {
    //加载bbwc教育页面
    [[LoginManage sharedInstance] addTouchIdObserver];
    
    [[LoginManage sharedInstance] addPopViewAction:^{
        UINavigationController *personNav =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController] );
        NSString *url = [NSString stringWithFormat: BBWC_EDUCATION,type];
        SOSWebViewController *bbwcEdu = [[SOSWebViewController alloc] initWithUrl:url];
        bbwcEdu.shouldDismiss = YES;
        bbwcEdu.isBBWC = YES;
        UINavigationController *bbwcNav = [[UINavigationController alloc] initWithRootViewController:bbwcEdu];
        [personNav presentViewController:bbwcNav animated:YES completion:nil];
    }];
}

+ (void)routerToOilRankH5    {
    [self routerToOilRankH5WithPageBackBlock:nil];
}

+ (void)routerToOilRankH5WithPageBackBlock:(void (^)(void))backBlock    {
    [self routerToOilRankH5WithPageBackBlock:backBlock LoadingStartTime:0 AndSuccessFuncID:nil FailureFuncID:nil];
}

+ (void)routerToOilRankH5WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID  {
    //1.//首次进入Y 再进>2
    
    //2.//非首次 E or null  再进>2
    
    //3.//关闭再打开N  再进>2
    
    //4//关闭 null 再进>4
    @weakify(self)
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]  showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        @strongify(self)
        NSString *url = DRIVING_OIL_CONSUMPTION_DEFAULTURL;
        NSString *key = [NSString stringWithFormat:@"FuelEconomyFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
        if ([CustomerInfo sharedInstance].servicesInfo.FuelEconomy.optStatus) {
            NSString *param = [NSString stringWithFormat:@"?isFirstInfo=%@",UserDefaults_Get_Object(key)?:@"Y"];
            url = [url stringByAppendingString:param];
        }
        [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
        
        // 积分公益增加积分
        [SOSDonateDataTool modifyUserDonateInfoWithActionType:SOSDonateOperationType_Fuel_Rank Success:nil Failure:nil];
        
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
        vc.isForNewDAAP = YES;
        if (successFuncID.length)     [vc configLoadingFuncIDWithStartTime:startTime AndSuccessFuncID:successFuncID FailureFuncID:failFuncID];
        
        if (backBlock)    vc.backClickCompleteBlock = backBlock;
        [SOSDaapManager sendActionInfo:Startrip_Fuelconsumption];
        [self routerToVc:vc checkAuth:YES checkLogin:YES];
        UserDefaults_Set_Object(@"E", key);
    }];
}

+ (void)routerToEnergyRankH5	{
    [self routerToEnergyRankH5WithPageBackBlock:nil];
}

+ (void)routerToEnergyRankH5WithPageBackBlock:(void (^)(void))backBlock 	{
    [self routerToEnergyRankH5WithPageBackBlock:backBlock LoadingStartTime:0 AndSuccessFuncID:nil FailureFuncID:nil];
}

+ (void)routerToEnergyRankH5WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID {
    //1.//(null)首次进入Y 再进>2
    
    //2.//非首次 E  再进>2
    
    //3.//关闭再打开N (每当开关开启都置为)  再进>2
    
    //4//关闭 E 再进>4
    NSString *url = DRIVING_ENERGINE_CONSUMPTION_URL;
    NSString *key = [NSString stringWithFormat:@"energyRankFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
//    if (![CustomerInfo sharedInstance].servicesInfo.EnergyEconomy.optStatus) {
        NSString *param = [NSString stringWithFormat:@"?isFirstInfo=%@",UserDefaults_Get_Object(key)?:@"Y"];
        url = [url stringByAppendingString:param];
//    }
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [SOSDaapManager sendActionInfo:Startrip_Energyconsumption];
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
    vc.isForNewDAAP = YES;
    if (successFuncID.length)     [vc configLoadingFuncIDWithStartTime:startTime AndSuccessFuncID:successFuncID FailureFuncID:failFuncID];
    
    if (backBlock)		vc.backClickCompleteBlock = backBlock;
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
    
    UserDefaults_Set_Object(@"E", key);
}

+ (void)routerToDrivingScoreH5 {
    
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]  showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        [SOSCardUtil routerToDrivingScoreH5:nil];
    }];
}

+ (void)routerToDrivingScoreH5:(id)fromVc	{
    [SOSCardUtil routerToDrivingScoreH5FromVC:fromVc WithPageBackBlock:nil];
}

+ (void)routerToDrivingScoreH5FromVC:(id)fromVc WithPageBackBlock:(void (^)(void))backBlock		{
    [SOSCardUtil routerToDrivingScoreH5FromVC:fromVc WithPageBackBlock:backBlock LoadingStartTime:0 AndSuccessFuncID:nil FailureFuncID:nil];
}

//跳转到驾驶行为
+ (void)routerToDrivingScoreH5FromVC:(id)fromVc WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID	{
    NSString *url = [NSString stringWithFormat:DRIVING_SCORE_URL, @"false"];
    NSString *firstKey = [NSString stringWithFormat:@"drivingScoreFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
    BOOL firstFlag = UserDefaults_Get_Bool(firstKey);
    
    NSString *reopenKey = [NSString stringWithFormat:@"drivingScoreReopen_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
    BOOL reopenFlg = UserDefaults_Get_Bool(reopenKey);
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    //第一次进入驾驶评分页面
    if (firstFlag == NO) {
        url = [NSString stringWithFormat:DRIVING_SCORE_URL, @"true"];
        UserDefaults_Set_Bool(YES, firstKey);
        
        [defaults removeObjectForKey:reopenKey];
        [defaults synchronize];
    }    else    {
        if (reopenFlg) {
            url = [NSString stringWithFormat:DRIVING_SCORE_URL, @"true"];
            [defaults removeObjectForKey:reopenKey];
            [defaults synchronize];
        }
    }
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    
    // 积分公益增加积分
    [SOSDonateDataTool modifyUserDonateInfoWithActionType:SOSDonateOperationType_Behavior_Score Success:nil Failure:nil];
    
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
    vc.isForNewDAAP = YES;
    if (successFuncID.length) 	[vc configLoadingFuncIDWithStartTime:startTime AndSuccessFuncID:successFuncID FailureFuncID:failFuncID];
    
    if (backBlock)	vc.backClickCompleteBlock = backBlock;
    vc.driveScoreFlg = YES;
    [self routerFromVc:fromVc ToVc:vc checkAuth:YES checkLogin:YES];
}

+ (void)routerToStarTravelH5	{
    [self routerToStarTravelH5:nil];
}

+ (void)routerToStarTravelH5:(NSString *)para {
    NSMutableString *url = STAR_TRAVEL_URL.mutableCopy;
    if (para) {
        [url appendString:@"&"];
        [url appendString:para];
    }
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
    
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}

+ (void)routerToVehicleEducationH5 {
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:VEHICLE_EDU_URL];
    vc.backRecordFunctionID = My_CarTutoria_back;
    [self routerToVc:vc];
}

+ (void)routerToCarReportH5 {
    [self vehicleEvaluateClick];
}

+ (void)routerToVehicleInfo {
//        [self checkAuth:YES checkLogin:YES complete:^{
//            [FlutterBoostPlugin open:@"vehicle://vehicle_setting_page" urlParams:@{} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
////                NSLog(@"call me when page finished, and your result is:%@", result);
//            } completion:^(BOOL f) {
////                NSLog(@"page is presented");
//            }];
//        }];
    
    SOSVehicleInfoViewController *vc = [[SOSVehicleInfoViewController alloc] initWithNibName:@"SOSVehicleInfoViewController" bundle:nil];
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];

}
+ (void)routerToOnstarPackage {
//    if ([SOSFlutterManager shareInstance].package_package_enable) {
//        [self checkAuth:YES checkLogin:YES complete:^{
//            [FlutterBoostPlugin open:@"package://package_onstar_package_page" urlParams:@{} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
//            } completion:^(BOOL f) {
//            }];
//        }];
//        return;
//    }
    SOSOnstarPackageVC *vc = [SOSOnstarPackageVC new];
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}

+ (void)routerTo4GPackage {
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    SOS4GPackageVC *vc = [SOS4GPackageVC new];
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}

+ (void)routerToPrepaymentCard {

//    if ([SOSFlutterManager shareInstance].package_prepayment_enable) {
//        [self checkAuth:YES checkLogin:YES complete:^{
//            [FlutterBoostPlugin open:@"package://package_prepayment_page" urlParams:@{} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
//                NSLog(@"call me when page finished, and your result is:%@", result);
//            } completion:^(BOOL f) {
//                NSLog(@"page is presented");
//            }];
//        }];
//    }else {
        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
        SOSPrepaidCardVC * vc = [SOSPrepaidCardVC new];
        [self routerToVc:vc checkAuth:YES checkLogin:YES];
//    }
}

+ (void)routerToUserManual{
    MeManualViewController *vc = [[MeManualViewController alloc] init];
    vc.backRecordFunctionID = My_More_Manual_back;
    [self routerToVc:vc checkAuth:NO checkLogin:NO];

}

+ (void)routerToAboutOnstar{
    [SOSDaapManager sendActionInfo:My_More_About];
    MeAboutUsViewController *vc = [[MeAboutUsViewController alloc] init];
    [self routerToVc:vc checkAuth:NO checkLogin:NO];

}
+ (void)callOnstar{
    [SOSUtil callPhoneNumber:@"400-820-1188"];
}

+ (void)carClass	{
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])	return;
        
        NSString *url = [BASE_URL stringByAppendingFormat:SOS_Car_Class_GetInfo_URL, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin, [UIApplication sharedApplication].appVersion];
        [Util showHUD];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util dismissHUD];
            if (operation.statusCode == 200) {
                NSDictionary *resDic = [responseStr mj_JSONObject];
                if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                    NSString *associationUrl = resDic[@"associationUrl"];
                    if ([associationUrl isKindOfClass:[NSString class]] && associationUrl.length) {
                        SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:associationUrl];
                        webVC.singlePageFlg = YES;
                        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:webVC animated:YES];
                        return;
                    }
                }
            }
            [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
    }];
}
+(void)routerToProtocols{
    SOSTermsViewController *vc = [[SOSTermsViewController alloc] init];
    [self routerToVc:vc checkAuth:NO checkLogin:NO];

}
+(void)routerToOnlineService{
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:MA8_1_Question_Feedback_URL];
    [self routerToVc:vc checkAuth:NO checkLogin:NO];

}
+(void)routerToMyDonate{
//    if ([[SOSWebViewController new] isUserReadyForDonation])        {
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
    SOSMyDonateVC *vc = [SOSMyDonateVC new];
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
//    }
//    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:^(BOOL finished) {
//        if (finished) {
//            if ([[SOSWebViewController new] isUserReadyForDonation])        {
//                SOSMyDonateVC *vc = [SOSMyDonateVC new];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//    }];
}

+ (void)routerToBuyOnstarPackage:(PackageType)type {
    
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }

    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]];
    SOSBuyPackageVC *vc = [SOSBuyPackageVC new];
    vc.selectPackageType = type;
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}


/**
 足迹
 */
//+ (void)routerToFootMark    {
//    [self routerToFootMarkWithPageBackBlock:nil];
//}

+ (void)routerToFootMarkWithPageBackBlock:(void (^)(void))backBlock {
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [SOSDaapManager sendActionInfo:Startrip_Footprints];
    
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:CAR_FootPrint_URL];
    [vc hideNavBar:YES];
    if (backBlock) {
        vc.backClickBlock = backBlock;
    }
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}

/** 安星定位 */
+ (void)routerToOnstarDeviceLocation     {
//    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    //demo：设置访问权限方式,设置进入依赖条件 ![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] 表示如果是登录状态且suite接口未加载完成，则依赖数据是非法的，不允许执行操作
    
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
        if (finished) {
            if ([SOS_APP_DELEGATE fetchRootViewController].selectedViewController.presentedViewController) {
                [[SOS_APP_DELEGATE fetchRootViewController].selectedViewController dismissViewControllerAnimated:YES completion:nil];
            }
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO] ;
#ifdef SOSSDK_SDK
     [[SOS_APP_DELEGATE fetchRootViewController] setSelectedIndex:1];

#else
        [[SOS_APP_DELEGATE fetchRootViewController] cyl_popSelectTabBarChildViewControllerAtIndex:1];
#endif
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CustomNavigationController * tripNav = (CustomNavigationController *)[(UITabBarController *)[SOS_APP_DELEGATE fetchRootViewController] selectedViewController];
                SOSTripHomeVC *vc = [tripNav.viewControllers objectAtIndex:0];
                [vc showLBS];
            });
        }
    }];
    
   
    
}
+ (void)routerToPinModificationWithDismissBlock:(void(^)(void))disblock{
   
    SOSEditQAPinViewController *vc1 = [SOSEditQAPinViewController new];
    CustomNavigationController *cvc = [[CustomNavigationController alloc] initWithRootViewController:vc1];
    if (disblock) {
        vc1.dismissComplete = disblock;
    }
    [KEY_WINDOW.rootViewController presentViewController:cvc animated:YES completion:nil];
}
+(void)routerToPinModificationDirectWay:(void (^)(void))disblock{
    SOSNStytleEditInfoViewController * editUser = [[SOSNStytleEditInfoViewController alloc] initWithNibName:@"SOSNStytleEditInfoViewController" bundle:nil];
    editUser.editType =SOSEditUserInfoTypeCarControlPassword;
    editUser.govid = [CustomerInfo sharedInstance].govid;
    editUser.backRecordFunctionID =changecontrolpin_back;
//    SOSWeakSelf(weakSelf);
    @weakify(editUser);
    [editUser setFixOkBlock:^(NSString * text){
        [Util showLoadingView];
        BOOL bbwcDone = [CustomerInfo sharedInstance].currentVehicle.bbwc;
        SOSBBWCSubmitWrapper * scr = [[SOSBBWCSubmitWrapper alloc] init];
        scr.bbwcDone = bbwcDone;
        scr.pin = text;
        [RegisterUtil submitBBWCInfoOrOnstarInfo:NO withEnrollInfo:[scr mj_JSONString] successHandler:^(NSString *responseStr) {
            @strongify(editUser);
            [Util hideLoadView];
            [editUser.navigationController dismissViewControllerAnimated:YES completion:^{
                NNBBWCResponse * resp = [NNBBWCResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
                if (resp && resp.vehicleType)
                {
                    [Util showAlertWithTitle:@"恭喜您" message:@"您已完成密码设置操作。\n若需要修改其他信息可通过个人信息的星用户信息页面进行修改。" completeBlock:^(NSInteger buttonIndex) {
                        {
                            [CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin = NO;
                            if (![CustomerInfo sharedInstance].currentVehicle.bbwc) {
                                [KEY_WINDOW.rootViewController dismissViewControllerAnimated:NO completion:^{
                                    [SOSCardUtil routerToBBwcWithType:resp.vehicleType];
                                }];
                                
                            }
                        }
                    } cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
                }

            }];
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            @strongify(editUser);
            [editUser.navigationController dismissViewControllerAnimated:YES completion:^{
                [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
            }];
        }];
    }];
     CustomNavigationController *cvc = [[CustomNavigationController alloc] initWithRootViewController:editUser];
    [KEY_WINDOW.rootViewController presentViewController:cvc animated:YES completion:nil];

}
#pragma mark - 爱车评估
+ (void)vehicleEvaluateClick
{
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        [self pushCarH5Web];
    }
    else if([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKEN){
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"ConnectingVehicle", nil) completeBlock:nil];
    }
    else {
        if ([Util isToastLoadUserProfileFailure])return;
        if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])     return;
        ///*
        if ([SOSCheckRoleUtil isOwner]) {
            NSLog(@"-----------=%d",UserDefaults_Get_Bool(@"showFirst"));
            if (!UserDefaults_Get_Bool(@"showFirst")) {
                UserDefaults_Set_Bool(YES, @"showFirst");
                 [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverComplete:^{
                    if(![CustomerInfo sharedInstance].servicesInfo.CarAssessment.optStatus){
                       SOSCarAssessmentView *carAssess = [[SOSCarAssessmentView alloc] initWithFrame:CGRectMake(60, 100, kScreenWidth - 120, kScreenHeight - 240)];
                        carAssess.carEnum = GOInCarReport;
                        [carAssess initView];
                        __block SOSCarAssessmentView *carA= carAssess;
                        [carAssess setAgreementUrl:^{
                            [Util showLoadingView];
                            [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_CARDATA_SHARE_TC)] success:^(NSDictionary *response) {
                                [Util hideLoadView];
                                NSDictionary *dic = response[agreementName(ONSTAR_CARDATA_SHARE_TC)];
                                SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
                                [carA dismissShareReportView];
                                SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:agreement.url];
                                //SmartDriver_agreement_share_URL
                                [CustomerInfo sharedInstance].showCarAlert_Home = YES;
                                [self routerToVc:vc];
                                 [SOSDaapManager sendActionInfo:CarAssmt_ViewCarAssmtServiceProtocol];
                                
                            } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                [Util toastWithMessage:@"获取协议内容失败"];
                            }];

                            
                        }];
                        
                        [carAssess setAgreeGoInAction:^(BOOL flag) {
                            if (flag) {
                                //上传同意数据 request interface
                                [Util openVehicleService:^{
                                    [self pushCarH5Web];
                                    [CustomerInfo sharedInstance].servicesInfo.CarAssessment.optStatus = YES;
                                } httpMethod:@"PUT"];
                                
                            } else {
                                [self pushCarH5Web];
                            }
                        }];
                        dispatch_async_on_main_queue(^{
                            [carAssess showShareReportView];
                        });
                        
                    }else{
                        [self pushCarH5Web];
                    }
                }];
            }
            else{
                [self pushCarH5Web];
            }
        }else{
            [self pushCarH5Web];
        }
    }
    
}

+ (void) pushCarH5Web
{
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:CAR_ASSESSMENT_URL];
    vc.backRecordFunctionID = CarValuation_back;
    vc.vehicleEvaluateFlg = YES;
    [self routerToVc:vc checkAuth:YES checkLogin:YES];
}

#if __has_include(<BlePatacSDK/BlueToothManager.h>)
/**
 转转至车辆操作页面
 */
+ (void)routerToBleOperationPageWithBleModel:(BLEModel *)bleModel {
    SOSBleUserCarOperationViewController *opVc = [[SOSBleUserCarOperationViewController alloc] initWithNibName:SOSBleUserCarOperationViewController.className bundle:nil];
    if (bleModel) {
        opVc.reConnectBleModel = bleModel;
    }
    [self routerToVc:opVc checkAuth:NO checkLogin:NO];
}
#endif
/**
 转转至蓝牙钥匙页面
 */
+ (void)routerToBleKeyPage
{
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    NSArray *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    
    if (!keys.count && [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        //登录 无钥匙  ->收到的共享
         [SOSDaapManager sendActionInfo:SmartVehicle_BLE_Keyentry_ReceivedCarsharing];
        [self routerToUserReceiveBlePage];
    }else {
        //未登录 or 登录有钥匙
        if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
            //登录有钥匙需更新下本地钥匙
            [self requestBleReceiveListComplete:^{
                SOSBleUserCarListViewController *vc = [SOSBleUserCarListViewController new];
                [self routerToVc:vc checkAuth:NO checkLogin:NO];
            }];
        }else {
            //s
            SOSBleUserCarListViewController *vc = [SOSBleUserCarListViewController new];
            [self routerToVc:vc checkAuth:NO checkLogin:NO];
        }
    }
#endif
    
    
}


//用车车辆操作页面
+ (void)gotoBleOperationPage {
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    SOSBleUserCarOperationViewController *opVc = [[SOSBleUserCarOperationViewController alloc] initWithNibName:SOSBleUserCarOperationViewController.className bundle:nil];
    [self routerToVc:opVc checkAuth:NO checkLogin:NO];
#endif
}


/**
 跳转共享我的车页面
 */
+ (void)routerToOwnerBle
{
    
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
//    //test code
//    [self realRouterToOwnerBle];
//    return;
    if (![CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.ble) {
        return;
    }
    [Util showLoadingView];
     //1.开关
    [SOSBleNetwork bleSwitchStatusSuccess:^(id JSONDict) {
        
        if ([[JSONDict objectForKey:@"statusCode"] isEqualToString:@"0000"]) {
            NSDictionary *dic =[JSONDict objectForKey:@"resultData"];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                BOOL switchOn = [[dic objectForKey:@"ble"] isEqualToString:@"ON"];
//                [self getToSignAgreementAndShowWithBleStatus:switchOn];
                if (switchOn) {
                    //直接进入
                    [self realRouterToOwnerBle];
                }else {
                    [self showBleSwitchOffAlert];
                }
            }
        }else {
//            if ([[JSONDict objectForKey:@"statusCode"] isEqualToString:@"5001"]) {
//                //未绑定车  获取蓝牙协议弹出alert同意后开关自动打开直接进入
//                [self getAgreementAndShow];
//            }else
            {
                NSString *msg = [JSONDict objectForKey:@"message"];
                [Util toastWithMessage:msg];
                [Util hideLoadView];
            }
        }
    } Failed:^(NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"网络错误，请稍后重试"];
        [Util hideLoadView];
    }];
#endif
}

+ (void)requestBleReceiveListComplete:(void(^)(void))complete {
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    [Util showLoadingView];
    [SOSBleNetwork bleUserAuthorizationsParams:@{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@""}
                                        method:@"POST"
                                       success:^(SOSAuthorInfo *authorInfo) {
                                           if ([authorInfo.statusCode isEqualToString:@"0000"]) {
                                               [SOSBleUtil disposeDataWithAuthorInfo:authorInfo];
                                           }
                                           [Util hideLoadView];
                                           !complete?:complete();
                                       } Failed:^(NSString *responseStr, NSError *error) {
                                           [Util hideLoadView];
                                           !complete?:complete();
                                       }];
#endif
    
}
#pragma mark - 90
+ (void)routerToChargeStation	{
    SOSTripChargeVC *vc = [[SOSTripChargeVC alloc] init];
    vc.mapType = MapTypeShowChargeStation;
    [self routerToVc:vc checkAuth:NO checkLogin:NO];

}

////获取最新的未签的协议
//+ (void)getToSignAgreementAndShowWithBleStatus:(BOOL)switchStatus {
//    [SOSBleNetwork loadBLENeedConfirmTypes:@[agreementName(ONSTAR_BLE)] success:^(NSArray<SOSAgreement *> *agreements) {
//        [Util hideLoadView];
//        if (agreements.count == 0) {
//            //ble开关
//            if (switchStatus) {
//                //开:直接进入
//                [self realRouterToOwnerBle];
//            }else {
//                //关:弹出去设置Ble开关提示
//                [self showBleSwitchOffAlert];
//            }
//        }else {
//            //弹出协议
//            [self showAgreementAlertViewWithAgreements:agreements success:^{
//                if (switchStatus) {
//                    [self realRouterToOwnerBle];
//                }else {
//                    [self showBleSwitchOffAlert];
//                }
//            }];
//        }
//    } failed:^(NSString *responseStr, NSError *error) {
//        [Util toastWithMessage:@"获取协议内容错误"];
//        [Util hideLoadView];
//    }];
//}

+ (void)showBleSwitchOffAlert {
    [Util hideLoadView];
    SOSCustomAlertView *cusAlertView = [[SOSCustomAlertView alloc] initWithTitle:@"服务关闭" detailText:@"您已关闭蓝牙钥匙功能,暂无法使用\n开启功能需要您在服务设置中打开" cancelButtonTitle:@"再想想" otherButtonTitles:@[@"前往设置"]];
    cusAlertView.backgroundModel = SOSAlertBackGroundModelStreak;
    cusAlertView.buttonMode = SOSAlertButtonModelHorizontal;
    @weakify(self)
    [cusAlertView setButtonClickHandle:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            //去设置页面
            @strongify(self)
            [self routerToSettingPage];
        }
    }];
    [cusAlertView show];
}

+ (void)routerToSettingPage {
    SOSSettingViewController *settingVc = [[SOSSettingViewController alloc] init];
    @weakify(self)
    settingVc.popBlock = ^{
        @strongify(self)
        [self routerToOwnerBle];
    };
    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:settingVc];
}

+ (void)routerToOnstarShop {
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:[Util.getConfigureURL stringByAppendingString: @"/sos/contentinfo/v1/switch/redirect?channel=ajxsc"]];
    [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
}

////获取最新蓝牙协议并弹出  弹出协议
//+ (void)getAgreementAndShow {
//    [Util showLoadingView];
//    [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_BLE)] success:^(NSDictionary *response) {
//        [Util hideLoadView];
//        NSDictionary *dic = response[agreementName(ONSTAR_BLE)];
//        SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
//        [self showAgreementAlertViewWithAgreements:@[agreement] success:^{
//            [self realRouterToOwnerBle];
//        }];
//    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        [Util toastWithMessage:@"获取协议内容错误"];
//        [Util hideLoadView];
//    }];
//}

////显示xBle协议 只显示
//+(void)showBleAgreement {
//    [Util showLoadingView];
//    [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_BLE)] success:^(NSDictionary *response) {
//        [Util hideLoadView];
//        NSDictionary *dic = response[agreementName(ONSTAR_BLE)];
//        SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
//        SOSAgreementAlertView *view = [[SOSAgreementAlertView alloc] initWithAlertViewStyle:SOSAgreementAlertViewStyleSignUp];
//        view.agreements = @[agreement];
//        [view show];
//    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        [Util toastWithMessage:@"获取协议内容错误"];
//        [Util hideLoadView];
//    }];
//
//}


////弹出蓝牙协议弹框
//+ (void)showAgreementAlertViewWithAgreements:(NSArray<SOSAgreement *>*)agreements
//                                     success:(void(^)(void))successBlock {
//    SOSAgreementAlertView *view = [SOSAgreementAlertView new];
//    view.agreements = agreements;
//    view.agree = ^{
//        [SOSBleNetwork requestBleBindOwnerSuccess:^(NSDictionary *resp) {
//            if ([resp[@"statusCode"] isEqualToString:@"0000"]) {
//
//                !successBlock?:successBlock();
//            }else {
//                NSString *msg = resp[@"message"];
//                if (msg.isNotBlank) {
//                    [Util toastWithMessage:msg];
//                }
//            }
//
//        } Failed:^(NSString *responseStr, NSError *error) {
//            NSString *errMsg = @"请求失败";
//            NSDictionary *response = [Util dictionaryWithJsonString:responseStr];
//            if (response) {
//                errMsg = [response valueForKey:@"errorMessage"];
//            }
//            [Util toastWithMessage:errMsg];
//
//        }];
//
//    };
//
//    [view showInView:[SOS_APP_DELEGATE fetchRootViewController].view];
//}


+ (void)realRouterToOwnerBle {
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
    [Util hideLoadView];
    SOSBleOwnerSharePageViewController *pageVc = [SOSBleOwnerSharePageViewController new];
    //TODO 判断BLE车主
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [[LoginManage sharedInstance] setIgnoreConnectingVehicleAlert:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [self routerToVc:pageVc checkAuth:YES checkLogin:YES];
#endif
}


/**
 跳转至收到的共享
 */
+ (void)routerToUserReceiveBlePage {
    [self routerToUserReceiveBlePageBlock:nil];
}

/**
 跳转云录播列表
 */
+ (void)routerToCloudVideoListWithIMEI:(NSString *)imei {
#ifndef SOSSDK_SDK
    SOSCloudVideoListVC *vc = [[SOSCloudVideoListVC alloc] init];
    vc.imei = imei;
    [self routerToVc:vc checkAuth:NO checkLogin:YES];
#endif
}

+ (void)routerToUserReceiveBlePageBlock:(void(^)(void))complete {
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
    SOSBleUserReceiveShareViewController *vc = [SOSBleUserReceiveShareViewController new];
    vc.delayPerform = complete;
    [self routerToVc:vc checkAuth:NO checkLogin:YES];
#endif
}


/**
 权限与登录状态判断

 @param vc to vc
 @param checkAuth YES:升级车主
 @param checkLogin YES:弹出登录
 */
+ (void)routerToVc:(id)vc checkAuth:(BOOL)checkAuth checkLogin:(BOOL)checkLogin{
    [SOSCardUtil routerFromVc:nil ToVc:vc checkAuth:checkAuth checkLogin:checkLogin];
}

+ (void)routerFromVc:(id)fromVc ToVc:(id)vc checkAuth:(BOOL)checkAuth checkLogin:(BOOL)checkLogin{
   
    if (checkAuth) {
        //升级车主
        if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])     return;
    }
    if (!fromVc) {
        fromVc = [SOS_APP_DELEGATE fetchMainNavigationController];
    }
    if (checkLogin ) {
        NSLog(@"-------state:%@",@([LoginManage sharedInstance].loginState));
        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:fromVc andTobePushViewCtr:nil completion:^(BOOL finished){
            if(finished){
                [self router:fromVc ToVc:vc];
            }
        }];
    }else {
        [self router:fromVc ToVc:vc];
    }
}


+ (void)checkAuth:(BOOL)checkAuth
       checkLogin:(BOOL)checkLogin
         complete:(void (^)(void))completion{
    if (checkAuth) {
        //升级车主
        if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])     return;
    }

    if (checkLogin) {
        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController] andTobePushViewCtr:nil completion:^(BOOL finished){
            if(finished){
                completion();
            }
        }];
    }else {
        completion();
    }
}

/**
 直接跳转
 */
+ (void)routerToVc:(id)vc {
    [SOSCardUtil router:nil ToVc:vc];
}
+ (void)router:(id)fromVc ToVc:(id)vc {
    AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
    if (!fromVc) {
        fromVc = ((UINavigationController *)[delegate fetchMainNavigationController]);
    }
    if (![fromVc respondsToSelector:@selector(topViewController)]) {
        [(UIViewController *)fromVc presentViewController:vc animated:YES completion:nil];
    }else{
        [fromVc pushViewController:vc animated:YES];
    }
}
+ (void)routerToForegtPassWord:(UIViewController *)parentVC;
{
    [SOSDaapManager sendActionInfo:Forgetpassword];
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:FORGETPASSWORD_URL];
    [parentVC.navigationController pushViewController:vc animated:YES];
}
+(void)routerToMessageWithCategory:(MessageModel *)model{
    SOSNotifyController *vc = [[SOSNotifyController alloc]init];
    vc.notifyCategory = model.category;
    vc.notifyTitle = model.categoryZh;
    vc.unreadNum = model.count;
    vc.totalNum = model.totalCount;
    [self routerToVc:vc checkAuth:YES checkLogin:YES];

}

/// 跳转 里程险 免责声明
+ (void)showMileAgeInsuranceStatementVCWithURL:(NSString *)url FromVC:(UIViewController *)fromVC Success:(void (^)(void))success	{
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:SOS_APP_DELEGATE.fetchMainNavigationController.topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
        if (finished) {
            BOOL needSign = YES;
            
            NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            NSString *const KMileAgeInsuranceStatement = @"KMileAgeInsuranceStatement";
            NSDictionary *sourceDic = UserDefaults_Get_Object(KMileAgeInsuranceStatement);
            NSMutableDictionary *cacheDic = [NSMutableDictionary dictionaryWithDictionary:sourceDic];
            NSString *signTime = cacheDic[idpid];
            // 签署过协议
            if (signTime.length > 0) {
                // 签署时间在 30 天以内
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                if (currentTime - signTime.longLongValue < 3600 * 24 * 30) {
                    needSign = NO;
                }
            }
            // 需要签署协议
            if (needSign) {
                SOSMileAgeInsuranceStatementVC *vc = [SOSMileAgeInsuranceStatementVC new];
                vc.successBlock = ^{
                    [SOSDaapManager sendActionInfo:Mileage_Insurance_Agree];
                    [SOSDaapManager sendActionInfo:Mileage_Jump_H5];
                    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                    cacheDic[idpid] = @(currentTime).stringValue;
                    UserDefaults_Set_Object(cacheDic, KMileAgeInsuranceStatement);
                    
/*					// 里程险页面会显示空白,原因不明
                    if ([fromVC isKindOfClass:[SOSWebViewController class]]) {
                        [SOS_APP_DELEGATE.fetchMainNavigationController popViewControllerAnimated:YES];
                        [((SOSWebViewController *)fromVC).webView loadURLString:url];
                    }    else    {
                    }
                    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
                    webVC.webView.uiWebView.dataDetectorTypes = UIDataDetectorTypeNone;
 */
                    
                    SOSThirdPartyWebVC *webVC = [[SOSThirdPartyWebVC alloc] initWithUrl:url];
                    [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:webVC animated:YES];
                    [SOS_APP_DELEGATE.fetchMainNavigationController.topViewController clearNavVCWithClassNameArray:@[@"SOSMileAgeInsuranceStatementVC"]];
                    if (success)	success();
                };
                vc.failureBlock = ^{
                    [SOSDaapManager sendActionInfo:Mileage_Insurance_Back];
                };
                [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
            }	else	{
                [SOSDaapManager sendActionInfo:Mileage_Jump_H5];
                SOSThirdPartyWebVC *vc = [[SOSThirdPartyWebVC alloc] initWithUrl:url];
                [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
                
/*				// 里程险页面会显示空白,原因不明
 				if ([fromVC isKindOfClass:[SOSWebViewController class]]) {
                    [((SOSWebViewController *)fromVC).webView loadURLString:url];
                }    else    {
                    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
                    webVC.webView.uiWebView.dataDetectorTypes = UIDataDetectorTypeNone;
                    [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:webVC animated:YES];
 				}
*/
                if (success)    success();
            }
            
        }
    }];
}
@end

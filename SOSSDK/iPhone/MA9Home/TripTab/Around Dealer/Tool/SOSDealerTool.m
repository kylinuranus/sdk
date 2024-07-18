//
//  SOSDealerTool.m
//  Onstar
//
//  Created by Coir on 18/12/2017.
//  Copyright © 2017 Shanghai Onstar. All rights reserved.
//

#import "SOSDealerTool.h"
#import "SOSUserLocation.h"
#import "SOSTripDealerVC.h"

/// 周边经销商 Cell 点击
NSString *const KDealerMapVCCellTappedNotify = @"KDealerMapVCCellTappedNotify";

/// 首选经销商点击
NSString *const KFirstDealerViewTappedNotify = @"KFirstDealerViewTappedNotify";

/// 周边经销商 在地图上显示列表
NSString *const KNeedShowDealerListMapNotify = @"KNeedShowDealerListMapNotify";
/// 首选经销商 在地图上显示列表
NSString *const KNeedShowFirstDealerMapNotify = @"KNeedShowFirstDealerMapNotify";

/// 周边经销商更换品牌筛选
NSString * const KAroundDealerChangeBrandNotify = @"KAroundDealerChangeBrandNotify";

/// 地图页面进入/退出全屏模式
NSString * const KMapVCEnterFullscreenNotify = @"KMapVCEnterFullscreenNotify";

@implementation SOSDealerTool

/// 跳转经销商选择页(Trip 新版)
+ (void)jumpToDealerListMapVCFromVC:(UIViewController *)vc WithPOI:(SOSPOI *)poi isFromTripPage:(BOOL)isFromTrip	{
    if (!vc)	vc = [SOS_APP_DELEGATE fetchMainNavigationController].topViewController;
    [SOSUserLocation handleLocationPOIInfoDone:poi Success:^(BOOL done, SOSPOI *resultPoi) {
        if (done) {
            [self jumpToMapDealerFromVC:vc WithPOI:resultPoi isFromTripPage:isFromTrip];
        }
    }];
}

//  获取当前用户车辆品牌
+ (SOSDealerBrandType)getBrandTypeForCurrentUser    {
    NSString *brandType = [[CustomerInfo sharedInstance] currentVehicle].brand ? : @"";
    if ([brandType isEqualToString:@"BUICK"]) {
        return SOSDealerBrandType_Buick;
    }    else if ([brandType isEqualToString:@"CHEVROLET"]) {
        return SOSDealerBrandType_Chevrolet;
    }    else if ([brandType isEqualToString:@"CADILLAC"]) {
        return SOSDealerBrandType_Cadillac;
    }    else {
        return SOSDealerBrandType_All;
    }
}

+ (NSString *)transformIntoBrandNameWithBrandType:(SOSDealerBrandType)brandType    {
    NSString *brandName = @"";
    switch (brandType) {
        case SOSDealerBrandType_All:
        case SOSDealerBrandType_Void:
            brandName = @"ALL";
            break;
        case SOSDealerBrandType_Buick:
            brandName = @"BUICK";
            break;
        case SOSDealerBrandType_Cadillac:
            brandName = @"CADILLAC";
            break;
        case SOSDealerBrandType_Chevrolet:
            brandName = @"CHEVROLET";
            break;
    }
    return brandName;
}

+ (void)jumpToMapDealerFromVC:(UIViewController *)fromVC WithPOI:(SOSPOI *)poi isFromTripPage:(BOOL)isFromTrip	{
    //排除未登录
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:fromVC withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        if (finished) {
            //排除访客
            if (![SOSCheckRoleUtil checkVisitorInPage:fromVC])     return;
            [Util showHUD];
            [SOSDealerTool requestDealerListWithCenterPOI:poi Success:^(NSArray<NNDealers *> *dealerList) {
                [Util dismissHUD];
                if (dealerList.count == 0)    [Util toastWithMessage:@"附近暂无经销商"];
                SOSTripDealerVC *vc = [[SOSTripDealerVC alloc] initWithPOI:poi];
                vc.fullScreenMode = !isFromTrip;
                vc.dealerArray = dealerList.mutableCopy;
                vc.mapType = isFromTrip ? MapTypeShowDealerPOI : MapTypeShowPoiList;
                [fromVC.navigationController pushViewController:vc animated:YES];
            } Failure:^{
                [Util dismissHUD];
            }];
        }
        
    }];
}

+ (void)requestDealerListWithCenterPOI:(SOSPOI*)centerPOI Success:(void (^)(NSArray <NNDealers *>* dealerList))success Failure:(void (^)(void))failure		{
    [SOSDealerTool requestDealerListWithCenterPOI:centerPOI Brand:SOSDealerBrandType_Void Success:success Failure:failure];
}

+ (void)requestDealerListWithCenterPOI:(SOSPOI*)centerPOI Brand:(SOSDealerBrandType)brandType Success:(void (^)(NSArray <NNDealers *>* dealerList))success Failure:(void (^)(void))failure       {
    SOSVehicle *vehicle = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle;
    NSString *vin = vehicle.vin ? vehicle.vin : @"";
    if (brandType == SOSDealerBrandType_Void) 	brandType = [SOSDealerTool getBrandTypeForCurrentUser];
    
    NSString *brand = [SOSDealerTool transformIntoBrandNameWithBrandType:brandType];
    NSString *url = [BASE_URL stringByAppendingFormat:DEALER_NEARBY_LIST];
    NSDictionary *d = @{ @"dealerBrand":brand,
                         @"dealerType":@"AFTER_SALE",
                         @"vin":vin,
                         @"longitude":centerPOI.longitude,
                         @"latitude":centerPOI.latitude};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSMutableArray *datas = [NSMutableArray array];
        if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
            NSDictionary *resDic = [responseStr mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSArray *recommendArray = resDic[@"recommendDealer"];
                if ([recommendArray isKindOfClass:[NSArray class]] && recommendArray.count) {
                    for (NSDictionary *dic in recommendArray) {
                        NNDealers *dealer = [NNDealers mj_objectWithKeyValues:dic];
                        dealer.isRecommendDealer = YES;
                        [datas addObject:dealer];
                    }
                }
                NSArray *nearbyArray = resDic[@"nearbyDealer"];
                if ([nearbyArray isKindOfClass:[NSArray class]] && nearbyArray.count) {
                    for (NSDictionary *dic in nearbyArray) {
                        NNDealers *dealer = [NNDealers mj_objectWithKeyValues:dic];
                        [datas addObject:dealer];
                    }
                }
            }
        }
        if (success)	success(datas);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"获取周边经销商列表失败"];
        if (failure)	failure();
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

+ (void)getPreferredDealerWithCenterPOI:(SOSPOI*)centerPOI Success:(void (^)(NNDealers *dealer))success Failure:(void (^)(void))failure {
    // 排除访客
    if ([SOSCheckRoleUtil isVisitor]) {
        if (success)	success(nil);
        return;
    }
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_PREFERRED_DEALER_DEALER];
    
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionary];
    paraDic[@"vin"] = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    paraDic[@"longitude"] = NONil(centerPOI.longitude);
    paraDic[@"latitude"] = NONil(centerPOI.latitude);
    SOSNetworkOperation* operation = [SOSNetworkOperation requestWithURL:url params:paraDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSDictionary *resDic = [responseStr mj_JSONObject];
                if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                    NNDealers *dealer = [NNDealers mj_objectWithKeyValues:resDic];
                    if (dealer.isPreferredDealer.boolValue && dealer.dealerName.length && dealer.address.length) {
                        if (success)    success(dealer);
                        return;
                    }
                }
            }
            if (success)    success(nil);
            return;
        }
        if (failure) 	failure();
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
        if (failure)     failure();
    }];
    [operation setHttpMethod:@"POST"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
    
}
@end

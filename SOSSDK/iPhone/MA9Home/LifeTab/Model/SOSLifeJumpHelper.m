//
//  SOSLifeJumpHelper.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeJumpHelper.h"
#import "SOSLifeJumpHeader.h"
#import "SOSNavigateTool.h"
#import "SOSProtocolVC.h"
#if __has_include(<CheLunQueryOutSDK/CLQuery.h>)
#import "CheLunQueryOutSDK/CLQuery.h"
#endif
#import "SOSVehicleInfoUtil.h"
#define KEDriveSignInfoKEY	@"KEDriveSignInfoKEY"
#define SelectorValue(SEL) [NSValue valueWithPointer:SEL]

@interface SOSLifeJumpHelper ()
@property (strong, nonatomic) NSDictionary<NSString *, NSValue *> *reflects;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *funcIds;

@end

@implementation SOSLifeJumpHelper

- (instancetype)initWithFromViewController:(__kindof UIViewController *)fromViewController {
    if (self = [super init]) {
        _fromViewController = fromViewController;
        _reflects = @{
                      @"智能互联": SelectorValue(@selector(jumpToSmartHome)),
                      @"分秒律师": SelectorValue(@selector(jumpToiLawPageWithBannerDic:)),
                      @"优惠加油":SelectorValue(@selector(jumpToOilMapVC)),
                      @"e代驾": SelectorValue(@selector(jumpToEDrive:)),
                      @"车主俱乐部": SelectorValue(@selector(jumpToOwnerClub)),
                      @"违章查办": SelectorValue(@selector(jumpToIllegalDriveAsk:)),
                      @"险贷检提醒": SelectorValue(@selector(jumpToCarSecretary)),
                      @"随星听": SelectorValue(@selector(jumpToMusic)),
//                      @"出行保障": SelectorValue(@selector(jumpToTravelSafeguard:)),
                      @"车检": SelectorValue(@selector(jumpToVehicleInspection)),
//                      @"有声书": SelectorValue(@selector(jumpToVoiceBook:)),
                      @"保养建议": SelectorValue(@selector(jumpToMaintainAdvice)),
                      @"安悦扫码充电": SelectorValue(@selector(jumpToScanCharge)),
                      @"安吉星公益": SelectorValue(@selector(jumpToOnstarPublicService:)),
                      @"爱车评估": SelectorValue(@selector(jumpToVehicleReport)),
                      
                      @"换证": SelectorValue(@selector(jumpToUpdateDriveLicence)),
                      @"星友圈": SelectorValue(@selector(jumpToIMHomePage))
                       };
        _funcIds = @{
                     @"智能互联": UF_ONSTARLINK,
                     @"分秒律师": @"",
                     @"优惠加油": @"",
                     @"e代驾": @"",
                     @"车主俱乐部": [Util vehicleIsCadillac] ? UF_JOYLIFE_CLUB_CADILLAC : ([Util vehicleIsChevrolet] ? UF_JOYLIFE_CLUB_CHEVROLET : @""),
                     @"违章查询": UF_VIOLATION_SEARCH,
                     @"险贷检提醒": UF_RISKCHECK,
                     @"随星听": UF_MUSIC,
                     @"出行保障": UF_TRAVELSECURE,
                     @"车检": UF_INSPECTION,
                     @"有声书": UF_BOOKSOUND,
                     @"保养建议": UF_MAINTENANCE,
                     @"安悦扫码充电": UF_JOYLIFE,
                     @"安吉星公益": UF_COMMONWEAL,
                     @"爱车评估": UF_CARVALUATIONCARD,
                     @"星推荐": UF_RECOMMENDATION,
                     @"换证": UF_DRIVELICENSE,
                     @"星友圈": LIFE_SOCIAL
                     };

    }
    return self;
}

- (void)jumpTo:(NSString *)title para:(id)para {
    NSString *funcId = _funcIds[title];
    if (funcId.length > 0) {
        [SOSDaapManager sendActionInfo:funcId];
    }
    if ([para isKindOfClass:NNBanner.class]) {
        NNBanner *banner = (NNBanner *)para;
        if ([title isEqualToString:@"e代驾"]) {
            [self jumpToEDrive:banner];
            return;
        }
        if (banner.showType.integerValue == 3) {
            [self pushH5WebView:banner];
            return;
        }
    }
    SEL selector = _reflects[title].pointerValue;
    if (!selector) {
        return;
    }
    SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:para]);
    
}

- (void)jumpToOilMapVC	{
    [SOSNavigateTool showAroundOilStationWithCenterPOI:nil FromVC:_fromViewController];
}

- (void)jumpToEDrive:(NNBanner *)bannerInfo	{
    [SOSDaapManager sendActionInfo:Uf_Edriver];
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        
        NSDictionary *sourceDic = UserDefaults_Get_Object(KEDriveSignInfoKEY);
        NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        NSNumber *signFlag = sourceDic[idpid];
        if (signFlag && signFlag.boolValue == YES) {
            [self pushH5WebView:bannerInfo NeedCheckAuth:NO];
            return;
        }
        NSMutableDictionary *signInfoDic = [NSMutableDictionary dictionaryWithDictionary:sourceDic];
        
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"免责声明" message:@"本服务由e代驾提供，相关服务和责任由该第三方承担。" customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
            [SOSDaapManager sendActionInfo:Uf_Edriver_Disclaimer_Cancel];
        }];
        SOSAlertAction *ensureAction = [SOSAlertAction actionWithTitle:@"立即前往" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
            [SOSDaapManager sendActionInfo:Uf_Edriver_Disclaimer_Yes];
            signInfoDic[idpid] = @(YES);
            UserDefaults_Set_Object(signInfoDic, KEDriveSignInfoKEY);
            [self pushH5WebView:bannerInfo NeedCheckAuth:NO];
        }];
        [vc addActions:@[cancelAction, ensureAction]];
        [vc show];
    }];
}

- (void)jumpToiLawPageWithBannerDic:(NSDictionary *)bannerDic		{
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        [Util showHUD];
        if ([SOSAgreement didLocalSignedAgreement:LAW_RATE_WEB_DISCLAIMER]) {
            [self requestiLawInfo];
        }	else	{
            [SOSAgreement requestAgreementsWhichNeedSignWithTypes:@[agreementName(LAW_RATE_WEB_DISCLAIMER)] success:^(NSDictionary *response) {
                if (response.count) {
                    [Util dismissHUD];
                    NSDictionary *dic = response[@[agreementName(LAW_RATE_WEB_DISCLAIMER)][0]];
                    if ([dic isKindOfClass:[NSDictionary class]] && dic.count) {
                        SOSAgreement *agreeMent = [SOSAgreement mj_objectWithKeyValues:dic];
                        SOSProtocolVC *vc = [SOSProtocolVC initWithTitle:agreeMent.docTitle AgreeTitle:@"立即前往" CancelTitle:@"取消" AgreementType:LAW_RATE_WEB_DISCLAIMER CompleteHanlder:^(BOOL agreeStatus) {
                            if (agreeStatus) {
                                [Util showHUD];
                                [self requestiLawInfo];
                            }
                        }];
                        [vc show];
                        
                    }
                }	else	{
                    // 返回空列表, 说明用户已签过该协议
                    [SOSAgreement localSignAgreement:LAW_RATE_WEB_DISCLAIMER];
                    [self requestiLawInfo];
                }
            } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [Util dismissHUD];
                [Util toastWithMessage:@"获取协议状态失败"];
            }];
        }
    }];
}

- (void)requestiLawInfo	{
    // 法率网 获取用户签名
    SOSLoginUserDefaultVehicleVO * userInfo = [CustomerInfo sharedInstance].userBasicInfo;
    NSString *parameters = nil;
    if (userInfo.subscriber.mobilePhone.length) {
        parameters = @{@"idpUserId": userInfo.idpUserId, @"phone": userInfo.subscriber.mobilePhone}.mj_JSONString;
    }    else    parameters = @{@"idpUserId": userInfo.idpUserId}.mj_JSONString;
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:[BASE_URL stringByAppendingString:SOSiLawMessageURL] params:parameters successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        NSDictionary *resDic = [responseStr mj_JSONObject];
        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
            NSString *code = resDic[@"code"];
            if ([code isEqualToString:@"E0000"]) {
                NSDictionary *dataDic = resDic[@"data"];
                if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
                    NSString *finalURL = dataDic[@"encrypt"];
                    
                    SOSWebViewController *pushedCon = [[SOSWebViewController alloc] initWithUrl:finalURL];
                    [self pushToViewController:pushedCon];
                }
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        [Util toastWithMessage:@"获取用户信息失败"];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

- (void)jumpToSmartHome {
 
#ifndef SOSSDK_SDK
    [SOSDaapManager sendActionInfo:JoyLife_Smarthome];
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        SOSSmartHomeEntranceViewController *pushedCon = [[SOSSmartHomeEntranceViewController alloc] init];
        [SOSCardUtil routerToVc:pushedCon checkAuth:NO checkLogin:YES];
    }];
#endif
}

- (void)jumpToOwnerClub {
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        NSString *reportString;
        NSString *clubUrl;
        //雪佛兰
        if ([Util vehicleIsChevrolet]) {
            clubUrl = ChevroletClubURL;
            reportString = UF_JOYLIFE_CLUB_CHEVROLET;
//            [Util toastWithMessage:@"功能升级中，敬请期待"];
//            return;
        }else if ([Util vehicleIsCadillac]) {
            //凯迪拉克
            clubUrl = CadillacClubURL;
            reportString = UF_JOYLIFE_CLUB_CADILLAC;
        }
        [SOSDaapManager sendActionInfo:reportString];
        SOSWebViewController *pushedCon = [[SOSWebViewController alloc] initWithUrl:clubUrl];
        [self pushToViewController:pushedCon];
    }];

}
- (void)initIllleagalDriveSDK {
    SEL selsdk = sel_registerName("initSDK");
    if ([[_fromViewController.navigationController.viewControllers objectAtIndex:0] respondsToSelector:selsdk]) {
        [[_fromViewController.navigationController.viewControllers objectAtIndex:0] performSelector:selsdk];
    }
}
- (void)jumpToIllegalDriveAsk:(NNBanner *)banner {
#ifndef SOSSDK_SDK
    @weakify(self);
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        @strongify(self)
        [self initIllleagalDriveSDK];
        if (![SOSCheckRoleUtil isOwner]) {
            [self chelunViewWithVehicleInfo:[NNVehicleInfoModel new]];
        }else{
            [Util showHUD];
//            if ([SOSAgreement didLocalSignedAgreement:ONSTAR_CONTENTINFO_PS]) {
//                [self requestVehicleInfoForIllegalDrive];
//            }    else    {
                [SOSAgreement requestAgreementsWhichNeedSignWithTypes:@[agreementName(ONSTAR_CONTENTINFO_PS)] success:^(NSDictionary *response) {
                    if (response.count) {
                        [Util dismissHUD];
                        NSDictionary *dic = response[@[agreementName(ONSTAR_CONTENTINFO_PS)][0]];
                        if ([dic isKindOfClass:[NSDictionary class]] && dic.count) {
                            SOSAgreement *agreeMent = [SOSAgreement mj_objectWithKeyValues:dic];
                            SOSProtocolVC *vc = [SOSProtocolVC initWithTitle:agreeMent.docTitle AgreeTitle:@"允许" CancelTitle:@"不允许" AgreementType:ONSTAR_CONTENTINFO_PS CompleteHanlder:^(BOOL agreeStatus) {
                                if (agreeStatus) {
                                    [Util showHUD];
                                    [self requestVehicleInfoForIllegalDrive];
                                }else{
                                    [self chelunViewWithVehicleInfo:[NNVehicleInfoModel new]];
                                }
                            }];
                            [vc.customView setHeight:100];
                            [vc show];
                        }
                    }    else    {
                        // 返回空列表, 说明用户已签过该协议
//                        [SOSAgreement localSignAgreement:ONSTAR_CONTENTINFO_PS];
                        [self requestVehicleInfoForIllegalDrive];
                    }
                } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    [Util dismissHUD];
                    [Util toastWithMessage:@"获取协议状态失败"];
                }];
//            }
        }
    }];
#endif
}
- (void)requestVehicleInfoForIllegalDrive    {
    #ifndef SOSSDK_SDK
    @weakify(self);
    [SOSVehicleInfoUtil requestVehicleEngineNumberComplete:^(NNVehicleInfoModel *vehicleModel) {
//        @strongify(self)
        if (vehicleModel ) {
            [Util dismissHUD];
            [self chelunViewWithVehicleInfo:vehicleModel];
        }else{
            [Util dismissHUD];
            [Util toastWithMessage:@"获取用户信息失败"];
        }
    }];
#endif
}
-(void)chelunViewWithVehicleInfo:(NNVehicleInfoModel *)vehicleInfo{
#ifndef SOSSDK_SDK
    NSString * vinStr = NONil(vehicleInfo.vin);
        NSDictionary * vd = @{@"vin":vinStr ,@"licensePlate":NONil(vehicleInfo.licensePlate),@"engineNumber":NONil(vehicleInfo.engineNumber)};
        UIViewController *controller =  [[CLQuery sharedInstance] pushController:[vd mj_JSONString]];
        [self pushToViewController:controller];

#endif
}
- (void)jumpToCarSecretary {
    [SOSDaapManager sendActionInfo:My_profile_VehicleAssistant];
    SOSCarSecretaryViewController *vc = [SOSCarSecretaryViewController new];
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];

//    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:_fromViewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
//        SOSCarSecretaryViewController *vc = [SOSCarSecretaryViewController new];
//        [self pushToViewController:vc];
//    }];
}

- (void)jumpToMusic {
#ifndef SOSSDK_SDK
    [[SOSMusicPlayer sharedInstance] pushToMusicHomePageFrom:_fromViewController];
#endif
}

- (void)jumpToTravelSafeguard:(NNBanner *)banner {
    [self pushH5WebView:banner];
}

- (void)jumpToVehicleInspection {
    OwnerLifeVehicleDetectionController *vc = [[OwnerLifeVehicleDetectionController alloc] init];
    vc.backRecordFunctionID = Inspection_back;
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];
}

- (void)jumpToVoiceBook:(NNBanner *)banner {
    [self pushH5WebView:banner];
}

- (void)jumpToMaintainAdvice {
    CarStatusDetailViewController *statusViewController = [[CarStatusDetailViewController alloc] initWithNibName:@"CarStatusDetailViewController" bundle:nil];
    statusViewController.gasStatus = [SOSVehicleVariousStatus gasStatus];
    statusViewController.oilStatus = [SOSVehicleVariousStatus oilStatus];
    statusViewController.pressureStatus = [SOSVehicleVariousStatus tirePressureStatus];
    statusViewController.mileage = [[CustomerInfo sharedInstance].oDoMeter floatValue];
    statusViewController.batteryStatus = [SOSVehicleVariousStatus batteryStatus];
    [SOSCardUtil routerToVc:statusViewController checkAuth:YES checkLogin:YES];
}

- (void)jumpToScanCharge {
    [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Banner];
    [SOSAYChargeManager enterAYChargeVCIsFromCarLife:YES];
}

- (void)jumpToOnstarPublicService:(NNBanner *)banner {
    [self pushH5WebView:banner];
}

- (void)jumpToVehicleReport {
    [SOSCardUtil routerToCarReportH5];
}

- (void)jumpToUpdateDriveLicence {
    OwnerLifeRenewalController *vc = [[OwnerLifeRenewalController alloc] init];
    vc.backRecordFunctionID = DriveLicense_back;
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];
}

- (void)jumpToIMHomePage {
#ifndef SOSSDK_SDK
    [[SOSIMLoginManager sharedManager] pushToIMHomePageFrom:_fromViewController];
#endif
}

#pragma mark - Private

- (void)pushToViewController:(__kindof UIViewController *)viewController {
    if (_fromViewController.navigationController) {
        [_fromViewController.navigationController pushViewController:viewController animated:YES];
    }	else 	{
        [_fromViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)pushH5WebView:(NNBanner *)banner	{
    [self pushH5WebView:banner NeedCheckAuth:YES];
}

- (void)pushH5WebView:(NNBanner *)banner NeedCheckAuth:(BOOL)checkAuth 	{
    SOSWebViewController *web = [SOSUtil generateBannerClickController:banner];
    //道路救援 report
    if ([banner.title isEqualToString:@"道路救援"]) {
        web.backRecordFunctionID = RoadsideService_back;
    }
    //违章 report
    else if ([banner.title isEqualToString:@"违章查询"]) {
        web.backRecordFunctionID = Violation_back;
        [SOSDaapManager sendActionInfo:Carbulter_Violationsearch];
    }
    
    [SOSCardUtil routerToVc:web checkAuth:checkAuth checkLogin:YES];
}

-(void)dealloc{
    NSLog(@"lifeJumpHelper dealloc");
}

@end

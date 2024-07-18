//
//  SOSGreetingUtil.m
//  Onstar
//
//  Created by lmd on 2017/9/29.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSGreetingManager.h"
#import "FootPrintDataOBJ.h"
#import "NSString+Category.h"
//#ifdef SOSSDK_SDK
//#import "FlutterBoost.h"
//#else
//#import <flutter_boost/FlutterBoost.h>
//#endif
//#import "PlatformRouterImp.h"

enum SOS_FLUTTER_LOGIN_STATE {
  SOS_FLUTTER_LOGIN_STATE_NON, //未登录

//第一步
  /// 加载token中
  SOS_FLUTTER_LOGIN_STATE_LOADINGTOKEN,

  /// 加载token完成
  SOS_FLUTTER_LOGIN_STATE_LOADINGTOKENSUCCESS,

  /// 加载token失败
  SOS_FLUTTER_LOGIN_STATE_LOADINGTOKENFAIL,

//第二步
  /// 加载用户基本数据中
  SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFO,

  /// 加载用户基本数据成功
  SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS,

  /// 加载用户基本数据失败
  SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFOFAIL,

//第三步
  /// 加载车辆Commands中
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDS,

  /// 加载车辆Commands成功
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS,

  /// 加载车辆Commands失败
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL,

//第四步
  /// 加载车辆信息和权限中
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGE,

  /// 加载车辆信息和权限成功
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS,

  /// 加载车辆信息和权限失败
  SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL,
};


@implementation SOSGreetingModel

@end


@implementation SOSGreetingManager


//+ (void)load {
//    [SOSGreetingManager shareInstance];
//}

+ (instancetype)shareInstance     {
    static dispatch_once_t onceToken;
    static SOSGreetingManager *manager = nil;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver];
//#ifdef TEST
//        self.flutterEnable = NO;
//#else
//        self.flutterEnable = YES;
//#endif
//        if (UserDefaults_Get_Bool(@"flutterEnable")) {
//            self.flutterEnable = YES;
//            UserDefaults_Set_Bool(NO, @"flutterEnable");
//        }else{
//            UserDefaults_Set_Bool(YES, @"flutterEnable");
//        }
        
    }
    return self;
}

- (void)addObserver {
    @weakify(self)
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil] subscribeNext:^(id x) {
//        @strongify(self)
        [self didFinishLanuch];
   // }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_IAP_BUY_4GPACKAGE object:nil] subscribeNext:^(id x) {
        @strongify(self)
        self.flowData = nil;
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_IAP_BUY_4GPACKAGE object:nil] subscribeNext:^(id x) {
        @strongify(self)
        self.packageData = nil;
    }];
}

- (void)setVehicleStatus:(RemoteControlStatus)vehicleStatus {
    _vehicleStatus = vehicleStatus;
}

- (void)didFinishLanuch {
    @weakify(self)
    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (x.integerValue == LOGIN_STATE_LOADINGTOKEN ) {
                  self.roleGreeting = @YES;
            }else if(x.integerValue == LOGIN_STATE_LOADINGTOKENFAIL || x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOFAIL){
                self.roleGreeting = @NO;
            }else if (x.integerValue == LOGIN_STATE_NON || x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                [self refreshGreetingIgnoreMemory:NO];
                if (x.integerValue == LOGIN_STATE_NON ) {
                    self.vehicleStatus = RemoteControlStatus_Void;
                }
            }else{
    //             self.roleGreeting = @NO;
    //             self.vehicleStatus = RemoteControlStatus_Void;
            }
        });
 
    }];
    
//    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [PlatformRouterImp sendEventToFlutter:@"ChannelEventLoginStatusChange" arguments:@{@"loginState":@([self covertToFlutterState:x])} result:nil];
//            if (x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
//                [self refreshPackageIfNeeded];
////                if (self.isFlutterChangeVehicle) {
////                    //刷新车辆设置
////                    [FlutterBoostPlugin.sharedInstance sendEvent:@"vehicleSettingRefresh" arguments:nil];
//////                    [PlatformRouterImp sendEventToFlutter:@"vehicleSettingRefresh" arguments:nil result:nil];
////                    //发送切车成功通知
////                    [[NSNotificationCenter defaultCenter] postNotificationName:SOSkSwitchVehicleSuccess object:nil];
////                    self.isFlutterChangeVehicle = NO;
////                }
//            }else if(x.integerValue == LOGIN_STATE_NON || x.integerValue == LOGIN_STATE_LOADINGTOKEN){
//                self.flowData = nil;
//                self.packageData = nil;
//                self.packageRemainDays = nil;
//            }
//        });
//    }];
}

- (NSInteger)covertToFlutterState:(NSNumber *)loginState {
    switch (loginState.intValue) {
        case LOGIN_STATE_NON:
            return SOS_FLUTTER_LOGIN_STATE_NON;
            break;
        case LOGIN_STATE_LOADINGTOKEN:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGTOKEN;
        break;
        case LOGIN_STATE_LOADINGTOKENSUCCESS:
            return SOS_FLUTTER_LOGIN_STATE_LOADINGTOKENSUCCESS;
            break;
        case LOGIN_STATE_LOADINGTOKENFAIL:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGTOKENFAIL;
        break;
        case LOGIN_STATE_LOADINGUSERBASICINFO:
            return SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFO;
            break;
        case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS;
        break;
        case LOGIN_STATE_LOADINGUSERBASICINFOFAIL:
            return SOS_FLUTTER_LOGIN_STATE_LOADINGUSERBASICINFOFAIL;
            break;
        case LOGIN_STATE_LOADINGVEHICLECOMMANDS:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDS;
        break;
        case LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS;
        break;
        case LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL;
        break;
        case LOGIN_STATE_LOADINGVEHICLEPRIVILIGE:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGE;
        break;
        case LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS;
        break;
        case LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL:
        return SOS_FLUTTER_LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL;
        break;
            
        default:
            break;
    }
    return SOS_FLUTTER_LOGIN_STATE_NON;
}


- (void)refreshPackageIfNeeded
{
    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
        //gen10 请求流量包
        [self refresh4GPackageIgnoreMemory:YES];
        //请求套餐包
        [self refreshOnstarPackageIgnoreMemory:YES];
        
    }
}
+ (NSString *)role {
    NSString *role = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role;
    if (role.isNotBlank) {
        return role.uppercaseString;
    }
    return @"UNLOGIN";
}

+ (void)getGreetingSuccess:(void (^)(id urlRequest))completion
                      Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    //找缓存 比对时间
    NSDictionary *cache = [[SOSGreetingCache shareInstance] getGreetingWithRole:[SOSGreetingManager role]];
    //1.命中 回调返回
    if (cache) {
        if (completion) {
            completion(cache);
        }
        return;
    }
    //2.未命中 清空并继续请求
    
    if ([[self role] isEqualToString:@"UNLOGIN"]) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:URL_Greeting, [self role]];
    url = [NSString stringWithFormat:@"%@%@", BASE_URL, url];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSDictionary *dic = [responseStr mj_JSONObject];
            if (dic) {
                [[SOSGreetingCache shareInstance] cacheGreeting:responseStr role:[self role]];
                if (completion) {
                    completion(dic);
                }
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

- (void)getPackageRemainDaysSuccess:(void (^)(NSString *remainDay))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion	{
    if (self.packageRemainDays && ![self.packageRemainDays isKindOfClass:[NSNumber class]]) {
        if (completion)		completion(self.packageRemainDays);
        return;
    }
    self.packageRemainDays = @(YES);
    NSString *url = [BASE_URL stringByAppendingFormat:Package_GetRemainDays_URL, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if ([returnData isKindOfClass:[NSString class]]) {
            if (completion)		completion(returnData);
            self.packageRemainDays = returnData;
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failCompletion)		failCompletion(responseStr, error);
        self.packageRemainDays = nil;
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
    [sosOperation start];
}

- (void)getPackageListSuccess:(void (^)(NSMutableArray <NNPackagelistarray *> *packageArray))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion	{
    
    if (self.packageData && ![self.packageData isKindOfClass:[NSNumber class]]) {
        if (completion) {
            completion(self.packageData);
        }
        return;
    }
    self.packageData = @YES;
    NSString *url = [BASE_URL stringByAppendingFormat:NEW_PACKAGEINFO_URL_PRE,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSArray *arr = [returnData mj_JSONObject];
        if (!arr || ![arr isKindOfClass:[NSArray class]]) {
            return;
        }
        
        NSMutableArray *packageArray = [NNPackagelistarray mj_objectArrayWithKeyValuesArray:arr];
        if (completion) 	completion(packageArray);
        self.packageData = packageArray;
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failCompletion)		failCompletion(responseStr, error);
        self.packageRemainData = nil;
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
    [sosOperation start];
}



- (void)getDataListSuccess:(void (^)(id urlRequest))completion
                    Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    if (self.flowData && ![self.flowData isKindOfClass:[NSNumber class]]) {
        if (completion) {
            completion(self.flowData);
        }
        return;
    }
    self.flowData = @YES;
//    NSString *url = [BASE_URL stringByAppendingFormat:NEW_PURCHASE_GET_DATA_LIST_URL,[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [BASE_URL stringByAppendingString:NEW_PURCHASE_GET_DATA_LIST_URL];
    url = [NSString stringWithFormat:@"%@?vin=%@",url,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NNGetDataListResponse *response = [NNGetDataListResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:returnData]];
        dispatch_async(dispatch_get_main_queue(), ^{

            if (completion && operation.statusCode == 200) {
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
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
    [sosOperation start];
}

//- (void)getFootMarkData
//{
//    if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
//        return;
//    }
////    if ([LoginManage sharedInstance].loginState != LOGIN_STATE_LOADINGTOKENSUCCESS) {
////        return;
////    }
//    if (![SOSCheckRoleUtil isOwner]) {
//        return;
//    }
//    if ([self.footmarkData isKindOfClass:[NSArray class]]) {
//        return;
//    }
//    @weakify(self);
//    self.footmarkData = @YES;
//    [FootPrintDataOBJ getFootPrintOverViewLoading:NO Success:^(NSArray *dataArray) {
//        @strongify(self);
//        self.footmarkData = dataArray;
//    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        @strongify(self);
//        self.footmarkData = @NO;
//    }];
//    [SOSDaapManager sendActionInfo:Startrip_refreshmyfootprints];
//}



#pragma mark 业务
- (SOSGreetingModel *)getGreetingModelWithType:(SOSGreetingType)type {
    //判断角色
    //判断哪个头部
    NSDictionary *dic = nil;
    NSString *icon = nil;
    if ([self.roleGreeting isKindOfClass:[NSDictionary class]]) {
        if (type == SOSGreetingTypeVehicle) {
            if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
                BOOL isgen9 = [Util vehicleIsG9];
                BOOL isExpired = [CustomerInfo sharedInstance].isExpired;

                SOSVehicleStatus vehicleStatus = [Util updateVehicleStatus];
                if (isgen9) {
                    //gen9
                    //套餐  车况
                    if (isExpired) {
                        if (vehicleStatus == SOSVehicleStatusBad) {
                            dic = self.roleGreeting[@"NOPACKAGESTATUSBADGEN9"];
                        }else if (vehicleStatus == SOSVehicleStatusBetter) {
                            dic = self.roleGreeting[@"NOPACKAGESTATUSNORMALGEN9"];
                        }else if (vehicleStatus == SOSVehicleStatusBest){
                            dic = self.roleGreeting[@"NOPACKAGESTATUSFINEGEN9"];
                        }else {
                            dic = self.roleGreeting[@"NOPACKAGEDATA"];
                        }
                    }else {
                        if (vehicleStatus == SOSVehicleStatusBad) {
                            dic = self.roleGreeting[@"PACKAGESTATUSBADGEN9"];
                        }else if (vehicleStatus == SOSVehicleStatusBetter) {
                            dic = self.roleGreeting[@"PACKAGESTATUSNORMALGEN9"];
                        }else if (vehicleStatus == SOSVehicleStatusBest){
                            dic = self.roleGreeting[@"PACKAGESTATUSFINEGEN9"];
                        }else {
                            dic = self.roleGreeting[@"GETPACKAGEDATAERROR"];
                        }
                    }
                }else {
                    //gen10
                    //套餐  流量到期
                    //                if (![resp isKindOfClass:[NNGetDataListResponse class]]) {
                    //                    dic = self.roleGreeting[@"GETPACKAGEDATAERROR"];
                    //                }else {
                    NNGetDataListResponse *resp = self.flowData;
                    if ([resp isEqual:@NO] || [self.packageData isEqual:@NO]) {
                        dic = self.roleGreeting[@"GETPACKAGEDATAERROR"];
                    }else if ([resp isKindOfClass:[NNGetDataListResponse class]] && [self.packageData isKindOfClass:[NNGetPackageListResponse class]]){
                        BOOL packageExpired = ([resp.currentRemainUsage length] == 0 || [resp.currentRemainUsage doubleValue]== 0.0);
                        if (isExpired && packageExpired) {//过期 没流量
                            dic = self.roleGreeting[@"ALLPACKAGEEXPIREDGEN10"];
                        }else if (!isExpired && packageExpired) {//未过期 没流量
                            dic = self.roleGreeting[@"DATAPACKAGEEXPIREDGEN10"];
                        }else if (isExpired && !packageExpired) {
                            dic = self.roleGreeting[@"COREPACKAGEEXPIREDGEN10"];
                        }else if (!isExpired && !packageExpired){
                            dic = self.roleGreeting[@"ALLPACKAGEFINEGEN10"];
                        }
                        
                    }
                }
            }
            else {
                dic = self.roleGreeting[@"NOPACKAGEDATA"];
            }

        }else if (type == SOSGreetingTypeStarTravel) {
            
            NSString *key = [[NSDate date] stringWithFormat:@"MM-dd"];
            //节日
            dic = self.roleGreeting[key];
            if (!dic) {
                if ([self isWeekend]) {//周末
                    dic = self.roleGreeting[@"WEEKEND"];
                }else {//工作日
                    dic = self.roleGreeting[@"WORKINGDAY"];
                }
            }
            
        }else if (type == SOSGreetingTypeLife){//悦生活
            if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKENSUCCESS) {
                dic = self.roleGreeting[@"HASEVENTDATA"];
            }
            if (!dic) {
                dic = self.roleGreeting[@"NOEVENTDATA"];
            }
        }else if (type == SOSGreetingTypeVehicleInfo) {//车辆信息
            if ([Util vehicleIsBuick]) {
                dic = self.roleGreeting[@"VEHINFOBUICK"];
            }else if ([Util vehicleIsCadillac]) {
                dic = self.roleGreeting[@"VEHINFOCADILLAC"];
            }else if ([Util vehicleIsChevrolet]) {
                dic = self.roleGreeting[@"VEHINFOCHEVROLET"];
            }else {
                dic = self.roleGreeting[@"GETVEHINFODATAERROR"];
            }
        }else if (type == SOSGreetingTypeVehicleCondition) {//车况
            SOSVehicleConditionCategory vehicleStatus = [Util updateVehicleConditionCategory];
//            VehicleConditionFine    = 0,        //车况优秀
//            VehicleConditionNormal,             //车况正常
//            TirePressureBad,                    //胎压红色告警
//            FuelNotEnough,                      //燃油红色告警
//            OilNotEnough,                       //机油红色告警
//            BatteryNotEnough,                   //电池红色告警
//            MoreThanOneBad,                     //2项及以上差
//            NoVehicleConditionData,             //无车况数据
//            VehicleConditionAbnormal,            //车况数据异常
//            TirePressureLow,                    //胎压黄色告警,,
//            FuelLow,                            //燃油黄色告警,,
//            OilLow,                             //机油黄色告警,,
//            BatteryLow,                         //电池黄色告警,,
//            CHARGINGABORTED,                    //充电中断,,
//            CHARGING,                           //充电中,,
//            STATECHARGINGCOMPLETE,              //已充满,,
//            BRAKEPADSNOTENOUGH,     //刹车片寿命即将耗尽
//            BRAKEPADSLOW,       //刹车片磨损严重
            
            NSArray *greetingArray =
            @[
                @{
                  @"title":@"VEHSTATUSFINE",
                  @"icon":[NSString appendCdSuff:@"Icon／22x22／OnStar_icon_fail_22x22"]
                    },
                @{
                    @"title":@"",
                    @"icon":@""
                    },
                @{
                    @"title":@"TIERPRESUREBAD",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"FUELNOTENOUGH",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"OILNOTENOUGH",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"BETTERYNOTENOUGH",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"MORETHAN1BAD",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"NOVEHSTATUSDATA",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-2"
                    },
                @{
                    @"title":@"",
                    @"icon":@""
                    },
                @{
                    @"title":@"TIERPRESURELOW",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-3"
                    },
                @{
                    @"title":@"FUELLOW",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-3"
                    },
                @{
                    @"title":@"OILLOW",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-3"
                    },
                @{
                    @"title":@"VEHBETTERYLOW",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-3"
                    },
                @{
                    @"title":@"CHARGINGABORTED",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                    },
                @{
                    @"title":@"CHARGING",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-4"
                    },
                @{
                    @"title":@"STATECHARGINGCOMPLETE",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-5"
                    },
                @{
                    @"title" : @"BRAKEPADSNOTENOUGH",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-3"
                },
                @{
                    @"title" : @"BRAKEPADSLOW",
                    @"icon":@"Icon／22x22／OnStar_icon_fail_22x22-1"
                }
                
  ];
            NSDictionary *keyDic = greetingArray[vehicleStatus];
            dic = self.roleGreeting[keyDic[@"title"]];
            icon = keyDic[@"icon"];
  
        }
    }
    
    SOSGreetingModel *model = [SOSGreetingModel mj_objectWithKeyValues:dic];
    if (!model) {
        model = [SOSGreetingModel new];
        model.greetings = @"未获取到数据!";
        model.subGreetings = @"再刷新试试";
        model.linkText = @"";
    }
    
    if (icon) {
        model.icon = icon;
    }
    if ([model.target isEqualToString:@"SMARTDRIVEHOME"]) {
        
        if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
            if ([Util vehicleIsG9] ||  [Util vehicleIsPHEV]) {
                //对GEN9功能不支持的车型，对于车主/司机/代理身份登陆，隐藏驾驶评分及油耗排名功能/能耗
                //是Gen10 PHEV车主隐藏驾驶行为评分
                model.target = @"";
                model.linkText = @"";
                model.target = @"";
            }
            
        }
    }
    
    //funcId
    switch (type) {
        case SOSGreetingTypeVehicle:
            model.funcId = SmartvehicleTT;
            break;
        case SOSGreetingTypeStarTravel:
            model.funcId = StarTravelTT;
            break;
        case SOSGreetingTypeLife:
            model.funcId = JoylifeTT;
            break;
        case SOSGreetingTypeVehicleCondition:
            model.funcId = CarconditionsTT;
            break;
        case SOSGreetingTypeVehicleInfo:
            model.funcId = CarInfoTT;
            break;
        case SOSGreetingTypeFootmark:
            model.funcId = FootprintTT;
            break;
        default:
            break;
    }
    
    return model;
}

- (BOOL)isWeekend {
    return [NSDate date].weekday == 1 || [NSDate date].weekday == 7;
}



#pragma mark refresh
/**
 强制刷新问候语
 */
- (void)refreshGreeting {
    [self refreshGreetingIgnoreMemory:YES];
}

- (void)refreshGreetingIgnoreMemory:(BOOL)ignoreMemory {
    if (ignoreMemory) {
        [[SOSGreetingCache shareInstance] removeGreetingCacheWithRole:[SOSGreetingManager role]];
    }
//    SOSFlutterVehicleConditionEnable({
//        [PlatformRouterImp sendEventToFlutter:CHANNELEVENT_REFRESHGREETING arguments:nil result:^(id  _Nullable result) {
//
//        }];
//    }, {
        self.roleGreeting = @YES;
        [SOSGreetingManager getGreetingSuccess:^(id urlRequest) {
            //加载至内存
            dispatch_async(dispatch_get_main_queue(), ^{
                self.roleGreeting = urlRequest;
            });
        } Failed:^(NSString *responseStr, NSError *error) {
            dispatch_async_on_main_queue(^{
                self.roleGreeting = @NO;
            });

        }];
//    });
}


/**
 刷新安吉星套餐包信息
 */
- (void)refreshOnstarPackageIgnoreMemory:(BOOL)ignoreMemory {
    if (ignoreMemory) {
        self.packageData = nil;
    }
    //请求套餐包
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        self.packageData = nil;
    }else{
        [self getPackageListSuccess:^(id urlRequest) {
            self.packageData = urlRequest;
        } Failed:^(NSString *responseStr, NSError *error) {
            self.packageData = @NO;
        }];
    }
}

/**
 刷新4G套餐包信息
 */
- (void)refresh4GPackageIgnoreMemory:(BOOL)ignoreMemory {
    if (ignoreMemory) {
        self.flowData = nil;
    }
    //gen10 请求流量包
    if (![Util vehicleIsG9]) {
        [self getDataListSuccess:^(id urlRequest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.flowData = urlRequest;
            });
        } Failed:^(NSString *responseStr, NSError *error) {
            dispatch_async_on_main_queue(^{
                self.flowData = @NO;
            });
        }];
    }else {
        self.flowData = nil;
    }
}


/**
 刷新首页头部问候语(包含 问候语接口 套餐包接口 gen10(4g流量包接口))
 note:不刷新车况,车况需调用刷车况接口
 */
- (void)refreshGreetingAndPackages {
    [self refreshGreeting];
    [self refreshPackageIfNeeded];
}

- (void)clearCardCache:(NSString *)cardName;
{
    [[SOSGreetingCache shareInstance] removeCardDataByCardName:cardName idpId:NONil([CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId)];
}
@end












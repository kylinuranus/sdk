//
//  SOStarJourneyUtil.h
//  Onstar
//
//  Created by lmd on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSPackageHeader.h"

@class BLEModel;

@interface SOSCardUtil : NSObject

//内存缓存星享之旅数据
@property (nonatomic, strong) id starResp;
@property (nonatomic, strong) id vehicleCashBookResp;
@property (nonatomic, strong) id myDonateInfo;
@property (nonatomic, strong) id packageResp;//套餐信息(overview,data & onstarpackage)

+ (instancetype)shareInstance ;

+ (NSString *)getUrlStringWithUrl:(NSString *)url dic:(NSDictionary *)dic ;


/// 获取爱车评估信息 ///msp/api/v3/user/evaluate/carconditionreport
/**
 查询vin的用车手账数据
 @param vin 查询的vin
 @param completion
 @param failCompletion 
 */
+ (void)getCarCashBookReport:(NSString  *)vin Success:(void (^)(NNVehicleCashResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// 获取综合油耗排名
+ (void)getOilRank:(NNRankReq *)req Success:(void (^)(NNOilRankResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// 获取综合能耗排名
+ (void)getEnergyRank:(NNRankReq *)req Success:(void (^)(NNEngrgyRankResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// 获取驾驶行为评分
+ (void)getDrivingScore:(NNCarconditionReportReq *)req Success:(void (^)(NNDrivingScoreResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// 获取近期行程
+ (void)getTrailDataSuccess:(void (^)(SOSTrailResp *response))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// 星享之旅
+ (void)getStatTravelSuccess:(void (^)(NNStarTravelResp *urlRequest))completion
                      Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

/// UBI
+ (void)getUBIInfoSuccess:(void (^)(NSDictionary *result))completion
                      Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;


@end


@interface SOSCardUtil ()



/**
 车辆控制
 */
+ (void)routerToRemoteControl;
+ (void)routerToRemoteControl:(id)fromvc;

/**
 跳转地图车辆位置
 */
+ (void)routerToVehicleLocationInMap;
/**
 车况
 */
+ (void)routerToVehicleCondition;

/**
 车况检测报告
 */
+ (void)routerToVehicleDetectionReport;
+ (void)routerToWifiSetting ;
+ (void)routerToOperationHistory ;
+ (void)routerToChargeMode ;
+ (void)routerToOnstarReflect ;
+ (void)routerToDealerRev ;
+ (void)routerToFlueStation ;
+ (void)routerToBackMirror ;
+ (void)routerToRecentJourney;
/**
 从指定Nav进入车况
 @param fromVC
 */
+ (void)routerToVehicleConditionFromPresentVC:(UINavigationController *)fromVC isPresentType:(BOOL)isPresent;

///油耗
+ (void)routerToOilRankH5 ;
+ (void)routerToOilRankH5WithPageBackBlock:(void (^)(void))backBlock;
+ (void)routerToOilRankH5WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID;

///能耗
+ (void)routerToEnergyRankH5;
+ (void)routerToEnergyRankH5WithPageBackBlock:(void (^)(void))backBlock;
+ (void)routerToEnergyRankH5WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID;

///驾驶行为评分
+ (void)routerToDrivingScoreH5;
+ (void)routerToDrivingScoreH5:(id)fromVc;
+ (void)routerToDrivingScoreH5FromVC:(id)fromVc WithPageBackBlock:(void (^)(void))backBlock;
+ (void)routerToDrivingScoreH5FromVC:(id)fromVc WithPageBackBlock:(void (^)(void))backBlock LoadingStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID;
/**
 星享之旅
 */
+ (void)routerToStarTravelH5;
+ (void)routerToStarTravelH5:(NSString *)para;

/**
 爱车课堂
 */
+ (void)routerToVehicleEducationH5;


/**
 爱车评估
 */
+ (void)routerToCarReportH5;

/**
 车辆信息
 */
+ (void)routerToVehicleInfo;

/**
 足迹
 */
+ (void)routerToFootMarkWithPageBackBlock:(void (^)(void))backBlock;

/**
 安星定位
 */
+ (void)routerToOnstarDeviceLocation;
/**
  Vistitor 升级车主
 */
+ (void)routerToUpgradeSubscriber;

/**
 安吉星套餐
 */
+ (void)routerToOnstarPackage;

/**
4G套餐
 */
+ (void)routerTo4GPackage ;

/**
 预付费卡激活
 */
+ (void)routerToPrepaymentCard ;

/**
 用户手册
 */
+ (void)routerToUserManual;

/**
 关于
 */
+ (void)routerToAboutOnstar;
+ (void)callOnstar;
+ (void)carClass;
+ (void)routerToProtocols;


/**
 在线客服
 */
+(void)routerToOnlineService;

/**
 积分公益
 */
+(void)routerToMyDonate;
/**
 购买安吉星套餐
 */
+ (void)routerToBuyOnstarPackage:(PackageType)type ;


/**
 跳转云视频列表

 @param imei 
 */
+ (void)routerToCloudVideoListWithIMEI:(NSString *)imei ;
/**
 跳转h5

 @param url url description
 */
+ (void)routerToH5Url:(NSString *)url;


/**
 转转至蓝牙钥匙页面
 */
+ (void)routerToBleKeyPage;

//用车车辆操作页面
+ (void)gotoBleOperationPage;

//todosdk,无ble隐藏
/**
 转转至BLE车辆操作页面
 */
+ (void)routerToBleOperationPageWithBleModel:(BLEModel *)bleModel;

/**
 跳转至Ble收到的共享
 */
+ (void)routerToUserReceiveBlePage;

/**
 跳转后1S执行某block
 */
+ (void)routerToUserReceiveBlePageBlock:(void(^)(void))complete;


/**
 跳转修改pin码界面,由2个层级界面

 @param disblock
 */
+ (void)routerToPinModificationWithDismissBlock:(void(^)(void))disblock;

/**
 直接跳转pin码修改界面

 */
+(void)routerToPinModificationDirectWay:(void (^)(void))disblock;

////显示xBle协议 只显示
//+(void)showBleAgreement;

/**
 弹出bbwc教育页面

 @param type type description
 */
+ (void)routerToBBwcWithType:(NSString *)type;


/**
 跳转共享我的车页面
 */
+ (void)routerToOwnerBle;

+ (void)routerToChargeStation;


/**
 权限与登录状态判断
 
 @param vc to vc
 @param checkAuth YES:升级车主
 @param checkLogin YES:弹出登录
 */
+ (void)routerToVc:(id)vc checkAuth:(BOOL)checkAuth checkLogin:(BOOL)checkLogin;

+ (void)routerToForegtPassWord:(UIViewController *)parentVC;
+(void)routerToMessageWithCategory:(MessageModel *)model;

+ (void)routerToOnstarShop;

/// 跳转 里程险 免责声明
+ (void)showMileAgeInsuranceStatementVCWithURL:(NSString *)url FromVC:(UIViewController *)fromVC Success:(void (^)(void))success;

@end



//
//  SOSHomeAndCompanyTool.h
//  Onstar
//
//  Created by Coir on 16/3/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KHomeAndCompanyChangedNotification		@"KHomeAndCompanyChangedNotification"

typedef NS_ENUM(NSUInteger, SetHomeAddress_PageType) {
    ///设置家的地址
    pageTypeHome = 1,
    ///设置公司地址
    pageTypeCompany,
    ///设置路线起点
    pageTypeRouteBegin,
//    ///设置智能家居家的地址
//    pageTypeSmartHome,
    ///设置路线终点
    pageTypeRouteDestination,
    ///一键到家
    pageTypeEasyBackHome,
    ///一键到公司
    pageTypeEasyBackCompany
};

@interface SOSHomeAndCompanyTool : NSObject

+ (SOSHomeAndCompanyTool *)sharedInstance;

/// 简化设定 家/公司 类型
+ (SelectPointOperation)simpleTypeWithType:(SelectPointOperation)type;

/// 设置 家/公司 地址(网络请求)
+ (void)setHomeOrCompanyWithPOI:(SOSPOI *)poi  OperationType:(SelectPointOperation)operationType successBlock:(SOSSuccessBlock)successBlock failureBlock:(SOSFailureBlock)failureBlock;

- (void)EasyGoHomeFromVC:(UIViewController *)vc WithType:(SetHomeAddress_PageType)pageType;

- (void)EasyGoHomeFromVC:(UIViewController *)vc WithType:(SetHomeAddress_PageType)pageType needShowWaitingVC:(BOOL)needShowVC needShowToast:(BOOL)needToast;

/// 一键回家/公司 前检查登录状态,账户权限,以及家/公司地址是否存在,存在则返回,否则返回 nil
- (void)checkAuthAndExitsWithType:(SetHomeAddress_PageType)pageType FromVC:(UIViewController *)vc Success:(void (^)(SOSPOI *resultPOI))success Failure:(void (^)(void))failBlock;

/// 设置成功,是否现在发送到车
+ (void)alertSendPOIWithOperationType:(SelectPointOperation)operationType;

/// 跳转设置 家/公司 地址页面
- (void)jumpToSetHomeAddressPageWithType:(SetHomeAddress_PageType)pageType;

@end

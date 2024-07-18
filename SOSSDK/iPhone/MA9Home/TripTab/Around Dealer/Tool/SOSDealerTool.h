//
//  SOSDealerTool.h
//  Onstar
//
//  Created by Coir on 18/12/2017.
//  Copyright © 2017 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 经销商品牌
typedef enum {
    /// 空,占位用
    SOSDealerBrandType_Void = 0,
    /// 别克
    SOSDealerBrandType_Buick = 1,
    /// 凯迪拉克
    SOSDealerBrandType_Cadillac,
    /// 雪佛兰
    SOSDealerBrandType_Chevrolet,
    /// 所有品牌
    SOSDealerBrandType_All,
}   SOSDealerBrandType;

/// 周边经销商 Cell 点击
extern NSString * const KDealerMapVCCellTappedNotify;
/// 首选经销商点击
extern NSString * const KFirstDealerViewTappedNotify;
/// 周边经销商 在地图上显示列表
extern NSString * const KNeedShowDealerListMapNotify;
/// 首选经销商 在地图上显示列表
extern NSString * const KNeedShowFirstDealerMapNotify;
/// 周边经销商更换品牌筛选
extern NSString * const KAroundDealerChangeBrandNotify;
/// 地图页面进入/退出全屏模式
extern NSString * const KMapVCEnterFullscreenNotify;

@interface SOSDealerTool : NSObject

//  获取当前用户车辆品牌
+ (SOSDealerBrandType)getBrandTypeForCurrentUser;

+ (NSString *)transformIntoBrandNameWithBrandType:(SOSDealerBrandType)brandType;

/// 跳转经销商选择页
+ (void)jumpToDealerListMapVCFromVC:(UIViewController *)vc WithPOI:(SOSPOI *)poi isFromTripPage:(BOOL)isFromTrip;

/// 获取周边经销商列表
+ (void)requestDealerListWithCenterPOI:(SOSPOI*)centerPOI Brand:(SOSDealerBrandType)brandType Success:(void (^)(NSArray <NNDealers *>* dealerList))success Failure:(void (^)(void))failure;

/// 获取首选经销商
+ (void)getPreferredDealerWithCenterPOI:(SOSPOI*)centerPOI Success:(void (^)(NNDealers *dealer))success Failure:(void (^)(void))failure;
@end

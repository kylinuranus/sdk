//
//  SelectDealerVC.h
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DealerCityTableV.h"
#import "DealerSubCitysTableV.h"
#import "SOSSearchResult.h"
#import <CoreLocation/CLLocationManager.h>

//1.  选定购车经销商时：传入DealerServiceType：PRE_SALE
//
//2.  首选经销商相关查询时：传入DealerServiceType：AFTER_SALE
//dealers/around
//dealers/city
//maintenance/dealers
typedef NS_ENUM(NSInteger ,SOSQueryDealerType)
{
    queryPreferDealer = 0,   //查询类型是首选经销商
    querySalerDealer         //查询类型是售车经销商
 
};

//经销商选择
@interface SOSSelectDealerVC : UIViewController
//查询参数,未登录做注册时候需要的查询参数
@property (nonatomic, copy) NSString *q_subscriberId;
@property (nonatomic, copy) NSString *q_accountId;
@property (nonatomic, copy) NSString *q_vin;
@property (nonatomic, copy) NSString *q_brand;
@property (nonatomic, copy) NSString *query_pagesize;
@property (nonatomic, assign) SOSQueryDealerType currentQueryType;
@property (nonatomic, assign) BOOL isForRegisterOrAddVehicle;//是否是用于添加车辆或者注册

//从注册进入
@property (nonatomic, copy) void(^selectDealerBlock)(id dealerModel);
//从更换首选经销商进入
@property(copy, nonatomic) void (^choosePreferDealer)(id dealerModel);

- (void)finishSearching;


@end

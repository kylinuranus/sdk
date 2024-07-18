//
//  UserCarInfoVC.h
//  Onstar
//
//  Created by Coir on 15/10/30.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//  修改车牌号、发动机号

#import <UIKit/UIKit.h>

typedef enum {
    CarInfoTypeLicenseNum = 1,//车牌号
    CarInfoTypeEngineNum = 2//发动机号
}   CarInfoType;

@interface UserCarInfoVC : UIViewController

@property (nonatomic, assign) CarInfoType carInfoType;//车辆信息type

#pragma mark 车牌号接口
+ (void)getVehicleBasicInfoSuccess:(nullable void (^)(BOOL success))block;

//#pragma mark 车牌号接口同步
//+ (void)getVehicle_baseinfo_request_Sync;

@end

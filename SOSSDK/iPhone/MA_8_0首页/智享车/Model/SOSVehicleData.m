//
//  SOSVehicleData.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleData.h"
#import "ServiceController.h"
#import "HandleDataRefreshDataUtil.h"

@implementation SOSVehicleData

#pragma mark 请求数据开始服务
//+ (void)getVehicleDataService:(NSString *)requestName withCell:(SOSVechicleTableViewCell *)cell andPath:(NSIndexPath *)indexPath Success:(void (^)(id result))completion Failed:(void (^)(void))failCompletion    {
//    ServiceController *service = [ServiceController sharedInstance];
//    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
//    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
//    [[ServiceController sharedInstance] updatePerformVehicleService];
//    
//    [service startFunctionWithName:requestName startSuccess:^(id result) {
//        NSLog(@"start success*\n*");
//        //[[SOSReportService shareInstance] recordActionWithFunctionID:Home_DragDownRefresh];
//        
//    } startFail:^(id result) {
//        dispatch_async_on_main_queue(^{
//            [cell showCellWithState:RemoteControlStatus_OperateFail WithIndexPath:indexPath];
//        });
//        failCompletion();
//    } askSuccess:^(id result) {
//        NSLog(@"polling success*\n*");
//        dispatch_async_on_main_queue(^{
//            [cell showCellWithState:RemoteControlStatus_OperateSuccess WithIndexPath:indexPath];
//        });
//        [self parseDataRefreshResult:result];
//        completion(result);
//        
//    } askFail:^(id result) {
//        dispatch_async_on_main_queue(^{
//            [cell showCellWithState:RemoteControlStatus_OperateFail WithIndexPath:indexPath];
//        });
//        failCompletion();
//    }];
//
//}

+ (void)getVehicleDataWithParameters:(NSString *)parameters Success:(void (^)(id result))success Failed:(void (^)(id result))failure		{
    ServiceController *service = [ServiceController sharedInstance];
    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
    [[ServiceController sharedInstance] updatePerformVehicleService];
    
    [service startFunctionWithName:GET_VEHICLE_DATA_REQUEST Parameters:parameters Vin:service.vin startSuccess:^(id result) {
        
    } startFail:^(id result) {
        if (failure)	failure(result);
    } askSuccess:^(id result) {
        NSLog(@"polling success*\n*");
        if (!parameters.length) 	[self parseDataRefreshResult:result];
        if (success)    success(result);
    } askFail:^(id result) {
        if (failure)    failure(result);
    } resultSuccess:^(id result) {
//        if (success)    success(result);
    } resultFail:^(id result) {
//        if (failure)    failure(result);
    }];
}

//+ (void)getVehicleDataSuccess:(void (^)(id result))completion Failed:(void (^)(id result))failCompletion        {
//    [self getVehicleDataWithParameters:nil Success:completion Failed:failCompletion];
//}

#pragma mark 请求车辆信息成功,解析数据
+ (void)parseDataRefreshResult:(NSDictionary *)dic{
    if (dic) {
        //设置车辆信息
        [HandleDataRefreshDataUtil setupVehicleStatusInfo:dic];
        //保持当前车辆信息到DB
//        [CustomerInfo insertInto:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [Util writeConfig:@"vinChanged" setValue:@"NO"];
    }
}

@end

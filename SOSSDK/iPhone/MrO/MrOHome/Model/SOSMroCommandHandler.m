//
//  SOSMroCommandHandler.m
//  Onstar
//
//  Created by Onstar on 2018/4/27.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "CarOperationWaitingVC.h"
#import "SOSMroCommandHandler.h"
#import "SOSBiometricsManager.h"
#import "SOSRemoteTool.h"
#import "SOSTripModule.h"
#import "SOSCardUtil.h"
@implementation SOSMroCommandHandler

- (void)handleCommand:(NSString *)commandValue		{
    NSString *errorMsg = @"您的车型不支持该服务。";
    BOOL dontSupport = NO;
    BOOL isCarOperation = NO;
    SOSRemoteOperationType operationType;
    NSString * commandUpper = [commandValue uppercaseString];
    if ([commandUpper isEqualToString:@"LOCKDOORS"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.lockDoorSupported) {
            operationType = SOSRemoteOperationType_LockCar;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL17];
        }   else   {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"UNLOCKDOORS"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.unlockDoorSupported) {
            operationType = SOSRemoteOperationType_UnLockCar;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL19];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"REMOTESTART"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.remoteStartSupported) {
            operationType = SOSRemoteOperationType_RemoteStart;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL18];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"CANCELSTART"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.remoteStopSupported) {
            operationType = SOSRemoteOperationType_RemoteStartCancel;
            [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL13];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"FLASHLIGHTS"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vehicleAlertSupported) {
            operationType = SOSRemoteOperationType_Light;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL14];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"HORN"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vehicleAlertSupported) {
            operationType = SOSRemoteOperationType_Horn;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL16];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"FLASHHORN"]) {
        isCarOperation = YES;
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vehicleAlertSupported) {
            operationType = SOSRemoteOperationType_LightAndHorn;
             [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL15];
        }   else    {
            dontSupport = YES;
        }
    }else if ([commandUpper isEqualToString:@"POSITION"]) {
        [self handleVehicleLocationCommand];
    }else if ([commandUpper isEqualToString:@"CONDITIONQUERY"]) {
        [self handleVehicleConditionCommand];
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL22];
    }else if ([commandUpper isEqualToString:@"PRESSUREQUERY"]) {
       [self handleVehicleConditionCommand];
       [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL23];
    }else if ([commandUpper isEqualToString:@"OILQUERY"]) {
        [self handleVehicleConditionCommand];
         [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL24];
    }else if ([commandUpper isEqualToString:@"OILLIFEQUERY"]) {
        [self handleVehicleConditionCommand];
         [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL25];
    }else if ([commandUpper isEqualToString:@"MILEAGEQUERY"]) {
        [self handleVehicleConditionCommand];
         [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL26];
    }else if ([commandUpper isEqualToString:@"VEHICLENAVI"]){
        [self handleVehicleTBTODD:_tbtPoi];
    }
    if (isCarOperation && !dontSupport) {
        [[SOSRemoteTool sharedInstance] startOperationWithOperationType:operationType];
    }	else if (dontSupport) {
        [Util showAlertWithTitle:nil message:errorMsg completeBlock:nil];
    }
}

#pragma mark -车辆位置
- (void)handleVehicleLocationCommand		{
    [Util showAlertWithTitle:nil message:@"车车快出现，哔" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self.baseController dismissViewControllerAnimated:YES completion:^{
                [SOS_APP_DELEGATE.fetchRootViewController setSelectedIndex:1];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[SOSTripModule getMainTripVC] showVehicleLocation:nil];
                });
            }];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"去看看",nil];
    [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL20];
}

#pragma mark -车况
- (void)handleVehicleConditionCommand	{
    [SOSCardUtil routerToVehicleConditionFromPresentVC:self.baseController isPresentType:YES];
}

#pragma mark -TBT/ODD
- (void)handleVehicleTBTODD:(SOSPOI *)poi	{
    if([SOSCheckRoleUtil checkPackageExpired:self.baseController])     return;
    CarOperationWaitingVC *carOPVC = [CarOperationWaitingVC initWithPoi:poi Type:OrderTypeAuto FromVC:_baseController];
    if (carOPVC.orderType == OrderTypeTBT) {
        [SOSDaapManager sendActionInfo:SendingTBT];
    }	else if (carOPVC.orderType == OrderTypeODD)   {
        [SOSDaapManager sendActionInfo:SendingODD];
    }
    [carOPVC checkAndShowFromVC:_baseController needToastMessage:NO needShowWaitingVC:NO completion:nil];

}
#pragma mark - 打开H5
- (void)handleWebOpen:(NSString *)url	{
        NSString * orderUrl =[NSString stringWithFormat:(@"%@" GET_SUPHKP_URL), BASE_URL,@"yhouse"];
        SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:orderUrl];
        [self.baseController pushViewController:webVC animated:YES];
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL21];
}

- (void)dealloc	{
    NSLog(@"CommandHandler dealloc----------");
}
@end

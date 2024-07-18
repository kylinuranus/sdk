//
//  SOSWalkRemoteControllView.m
//  Onstar
//
//  Created by Coir on 01/02/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTripCarRemoteView.h"
#import "SOSRemoteTool.h"

@interface SOSTripCarRemoteView ()

@end

@implementation SOSTripCarRemoteView

- (IBAction)lightAndHornButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_RemoteControl_FlashingWhistle];
    [self startCarOperationWithIndex:0];
}

- (IBAction)unlockDoorButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_RemoteControl_DoorUnlock];
    [self startCarOperationWithIndex:1];
}

- (void)startCarOperationWithIndex:(int)index	{
    SOSRemoteOperationType operationType = index ? SOSRemoteOperationType_UnLockCar : SOSRemoteOperationType_LightAndHorn;
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:operationType];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        NSDictionary *notiDic = noti.userInfo;
        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
        NSString *message = notiDic[@"message"];
        if (operationType == SOSRemoteOperationType_UnLockCar || [SOSRemoteTool isHornAndFlashMode:operationType]) {
            switch (resultState) {
                case RemoteControlStatus_InitSuccess:
                    [Util showHUD];
                    break;
                case RemoteControlStatus_OperateFail:
                    [Util dismissHUD];
                    [Util showErrorHUDWithStatus:message];
                    break;
                case RemoteControlStatus_OperateSuccess:
                    [Util dismissHUD];
                    [Util showSuccessHUDWithStatus:message];
                	break;
                default:
                    break;
            }
        }
    }];
}

- (void)dealloc		{
    [Util dismissHUD];
}

@end

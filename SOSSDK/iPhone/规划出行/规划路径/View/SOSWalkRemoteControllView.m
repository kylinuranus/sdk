//
//  SOSWalkRemoteControllView.m
//  Onstar
//
//  Created by Coir on 01/02/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSWalkRemoteControlResultView.h"
#import "SOSWalkRemoteControllView.h"
#import "SOSRemoteTool.h"

@interface SOSWalkRemoteControllView ()

@property (strong, nonatomic) SOSWalkRemoteControlResultView *resultView;

@end

@implementation SOSWalkRemoteControllView

- (IBAction)lightAndHornButtonTapped {
    [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_flashandhorn];
    [self startCarOperationWithIndex:0];
}

- (IBAction)unlockDoorButtonTapped {
    [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_doorunlock];
    [self startCarOperationWithIndex:1];
}

- (void)startCarOperationWithIndex:(int)index	{
    SOSRemoteOperationType operationType = index ? SOSRemoteOperationType_UnLockCar : SOSRemoteOperationType_LightAndHorn;
    __weak __typeof(self) weakSelf = self;
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:operationType];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        NSDictionary *notiDic = noti.userInfo;
        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
//        NSString *message = notiDic[@"message"];
        if (operationType == SOSRemoteOperationType_UnLockCar || [SOSRemoteTool isHornAndFlashMode:operationType]) {
            switch (resultState) {
                case RemoteControlStatus_InitSuccess:
                    [weakSelf showLoadingView:YES];
                    break;
                case RemoteControlStatus_OperateFail:
                case RemoteControlStatus_OperateSuccess:
                    [weakSelf showLoadingView:NO];
                	break;
                default:
                    break;
            }
        }
    }];
}

- (void)showLoadingView:(BOOL)show		{
    UIViewController *fatherVC = (UIViewController *)self.VC;
    if (show) {
        if (self.resultView == nil) {
            self.resultView = [[NSBundle SOSBundle] loadNibNamed:@"SOSWalkRemoteControlResultView" owner:self options:nil][0];
            self.resultView.frame = fatherVC.view.bounds;
        }
        [self.resultView showWithResultMode:SOSWalkRemoteResultType_Loading];
        [fatherVC.view addSubview:self.resultView];
    }	else	{
        [self.resultView removeFromSuperview];
    }
}

@end

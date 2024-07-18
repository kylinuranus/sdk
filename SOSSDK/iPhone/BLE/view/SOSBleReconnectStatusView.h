//
//  SOSBleReconnectStatusView.h
//  Onstar
//
//  Created by onstar on 2018/8/6.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleReconnectStatusView : UIView

//RemoteControlStatus_InitSuccess,
//RemoteControlStatus_OperateFail
//只有两种状态
@property (nonatomic, assign) RemoteControlStatus status;
@property (nonatomic, copy) void(^retryBlock)(SOSBleReconnectStatusView *statusView);
@end

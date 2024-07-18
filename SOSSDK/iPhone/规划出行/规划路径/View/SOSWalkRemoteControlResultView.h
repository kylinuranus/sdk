//
//  SOSWalkRemoteControlResultView.h
//  Onstar
//
//  Created by Coir on 2018/8/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SOSWalkRemoteResultType)   {
    SOSWalkRemoteResultType_Loading = 1,
    SOSWalkRemoteResultType_LockDoor_Success,
    SOSWalkRemoteResultType_LockDoor_Fail,
    SOSWalkRemoteResultType_Light_Success,
    SOSWalkRemoteResultType_Light_Fail,
    SOSWalkRemoteResultType_Horn_Success,
    SOSWalkRemoteResultType_Horn_Fail,
    SOSWalkRemoteResultType_LightAndHorn_Success,
    SOSWalkRemoteResultType_LightAndHorn_Fail,
};

@interface SOSWalkRemoteControlResultView : UIView

- (void)showWithResultMode:(SOSWalkRemoteResultType)mode;

@end

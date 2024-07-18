//
//  SOSLBSAddDeviceVC.h
//  Onstar
//
//  Created by Coir on 19/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSLBSHeader.h"

@interface SOSLBSAddDeviceVC : UIViewController

/** 添加设备-步骤 */
typedef enum {
    /** 添加设备-第一步 */
    SOSLBSAddDeviceStep_First = 1,
    /** 添加设备-第二步 */
    SOSLBSAddDeviceStep_Last = 2
} SOSLBSAddDeviceStep;

/** 添加设备步骤类型 */
@property (nonatomic, assign) SOSLBSAddDeviceStep stepType;

/** 当且仅当 stepType 为 SOSLBSAddDeviceStep_Last 时,需要传入  */
@property (nonatomic, strong) NNLBSDadaInfo *lbsDataInfo;

///校验密码
+ (BOOL)checkPassword:(NSString *)passWord;

/// 校验用户名
+ (BOOL)checkDeviceName:(NSString *)deviceName;

- (void)setCompleteHanlder:(void (^ __nullable)(NNLBSDadaInfo *newDevice))completion;

@end

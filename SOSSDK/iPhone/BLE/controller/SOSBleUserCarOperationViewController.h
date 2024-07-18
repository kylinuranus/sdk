//
//  SOSBleUserCarOperationViewController.h
//  Onstar
//
//  Created by onstar on 2018/7/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BlePatacSDK/BLEModel.h>

@interface SOSBleUserCarOperationViewController : UIViewController


/**
 需重新连接
 */
@property (nonatomic, strong) BLEModel *reConnectBleModel;

@end

//
//  FIrstVC.h
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Values for SOSPushType */
typedef NS_ENUM(NSInteger, SOSPushType) {
    SOSPushTypeNone = 0, // 默认
    SOSPushTypeConfirmOrder = 1, // 确认支付
};

@interface LBSConsigneeVC : UIViewController

@property (nonatomic, assign) SOSPushType pushType;
@end

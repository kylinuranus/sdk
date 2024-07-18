//
//  LBSOrderRecordListVC.h
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 压栈类型 */
typedef NS_ENUM(NSInteger, SOSOrderListPushType) {
    SOSOrderListPushTypeDefault = 0, // 默认压栈
    SOSOrderListPushTypeLBSPaySuccess = 1, // lbs支付成功压栈
};


@interface LBSOrderRecordListVC : UIViewController

@property (nonatomic, assign) SOSOrderListPushType pushType;
@end


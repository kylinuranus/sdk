//
//  SOSPinContentView.h
//  Onstar
//
//  Created by onstar on 2018/12/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SOSPinType) {
    SOSPinTypeAuto,         //不带闪灯鸣笛 自动判断显示pin 还是face或指纹
    SOSPinTypePassword,     //强制pin输入框
    SOSPinTypeFace,         //强制显示face或指纹
    SOSPinTypeAutoHonkAndFlash,         //带闪灯鸣笛 自动判断显示pin 还是face或指纹
    SOSPinTypePasswordHonkAndFlash,     //带闪灯鸣笛 强制pin输入框
    SOSPinTypeFaceHonkAndFlash,         //带闪灯鸣笛 强制显示face或指纹
};

@interface SOSPinContentView : UIView

@property (nonatomic, assign) SOSPinType pinType;

@property (nonatomic, assign) BOOL flashSelected;
@property (nonatomic, assign) BOOL hornSelected;
@property (nonatomic, copy) NSString *errorMsg;


@property (nonatomic, copy) void(^didCompleteInputBlock)(NSString *pinCode,SOSPinContentView *pinView);
/**
 @return 是否支持生物密码
 */
- (BOOL)supportBiometric;

@end

NS_ASSUME_NONNULL_END

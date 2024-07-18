//
//  SOSOnstarLinkBindPhoneVC.h
//  Onstar
//
//  Created by Coir on 2018/7/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SOSOnstarLinkBindPhonePageType) {
    /// Onstar Link 绑定手机号
    OnstarLinkBindPhonePageType_bind,
    /// Onstar Link 修改手机号
    OnstarLinkBindPhonePageType_modify,
    /// 安悦充电 绑定手机号
    SOSAYBindPhone,
    SOSBLEBindPhone,
};

@interface SOSOnstarLinkBindPhoneVC : UIViewController

@property (nonatomic, assign) SOSOnstarLinkBindPhonePageType pageType;

@property (nonatomic, copy) void (^operationSuccessBlock)(NSString *mobilePhoneNum);


@end

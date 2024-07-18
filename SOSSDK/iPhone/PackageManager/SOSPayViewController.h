//
//  SOSPayViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/7/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurePayView.h"
#import "PurchaseCommonDefination.h"
@protocol payProtocol <NSObject>
- (void)payClick:(PayChannel)currentChannel;
@end
//使用controller代替原版本view，避免view内写入数据请求等代码,直接使用该controller调出支付选择界面
@interface SOSPayViewController : UIViewController<SurePayDelegate,SelectPayWaysDelegate>
@property (weak  ,nonatomic)  PackageInfos * package;
@property (strong,nonatomic)  UIView *backgroundView;
@property (strong,nonatomic)  SurePayView *surePayView;
//@property (strong,nonatomic)  SelectPayWaysView *payWaysV;
@property (weak,  nonatomic)  id<payProtocol> payDelegate;
- (instancetype)initWithPackage:(PackageInfos *)package;
@end


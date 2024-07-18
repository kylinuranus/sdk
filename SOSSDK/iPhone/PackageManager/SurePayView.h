//
//  SurePayView.h
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectPayWaysView.h"

// 代理
@protocol SurePayDelegate <NSObject>

- (void)backFromSurePayVC;
- (void)surePay;
- (void)selectPayWay_surePayDelegate;
//- (void)canPay:(BOOL)canPay;

@end

@interface SurePayView : UIView
- (IBAction)backAct:(id)sender;
@property (nonatomic, weak) id<SurePayDelegate> surePayDelegate;
@property (weak, nonatomic) IBOutlet UILabel *NameLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLB;
@property (weak, nonatomic) IBOutlet UILabel *payWayLB;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectChannelArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
- (void)loadingChannelState;//正在获取支付渠道状态
- (void)channelLoadAlreadyState;
- (void)unavailableChannelState;

@end

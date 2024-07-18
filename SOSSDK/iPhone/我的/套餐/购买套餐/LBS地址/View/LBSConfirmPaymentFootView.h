//
//  LBSConfirmPaymentFootView.h
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBSConfirmPaymentFootViewDelegate <NSObject>

@required
/** 支付按钮事件 */
- (void)confirmPaymentFootViewPaymentBtnClick;
@end

@interface LBSConfirmPaymentFootView : UIView

@property (nonatomic, strong) PackageInfos *packageInfos;
@property (nonatomic, weak) id <LBSConfirmPaymentFootViewDelegate> delegate;
//@property (nonatomic, copy) dispatch_block_t paymentBtnBlock;

@end


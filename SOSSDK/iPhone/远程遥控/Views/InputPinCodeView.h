//
//  DCPaymentView.h
//  DCPayAlertDemo
//
//  Created by dawnnnnn on 15/12/9.
//  Copyright © 2015年 dawnnnnn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputPinCodeView : UIView

@property (nonatomic, assign)BOOL isHornFlash;

@property (nonatomic,copy) void (^completeHandle)(NSString *inputPwd,BOOL flashSelected,BOOL hornSelected);

@property(nonatomic,copy) void(^cancelPIN)(void);
- (void)show;

@end

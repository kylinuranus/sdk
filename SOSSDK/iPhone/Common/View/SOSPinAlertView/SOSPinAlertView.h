//
//  SOSPinAlertView.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSFlexibleAlertController.h"

@interface SOSPinAlertView : UIView

//@property (copy, nonatomic) void (^cancel)(void);
@property (copy, nonatomic) void (^confirm)(NSString *inputPwd, BOOL flashSelected, BOOL hornSelected);
@property (copy, nonatomic) NSString *phoneFuncId;


+ (instancetype)pinAlertView;
//+ (instancetype)pinAlertViewShouldShowHonkAndFlash:(BOOL)shouldShowHonkAndFlash;

- (void)show;

@end

//
//  UIView+SOSBleToast.m
//  Onstar
//
//  Created by onstar on 2018/8/6.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "UIView+SOSBleToast.h"
#import "CustomCover.h"
#import "UIView+Toast.h"
#import "SOSBleLoadingView.h"

@implementation UIView (SOSBleToast)

- (UIView *)showBleAlertWithMessage:(NSString *)message {
    UIView *loadingView = [SOSBleLoadingView viewFromXib];
    [self addSubview:loadingView];
    
    [loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    return loadingView;
}

- (void)hideBleAlert:(UIView *)loadingView {
    [loadingView removeAllSubviews];
    [loadingView removeFromSuperview];
}


- (UIView *)showBleAlertView:(UIView *)alertView {
    [self addSubview:alertView];
    
    [alertView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    return alertView;
}


@end
